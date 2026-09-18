"""
입력 검증 유틸리티

2026-01-08 06:50:00 EST - 초기 생성
2026-01-18 21:30:00 EST - SSOT로 확립 (공통 검증 로직 통합)
"""

from typing import List, Optional
from app.algorithms.constants import (
    LOTTO_MIN_NUMBER,
    LOTTO_MAX_NUMBER,
    LOTTO_NUMBERS_PER_DRAW,
    MAX_EXCLUDE_NUMBERS,
    MAX_INCLUDE_NUMBERS,
    MIN_SETS,
    MAX_SETS,
)
from app.algorithms.types import ValidationResult


def validate_n_sets(n_sets: int) -> ValidationResult:
    """
    세트 수 검증
    
    2026-01-18 21:30:00 EST - 공통 검증 로직 (SSOT)
    """
    if not isinstance(n_sets, int):
        return False, "세트 수는 정수여야 합니다"
    
    if n_sets < MIN_SETS or n_sets > MAX_SETS:
        return False, f"세트 수는 {MIN_SETS}~{MAX_SETS} 사이여야 합니다"
    
    return True, None


def validate_numbers(
    numbers: List[int],
    name: str = "번호"
) -> ValidationResult:
    """번호 리스트 검증"""
    if not isinstance(numbers, list):
        return False, f"{name}는 리스트여야 합니다"
    
    for num in numbers:
        if not isinstance(num, int):
            return False, f"{name}는 정수여야 합니다: {num}"
        
        if not LOTTO_MIN_NUMBER <= num <= LOTTO_MAX_NUMBER:
            return False, f"{name}는 {LOTTO_MIN_NUMBER}~{LOTTO_MAX_NUMBER} 사이여야 합니다: {num}"
    
    if len(numbers) != len(set(numbers)):
        return False, f"{name}에 중복이 있습니다"
    
    return True, None


def validate_exclude_numbers(
    exclude_numbers: Optional[List[int]]
) -> ValidationResult:
    """제외 번호 검증"""
    if exclude_numbers is None:
        return True, None
    
    if len(exclude_numbers) > MAX_EXCLUDE_NUMBERS:
        return False, f"제외 번호는 최대 {MAX_EXCLUDE_NUMBERS}개까지 가능합니다"
    
    return validate_numbers(exclude_numbers, "제외 번호")


def validate_include_numbers(
    include_numbers: Optional[List[int]]
) -> ValidationResult:
    """포함 번호 검증"""
    if include_numbers is None:
        return True, None
    
    if len(include_numbers) > MAX_INCLUDE_NUMBERS:
        return False, f"포함 번호는 최대 {MAX_INCLUDE_NUMBERS}개까지 가능합니다"
    
    return validate_numbers(include_numbers, "포함 번호")


def validate_parameters(
    n_sets: int,
    exclude_numbers: Optional[List[int]] = None,
    include_numbers: Optional[List[int]] = None
) -> ValidationResult:
    """
    전체 파라미터 검증 (SSOT)
    
    2026-01-18 21:30:00 EST - base.py 및 모든 알고리즘에서 사용하는 공통 검증
    
    Returns:
        (유효 여부, 오류 메시지)
    """
    # 세트 수
    valid, error_msg = validate_n_sets(n_sets)
    if not valid:
        return False, error_msg
    
    # 제외 번호
    valid, error_msg = validate_exclude_numbers(exclude_numbers)
    if not valid:
        return False, error_msg
    
    # 포함 번호
    valid, error_msg = validate_include_numbers(include_numbers)
    if not valid:
        return False, error_msg
    
    # 겹침 확인
    if exclude_numbers and include_numbers:
        overlap = set(exclude_numbers) & set(include_numbers)
        if overlap:
            return False, f"제외/포함 번호가 겹칩니다: {overlap}"
    
    # 사용 가능한 번호 충분한지 확인
    excluded_count = len(exclude_numbers) if exclude_numbers else 0
    included_count = len(include_numbers) if include_numbers else 0
    available_count = (LOTTO_MAX_NUMBER - LOTTO_MIN_NUMBER + 1) - excluded_count
    required_count = LOTTO_NUMBERS_PER_DRAW - included_count
    
    if available_count < required_count:
        return False, "사용 가능한 번호가 부족합니다"
    
    return True, None

