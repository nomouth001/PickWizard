"""
알고리즘 베이스 클래스

모든 로또 번호 생성 알고리즘의 추상 클래스

2026-01-04 EST - 초기 생성
2026-01-08 05:30:00 EST - 공통 헬퍼 메서드 추가 (DRY 원칙 적용)
2026-01-08 06:40:00 EST - 매직 넘버 상수화 (constants.py 사용)
"""

import random
from abc import ABC, abstractmethod
from typing import List, Dict, Optional, Any
from collections import Counter

import pandas as pd

# 2026-01-08 06:40:00 EST - 공통 상수 import
from app.algorithms.constants import (
    LOTTO_MIN_NUMBER,
    LOTTO_MAX_NUMBER,
    LOTTO_NUMBERS_PER_DRAW,
    MAX_EXCLUDE_NUMBERS,
    MAX_INCLUDE_NUMBERS,
    MIN_SETS,
    MAX_SETS,
)


class LottoAlgorithm(ABC):
    """
    로또 알고리즘 추상 베이스 클래스
    
    모든 알고리즘은 이 클래스를 상속받아 구현
    
    2026-01-08 05:30:00 EST - 공통 헬퍼 메서드 추가:
    - calculate_frequency: 빈도 계산
    - generate_random_sets: 랜덤 번호 생성 (fallback)
    - apply_temperature: 온도 파라미터 적용
    - apply_recent_draw_penalty: 직전 회차 페널티
    """
    
    def __init__(
        self,
        algorithm_id: int,
        name: str,
        description: str,
        cost_per_set: int = 0  # 2026-01-18 20:30:00 EST - 기본값 0 (실제 가격은 pricing_config.yaml에서 로드)
    ):
        """
        Args:
            algorithm_id: 알고리즘 ID (1~9)
            name: 알고리즘 이름
            description: 설명
            cost_per_set: 세트당 코인 비용 (기본값 0, pricing_config.yaml에서 오버라이드됨)
        """
        self.algorithm_id = algorithm_id
        self.name = name
        self.description = description
        self.cost_per_set = cost_per_set  # API에서 pricing_service로 덮어씀
        self.version = "1.0"
    
    @abstractmethod
    def generate_numbers(
        self,
        historical_data: Optional[pd.DataFrame],
        n_sets: int = 5,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None,
        **kwargs
    ) -> List[List[int]]:
        """
        번호 생성 (추상 메서드)
        
        Args:
            historical_data: 과거 당첨번호 DataFrame
            n_sets: 생성할 세트 수 (기본 5)
            exclude_numbers: 제외할 번호 리스트
            include_numbers: 반드시 포함할 번호 리스트
            **kwargs: 알고리즘별 추가 파라미터
            
        Returns:
            List[List[int]]: 생성된 번호 세트 리스트
        """
        pass
    
    def validate_parameters(
        self,
        n_sets: int,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None
    ) -> tuple[bool, Optional[str]]:
        """
        파라미터 검증
        
        2026-01-08 06:40:00 EST - 매직 넘버를 상수로 변경
        2026-01-18 21:30:00 EST - validation.py의 validate_parameters 사용 (DRY 원칙)
        
        Returns:
            (유효 여부, 오류 메시지)
        """
        # 2026-01-18 21:30:00 EST - validation.py의 공통 검증 로직 사용
        from app.algorithms import validation
        return validation.validate_parameters(n_sets, exclude_numbers, include_numbers)
    
    def get_available_numbers(
        self,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None
    ) -> List[int]:
        """
        사용 가능한 번호 리스트 반환
        
        2026-01-08 06:40:00 EST - 매직 넘버를 상수로 변경
        """
        all_numbers = set(range(LOTTO_MIN_NUMBER, LOTTO_MAX_NUMBER + 1))
        
        if exclude_numbers:
            all_numbers -= set(exclude_numbers)
        
        if include_numbers:
            all_numbers -= set(include_numbers)
        
        return sorted(list(all_numbers))
    
    def get_info(self) -> Dict[str, Any]:
        """알고리즘 정보 반환"""
        return {
            'id': self.algorithm_id,
            'name': self.name,
            'description': self.description,
            'version': self.version,
            'cost_per_set': self.cost_per_set,
            'parameters': self.get_default_parameters()
        }
    
    @abstractmethod
    def get_default_parameters(self) -> Dict[str, Any]:
        """기본 파라미터 반환"""
        pass
    
    def __str__(self) -> str:
        return f"Algorithm {self.algorithm_id}: {self.name}"
    
    def __repr__(self) -> str:
        return f"<{self.__class__.__name__}(id={self.algorithm_id}, name='{self.name}')>"
    
    # ========================================
    # 공통 헬퍼 메서드
    # 2026-01-08 05:30:00 EST - DRY 원칙 적용
    # 2026-01-16 EST - Phase 1 리팩토링: utils.py로 위임
    # ========================================
    
    def calculate_frequency(
        self,
        data: pd.DataFrame,
        include_zero_freq: bool = True
    ) -> Dict[int, int]:
        """
        번호별 출현 빈도 계산 (공통 헬퍼 메서드)
        
        알고리즘 2, 4, 6에서 중복 제거
        
        2026-01-08 06:40:00 EST - 매직 넘버를 상수로 변경
        2026-01-16 EST - utils.calculate_frequency()로 위임 (중복 제거)
        
        Args:
            data: 과거 당첨번호 DataFrame
            include_zero_freq: 0회 출현 번호도 포함 여부 (기본 True)
        
        Returns:
            Dict[int, int]: {번호: 출현 횟수}
        
        Example:
            >>> frequency = self.calculate_frequency(historical_data)
            >>> print(frequency[12])  # 12번 출현 횟수
            45
        """
        from app.algorithms import utils
        return utils.calculate_frequency(data, include_zero_freq)
    
    def generate_random_sets(
        self,
        n_sets: int,
        exclude_numbers: Optional[List[int]] = None,
        include_numbers: Optional[List[int]] = None
    ) -> List[List[int]]:
        """
        순수 랜덤 번호 생성 (공통 fallback 메서드)
        
        알고리즘 2, 5, 6, 7에서 중복 제거
        과거 데이터 없을 때 모든 알고리즘이 사용
        
        2026-01-08 06:40:00 EST - 매직 넘버를 상수로 변경
        2026-01-16 EST - sampling.generate_random_sets()로 위임 (중복 제거)
        
        Args:
            n_sets: 생성할 세트 수
            exclude_numbers: 제외할 번호 리스트
            include_numbers: 반드시 포함할 번호 리스트
        
        Returns:
            List[List[int]]: 생성된 번호 세트 리스트
        
        Example:
            >>> if historical_data is None:
            ...     return self.generate_random_sets(5, exclude, include)
        """
        from app.algorithms import sampling
        available_numbers = self.get_available_numbers(
            exclude_numbers, include_numbers
        )
        return sampling.generate_random_sets(n_sets, available_numbers, include_numbers)
    
    @staticmethod
    def apply_temperature(
        probabilities: Dict[int, float],
        temperature: float
    ) -> Dict[int, float]:
        """
        확률 분포에 온도 파라미터 적용 (공통 유틸리티)
        
        알고리즘 2, 3에서 중복 제거
        
        2026-01-16 EST - utils.apply_temperature()로 위임 (중복 제거)
        
        Args:
            probabilities: 원본 확률 분포 {번호: 확률}
            temperature: 온도 파라미터 (0.1~3.0)
                - < 1.0: 확률 차이 극대화 (날카로운 분포)
                - = 1.0: 원본 유지 (변경 없음)
                - > 1.0: 확률 차이 완화 (평탄한 분포)
        
        Returns:
            Dict[int, float]: 조정된 확률 분포
        
        Example:
            >>> probs = {1: 0.1, 2: 0.2, 3: 0.7}
            >>> adjusted = LottoAlgorithm.apply_temperature(probs, 0.5)
            >>> # 0.7 확률이 더 강조됨
        
        References:
            - Softmax temperature scaling
            - 010.1_Algorithm_Redesign.md 섹션 D
        """
        from app.algorithms import utils
        return utils.apply_temperature(probabilities, temperature)
    
    @staticmethod
    def apply_recent_draw_penalty(
        probabilities: Dict[int, float],
        historical_data: pd.DataFrame,
        penalty_rate: float
    ) -> Dict[int, float]:
        """
        직전 회차 출현 번호 확률 할인 (공통 유틸리티)
        
        알고리즘 2, 3에서 중복 제거
        
        2026-01-16 EST - utils.apply_recent_draw_penalty()로 위임 (중복 제거)
        
        Args:
            probabilities: 원본 확률 분포 {번호: 확률}
            historical_data: 과거 당첨번호 DataFrame
            penalty_rate: 할인율 (0.1~1.0)
                - 0.5: 확률을 절반으로 (50% 할인)
                - 0.33: 확률을 1/3로 (66% 할인)
        
        Returns:
            Dict[int, float]: 조정된 확률 분포
        
        Example:
            >>> # 직전 회차: [5, 12, 23, 31, 38, 42]
            >>> probs = {5: 0.02, 12: 0.022, ...}
            >>> adjusted = LottoAlgorithm.apply_recent_draw_penalty(
            ...     probs, historical_data, penalty_rate=0.5
            ... )
            >>> # 5번, 12번 등의 확률이 절반으로 감소
        
        References:
            - 010.1_Algorithm_Redesign.md 섹션 B-3
        """
        from app.algorithms import utils
        return utils.apply_recent_draw_penalty(probabilities, historical_data, penalty_rate)

