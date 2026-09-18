"""
OAuth 인증 서비스 (034 설계서)

- Google/Apple/Kakao/Naver 토큰·코드 검증
- 계정 연동/생성: (provider, provider_user_id) 기준 SSOT
"""

import logging
from typing import Any, Dict, Tuple

import httpx
from sqlalchemy.orm import Session

from app.config import settings
from app.db.models.user import User, AuthProvider
from app.db.models.oauth_identity import OAuthIdentity

logger = logging.getLogger(__name__)

_PROVIDER_TO_AUTH = {
    "google": AuthProvider.GOOGLE,
    "apple": AuthProvider.APPLE,
    "kakao": AuthProvider.KAKAO,
    "naver": AuthProvider.NAVER,
}


class OAuthService:
    """OAuth 인증 통합 서비스"""

    @staticmethod
    async def verify_google_token(code: str, redirect_uri: str) -> Dict[str, Any]:
        """Google Authorization Code 검증 후 사용자 정보 반환"""
        if not settings.GOOGLE_CLIENT_ID or not settings.GOOGLE_CLIENT_SECRET:
            raise ValueError("Google OAuth 설정이 없습니다 (GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET)")
        token_url = "https://oauth2.googleapis.com/token"
        data = {
            "code": code,
            "client_id": settings.GOOGLE_CLIENT_ID,
            "client_secret": settings.GOOGLE_CLIENT_SECRET,
            "redirect_uri": redirect_uri,
            "grant_type": "authorization_code",
        }
        async with httpx.AsyncClient() as client:
            res = await client.post(token_url, data=data)
            res.raise_for_status()
            tokens = res.json()
            user_info_res = await client.get(
                "https://www.googleapis.com/oauth2/v2/userinfo",
                headers={"Authorization": f"Bearer {tokens['access_token']}"},
            )
            user_info_res.raise_for_status()
            user_info = user_info_res.json()
        return {
            "email": user_info.get("email"),
            "name": user_info.get("name", ""),
            "provider": "google",
            "provider_id": user_info["id"],
            "email_verified": user_info.get("verified_email", True),
        }

    @staticmethod
    async def verify_apple_token(*, code: str | None = None, id_token: str | None = None) -> Dict[str, Any]:
        """
        Apple Sign In 검증.
        Mobile: id_token 전송. Web: code 교환.
        최소 구현: id_token 검증 시 sub를 provider_id로 사용.
        """
        if not (id_token or code):
            raise ValueError("apple: id_token 또는 code가 필요합니다.")
        # TODO: Apple JWKs로 서명 검증, payload에서 sub/email 추출 (034 v1.2)
        # 현재는 클라이언트에서 전달한 id_token payload를 신뢰하지 않고 stub 반환 가능.
        # 실제 구현 시 PyJWT + Apple JWKS URL로 검증 후 sub 사용.
        return {
            "email": None,
            "name": "",
            "provider": "apple",
            "provider_id": "APPLE_SUB_PLACEHOLDER",
            "email_verified": None,
        }

    @staticmethod
    async def verify_kakao(access_token: str) -> Dict[str, Any]:
        """Kakao: access_token으로 user/me 조회 후 provider_id 획득"""
        if not settings.KAKAO_REST_API_KEY:
            raise ValueError("Kakao REST API 키가 없습니다")
        async with httpx.AsyncClient() as client:
            res = await client.get(
                "https://kapi.kakao.com/v2/user/me",
                headers={"Authorization": f"Bearer {access_token}"},
            )
            res.raise_for_status()
            data = res.json()
        kakao_id = str(data.get("id", ""))
        account = data.get("kakao_account", {}) or {}
        profile = account.get("profile", {}) or {}
        return {
            "email": account.get("email"),
            "name": profile.get("nickname", ""),
            "provider": "kakao",
            "provider_id": kakao_id,
            "email_verified": account.get("is_email_verified"),
        }

    @staticmethod
    async def verify_naver(access_token: str) -> Dict[str, Any]:
        """Naver: access_token으로 nid/me 조회 후 provider_id 획득"""
        async with httpx.AsyncClient() as client:
            res = await client.get(
                "https://openapi.naver.com/v1/nid/me",
                headers={"Authorization": f"Bearer {access_token}"},
            )
            res.raise_for_status()
            data = res.json()
        response = data.get("response", {}) or {}
        return {
            "email": response.get("email"),
            "name": response.get("name", ""),
            "provider": "naver",
            "provider_id": response.get("id", "NAVER_ID"),
            "email_verified": response.get("email_verified", True),
        }


def link_or_create_user_with_oauth_identity(
    db: Session,
    info: Dict[str, Any],
) -> Tuple[User, bool]:
    """
    (provider, provider_user_id)로 OAuthIdentity 조회.
    있으면 해당 User 반환, is_new=False.
    없으면 신규 User + OAuthIdentity 생성 후 반환, is_new=True.
    """
    provider = info["provider"]
    provider_id = info["provider_id"]
    identity = (
        db.query(OAuthIdentity)
        .filter(
            OAuthIdentity.provider == provider,
            OAuthIdentity.provider_user_id == provider_id,
        )
        .first()
    )
    if identity:
        return identity.user, False

    auth_provider = _PROVIDER_TO_AUTH.get(provider, AuthProvider.GUEST)
    new_user = User(
        email=info.get("email"),
        display_name=info.get("name") or None,
        auth_provider=auth_provider,
        is_guest=False,
        is_active=True,
    )
    db.add(new_user)
    db.flush()

    oauth_identity = OAuthIdentity(
        user_id=new_user.id,
        provider=provider,
        provider_user_id=provider_id,
        email=info.get("email"),
        email_verified=info.get("email_verified"),
    )
    db.add(oauth_identity)
    db.commit()
    db.refresh(new_user)
    return new_user, True
