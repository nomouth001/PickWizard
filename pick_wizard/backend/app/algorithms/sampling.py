"""
샘플링 유틸리티

2026-01-08 06:50:00 EST - 초기 생성
"""

import random
from typing import List, Optional
import numpy as np

from app.algorithms.constants import LOTTO_NUMBERS_PER_DRAW
from app.algorithms.types import (
    LottoNumbers,
    LottoNumberSet,
    ProbabilityDict,
)


def sample_with_probability(
    probabilities: ProbabilityDict,
    n_samples: int,
    exclude: Optional[List[int]] = None
) -> List[int]:
    """
    확률 기반 샘플링
    
    Args:
        probabilities: 확률 딕셔너리
        n_samples: 샘플링할 개수
        exclude: 제외할 번호 (이미 선택된 번호 등)
    
    Returns:
        샘플링된 번호 리스트
    """
    # 제외 번호 필터링
    if exclude:
        probabilities = {
            num: prob
            for num, prob in probabilities.items()
            if num not in exclude
        }
    
    # 확률 정규화
    total = sum(probabilities.values())
    if total == 0:
        # 모든 확률이 0이면 균등 분포
        numbers = list(probabilities.keys())
        return sorted(random.sample(numbers, n_samples))
    
    probabilities = {num: prob / total for num, prob in probabilities.items()}
    
    # numpy로 샘플링
    numbers = list(probabilities.keys())
    probs = list(probabilities.values())
    
    sampled = np.random.choice(
        numbers,
        size=n_samples,
        replace=False,
        p=probs
    )
    
    return sorted(sampled.tolist())


def generate_random_sets(
    n_sets: int,
    available_numbers: List[int],
    include_numbers: Optional[List[int]] = None
) -> LottoNumberSet:
    """
    순수 랜덤 번호 생성
    
    Args:
        n_sets: 생성할 세트 수
        available_numbers: 사용 가능한 번호 리스트
        include_numbers: 반드시 포함할 번호
    
    Returns:
        생성된 번호 세트 리스트
    """
    results: LottoNumberSet = []
    
    for _ in range(n_sets):
        numbers: LottoNumbers = []
        
        # 포함 번호 먼저 추가
        if include_numbers:
            numbers.extend(include_numbers)
        
        # 나머지 번호 랜덤 선택
        remaining_count = LOTTO_NUMBERS_PER_DRAW - len(numbers)
        selected = random.sample(available_numbers, remaining_count)
        numbers.extend(selected)
        
        results.append(sorted(numbers))
    
    return results

