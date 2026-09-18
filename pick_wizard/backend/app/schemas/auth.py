"""
인증 관련 스키마

2026-01-08 08:05:00 EST - 초기 생성
"""

from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field


class GuestCreateRequest(BaseModel):
    """게스트 생성 요청"""
    device_id: str = Field(..., description="디바이스 ID")
    user_id: Optional[UUID] = Field(None, description="기존 사용자 ID (재로그인)")
    fcm_token: Optional[str] = Field(None, description="FCM 토큰")
    
    class Config:
        json_schema_extra = {
            "example": {
                "device_id": "android-abc123",
                "user_id": None,
                "fcm_token": "fcm_token_here"
            }
        }


class GuestCreateResponse(BaseModel):
    """게스트 생성 응답"""
    user_id: UUID
    device_id: str
    is_new_user: bool
    welcome_bonus: int
    total_coins: int
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "device_id": "android-abc123",
                "is_new_user": True,
                "welcome_bonus": 100,
                "total_coins": 100
            }
        }


class LoginRequest(BaseModel):
    """034 OAuth 로그인 요청"""
    provider: str = Field(..., description="google | apple | kakao | naver")
    code: Optional[str] = Field(None, description="Authorization code (Google/Apple)")
    id_token: Optional[str] = Field(None, description="Apple ID Token (모바일)")
    access_token: Optional[str] = Field(None, description="Kakao/Naver access_token")
    redirect_uri: Optional[str] = Field(None, description="Google redirect_uri (code 사용 시)")


class LoginResponse(BaseModel):
    """034 OAuth 로그인 응답"""
    access_token: str
    token_type: str = "bearer"
    user_id: UUID
    email: Optional[str] = None
    display_name: Optional[str] = None
    is_new_user: bool = False


class UserResponse(BaseModel):
    """사용자 정보 응답"""
    user_id: UUID
    device_id: Optional[str]
    email: Optional[str]
    is_guest: bool
    is_active: bool
    auth_provider: str
    total_coins: int
    free_coins: int
    paid_coins: int
    created_at: datetime
    
    class Config:
        from_attributes = True
        json_schema_extra = {
            "example": {
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "device_id": "android-abc123",
                "email": None,
                "is_guest": True,
                "is_active": True,
                "auth_provider": "guest",
                "total_coins": 150,
                "free_coins": 150,
                "paid_coins": 0,
                "created_at": "2026-01-08T08:00:00"
            }
        }
