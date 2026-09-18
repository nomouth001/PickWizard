"""
Algorithm 1: 자동선택 (Quick Pick)

완전 무작위 번호 생성

2026-01-04 EST - 초기 생성
2026-01-16 EST - 이름 변경: "순수 랜덤" → "자동선택 (Quick Pick)"
"""

import random
from typing import List, Dict, Optional, Any

import pandas as pd

from app.algorithms.base import LottoAlgorithm


class RandomAlgorithm(LottoAlgorithm):
    """
    자동선택 알고리즘 (Quick Pick)
    
    1~45 중 6개를 완전 무작위로 선택
    가장 공정하고 편향 없는 방법
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=1,
            name="자동선택 (Quick Pick)",
            description="1~45 중 6개를 완전 무작위로 선택합니다. 가장 공정하고 편향 없는 방법입니다."
            # 2026-01-18 20:30:00 EST - cost_per_set 제거 (SSOT 원칙: pricing_config.yaml만 사용)
            # cost_per_set=0  # 무료
        )
    
    def generate_numbers(
        self,
        historical_data: Optional[pd.DataFrame],
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        **kwargs
    ) -> List[List[int]]:
        """순수 랜덤 번호 생성"""
        # 파라미터 검증
        valid, error_msg = self.validate_parameters(n_sets, exclude_numbers, include_numbers)
        if not valid:
            raise ValueError(error_msg)
        
        results = []
        
        # 사용 가능한 번호 풀
        available_numbers = self.get_available_numbers(exclude_numbers, include_numbers)
        
        for _ in range(n_sets):
            numbers = []
            
            # 포함 번호 먼저 추가
            if include_numbers:
                numbers.extend(include_numbers)
            
            # 나머지 번호 랜덤 선택
            remaining_count = 6 - len(numbers)
            selected = random.sample(available_numbers, remaining_count)
            numbers.extend(selected)
            
            # 정렬
            results.append(sorted(numbers))
        
        return results
    
    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터"""
        return {
            'n_sets': 5,
            'exclude_numbers': None,
            'include_numbers': None
        }

