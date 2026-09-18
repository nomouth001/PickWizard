"""
로또 회차 관련 Pydantic 스키마

2026-01-04 EST - 초기 생성
"""

from datetime import date, datetime
from typing import List, Optional
from pydantic import BaseModel, Field


class DrawInfo(BaseModel):
    """로또 회차 정보"""
    draw_no: int = Field(..., description="회차 번호")
    draw_date: date = Field(..., description="추첨일")
    numbers: List[int] = Field(..., min_length=6, max_length=6, description="당첨번호 6개")
    bonus: int = Field(..., ge=1, le=45, description="보너스 번호")
    first_prize_amount: Optional[int] = Field(None, description="1등 당첨금 (원)")
    first_winner_count: Optional[int] = Field(None, description="1등 당첨자 수")
    created_at: Optional[datetime] = Field(None, description="데이터 생성 시각")
    
    class Config:
        json_schema_extra = {
            "example": {
                "draw_no": 1169,
                "draw_date": "2024-12-30",
                "numbers": [5, 12, 23, 31, 38, 42],
                "bonus": 7,
                "first_prize_amount": 2000000000,
                "first_winner_count": 10,
                "created_at": "2024-12-30T21:00:00"
            }
        }


class DrawListResponse(BaseModel):
    """회차 목록 응답"""
    total: int = Field(..., description="전체 회차 수")
    draws: List[DrawInfo] = Field(..., description="회차 목록")
    
    class Config:
        json_schema_extra = {
            "example": {
                "total": 1169,
                "draws": [
                    {
                        "draw_no": 1169,
                        "draw_date": "2024-12-30",
                        "numbers": [5, 12, 23, 31, 38, 42],
                        "bonus": 7
                    }
                ]
            }
        }

