"""
API 의존성 (034 설계서)

- get_current_user: JWT 파싱 후 User 반환. 인증 필요 API 진입점.
"""

from datetime import datetime, timedelta
from typing import Annotated
from uuid import UUID

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.config import settings
from app.db.session import get_db
from app.db.models.user import User

security = HTTPBearer(auto_error=False)


def create_jwt_token(user_id: UUID) -> str:
    """Phase 1: Access JWT 단일 토큰 발급 (만료 7일)."""
    expire_days = getattr(settings, "ACCESS_TOKEN_EXPIRE_DAYS", 7)
    expire_minutes = expire_days * 24 * 60
    expire = datetime.utcnow() + timedelta(minutes=expire_minutes)
    payload = {"sub": str(user_id), "exp": expire, "type": "access"}
    return jwt.encode(
        payload,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(security)],
    db: Session = Depends(get_db),
) -> User:
    """JWT Bearer에서 user_id 추출 후 DB 조회하여 User 반환. 401 없으면 예외."""
    if not credentials or not credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="인증이 필요합니다",
            headers={"WWW-Authenticate": "Bearer"},
        )
    token = credentials.credentials
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
        )
        sub = payload.get("sub")
        if not sub:
            raise HTTPException(status_code=401, detail="잘못된 토큰입니다")
        user_id = UUID(sub)
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="토큰이 만료되었습니다")
    except (jwt.InvalidTokenError, ValueError) as e:
        raise HTTPException(status_code=401, detail="유효하지 않은 토큰입니다")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=401, detail="사용자를 찾을 수 없습니다")
    if not user.is_active:
        raise HTTPException(status_code=401, detail="비활성화된 계정입니다")
    return user
