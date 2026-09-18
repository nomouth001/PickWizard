"""
Algorithm 5: 가중치 조합 (Weighted Combination)

사용자 지정 가중치로 번호 선택 확률 조정

2026-01-08 03:24:00 EST - 초기 생성
2026-01-08 05:50:00 EST - 중복 제거: base 클래스 메서드 사용
"""

import random
from typing import List, Dict, Optional, Any
from collections import Counter
import math

import pandas as pd
import numpy as np

from app.algorithms.base import LottoAlgorithm


class WeightedAlgorithm(LottoAlgorithm):
    """
    가중치 조합 알고리즘
    
    빈도, 최근성, 구간 등 다양한 요소에 가중치를 부여하여
    사용자 맞춤형 번호 생성
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=5,
            # 2026-01-17 20:00:00 EST - 명칭 변경: "가중치 조합" → "가중치 조합 선택"
            name="가중치 조합 선택 (Weighted Selection)",
            description="빈도, 최근성, 구간 등에 가중치를 부여하여 번호를 생성합니다."
            # 2026-01-18 20:30:00 EST - cost_per_set 제거 (SSOT 원칙: pricing_config.yaml만 사용)
            # cost_per_set=3
        )
    
    def generate_numbers(
        self,
        historical_data: Optional[pd.DataFrame],
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        **kwargs
    ) -> List[List[int]]:
        """
        가중치 기반 번호 생성
        
        Args:
            historical_data: 과거 당첨번호 DataFrame
            n_sets: 생성할 세트 수
            exclude_numbers: 제외할 번호
            include_numbers: 포함할 번호
            **kwargs:
                - frequency_weight: 빈도 가중치 (기본: 0.3)
                - recency_weight: 최근성 가중치 (기본: 0.3)
                - zone_weight: 구간 균형 가중치 (기본: 0.2)
                - diversity_weight: 다양성 가중치 (기본: 0.2)
                - recent_draws: 최근 N회차만 사용 (기본: 100)
                
        Returns:
            List[List[int]]: 번호 세트
        """
        # 파라미터 검증
        valid, error_msg = self.validate_parameters(n_sets, exclude_numbers, include_numbers)
        if not valid:
            raise ValueError(error_msg)
        
        # 가중치 파라미터
        freq_weight = kwargs.get('frequency_weight', 0.3)
        recency_weight = kwargs.get('recency_weight', 0.3)
        zone_weight = kwargs.get('zone_weight', 0.2)
        diversity_weight = kwargs.get('diversity_weight', 0.2)
        
        # 가중치 정규화
        total_weight = freq_weight + recency_weight + zone_weight + diversity_weight
        if total_weight > 0:
            freq_weight /= total_weight
            recency_weight /= total_weight
            zone_weight /= total_weight
            diversity_weight /= total_weight
        
        # 최근 N회차만 사용
        recent_draws = kwargs.get('recent_draws', 100)
        if historical_data is not None and len(historical_data) > 0:
            df = historical_data.tail(recent_draws)
        else:
            # 과거 데이터 없으면 순수 랜덤으로 폴백
            # 2026-01-08 05:50:00 EST - base 클래스 메서드 사용
            return self.generate_random_sets(n_sets, exclude_numbers, include_numbers)
        
        # 사용 가능한 번호 풀
        available_numbers = self.get_available_numbers(exclude_numbers, include_numbers)
        
        # 각 번호별 점수 계산
        scores = self._calculate_weighted_scores(
            df,
            available_numbers,
            freq_weight,
            recency_weight,
            zone_weight,
            diversity_weight
        )
        
        results = []
        
        for _ in range(n_sets):
            numbers = []
            
            # 포함 번호 먼저 추가
            if include_numbers:
                numbers.extend(include_numbers)
            
            # 나머지 번호 점수 기반 선택
            remaining_count = 6 - len(numbers)
            remaining_pool = [n for n in available_numbers if n not in numbers]
            
            # 점수를 확률로 변환
            pool_scores = [scores.get(n, 1.0) for n in remaining_pool]
            
            # 소프트맥스 적용 (온도 = 0.5)
            temperature = 0.5
            exp_scores = [math.exp(s / temperature) for s in pool_scores]
            total_exp = sum(exp_scores)
            
            if total_exp > 0:
                probabilities = [e / total_exp for e in exp_scores]
            else:
                probabilities = [1.0 / len(pool_scores)] * len(pool_scores)
            
            # 확률 기반 선택 (중복 없이)
            selected_indices = []
            temp_pool = remaining_pool.copy()
            temp_probs = probabilities.copy()
            
            for _ in range(remaining_count):
                if not temp_pool:
                    break
                
                # 확률 기반 선택
                chosen_idx = random.choices(
                    range(len(temp_pool)), 
                    weights=temp_probs, 
                    k=1
                )[0]
                
                numbers.append(temp_pool[chosen_idx])
                
                # 선택된 번호 제거
                temp_pool.pop(chosen_idx)
                temp_probs.pop(chosen_idx)
                
                # 확률 재정규화
                if temp_probs:
                    total = sum(temp_probs)
                    if total > 0:
                        temp_probs = [p / total for p in temp_probs]
            
            # 정렬
            results.append(sorted(numbers))
        
        return results
    
    def _calculate_weighted_scores(
        self,
        df: pd.DataFrame,
        available_numbers: List[int],
        freq_weight: float,
        recency_weight: float,
        zone_weight: float,
        diversity_weight: float
    ) -> Dict[int, float]:
        """가중치 기반 점수 계산"""
        scores = {}
        
        # 1. 빈도 점수 계산
        frequency_scores = self._calculate_frequency_scores(df, available_numbers)
        
        # 2. 최근성 점수 계산
        recency_scores = self._calculate_recency_scores(df, available_numbers)
        
        # 3. 구간 균형 점수 계산
        zone_scores = self._calculate_zone_scores(available_numbers)
        
        # 4. 다양성 점수 계산
        diversity_scores = self._calculate_diversity_scores(available_numbers)
        
        # 가중치 합산
        for num in available_numbers:
            score = (
                frequency_scores.get(num, 0.0) * freq_weight +
                recency_scores.get(num, 0.0) * recency_weight +
                zone_scores.get(num, 0.0) * zone_weight +
                diversity_scores.get(num, 0.0) * diversity_weight
            )
            scores[num] = score
        
        return scores
    
    def _calculate_frequency_scores(
        self,
        df: pd.DataFrame,
        available_numbers: List[int]
    ) -> Dict[int, float]:
        """빈도 점수 계산"""
        frequency = Counter()
        
        for idx, row in df.iterrows():
            for i in range(1, 7):
                frequency[row[f'num{i}']] += 1
        
        # 정규화 (0~1)
        max_freq = max(frequency.values()) if frequency else 1
        
        scores = {}
        for num in available_numbers:
            scores[num] = frequency.get(num, 0) / max_freq
        
        return scores
    
    def _calculate_recency_scores(
        self,
        df: pd.DataFrame,
        available_numbers: List[int]
    ) -> Dict[int, float]:
        """최근성 점수 계산 (최근에 나온 번호일수록 높은 점수)"""
        scores = {num: 0.0 for num in available_numbers}
        
        # 최근 20회차만 사용
        recent_df = df.tail(20)
        
        # 각 번호의 마지막 출현 회차 찾기
        total_draws = len(recent_df)
        
        for idx, (_, row) in enumerate(reversed(list(recent_df.iterrows()))):
            draw_numbers = [row[f'num{i}'] for i in range(1, 7)]
            
            for num in draw_numbers:
                if num in available_numbers and scores[num] == 0.0:
                    # 최근일수록 높은 점수 (지수 감쇠)
                    recency = (total_draws - idx) / total_draws
                    scores[num] = recency
        
        return scores
    
    def _calculate_zone_scores(
        self,
        available_numbers: List[int]
    ) -> Dict[int, float]:
        """구간 균형 점수 계산"""
        # 각 구간의 번호 개수
        zones = [0] * 5  # 1-9, 10-18, 19-27, 28-36, 37-45
        
        for num in available_numbers:
            zone_idx = self._get_zone_index(num)
            zones[zone_idx] += 1
        
        # 구간이 적을수록 높은 점수 (균형을 위해)
        max_count = max(zones) if zones else 1
        
        scores = {}
        for num in available_numbers:
            zone_idx = self._get_zone_index(num)
            zone_count = zones[zone_idx]
            # 역수 점수 (적은 구간일수록 높은 점수)
            scores[num] = 1.0 - (zone_count / max_count) if max_count > 0 else 0.5
        
        return scores
    
    def _calculate_diversity_scores(
        self,
        available_numbers: List[int]
    ) -> Dict[int, float]:
        """다양성 점수 계산 (홀/짝, 끝자리 등)"""
        scores = {}
        
        # 홀수/짝수 개수
        odd_count = sum(1 for n in available_numbers if n % 2 == 1)
        even_count = len(available_numbers) - odd_count
        
        # 끝자리 분포
        last_digit_counts = Counter([n % 10 for n in available_numbers])
        
        for num in available_numbers:
            score = 0.0
            
            # 1. 홀/짝 균형 (50%)
            if num % 2 == 1:
                # 홀수가 적으면 점수 높음
                score += (1.0 - odd_count / len(available_numbers)) * 0.5
            else:
                # 짝수가 적으면 점수 높음
                score += (1.0 - even_count / len(available_numbers)) * 0.5
            
            # 2. 끝자리 다양성 (50%)
            last_digit = num % 10
            digit_count = last_digit_counts[last_digit]
            max_digit_count = max(last_digit_counts.values())
            # 끝자리가 적을수록 높은 점수
            score += (1.0 - digit_count / max_digit_count) * 0.5 if max_digit_count > 0 else 0.5
            
            scores[num] = score
        
        return scores
    
    def _get_zone_index(self, number: int) -> int:
        """번호의 구간 인덱스 반환 (0~4)"""
        if number <= 9:
            return 0
        elif number <= 18:
            return 1
        elif number <= 27:
            return 2
        elif number <= 36:
            return 3
        else:
            return 4
    
    # 2026-01-08 05:50:00 EST - _fallback_random 삭제 (base 클래스로 이동)

    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터"""
        return {
            'n_sets': 5,
            'exclude_numbers': None,
            'include_numbers': None,
            'frequency_weight': 0.3,
            'recency_weight': 0.3,
            'zone_weight': 0.2,
            'diversity_weight': 0.2,
            'recent_draws': 100
        }

