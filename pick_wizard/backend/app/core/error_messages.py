"""
에러 메시지 표준 상수

2026-01-16 EST - Phase 5: 에러 메시지 일관성

모든 에러 메시지를 한 곳에서 관리하여 일관성 유지
"""

from typing import Dict


class ErrorMessages:
    """에러 메시지 상수 클래스"""
    
    # ============================================================================
    # 인증 관련
    # ============================================================================
    AUTH_INVALID_CREDENTIALS = "아이디 또는 비밀번호가 올바르지 않습니다"
    AUTH_TOKEN_EXPIRED = "인증 토큰이 만료되었습니다"
    AUTH_TOKEN_INVALID = "유효하지 않은 인증 토큰입니다"
    AUTH_UNAUTHORIZED = "로그인이 필요한 서비스입니다"
    
    # ============================================================================
    # 사용자 관련
    # ============================================================================
    USER_NOT_FOUND = "사용자를 찾을 수 없습니다 (ID: {user_id})"
    USER_ALREADY_EXISTS = "이미 존재하는 사용자입니다 (Username: {username})"
    USER_INVALID_EMAIL = "유효하지 않은 이메일 형식입니다"
    
    # ============================================================================
    # 코인 관련
    # ============================================================================
    COIN_WALLET_NOT_FOUND = "코인 지갑을 찾을 수 없습니다 (User ID: {user_id})"
    COIN_INSUFFICIENT = "코인이 부족합니다 (필요: {required}코인, 보유: {balance}코인)"
    COIN_DEDUCTION_FAILED = "코인 차감에 실패했습니다"
    COIN_INVALID_AMOUNT = "유효하지 않은 코인 금액입니다 (Amount: {amount})"
    
    # ============================================================================
    # 알고리즘 관련
    # ============================================================================
    ALGORITHM_NOT_FOUND = "알고리즘을 찾을 수 없습니다 (ID: {algorithm_id})"
    ALGORITHM_INVALID_PARAM = "잘못된 알고리즘 파라미터입니다: {param_name}={value}"
    ALGORITHM_GENERATION_FAILED = "번호 생성에 실패했습니다: {reason}"
    
    # ============================================================================
    # 번호 생성 관련
    # ============================================================================
    GENERATION_INVALID_N_SETS = "세트 수는 1~100 사이여야 합니다 (입력: {n_sets})"
    GENERATION_INVALID_EXCLUDE = "제외 번호는 최대 39개까지 가능합니다 (입력: {count}개)"
    GENERATION_INVALID_INCLUDE = "포함 번호는 최대 6개까지 가능합니다 (입력: {count}개)"
    GENERATION_INVALID_NUMBER_RANGE = "번호는 1~45 사이여야 합니다 (입력: {number})"
    GENERATION_OVERLAPPING_NUMBERS = "제외 번호와 포함 번호가 중복됩니다: {numbers}"
    
    # ============================================================================
    # 내 번호 관련
    # ============================================================================
    MY_NUMBERS_NOT_FOUND = "저장된 번호를 찾을 수 없습니다 (ID: {number_id})"
    MY_NUMBERS_INVALID_FORMAT = "유효하지 않은 번호 형식입니다"
    MY_NUMBERS_LIMIT_EXCEEDED = "최대 {limit}개까지 저장 가능합니다"
    
    # ============================================================================
    # 당첨 확인 관련
    # ============================================================================
    WINNING_CHECK_NO_DRAW = "확인 가능한 당첨 회차가 없습니다"
    WINNING_CHECK_INVALID_DRAW = "유효하지 않은 회차 번호입니다 (Draw No: {draw_no})"
    WINNING_CHECK_FAILED = "당첨 확인에 실패했습니다: {reason}"
    
    # ============================================================================
    # 데이터 관련
    # ============================================================================
    DATA_NOT_FOUND = "데이터를 찾을 수 없습니다"
    DATA_FETCH_FAILED = "데이터 조회에 실패했습니다: {reason}"
    DATA_SAVE_FAILED = "데이터 저장에 실패했습니다: {reason}"
    DATA_UPDATE_FAILED = "데이터 업데이트에 실패했습니다: {reason}"
    DATA_DELETE_FAILED = "데이터 삭제에 실패했습니다: {reason}"
    
    # ============================================================================
    # 서버 오류
    # ============================================================================
    SERVER_ERROR = "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요"
    SERVER_DATABASE_ERROR = "데이터베이스 오류가 발생했습니다"
    SERVER_EXTERNAL_API_ERROR = "외부 API 호출에 실패했습니다: {api_name}"
    
    # ============================================================================
    # 유효성 검증
    # ============================================================================
    VALIDATION_REQUIRED_FIELD = "필수 항목입니다: {field_name}"
    VALIDATION_INVALID_TYPE = "유효하지 않은 타입입니다: {field_name} (기대: {expected}, 입력: {actual})"
    VALIDATION_OUT_OF_RANGE = "범위를 벗어났습니다: {field_name} ({min}~{max})"
    
    @classmethod
    def format(cls, message: str, **kwargs) -> str:
        """
        에러 메시지 포맷팅
        
        Args:
            message: 에러 메시지 템플릿
            **kwargs: 포맷팅 파라미터
        
        Returns:
            포맷팅된 에러 메시지
        
        Example:
            >>> ErrorMessages.format(
            ...     ErrorMessages.COIN_INSUFFICIENT,
            ...     required=5, balance=3
            ... )
            '코인이 부족합니다 (필요: 5코인, 보유: 3코인)'
        """
        try:
            return message.format(**kwargs)
        except KeyError as e:
            return f"{message} (포맷 오류: {e})"


# Flutter용 에러 코드 매핑
ERROR_CODES: Dict[str, str] = {
    # 인증
    "AUTH_001": ErrorMessages.AUTH_INVALID_CREDENTIALS,
    "AUTH_002": ErrorMessages.AUTH_TOKEN_EXPIRED,
    "AUTH_003": ErrorMessages.AUTH_TOKEN_INVALID,
    "AUTH_004": ErrorMessages.AUTH_UNAUTHORIZED,
    
    # 사용자
    "USER_001": ErrorMessages.USER_NOT_FOUND,
    "USER_002": ErrorMessages.USER_ALREADY_EXISTS,
    
    # 코인
    "COIN_001": ErrorMessages.COIN_WALLET_NOT_FOUND,
    "COIN_002": ErrorMessages.COIN_INSUFFICIENT,
    "COIN_003": ErrorMessages.COIN_DEDUCTION_FAILED,
    
    # 알고리즘
    "ALGO_001": ErrorMessages.ALGORITHM_NOT_FOUND,
    "ALGO_002": ErrorMessages.ALGORITHM_INVALID_PARAM,
    "ALGO_003": ErrorMessages.ALGORITHM_GENERATION_FAILED,
    
    # 번호 생성
    "GEN_001": ErrorMessages.GENERATION_INVALID_N_SETS,
    "GEN_002": ErrorMessages.GENERATION_INVALID_EXCLUDE,
    "GEN_003": ErrorMessages.GENERATION_INVALID_INCLUDE,
    "GEN_004": ErrorMessages.GENERATION_INVALID_NUMBER_RANGE,
    
    # 서버
    "SRV_001": ErrorMessages.SERVER_ERROR,
    "SRV_002": ErrorMessages.SERVER_DATABASE_ERROR,
}


def get_error_message(error_code: str, **kwargs) -> str:
    """
    에러 코드로 메시지 조회
    
    Args:
        error_code: 에러 코드 (예: "COIN_002")
        **kwargs: 포맷팅 파라미터
    
    Returns:
        포맷팅된 에러 메시지
    
    Example:
        >>> get_error_message("COIN_002", required=5, balance=3)
        '코인이 부족합니다 (필요: 5코인, 보유: 3코인)'
    """
    message_template = ERROR_CODES.get(error_code, ErrorMessages.SERVER_ERROR)
    return ErrorMessages.format(message_template, **kwargs)
