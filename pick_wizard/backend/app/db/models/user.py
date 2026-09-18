"""
사용자 모델

2026-01-04 EST - 초기 생성 (게스트 모드)
"""

from enum import Enum
from uuid import uuid4

from sqlalchemy import Column, String, Boolean, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.base import Base


class AuthProvider(str, Enum):
    """인증 제공자"""
    GUEST = "guest"
    GOOGLE = "google"
    APPLE = "apple"
    KAKAO = "kakao"
    NAVER = "naver"


class User(Base):
    """
    사용자 계정 (게스트/정식)
    """
    __tablename__ = "users"
    
    # === 기본 정보 ===
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
        comment="사용자 ID (UUID)"
    )
    
    device_id = Column(
        String(255),
        unique=True,
        nullable=True,
        comment="디바이스 ID (게스트 식별용)"
    )
    
    # === 인증 정보 ===
    auth_provider = Column(
        SQLEnum(AuthProvider),
        nullable=False,
        default=AuthProvider.GUEST,
        comment="인증 제공자"
    )
    
    social_id = Column(
        String(255),
        nullable=True,
        comment="소셜 로그인 ID"
    )
    
    email = Column(
        String(255),
        unique=True,
        nullable=True,
        comment="이메일"
    )

    display_name = Column(
        String(100),
        nullable=True,
        comment="표시 이름 (034 OAuth 설계)"
    )
    
    # === 상태 ===
    is_active = Column(
        Boolean,
        default=True,
        nullable=False,
        comment="활성 여부"
    )
    
    is_guest = Column(
        Boolean,
        default=True,
        nullable=False,
        comment="게스트 여부"
    )
    
    # === FCM 토큰 (Push 알림) ===
    fcm_token = Column(
        String(255),
        nullable=True,
        comment="Firebase Cloud Messaging 토큰"
    )
    
    # === 관계 ===
    # 2026-01-08 08:00:00 EST - wallet 관계 추가
    wallet = relationship("CoinWallet", back_populates="user", uselist=False, cascade="all, delete-orphan")
    # 034 OAuth - 다중 로그인 수단
    oauth_identities = relationship(
        "OAuthIdentity",
        back_populates="user",
        cascade="all, delete-orphan",
    )
    
    def __repr__(self) -> str:
        user_type = "Guest" if self.is_guest else "User"
        return f"<User({user_type}, id={self.id}, email={self.email})>"

