"""
코인 관련 스키마

2026-01-08 08:05:00 EST - 초기 생성
"""

from datetime import datetime
from typing import Optional, List
from uuid import UUID

from pydantic import BaseModel, Field


class CoinBalanceResponse(BaseModel):
    """코인 잔액 응답"""
    user_id: UUID
    free_coins: int
    paid_coins: int
    total_coins: int
    total_earned: int
    total_spent: int
    
    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "free_coins": 150,
                "paid_coins": 50,
                "total_coins": 200,
                "total_earned": 300,
                "total_spent": 100
            }
        }


class DailyLoginRequest(BaseModel):
    """일일 로그인 요청"""
    user_id: UUID = Field(..., description="사용자 ID")


class DailyLoginResponse(BaseModel):
    """일일 로그인 응답"""
    success: bool
    coins_earned: int
    message: str
    new_balance: int
    consecutive_days: Optional[int] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "coins_earned": 10,
                "message": "일일 로그인 보상 10코인을 받았습니다!",
                "new_balance": 210,
                "consecutive_days": 5
            }
        }


class WatchAdRequest(BaseModel):
    """광고 시청 요청"""
    user_id: UUID = Field(..., description="사용자 ID")
    ad_id: str = Field(..., description="광고 ID")
    ad_provider: str = Field(default="admob", description="광고 제공자")


class WatchAdResponse(BaseModel):
    """광고 시청 응답"""
    success: bool
    coins_earned: int
    message: str
    new_balance: int
    remaining_ads: int
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "coins_earned": 5,
                "message": "광고 시청 보상 5코인을 받았습니다!",
                "new_balance": 215,
                "remaining_ads": 9
            }
        }


class CoinTransactionResponse(BaseModel):
    """코인 거래 내역 응답"""
    id: int
    user_id: UUID
    type: str
    amount: int
    balance_after: int
    description: Optional[str]
    metadata: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "id": 123,
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "type": "daily_login",
                "amount": 10,
                "balance_after": 210,
                "description": "일일 로그인 보상",
                "metadata": None,
                "created_at": "2026-01-08T08:00:00"
            }
        }


class CoinHistoryResponse(BaseModel):
    """코인 거래 내역 목록 응답"""
    total: int
    transactions: List[CoinTransactionResponse]
    
    class Config:
        json_schema_extra = {
            "example": {
                "total": 15,
                "transactions": []
            }
        }
