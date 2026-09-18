"""
Algorithm 7: 핫/콜드 넘버 (Hot & Cold Numbers)

최근 자주 나온 번호(Hot)와 오랫동안 안 나온 번호(Cold) 혼합

2026-01-04 EST - 초기 생성
2026-01-08 05:50:00 EST - 중복 제거: base 클래스 메서드 사용
"""

import random
from typing import List, Dict, Optional, Any
from collections import Counter

import pandas as pd

from app.algorithms.base import LottoAlgorithm


class HotColdAlgorithm(LottoAlgorithm):
    """
    핫/콜드 넘버 알고리즘
    
    최근 N회차에서 자주 나온 번호(Hot)와
    오랫동안 나오지 않은 번호(Cold)를 혼합 선택
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=7,
            # 2026-01-17 20:00:00 EST - 명칭 변경: "핫/콜드 넘버" → "핫/콜드 넘버 선택"
            name="핫/콜드 넘버 선택 (Hot & Cold Selection)",
            description="최근 자주 나온 번호(Hot)와 오래 안 나온 번호(Cold)를 혼합합니다."
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
        """핫/콜드 번호 생성"""
        # 파라미터 검증
        valid, error_msg = self.validate_parameters(n_sets, exclude_numbers, include_numbers)
        if not valid:
            raise ValueError(error_msg)
        
        # 과거 데이터 없으면 랜덤
        # 2026-01-08 05:50:00 EST - base 클래스 메서드 사용
        if historical_data is None or len(historical_data) == 0:
            return self.generate_random_sets(n_sets, exclude_numbers, include_numbers)
        
        # 파라미터 추출
        hot_window = kwargs.get('hot_window', 20)
        cold_window = kwargs.get('cold_window', 50)
        hot_count = kwargs.get('hot_count', 3)
        cold_count = kwargs.get('cold_count', 2)
        
        # Hot/Cold 번호 계산
        hot_numbers = self._get_hot_numbers(
            historical_data.tail(hot_window),
            exclude_numbers,
            include_numbers
        )
        cold_numbers = self._get_cold_numbers(
            historical_data.tail(cold_window),
            exclude_numbers,
            include_numbers
        )
        
        results = []
        available = self.get_available_numbers(exclude_numbers, include_numbers)
        
        for _ in range(n_sets):
            numbers = []
            
            # 포함 번호 먼저 추가
            if include_numbers:
                numbers.extend(include_numbers)
            
            # Hot 번호 선택
            hot_pick_count = min(hot_count, 6 - len(numbers))
            if hot_pick_count > 0 and hot_numbers:
                hot_selected = random.sample(hot_numbers, min(hot_pick_count, len(hot_numbers)))
                numbers.extend(hot_selected)
            
            # Cold 번호 선택
            cold_pick_count = min(cold_count, 6 - len(numbers))
            if cold_pick_count > 0 and cold_numbers:
                cold_candidates = [n for n in cold_numbers if n not in numbers]
                if cold_candidates:
                    cold_selected = random.sample(cold_candidates, min(cold_pick_count, len(cold_candidates)))
                    numbers.extend(cold_selected)
            
            # 나머지 랜덤 선택
            remaining_count = 6 - len(numbers)
            if remaining_count > 0:
                remaining_pool = [n for n in available if n not in numbers]
                if remaining_pool:
                    random_selected = random.sample(remaining_pool, min(remaining_count, len(remaining_pool)))
                    numbers.extend(random_selected)
            
            # 정렬
            results.append(sorted(numbers))
        
        return results
    
    def _get_hot_numbers(
        self,
        df: pd.DataFrame,
        exclude: Optional[List[int]],
        include: Optional[List[int]]
    ) -> List[int]:
        """Hot 번호 추출 (최근 자주 나온 번호)"""
        all_numbers = []
        
        for _, row in df.iterrows():
            for i in range(1, 7):
                all_numbers.append(row[f'num{i}'])
        
        frequency = Counter(all_numbers)
        
        # 제외/포함 필터링
        if exclude:
            frequency = {k: v for k, v in frequency.items() if k not in exclude}
        if include:
            frequency = {k: v for k, v in frequency.items() if k not in include}
        
        # 상위 10개 반환
        hot = [num for num, count in frequency.most_common(10)]
        return hot
    
    def _get_cold_numbers(
        self,
        df: pd.DataFrame,
        exclude: Optional[List[int]],
        include: Optional[List[int]]
    ) -> List[int]:
        """Cold 번호 추출 (오래 안 나온 번호)"""
        all_numbers = []
        
        for _, row in df.iterrows():
            for i in range(1, 7):
                all_numbers.append(row[f'num{i}'])
        
        frequency = Counter(all_numbers)
        all_nums = set(range(1, 46))
        
        # 제외/포함 필터링
        if exclude:
            all_nums -= set(exclude)
        if include:
            all_nums -= set(include)
        
        # 빈도가 낮은 순으로 정렬
        cold = sorted(all_nums, key=lambda x: frequency.get(x, 0))
        
        # 하위 10개 반환
        return cold[:10]
    
    # 2026-01-08 05:50:00 EST - _fallback_random 삭제 (base 클래스로 이동)
    
    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터"""
        return {
            'n_sets': 5,
            'exclude_numbers': None,
            'include_numbers': None,
            'hot_window': 20,
            'cold_window': 50,
            'hot_count': 3,
            'cold_count': 2
        }

