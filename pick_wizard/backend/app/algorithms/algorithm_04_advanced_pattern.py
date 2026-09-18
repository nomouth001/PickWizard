"""
Algorithm 4: 패턴 분석 (Advanced Pattern)

메타 패턴 분석 (범위/순위)

2026-01-07 EST - 초기 생성 (010.3_Algorithm_Redesign_Pattern.md 기반)
2026-01-08 05:45:00 EST - 중복 제거: base 클래스 메서드 사용
"""

from typing import List, Dict, Optional, Any, Literal, Tuple
from collections import Counter
from itertools import combinations

import numpy as np
import pandas as pd

from app.algorithms.base import LottoAlgorithm


# =====================================
# 범위 패턴 유틸리티
# =====================================

def get_default_ranges(divisions: int) -> Dict[str, Tuple[int, int]]:
    """
    기본 구간 정의
    
    Args:
        divisions: 2, 3, 5, 10
    
    Returns:
        {'A': (1, 9), 'B': (10, 18), ...}
    """
    if divisions == 2:
        return {
            'L': (1, 22),   # Low
            'H': (23, 45)   # High
        }
    elif divisions == 3:
        return {
            'L': (1, 15),   # Low
            'M': (16, 30),  # Mid
            'H': (31, 45)   # High
        }
    elif divisions == 5:
        return {
            'A': (1, 9),
            'B': (10, 18),
            'C': (19, 27),
            'D': (28, 36),
            'E': (37, 45)
        }
    elif divisions == 10:
        labels = 'ABCDEFGHIJ'
        ranges = {}
        for i, label in enumerate(labels):
            start = i * 5 + 1
            end = min((i + 1) * 5, 45)
            ranges[label] = (start, end)
        return ranges
    else:
        raise ValueError(f"Unsupported divisions: {divisions}")


def numbers_to_range_pattern(
    numbers: List[int],
    ranges: Dict[str, Tuple[int, int]]
) -> str:
    """번호 → 범위 패턴 변환"""
    pattern = []
    
    for num in numbers:
        for label, (start, end) in ranges.items():
            if start <= num <= end:
                pattern.append(label)
                break
    
    return ''.join(sorted(pattern))


# =====================================
# 순위 패턴 유틸리티
# =====================================

def calculate_frequency_ranks(
    historical_data: pd.DataFrame,
    mode: str = 'cumulative',
    window_size: int = 50
) -> Dict[int, Dict[int, int]]:
    """
    빈도 기반 순위 계산
    
    Args:
        mode: 'cumulative' | 'recent'
    
    Returns:
        {회차_idx: {번호: 순위}}
    """
    ranks_per_round = {}
    
    if mode == 'cumulative':
        # 누적 빈도
        cumulative_freq = Counter()
        
        for idx, row in historical_data.iterrows():
            # 현재까지의 누적 빈도로 순위 계산
            if len(cumulative_freq) > 0:
                sorted_nums = sorted(
                    cumulative_freq.items(),
                    key=lambda x: (-x[1], x[0])
                )
                rank_dict = {num: rank+1 for rank, (num, _) in enumerate(sorted_nums)}
            else:
                rank_dict = {}
            
            # 0회 출현 번호는 46위
            for num in range(1, 46):
                if num not in rank_dict:
                    rank_dict[num] = 46
            
            ranks_per_round[idx] = rank_dict
            
            # 현재 회차 누적
            for i in range(1, 7):
                cumulative_freq[row[f'num{i}']] += 1
    
    else:  # 'recent'
        for idx in range(len(historical_data)):
            start = max(0, idx - window_size)
            recent = historical_data.iloc[start:idx]
            
            freq = Counter()
            for _, row in recent.iterrows():
                for i in range(1, 7):
                    freq[row[f'num{i}']] += 1
            
            if len(freq) > 0:
                sorted_nums = sorted(freq.items(), key=lambda x: (-x[1], x[0]))
                rank_dict = {num: rank+1 for rank, (num, _) in enumerate(sorted_nums)}
            else:
                rank_dict = {}
            
            for num in range(1, 46):
                if num not in rank_dict:
                    rank_dict[num] = 46
            
            ranks_per_round[idx] = rank_dict
    
    return ranks_per_round


# =====================================
# 통합 알고리즘 클래스
# =====================================

class AdvancedPatternAlgorithm(LottoAlgorithm):
    """
    알고리즘 4: 패턴 분석 (통합 버전)
    
    범위 패턴 × 순위 패턴
    """
    
    def __init__(self):
        super().__init__(
            algorithm_id=4,
            # 2026-01-17 20:00:00 EST - 명칭 변경: "패턴 분석" → "출현 번호 패턴 기반 선택"
            name="출현 번호 패턴 기반 선택 (Pattern-Based Selection)",
            description="메타 패턴 분석 (범위/순위)"
            # 2026-01-18 20:30:00 EST - cost_per_set 제거 (SSOT 원칙: pricing_config.yaml만 사용)
            # cost_per_set=2
        )
    
    def generate_numbers(
        self,
        historical_data: Optional[pd.DataFrame],
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        
        # A. 패턴 타입 [PATTERN_TYPE]
        pattern_type: Literal['range', 'rank'] = 'range',
        
        # B-1. 범위 패턴 설정
        range_divisions: int = 5,
        custom_ranges: Optional[Dict[str, Tuple[int, int]]] = None,
        
        # B-2. 순위 패턴 설정
        rank_combo_size: int = 3,
        rank_mode: Literal['cumulative', 'recent'] = 'cumulative',
        rank_window: int = 50,
        
        # C. 분석 범위
        analysis_window_type: Literal['all', 'recent'] = 'all',
        analysis_window_size: Optional[int] = None,
        
        # D. 상위 패턴 개수
        top_n_patterns: int = 10,
        
        # E. 패턴 내 확률 분포
        in_pattern_probability: Literal['uniform', 'frequency', 'inverse'] = 'frequency',
        
        # F. 패턴 선택 확률
        pattern_selection_probability: Literal['normal', 'inverse'] = 'normal',
        
        **kwargs
    ) -> List[List[int]]:
        """패턴 분석 번호 생성 (통합 버전)"""
        
        # 파라미터 검증
        valid, error_msg = self.validate_parameters(
            n_sets, exclude_numbers, include_numbers
        )
        if not valid:
            raise ValueError(error_msg)
        
        if historical_data is None or len(historical_data) < 10:
            raise ValueError("최소 10회차 이상의 데이터 필요")
        
        # 분석 범위 설정
        if analysis_window_type == 'all':
            analysis_data = historical_data
        else:
            analysis_data = historical_data.tail(analysis_window_size or 100)
        
        # ===== 1. 패턴 타입에 따라 분기 =====
        
        if pattern_type == 'range':
            # 범위 패턴
            patterns, pattern_generator = self._analyze_range_patterns(
                analysis_data, historical_data,
                range_divisions, custom_ranges,
                top_n_patterns, pattern_selection_probability
            )
        else:  # 'rank'
            # 순위 패턴
            patterns, pattern_generator = self._analyze_rank_patterns(
                analysis_data, historical_data,
                rank_combo_size, rank_mode, rank_window,
                top_n_patterns, pattern_selection_probability
            )
        
        # ===== 2. 빈도 계산 (패턴 내 번호 선택용) =====
        # 2026-01-08 05:45:00 EST - base 클래스 메서드 사용
        frequency_dict = self.calculate_frequency(analysis_data)
        
        # ===== 3. 번호 생성 =====
        results = []
        
        for i in range(n_sets):
            # 패턴 선택
            selected_pattern = patterns[i % len(patterns)]
            
            # 패턴 → 번호 변환
            numbers = pattern_generator(
                selected_pattern,
                frequency_dict,
                in_pattern_probability
            )
            
            # 제외 번호 필터링
            if exclude_numbers:
                numbers = [n for n in numbers if n not in exclude_numbers]
            
            # 포함 번호 추가
            if include_numbers:
                numbers = list(set(numbers + include_numbers))
            
            # 6개 맞추기
            while len(numbers) < 6:
                pool = [n for n in range(1, 46) 
                        if n not in numbers 
                        and (not exclude_numbers or n not in exclude_numbers)]
                
                if not pool:
                    break
                
                # 빈도 기반 추가
                if in_pattern_probability == 'frequency':
                    weights = [frequency_dict.get(n, 1) for n in pool]
                elif in_pattern_probability == 'inverse':
                    max_freq = max(frequency_dict.get(n, 1) for n in pool)
                    weights = [max_freq - frequency_dict.get(n, 1) + 1 for n in pool]
                else:  # uniform
                    weights = [1] * len(pool)
                
                total = sum(weights)
                if total > 0:
                    probs = [w / total for w in weights]
                else:
                    probs = [1.0 / len(pool)] * len(pool)
                
                chosen = np.random.choice(pool, size=1, p=probs)[0]
                numbers.append(chosen)
            
            # 6개 초과 시 제거
            if len(numbers) > 6:
                numbers = numbers[:6]
            
            results.append(sorted(numbers))
        
        return results
    
    def _analyze_range_patterns(
        self,
        analysis_data: pd.DataFrame,
        full_data: pd.DataFrame,
        divisions: int,
        custom_ranges: Optional[Dict],
        top_n: int,
        selection_mode: str
    ) -> Tuple[List[str], callable]:
        """범위 패턴 분석"""
        
        # 구간 정의
        if custom_ranges:
            ranges = custom_ranges
        else:
            ranges = get_default_ranges(divisions)
        
        # 패턴 빈도 집계
        pattern_counter = Counter()
        
        for idx, row in analysis_data.iterrows():
            numbers = [row[f'num{i}'] for i in range(1, 7)]
            pattern = numbers_to_range_pattern(numbers, ranges)
            pattern_counter[pattern] += 1
        
        # 상위 패턴 선택
        if selection_mode == 'normal':
            # 빈도 높은 순
            top_patterns = [pat for pat, _ in pattern_counter.most_common(top_n)]
        else:  # 'inverse'
            # 빈도 낮은 순
            sorted_patterns = sorted(pattern_counter.items(), key=lambda x: x[1])
            top_patterns = [pat for pat, _ in sorted_patterns[:top_n]]
        
        # 패턴 → 번호 변환 함수
        def generate_from_pattern(pattern, freq_dict, prob_mode):
            selected = []
            
            for symbol in pattern:
                start, end = ranges[symbol]
                pool = [n for n in range(start, end+1) if n not in selected]
                
                if not pool:
                    continue
                
                if prob_mode == 'uniform':
                    weights = [1] * len(pool)
                elif prob_mode == 'frequency':
                    weights = [freq_dict.get(n, 1) for n in pool]
                else:  # 'inverse'
                    max_freq = max(freq_dict.get(n, 1) for n in pool)
                    weights = [max_freq - freq_dict.get(n, 1) + 1 for n in pool]
                
                total = sum(weights)
                if total > 0:
                    probs = [w / total for w in weights]
                else:
                    probs = [1.0 / len(pool)] * len(pool)
                
                chosen = np.random.choice(pool, size=1, p=probs)[0]
                selected.append(chosen)
            
            return selected
        
        return top_patterns, generate_from_pattern
    
    def _analyze_rank_patterns(
        self,
        analysis_data: pd.DataFrame,
        full_data: pd.DataFrame,
        combo_size: int,
        rank_mode: str,
        rank_window: int,
        top_n: int,
        selection_mode: str
    ) -> Tuple[List[tuple], callable]:
        """순위 패턴 분석"""
        
        # 순위 계산
        ranks_per_round = calculate_frequency_ranks(
            full_data, rank_mode, rank_window
        )
        
        # 순위 조합 패턴 집계
        pattern_counter = Counter()
        
        for idx, row in analysis_data.iterrows():
            numbers = [row[f'num{i}'] for i in range(1, 7)]
            
            if idx not in ranks_per_round:
                continue
            
            rank_dict = ranks_per_round[idx]
            ranks = [rank_dict.get(num, 46) for num in numbers]
            
            # N개 조합 생성
            for combo in combinations(sorted(ranks), combo_size):
                pattern_counter[combo] += 1
        
        # 상위 패턴 선택
        if selection_mode == 'normal':
            top_patterns = [pat for pat, _ in pattern_counter.most_common(top_n)]
        else:  # 'inverse'
            sorted_patterns = sorted(pattern_counter.items(), key=lambda x: x[1])
            top_patterns = [pat for pat, _ in sorted_patterns[:top_n]]
        
        # 최신 회차 순위 (번호 생성용)
        latest_idx = len(full_data) - 1
        if latest_idx in ranks_per_round:
            latest_ranks = ranks_per_round[latest_idx]
        else:
            # fallback: 빈도 기반 순위
            freq = Counter()
            for idx, row in full_data.iterrows():
                for i in range(1, 7):
                    freq[row[f'num{i}']] += 1
            sorted_nums = sorted(freq.items(), key=lambda x: (-x[1], x[0]))
            latest_ranks = {num: rank+1 for rank, (num, _) in enumerate(sorted_nums)}
            for num in range(1, 46):
                if num not in latest_ranks:
                    latest_ranks[num] = 46
        
        reverse_ranks = {rank: num for num, rank in latest_ranks.items()}
        
        # 패턴 → 번호 변환 함수
        def generate_from_pattern(rank_combo, freq_dict, prob_mode):
            selected = []
            
            # 순위 조합 → 번호
            for target_rank in rank_combo:
                if target_rank in reverse_ranks:
                    selected.append(reverse_ranks[target_rank])
            
            return selected
        
        return top_patterns, generate_from_pattern
    
    # 2026-01-08 05:45:00 EST - _calculate_frequency 삭제 (base 클래스로 이동)
    
    def calculate_cost(
        self,
        pattern_type: str,
        in_pattern_probability: str,
        range_divisions: int = 5,
        rank_combo_size: int = 3
    ) -> int:
        """파라미터 조합에 따른 비용 계산"""
        
        base_cost = 2
        
        # 역확률 사용 시 +1
        if in_pattern_probability == 'inverse':
            base_cost += 1
        
        # 복잡도에 따라 추가
        if pattern_type == 'range' and range_divisions >= 10:
            base_cost += 1
        
        if pattern_type == 'rank' and rank_combo_size >= 4:
            base_cost += 1
        
        return base_cost
    
    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터"""
        return {
            'pattern_type': 'range',
            'range_divisions': 5,
            'custom_ranges': None,
            'rank_combo_size': 3,
            'rank_mode': 'cumulative',
            'rank_window': 50,
            'analysis_window_type': 'all',
            'analysis_window_size': None,
            'top_n_patterns': 10,
            'in_pattern_probability': 'frequency',
            'pattern_selection_probability': 'normal'
        }

