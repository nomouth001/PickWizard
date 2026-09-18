"""
Algorithm 2: 고급 빈도 분석 (Advanced Frequency)

과거 출현 빈도 기반 + 다양한 필터 + 역확률 샘플링

2026-01-07 EST - 초기 생성 (010.1_Algorithm_Redesign.md 기반)
2026-01-08 05:35:00 EST - 중복 제거: base 클래스 메서드 사용
"""

import random
from typing import List, Dict, Optional, Any, Literal
from collections import Counter

import pandas as pd
import numpy as np

from app.algorithms.base import LottoAlgorithm


class AdvancedFrequencyAlgorithm(LottoAlgorithm):
    """
    고급 빈도 분석 알고리즘
    
    Trial02의 알고리즘 6,7,8,9를 통합
    - 다양한 필터 (연속 출현, 고빈도 제외)
    - 역확률 샘플링
    - 직전 회차 확률 할인
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=2,
            # 2026-01-17 20:00:00 EST - 이름 변경: "고급 빈도 분석" → "출현 번호 빈도 기반 선택 (고급)"
            name="출현 번호 빈도 기반 선택 (고급) (Frequency-Based Selection (Advanced))",
            description="과거 출현 빈도 기반, 다양한 필터와 역확률 적용 가능"
            # 2026-01-18 20:30:00 EST - cost_per_set 제거 (SSOT 원칙: pricing_config.yaml만 사용)
            # cost_per_set=1  # 기본값, 파라미터에 따라 조정
        )
    
    def generate_numbers(
        self,
        historical_data: Optional[pd.DataFrame],
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        
        # A. 분석 범위
        window_type: str = 'all',
        window_size: Optional[int] = None,
        
        # B-1. 연속 출현 제외 (직전 2회차 고정)
        exclude_consecutive_2: bool = False,
        
        # B-2. 고빈도 출현 제외 (커스텀)
        exclude_frequent: bool = False,
        frequent_lookback: int = 10,
        frequent_threshold: int = 5,
        
        # B-3. 직전 회차 출현 번호 확률 할인
        apply_recent_penalty: bool = False,
        penalty_rate: float = 0.5,
        
        # C. 확률 모드
        probability_mode: str = 'normal',
        
        # D. 온도
        temperature: float = 1.0,
        
        **kwargs
    ) -> List[List[int]]:
        """
        고급 빈도 분석 번호 생성
        
        2026-01-16 EST - Phase 2.1: 함수 분해 (4개 헬퍼 메서드로 위임)
        """
        
        # 파라미터 검증
        valid, error_msg = self.validate_parameters(
            n_sets, exclude_numbers, include_numbers
        )
        if not valid:
            raise ValueError(error_msg)
        
        # 과거 데이터 검증
        if historical_data is None or len(historical_data) == 0:
            return self.generate_random_sets(n_sets, exclude_numbers, include_numbers)
        
        # 1. 빈도 계산 (분석 범위 포함)
        frequency = self._calculate_filtered_frequency(
            historical_data, window_type, window_size
        )
        
        # 2. 제외 필터 적용
        frequency = self._apply_exclusion_filters(
            frequency, historical_data, exclude_numbers, include_numbers,
            exclude_consecutive_2, exclude_frequent, 
            frequent_lookback, frequent_threshold
        )
        
        # 3. 확률 분포 생성 (모드 + 패널티 + 온도)
        probabilities = self._build_probability_distribution(
            frequency, historical_data, probability_mode,
            apply_recent_penalty, penalty_rate, temperature
        )
        
        # 4. 번호 샘플링
        results = self._sample_numbers_from_distribution(
            probabilities, n_sets, include_numbers
        )
        
        return results
    
    # ========================================
    # 2026-01-16 EST - Phase 2.1: 분해된 헬퍼 메서드들
    # ========================================
    
    def _calculate_filtered_frequency(
        self,
        historical_data: pd.DataFrame,
        window_type: str,
        window_size: Optional[int]
    ) -> Dict[int, int]:
        """
        1단계: 빈도 계산 (분석 범위 설정 포함)
        
        2026-01-16 EST - Phase 2.1: generate_numbers()에서 분리
        """
        # 분석 범위 설정
        if window_type == 'all':
            analysis_data = historical_data
        else:
            analysis_data = historical_data.tail(window_size or 50)
        
        # 빈도 계산
        return self.calculate_frequency(analysis_data)
    
    def _apply_exclusion_filters(
        self,
        frequency: Dict[int, int],
        historical_data: pd.DataFrame,
        exclude_numbers: Optional[List[int]],
        include_numbers: Optional[List[int]],
        exclude_consecutive_2: bool,
        exclude_frequent: bool,
        frequent_lookback: int,
        frequent_threshold: int
    ) -> Dict[int, int]:
        """
        2단계: 제외 필터 적용
        
        2026-01-16 EST - Phase 2.1: generate_numbers()에서 분리
        """
        exclude_set = set(exclude_numbers or [])
        
        # B-1. 연속 출현 제외
        if exclude_consecutive_2:
            consecutive_nums = self._get_consecutive_2_numbers(historical_data)
            exclude_set.update(consecutive_nums)
        
        # B-2. 고빈도 출현 제외
        if exclude_frequent:
            frequent_nums = self._get_frequent_numbers(
                historical_data, frequent_lookback, frequent_threshold
            )
            exclude_set.update(frequent_nums)
        
        # 제외 번호 필터링
        filtered = {k: v for k, v in frequency.items() if k not in exclude_set}
        
        # 포함 번호 제거 (이미 선택됨)
        if include_numbers:
            filtered = {k: v for k, v in filtered.items() if k not in include_numbers}
        
        return filtered
    
    def _build_probability_distribution(
        self,
        frequency: Dict[int, int],
        historical_data: pd.DataFrame,
        probability_mode: str,
        apply_recent_penalty: bool,
        penalty_rate: float,
        temperature: float
    ) -> Dict[int, float]:
        """
        3단계: 확률 분포 생성 (모드 + 패널티 + 온도)
        
        2026-01-16 EST - Phase 2.1: generate_numbers()에서 분리
        """
        # 확률 모드 적용
        probabilities = self._apply_probability_mode(frequency, probability_mode)
        
        # 직전 회차 확률 할인
        if apply_recent_penalty:
            probabilities = self.apply_recent_draw_penalty(
                probabilities, historical_data, penalty_rate
            )
        
        # 온도 조정
        probabilities = self.apply_temperature(probabilities, temperature)
        
        return probabilities
    
    def _sample_numbers_from_distribution(
        self,
        probabilities: Dict[int, float],
        n_sets: int,
        include_numbers: Optional[List[int]]
    ) -> List[List[int]]:
        """
        4단계: 확률 분포에서 번호 샘플링
        
        2026-01-16 EST - Phase 2.1: generate_numbers()에서 분리
        """
        results = []
        numbers_list = list(probabilities.keys())
        probs_list = list(probabilities.values())
        
        for _ in range(n_sets):
            selected = []
            
            # 포함 번호 먼저 추가
            if include_numbers:
                selected.extend(include_numbers)
            
            # 확률 기반 샘플링
            remaining = 6 - len(selected)
            if remaining > 0:
                chosen = np.random.choice(
                    numbers_list,
                    size=remaining,
                    replace=False,
                    p=probs_list
                )
                selected.extend(chosen.tolist())
            
            results.append(sorted(selected))
        
        return results
    
    # ========================================
    # 기존 헬퍼 메서드들
    # ========================================
    
    # 2026-01-08 05:35:00 EST - _calculate_frequency 삭제 (base 클래스로 이동)
    
    def _get_consecutive_2_numbers(
        self,
        historical_data: pd.DataFrame
    ) -> List[int]:
        """직전 2회차 연속 출현 번호 추출"""
        if len(historical_data) < 2:
            return []
        
        recent_2 = historical_data.tail(2)
        
        # 직전 회차 번호
        prev_numbers = set()
        for i in range(1, 7):
            prev_numbers.add(recent_2.iloc[0][f'num{i}'])
        
        # 최신 회차 번호
        latest_numbers = set()
        for i in range(1, 7):
            latest_numbers.add(recent_2.iloc[1][f'num{i}'])
        
        # 교집합 (연속 출현)
        consecutive = list(prev_numbers & latest_numbers)
        
        return consecutive
    
    def _get_frequent_numbers(
        self,
        data: pd.DataFrame,
        lookback: int,
        threshold: int
    ) -> List[int]:
        """고빈도 출현 번호 추출"""
        if len(data) < lookback:
            lookback = len(data)
        
        recent = data.tail(lookback)
        frequency = {}
        
        for idx, row in recent.iterrows():
            for i in range(1, 7):
                num = row[f'num{i}']
                frequency[num] = frequency.get(num, 0) + 1
        
        exclude = [num for num, count in frequency.items() 
                   if count >= threshold]
        return exclude
    
    def _apply_probability_mode(
        self,
        frequency: Dict[int, int],
        mode: str
    ) -> Dict[int, float]:
        """확률 모드 적용"""
        if mode == 'normal':
            # 정확률
            total = sum(frequency.values())
            if total == 0:
                # 모든 빈도가 0이면 균등 분포
                return {num: 1.0 / len(frequency) for num in frequency.keys()}
            return {num: count / total 
                    for num, count in frequency.items()}
        else:  # 'inverse'
            # 역확률 [INVERSE]
            max_freq = max(frequency.values())
            inverse = {num: max_freq - count + 1 
                       for num, count in frequency.items()}
            total = sum(inverse.values())
            return {num: inv / total 
                    for num, inv in inverse.items()}
    
    # 2026-01-08 05:35:00 EST - _apply_recent_draw_penalty 삭제 (base 클래스로 이동)
    # 2026-01-08 05:35:00 EST - _apply_temperature 삭제 (base 클래스로 이동)
    # 2026-01-08 05:35:00 EST - _fallback_random 삭제 (base 클래스로 이동)
    
    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터"""
        return {
            'window_type': 'all',
            'window_size': None,
            'exclude_consecutive_2': False,
            'exclude_frequent': False,
            'frequent_lookback': 10,
            'frequent_threshold': 5,
            'apply_recent_penalty': False,
            'penalty_rate': 0.5,
            'probability_mode': 'normal',
            'temperature': 1.0
        }
    
    def calculate_cost(
        self,
        probability_mode: str = 'normal',
        exclude_consecutive_2: bool = False,
        exclude_frequent: bool = False,
        apply_recent_penalty: bool = False
    ) -> int:
        """파라미터 조합에 따른 비용 계산"""
        cost = 1  # 기본 비용
        
        # 역확률 사용 시 +1
        if probability_mode == 'inverse':
            cost += 1
        
        # 필터 사용 시 +1
        if exclude_consecutive_2 or exclude_frequent or apply_recent_penalty:
            cost += 1
        
        return cost

