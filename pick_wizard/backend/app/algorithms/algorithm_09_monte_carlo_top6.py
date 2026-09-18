"""
Algorithm 9: 몬테카를로 상위 6개 (Monte Carlo Top 6)

1~45를 10,000회 무작위 추출 후 출현 빈도 상위 6개를 1세트로 사용

2026-02-15 - 038 설계서 구현
"""

import random
from collections import Counter
from typing import List, Dict, Optional, Any

import pandas as pd

from app.algorithms.base import LottoAlgorithm
from app.algorithms.constants import (
    LOTTO_MIN_NUMBER,
    LOTTO_MAX_NUMBER,
    LOTTO_NUMBERS_PER_DRAW,
)

# 038: 세트당 시행 횟수
TRIALS_PER_SET = 10_000


class MonteCarloTop6Algorithm(LottoAlgorithm):
    """
    몬테카를로 상위 6개 알고리즘

    1~45 범위에서 한 번에 하나씩 무작위 추출을 10,000회 반복한 뒤,
    가장 많이 나온 6개 번호를 한 세트로 사용합니다.
    동점 시 번호 오름차순으로 정렬하여 상위 6개 확정.
    """

    def __init__(self):
        super().__init__(
            algorithm_id=9,
            name="몬테카를로 상위 6개 (Monte Carlo Top 6)",
            description="1~45를 10,000번 무작위로 뽑아 가장 많이 나온 6개를 한 세트로 합니다.",
        )

    def generate_numbers(
        self,
        historical_data: Optional[pd.DataFrame],
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        **kwargs
    ) -> List[List[int]]:
        """몬테카를로 상위 6개 번호 생성 (historical_data 미사용)"""
        valid, error_msg = self.validate_parameters(n_sets, exclude_numbers, include_numbers)
        if not valid:
            raise ValueError(error_msg)

        # 사용 가능한 번호 풀 (exclude 제외, include는 선택 후보에서 제거)
        pool = self.get_available_numbers(exclude_numbers, include_numbers)
        if len(pool) < LOTTO_NUMBERS_PER_DRAW - (len(include_numbers) if include_numbers else 0):
            raise ValueError(
                "제외/포함 조건으로 인해 남은 후보 수가 부족합니다. "
                "제외 번호를 줄이거나 포함 번호를 조정해 주세요."
            )

        results = []
        n_include = len(include_numbers) if include_numbers else 0
        need_per_set = LOTTO_NUMBERS_PER_DRAW - n_include

        for _ in range(n_sets):
            # 풀에서 한 번에 하나씩 TRIALS_PER_SET회 추출
            counter = Counter(random.choices(pool, k=TRIALS_PER_SET))

            # 빈도 내림차순, 동점 시 번호 오름차순 (038 동점 처리)
            sorted_items = sorted(
                counter.items(),
                key=lambda x: (-x[1], x[0])
            )

            # 상위 need_per_set개 번호 선택 (중복 없음 보장)
            selected = []
            for num, _ in sorted_items:
                if len(selected) >= need_per_set:
                    break
                selected.append(num)

            # 포함 번호 + 선택 번호 합친 뒤 정렬
            if include_numbers:
                numbers = list(include_numbers) + selected
            else:
                numbers = selected
            results.append(sorted(numbers))

        return results

    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터 (공통만)"""
        return {
            "n_sets": 5,
            "exclude_numbers": None,
            "include_numbers": None,
        }
