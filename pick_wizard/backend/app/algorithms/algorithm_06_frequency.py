"""
Algorithm 6: 빈도 기반 (Frequency Analysis)

과거 출현 빈도가 높은 번호 우선 선택

2026-01-04 EST - 초기 생성
2026-01-08 05:50:00 EST - 중복 제거: base 클래스 메서드 사용
"""

import random
from typing import List, Dict, Optional, Any
from collections import Counter

import pandas as pd
import numpy as np

from app.algorithms.base import LottoAlgorithm


class FrequencyAlgorithm(LottoAlgorithm):
    """
    빈도 기반 알고리즘
    
    과거 데이터에서 가장 많이 나온 번호를 높은 확률로 선택
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=6,
            # 2026-01-17 20:00:00 EST - 명칭 변경: "빈도 기반" → "출현 번호 빈도 기반 선택"
            name="출현 번호 빈도 기반 선택 (Frequency-Based Selection)",
            description="과거 출현 빈도가 높은 번호를 우선적으로 선택합니다."
            # 2026-01-18 20:30:00 EST - cost_per_set 제거 (SSOT 원칙: pricing_config.yaml만 사용)
            # cost_per_set=1
        )
    
    def generate_numbers(
        self,
        historical_data: Optional[pd.DataFrame],
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        **kwargs
    ) -> List[List[int]]:
        """빈도 기반 번호 생성"""
        # 파라미터 검증
        valid, error_msg = self.validate_parameters(n_sets, exclude_numbers, include_numbers)
        if not valid:
            raise ValueError(error_msg)
        
        # 과거 데이터가 없으면 랜덤으로 fallback
        # 2026-01-08 05:50:00 EST - base 클래스 메서드 사용
        if historical_data is None or len(historical_data) == 0:
            return self.generate_random_sets(n_sets, exclude_numbers, include_numbers)
        
        # 최근 N회차만 사용
        recent_draws = kwargs.get('recent_draws', 100)
        df = historical_data.tail(recent_draws)
        
        # 빈도 계산
        # 2026-01-08 05:50:00 EST - base 클래스 메서드 사용
        frequency = self.calculate_frequency(df)
        
        # 제외 번호 필터링
        if exclude_numbers:
            frequency = {k: v for k, v in frequency.items() if k not in exclude_numbers}
        
        # 포함 번호 제거 (이미 선택됨)
        if include_numbers:
            frequency = {k: v for k, v in frequency.items() if k not in include_numbers}
        
        # 확률 분포 생성
        temperature = kwargs.get('temperature', 1.0)
        probs = self._create_probability_distribution(frequency, temperature)
        
        results = []
        
        for _ in range(n_sets):
            numbers = []
            
            # 포함 번호 먼저 추가
            if include_numbers:
                numbers.extend(include_numbers)
            
            # 나머지 번호 확률적 선택
            remaining_count = 6 - len(numbers)
            available_nums = list(frequency.keys())
            available_probs = [probs[num] for num in available_nums]
            
            # numpy로 확률 기반 선택
            selected = np.random.choice(
                available_nums,
                size=remaining_count,
                replace=False,
                p=available_probs
            )
            numbers.extend(selected.tolist())
            
            # 정렬
            results.append(sorted(numbers))
        
        return results
    
    # 2026-01-08 05:50:00 EST - _calculate_frequency 삭제 (base 클래스로 이동)
    
    def _create_probability_distribution(
        self,
        frequency: Dict[int, int],
        temperature: float = 1.0
    ) -> Dict[int, float]:
        """빈도를 확률 분포로 변환"""
        # 빈도를 배열로 변환
        numbers = list(frequency.keys())
        counts = np.array([frequency[num] for num in numbers])
        
        # 모든 빈도가 0이면 균등 분포
        if counts.sum() == 0:
            probs = np.ones(len(counts)) / len(counts)
        else:
            # Temperature 적용
            if temperature != 1.0:
                counts = counts ** (1.0 / temperature)
            
            # 확률 정규화
            probs = counts / counts.sum()
        
        return {num: prob for num, prob in zip(numbers, probs)}
    
    # 2026-01-08 05:50:00 EST - _fallback_random 삭제 (base 클래스로 이동)
    
    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터"""
        return {
            'n_sets': 5,
            'exclude_numbers': None,
            'include_numbers': None,
            'recent_draws': 100,
            'temperature': 1.0
        }

