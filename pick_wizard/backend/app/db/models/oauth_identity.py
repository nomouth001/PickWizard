"""
OAuth 연동 식별자 모델 (034 설계서 SSOT)

- users: "누구인가"
- oauth_identities: "어떻게 로그인했는가"
- Unique(provider, provider_user_id) 로 중복 로그인 방지
"""

from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.base import Base


class OAuthIdentity(Base):
    """OAuth 로그인 수단 (다중 OAuth/계정 연동용)"""
    __tablename__ = "oauth_identities"

    id = Column(Integer, primary_key=True, autoincrement=True)

    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="연결된 사용자 ID",
    )

    provider = Column(
        String(20),
        nullable=False,
        comment="제공자: google, apple, kakao, naver",
    )

    provider_user_id = Column(
        String(255),
        nullable=False,
        comment="제공자 측 사용자 고유 ID",
    )

    email = Column(
        String(255),
        nullable=True,
        index=True,
        comment="제공자가 준 이메일 (Apple은 최초 1회만 가능)",
    )

    email_verified = Column(
        Boolean,
        nullable=True,
        comment="이메일 검증 여부",
    )

    user = relationship("User", back_populates="oauth_identities")

    __table_args__ = (
        UniqueConstraint(
            "provider",
            "provider_user_id",
            name="uq_oauth_identities_provider_provider_user_id",
        ),
    )

    def __repr__(self) -> str:
        return f"<OAuthIdentity(provider={self.provider}, provider_user_id={self.provider_user_id[:8]}...)>"
