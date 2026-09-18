"""
번호 생성 관련 Pydantic 스키마

2026-01-04 EST - 초기 생성
2026-01-08 08:20:00 EST - user_id 필드 추가
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID
from pydantic import BaseModel, Field


class GenerateRequest(BaseModel):
    """번호 생성 요청"""
    user_id: Optional[UUID] = Field(None, description="사용자 ID (코인 차감용)")
    algorithm_id: int = Field(..., ge=1, le=9, description="알고리즘 ID (1~9)")
    n_sets: int = Field(5, ge=1, le=100, description="생성할 세트 수 (1~100)")
    exclude_numbers: Optional[List[int]] = Field(None, description="제외할 번호 리스트")
    include_numbers: Optional[List[int]] = Field(None, description="반드시 포함할 번호 리스트")
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "algorithm_id": 1,
                "n_sets": 5,
                "exclude_numbers": [1, 2, 3],
                "include_numbers": [7, 14]
            }
        }


class NumberSet(BaseModel):
    """생성된 번호 세트"""
    set_no: int = Field(..., description="세트 번호")
    numbers: List[int] = Field(..., description="로또 번호 6개")
    
    class Config:
        json_schema_extra = {
            "example": {
                "set_no": 1,
                "numbers": [5, 12, 23, 31, 38, 42]
            }
        }


class GenerateResponse(BaseModel):
    """번호 생성 응답"""
    algorithm_id: int = Field(..., description="사용된 알고리즘 ID")
    algorithm_name: str = Field(..., description="알고리즘 이름")
    results: List[NumberSet] = Field(..., description="생성된 번호 세트 리스트")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="생성 시각")
    cost: int = Field(..., description="소모된 코인")
    
    class Config:
        json_schema_extra = {
            "example": {
                "algorithm_id": 1,
                "algorithm_name": "순수 랜덤",
                "results": [
                    {"set_no": 1, "numbers": [5, 12, 23, 31, 38, 42]},
                    {"set_no": 2, "numbers": [1, 7, 14, 21, 28, 35]}
                ],
                "timestamp": "2024-01-04T12:00:00",
                "cost": 0
            }
        }

