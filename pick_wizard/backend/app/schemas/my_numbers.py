"""
내 번호 관련 스키마

2026-01-16 04:20:00 EST - 초기 생성
"""

from datetime import datetime
from typing import Optional, List
from uuid import UUID

from pydantic import BaseModel, Field


class SaveNumberRequest(BaseModel):
    """번호 저장 요청"""
    user_id: UUID = Field(..., description="사용자 ID")
    numbers: List[int] = Field(..., description="번호 6개", min_length=6, max_length=6)
    algorithm_id: Optional[int] = Field(None, description="생성 알고리즘 ID")
    algorithm_name: Optional[str] = Field(None, description="알고리즘 이름")
    memo: Optional[str] = Field(None, description="메모", max_length=255)
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "numbers": [1, 7, 14, 21, 28, 35],
                "algorithm_id": 2,
                "algorithm_name": "고급 빈도 분석",
                "memo": "이번 주 번호"
            }
        }


class SaveNumberResponse(BaseModel):
    """번호 저장 응답"""
    id: int
    user_id: UUID
    numbers: List[int]
    algorithm_id: Optional[int]
    algorithm_name: Optional[str]
    memo: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True


class UserNumberResponse(BaseModel):
    """사용자 번호 응답"""
    id: int
    user_id: UUID
    numbers: List[int]
    algorithm_id: Optional[int]
    algorithm_name: Optional[str]
    memo: Optional[str]
    is_checked: bool
    checked_draw_no: Optional[int]
    winning_rank: Optional[str]
    matched_count: int
    created_at: datetime
    
    class Config:
        from_attributes = True


class CheckWinningRequest(BaseModel):
    """당첨 확인 요청"""
    user_id: UUID = Field(..., description="사용자 ID")
    draw_no: int = Field(..., description="확인할 회차")
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "draw_no": 1206
            }
        }


class WinningCheckDetail(BaseModel):
    """개별 번호 당첨 확인 결과"""
    number_id: int
    numbers: List[int]
    memo: Optional[str]
    matched_count: int
    has_bonus: bool
    winning_rank: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "number_id": 1,
                "numbers": [1, 7, 14, 21, 28, 35],
                "memo": "이번 주 번호",
                "matched_count": 3,
                "has_bonus": False,
                "winning_rank": "5등"
            }
        }


class CheckWinningResponse(BaseModel):
    """당첨 확인 응답"""
    draw_no: int
    winning_numbers: List[int]
    bonus_number: int
    total_checked: int
    results: List[WinningCheckDetail]
    
    class Config:
        json_schema_extra = {
            "example": {
                "draw_no": 1206,
                "winning_numbers": [1, 3, 17, 26, 27, 42],
                "bonus_number": 23,
                "total_checked": 2,
                "results": []
            }
        }


class MyNumbersListResponse(BaseModel):
    """내 번호 목록 응답"""
    total: int
    numbers: List[UserNumberResponse]
    
    class Config:
        json_schema_extra = {
            "example": {
                "total": 5,
                "numbers": []
            }
        }
