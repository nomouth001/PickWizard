"""
알고리즘 공통 유틸리티

순수 함수로 구성하여 테스트 및 재사용 용이

2026-01-08 06:50:00 EST - 초기 생성
"""

from typing import Dict, List
from collections import Counter
import pandas as pd

from app.algorithms.constants import (
    LOTTO_MIN_NUMBER,
    LOTTO_MAX_NUMBER,
    LOTTO_NUMBERS_PER_DRAW,
)
from app.algorithms.types import (
    FrequencyDict,
    ProbabilityDict,
    LottoDataFrame,
)


# ============================================================================
# 빈도 계산
# ============================================================================

def calculate_frequency(
    data: LottoDataFrame,
    include_zero_freq: bool = True
) -> FrequencyDict:
    """
    번호별 출현 빈도 계산
    
    Args:
        data: 과거 당첨번호 DataFrame
        include_zero_freq: 0회 출현 번호 포함 여부
    
    Returns:
        {번호: 출현 횟수}
    """
    frequency: FrequencyDict = Counter()
    
    for _, row in data.iterrows():
        for i in range(1, LOTTO_NUMBERS_PER_DRAW + 1):
            frequency[row[f'num{i}']] += 1
    
    if include_zero_freq:
        for num in range(LOTTO_MIN_NUMBER, LOTTO_MAX_NUMBER + 1):
            if num not in frequency:
                frequency[num] = 0
    
    return dict(frequency)


def frequency_to_probability(
    frequency: FrequencyDict,
    mode: str = 'normal'
) -> ProbabilityDict:
    """
    빈도를 확률로 변환
    
    Args:
        frequency: 빈도 딕셔너리
        mode: 'normal' (정확률) 또는 'inverse' (역확률)
    
    Returns:
        확률 딕셔너리
    """
    if mode == 'normal':
        total = sum(frequency.values())
        if total == 0:
            return {num: 1.0 / len(frequency) for num in frequency}
        return {num: count / total for num, count in frequency.items()}
    
    elif mode == 'inverse':
        max_freq = max(frequency.values())
        inverse = {num: max_freq - count + 1 for num, count in frequency.items()}
        total = sum(inverse.values())
        return {num: inv / total for num, inv in inverse.items()}
    
    else:
        raise ValueError(f"Unknown mode: {mode}")


# ============================================================================
# 확률 조정
# ============================================================================

def apply_temperature(
    probabilities: ProbabilityDict,
    temperature: float
) -> ProbabilityDict:
    """
    확률 분포에 온도 파라미터 적용
    
    Args:
        probabilities: 원본 확률 분포
        temperature: 온도 (0.1~3.0)
            - < 1.0: 날카로운 분포
            - = 1.0: 원본 유지
            - > 1.0: 평탄한 분포
    
    Returns:
        조정된 확률 분포
    """
    if temperature == 1.0:
        return probabilities
    
    adjusted = {
        num: p ** (1 / temperature)
        for num, p in probabilities.items()
    }
    
    total = sum(adjusted.values())
    if total > 0:
        return {num: adj / total for num, adj in adjusted.items()}
    
    return probabilities


def apply_recent_draw_penalty(
    probabilities: ProbabilityDict,
    historical_data: LottoDataFrame,
    penalty_rate: float
) -> ProbabilityDict:
    """
    직전 회차 출현 번호 확률 할인
    
    Args:
        probabilities: 원본 확률 분포
        historical_data: 과거 당첨번호
        penalty_rate: 할인율 (0.1~1.0)
    
    Returns:
        조정된 확률 분포
    """
    if len(historical_data) < 1:
        return probabilities
    
    latest_draw = historical_data.tail(1).iloc[0]
    latest_numbers = {latest_draw[f'num{i}'] for i in range(1, LOTTO_NUMBERS_PER_DRAW + 1)}
    
    adjusted = probabilities.copy()
    for num in latest_numbers:
        if num in adjusted:
            adjusted[num] *= penalty_rate
    
    total = sum(adjusted.values())
    if total > 0:
        adjusted = {num: prob / total for num, prob in adjusted.items()}
    
    return adjusted


# ============================================================================
# 번호 필터링
# ============================================================================

def get_consecutive_numbers(
    historical_data: LottoDataFrame,
    n_consecutive: int = 2
) -> List[int]:
    """
    연속 출현 번호 추출
    
    Args:
        historical_data: 과거 당첨번호
        n_consecutive: 연속 출현 회차 수
    
    Returns:
        연속 출현 번호 리스트
    """
    if len(historical_data) < n_consecutive:
        return []
    
    recent_draws = historical_data.tail(n_consecutive)
    
    # 각 회차의 번호 set 생성
    number_sets = []
    for _, row in recent_draws.iterrows():
        numbers = {row[f'num{i}'] for i in range(1, LOTTO_NUMBERS_PER_DRAW + 1)}
        number_sets.append(numbers)
    
    # 교집합 (모든 회차에 출현)
    consecutive = set.intersection(*number_sets)
    
    return sorted(list(consecutive))


def get_frequent_numbers(
    data: LottoDataFrame,
    lookback: int,
    threshold: int
) -> List[int]:
    """
    고빈도 출현 번호 추출
    
    Args:
        data: 과거 당첨번호
        lookback: 분석 회차 수
        threshold: 임계값 (이상이면 고빈도)
    
    Returns:
        고빈도 번호 리스트
    """
    if len(data) < lookback:
        lookback = len(data)
    
    recent = data.tail(lookback)
    frequency = calculate_frequency(recent, include_zero_freq=False)
    
    return [num for num, count in frequency.items() if count >= threshold]


# ============================================================================
# 데이터 변환
# ============================================================================

def normalize_probabilities(
    probabilities: Dict[int, float]
) -> ProbabilityDict:
    """
    확률 합계를 1로 정규화
    
    Args:
        probabilities: 원본 확률 딕셔너리
    
    Returns:
        정규화된 확률 딕셔너리
    """
    total = sum(probabilities.values())
    
    if total == 0:
        # 모두 0이면 균등 분포
        n = len(probabilities)
        return {num: 1.0 / n for num in probabilities}
    
    return {num: prob / total for num, prob in probabilities.items()}


def merge_probabilities(
    prob1: ProbabilityDict,
    prob2: ProbabilityDict,
    weight1: float = 0.5,
    weight2: float = 0.5
) -> ProbabilityDict:
    """
    두 확률 분포 병합
    
    Args:
        prob1: 첫 번째 확률 분포
        prob2: 두 번째 확률 분포
        weight1: 첫 번째 가중치
        weight2: 두 번째 가중치
    
    Returns:
        병합된 확률 분포
    """
    all_numbers = set(prob1.keys()) | set(prob2.keys())
    
    merged = {}
    for num in all_numbers:
        p1 = prob1.get(num, 0)
        p2 = prob2.get(num, 0)
        merged[num] = p1 * weight1 + p2 * weight2
    
    return normalize_probabilities(merged)


# ============================================================================
# 2026-01-16 EST - Phase 3.1: 추가 유틸리티 함수
# ============================================================================

def normalize_weights(weights: Dict[int, float]) -> ProbabilityDict:
    """
    가중치를 확률로 정규화 (normalize_probabilities의 별칭)
    
    2026-01-16 EST - Phase 3.1: 테스트 커버리지 향상
    """
    return normalize_probabilities(weights)


def calculate_entropy(probabilities: ProbabilityDict) -> float:
    """
    확률 분포의 엔트로피 계산 (Shannon Entropy)
    
    2026-01-16 EST - Phase 3.1: 테스트 커버리지 향상
    
    Args:
        probabilities: 확률 분포
    
    Returns:
        엔트로피 값 (bits)
    """
    import math
    
    entropy = 0.0
    for prob in probabilities.values():
        if prob > 0:
            entropy -= prob * math.log2(prob)
    
    return entropy


def weighted_sample_with_replacement(
    numbers: List[int],
    weights: Dict[int, float],
    k: int
) -> List[int]:
    """
    가중치 기반 복원 샘플링
    
    2026-01-16 EST - Phase 3.1: 테스트 커버리지 향상
    
    Args:
        numbers: 번호 리스트
        weights: 가중치 딕셔너리
        k: 샘플 개수
    
    Returns:
        샘플링된 번호 리스트
    """
    import random
    
    weight_list = [weights.get(num, 0) for num in numbers]
    return random.choices(numbers, weights=weight_list, k=k)


def weighted_sample_without_replacement(
    numbers: List[int],
    weights: Dict[int, float],
    k: int
) -> List[int]:
    """
    가중치 기반 비복원 샘플링
    
    2026-01-16 EST - Phase 3.1: 테스트 커버리지 향상
    
    Args:
        numbers: 번호 리스트
        weights: 가중치 딕셔너리
        k: 샘플 개수
    
    Returns:
        샘플링된 번호 리스트 (중복 없음)
    """
    import numpy as np
    
    weight_list = [weights.get(num, 0) for num in numbers]
    probs = np.array(weight_list) / sum(weight_list)
    
    return list(np.random.choice(numbers, size=k, replace=False, p=probs))


def validate_lotto_number(number: int) -> bool:
    """
    로또 번호 유효성 검증
    
    2026-01-16 EST - Phase 3.1: 테스트 커버리지 향상
    
    Args:
        number: 번호
    
    Returns:
        유효 여부
    """
    return LOTTO_MIN_NUMBER <= number <= LOTTO_MAX_NUMBER


def validate_lotto_set(numbers: List[int]) -> bool:
    """
    로또 세트 유효성 검증
    
    2026-01-16 EST - Phase 3.1: 테스트 커버리지 향상
    
    Args:
        numbers: 번호 리스트
    
    Returns:
        유효 여부
    """
    # 개수 확인
    if len(numbers) != LOTTO_NUMBERS_PER_DRAW:
        return False
    
    # 중복 확인
    if len(set(numbers)) != LOTTO_NUMBERS_PER_DRAW:
        return False
    
    # 범위 확인
    return all(validate_lotto_number(num) for num in numbers)


