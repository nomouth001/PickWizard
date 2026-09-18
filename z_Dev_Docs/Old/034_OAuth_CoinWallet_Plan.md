# 034. OAuth 계정 연동 및 코인지갑 관리 시스템

**작성일**: 2026-01-19  
**수정일**: 2026-02-13  
**버전**: 1.2 (Reviewed & Ready)  
**대상**: LuckyAI 645 Flutter 앱 + FastAPI 백엔드  
**목표**: Google, Apple ID, Kakao, Naver 소셜 로그인 및 코인지갑 통합

---

## ✅ 리뷰 요약 (완성도 100점 기준 반영)

### 결정 사항(SSOT/DRY/KISS)
- **계정 모델**: `users`(사용자)와 `oauth_identities`(로그인 수단)를 분리한다. (다중 OAuth/연동 대비)
- **토큰**: Phase 1은 **Access JWT 단일 토큰(만료 포함)**로 단순화하고, 필요 시 Phase 2에서 Refresh Token 회전으로 확장한다.
- **코인지갑 SSOT**: 코인 잔액의 진실은 **`coin_transactions` 원장(ledger)**이다. 필요 시 `user_coin_balances`는 **캐시(파생 데이터)**로만 둔다.
- **중복 방지(Idempotency)**: 코인 지급/차감은 항상 `reference_type + reference_id` 유니크 제약으로 중복을 막는다.

### 변경 이력
- v1.2: 계정연동/데이터모델/토큰정책/보안·테스트·관측/원칙검증 체크리스트 보강 (2026-02-13)

## 📋 목차

1. [개요](#1-개요)
2. [시스템 아키텍처](#2-시스템-아키텍처)
3. [OAuth 제공자 설정](#3-oauth-제공자-설정)
4. [백엔드 구현](#4-백엔드-구현)
5. [프론트엔드 구현](#5-프론트엔드-구현)
6. [코인지갑 관리](#6-코인지갑-관리)
7. [운영/보안/테스트](#7-운영보안테스트)
8. [구현 체크리스트](#8-구현-체크리스트)
9. [원칙 검증 (중복방지/리팩토링/DRY/SSOT/KISS)](#9-원칙-검증-중복방지리팩토링dryssotkiss)

---

## 1. 개요

### 1.1 배경

**현재 상태**:
- ✅ 백엔드 코인 시스템 구현 완료
- ✅ IAP 결제 시스템 계획 완료 (035번 문서)
- 🔄 사용자 인증 시스템 미구현
- 🔄 코인 잔액 조회 UI 미구현

**요구사항**:
- 소셜 로그인으로 사용자 식별
- 계정별 코인 잔액 관리
- 코인 사용 내역 조회
- 로그아웃 시에도 코인 보존

### 1.2 범위 / 비범위 (KISS)
- **범위**
  - Google/Apple/Kakao/Naver 로그인
  - 서버 발급 JWT 기반 인증(`get_current_user`)
  - 코인지갑(잔액/원장) 조회 API
  - 계정 연동(동일 사용자에 다중 OAuth 연결)
- **비범위(추후)**
  - Refresh Token 회전/세션 강제 만료(Phase 2)
  - 관리자 패널/CS 환불 처리(별도 문서)
  - 기기 간 동시 로그인 제한(정책 결정 필요 시 추가)

### 1.3 지원할 OAuth 제공자

| 제공자 | 우선순위 | 이유 |
|--------|---------|------|
| **Google** | ⭐⭐⭐ 필수 | Play Store 필수, 가장 보편적 |
| **Apple ID** | ⭐⭐ 높음 | iOS 출시 시 필수 |
| **Kakao** | ⭐⭐ 높음 | 한국 사용자 선호 |
| **Naver** | ⭐ 중간 | 한국 사용자 일부 선호 |

---

## 2. 시스템 아키텍처

### 2.1 인증 플로우 (KISS 준수)

```
[사용자]
   ↓ 1. "Google로 로그인" 클릭
[Flutter 앱]
   ↓ 2. OAuth 요청 (Google SDK)
[Google OAuth]
   ↓ 3. 사용자 인증 및 권한 승인
   ↓ 4. Authorization Code (또는 ID Token) 반환
[Flutter 앱]
   ↓ 5. Code/Token을 백엔드로 전송 (/api/auth/login)
[FastAPI 백엔드]
   ↓ 6. Provider 검증 (Google/Apple/Kakao/Naver)
   ↓ 7. 사용자 식별 및 연동 (oauth_identities ↔ users)
   ↓ 8. DB 조회/생성 (users + oauth_identities)
   ↓ 9. JWT Access Token 발급
[Flutter 앱]
   ↓ 10. JWT 저장 (Secure Storage)
```

### 2.2 코인지갑 구조 (SSOT)

- **SSOT(진실의 원천)**: `coin_transactions`(원장, 불변 로그)
- **파생 데이터(옵션)**: `user_coin_balances`(집계/캐시, 재생성 가능)
- **User**: 사용자(사람) 단위 엔티티 (`users`)
- **OAuthIdentity**: 로그인 수단 단위 엔티티 (`oauth_identities`)
- **분리 원칙**: `users`는 "누구인가", `oauth_identities`는 "어떻게 로그인했는가", `coin_transactions`는 "얼마가 변했는가"만 담당.

### 2.3 데이터 모델(권장 스키마; SSOT/중복방지)

#### `users`
- `id` (PK, UUID/INT)
- `email` (nullable; 제공자에 따라 미제공 가능 대비)
- `display_name`
- `created_at`, `updated_at`

#### `oauth_identities` (다중 OAuth/계정연동의 핵심)
- `id` (PK)
- `user_id` (FK → `users.id`)
- `provider` (enum/string: google/apple/kakao/naver)
- `provider_user_id` (string; 각 제공자 고유 식별자)
- `email` (nullable; 제공자가 준 경우만 저장)
- `email_verified` (bool/nullable)
- `created_at`
- **Unique**: `(provider, provider_user_id)`  ← 중복 로그인 방지
- **Index**: `user_id`, `email` (연동/조회 최적화)

#### `coin_transactions` (원장, 불변)
- `id` (PK)
- `user_id` (FK)
- `delta` (int; +지급 / -차감)
- `reason` (string)
- `reference_type` (string: iap/order, ads/ssv, admin, bonus, etc.)
- `reference_id` (string; order_id, transaction_id 등)
- `created_at`
- **Unique**: `(reference_type, reference_id)`  ← Idempotency 핵심
- **Check**: `delta != 0`

---

## 3. OAuth 제공자 설정

### 3.1 Google OAuth
- **Client ID**: GCP Console > API 및 서비스 > 사용자 인증 정보
- **Redirect URI**: `https://your-backend-url/api/auth/google/callback`

### 3.2 Apple Sign In
- **Service ID**: Apple Developer > Identifiers > Services IDs
- **Key**: Sign in with Apple Key (.p8)
- **설정**: Return URLs 등록 필수

### 3.3 Kakao/Naver
- **Kakao**: Kakao Developers > 플랫폼 > Android 키 해시 등록
- **Naver**: Naver Developers > API 설정 > 로그인 오픈 API

---

## 4. 백엔드 구현

### 4.1 인증 서비스 (`auth_service.py`)

```python
"""
OAuth 인증 서비스
"""
import httpx
from typing import Dict, Optional
import logging
from app.config import settings

logger = logging.getLogger(__name__)

class OAuthService:
    """OAuth 인증 통합 서비스"""
    
    @staticmethod
    async def verify_google_token(code: str, redirect_uri: str) -> Dict:
        """Google Authorization Code 검증"""
        token_url = "https://oauth2.googleapis.com/token"
        data = {
            'code': code,
            'client_id': settings.GOOGLE_CLIENT_ID,
            'client_secret': settings.GOOGLE_CLIENT_SECRET,
            'redirect_uri': redirect_uri,
            'grant_type': 'authorization_code'
        }
        async with httpx.AsyncClient() as client:
            res = await client.post(token_url, data=data)
            res.raise_for_status()
            tokens = res.json()
            
            # 사용자 정보 조회
            user_info_res = await client.get(
                "https://www.googleapis.com/oauth2/v2/userinfo",
                headers={'Authorization': f"Bearer {tokens['access_token']}"}
            )
            user_info = user_info_res.json()
            return {
                'email': user_info['email'],
                'name': user_info.get('name', ''),
                'provider': 'google',
                'provider_id': user_info['id']
            }

    @staticmethod
    async def verify_apple_token(code: str = None, id_token: str = None) -> Dict:
        """
        Apple Sign In 검증
        - Mobile App: 주로 id_token을 직접 받아서 전송
        - Web: code를 받아서 교환
        """
        # ✅ v1.2 기준: "최소 구현"은 id_token 검증(서명/iss/aud/exp/nonce)으로 정의한다.
        # - provider_id는 Apple의 "sub"를 사용
        # - email은 최초 1회만 내려올 수 있으므로 nullable 처리
        if not (id_token or code):
            raise ValueError("apple: id_token 또는 code가 필요합니다.")
        # 구현 포인트(요약):
        # 1) Apple 공개키(JWKs)로 서명 검증
        # 2) payload에서 sub/email/email_verified 추출
        # 3) aud(서비스ID/번들ID), iss, exp, nonce 검증
        return {'email': None, 'name': '', 'provider': 'apple', 'provider_id': 'APPLE_SUB'}

    @staticmethod
    async def verify_kakao(access_token: str) -> Dict:
        """Kakao: access_token으로 userinfo 조회 후 provider_id 획득"""
        # https://kapi.kakao.com/v2/user/me
        return {'email': None, 'name': '', 'provider': 'kakao', 'provider_id': 'KAKAO_ID'}

    @staticmethod
    async def verify_naver(access_token: str) -> Dict:
        """Naver: access_token으로 userinfo 조회 후 provider_id 획득"""
        # https://openapi.naver.com/v1/nid/me
        return {'email': None, 'name': '', 'provider': 'naver', 'provider_id': 'NAVER_ID'}
```

### 4.2 인증 API (`auth.py`)

```python
@router.post("/login", response_model=LoginResponse)
async def login(request: LoginRequest):
    # 1. Provider별 검증
    if request.provider == 'google':
        info = await OAuthService.verify_google_token(request.code, request.redirect_uri)
    # ... others
    
    # 2. 계정 연동/생성 (SSOT: users + oauth_identities)
    # - (provider, provider_user_id)로 OAuthIdentity를 먼저 찾는다.
    # - 없으면: (정책에 따라) 기존 user(email_verified)와 연동하거나 신규 user 생성.
    user, is_new = link_or_create_user_with_oauth_identity(info)
    
    # 3. 신규 가입 보너스
    if is_new:
        get_coin_service().grant_coins(user.id, 5, "Welcome Bonus")
        
    # 4. JWT 발급
    token = create_jwt_token(user.id)
    
    return LoginResponse(access_token=token, ...)
```

### 4.3 사용자 모델 및 인증 의존성 (SSOT)

**`backend/app/models/user.py`**:
- **Schema(권장)**: `id` (PK), `email(nullable)`, `display_name`, `created_at`, `updated_at`

**`backend/app/models/oauth_identity.py`**:
- **Schema**: `user_id`, `provider`, `provider_user_id`, `email(nullable)`, `email_verified(nullable)`, `created_at`
- **Unique Constraint**: `(provider, provider_user_id)`  ← SSOT

**`backend/app/api/deps.py`**:
- **`get_current_user`**:
  - 모든 인증 필요 API(IAP, 코인 조회 등)의 진입점.
  - JWT 헤더 파싱 -> `user_id` 추출 -> DB 조회 -> `User` 객체 반환.
  - 035(IAP), 036(Ads 보상) 등 타 모듈에서 이 함수를 import하여 사용.

### 4.4 계정 연동 정책(중복방지)
- **기본 원칙**: “같은 사람” 판단은 **(provider, provider_user_id)**가 1순위다.
- **이메일 기반 연동(선택적)**:
  - 동일 이메일이라도 **email_verified가 true이고 제공자가 신뢰 가능한 경우에만** 자동 연동 허용.
  - 자동 연동을 하지 않으면, 사용자가 앱 내에서 “계정 연동”을 명시적으로 수행하는 흐름(Phase 2)로 분리.
- **금지**: 단순히 `email`만 같다는 이유로 무조건 병합(계정 탈취 위험).

### 4.5 토큰 정책(KISS → 확장 가능)
- **Phase 1(권장)**: Access JWT 단일 토큰
  - 만료: 예) 7일
  - 저장: Flutter Secure Storage
  - 로그아웃: 클라이언트 저장소 삭제 + (옵션) 서버 측 `token_version`로 무효화(Phase 2)
- **Phase 2(필요 시)**: Refresh Token 회전(탈취 대응 강화)
  - 서버 저장은 **해시**(plain 저장 금지)
  - 재사용 탐지 시 전체 세션 폐기

---

## 5. 프론트엔드 구현

### 5.1 인증 서비스 (`auth_service.dart`)

- **책임**: 로그인 처리, 토큰 관리(SecureStorage), 로그아웃.
- **의존성**: `ApiClient` (HTTP 요청), `FlutterSecureStorage`.

### 5.2 구현 상세
- **Google**: `google_sign_in` 패키지 사용. `serverAuthCode`를 받아 백엔드로 전송.
- **Apple**: `sign_in_with_apple` 패키지 사용. `identityToken` 또는 `authorizationCode` 전송.

---

## 6. 코인지갑 관리

### 6.1 잔액 조회
- API: `GET /api/users/me/coins`
- 응답: `{ "coins": 100 }`
- **SSOT**: 코인 잔액의 진실은 **`coin_transactions` 원장 집계**다.
  - 성능을 위해 `user_coin_balances`(캐시/집계 테이블)를 둘 수 있으나, 이는 **원장에서 재생성 가능**해야 한다.

### 6.2 사용 내역(원장) 조회
- API: `GET /api/users/me/coin-transactions?cursor=...&limit=...`
- 응답(예): `{ "items": [{"delta": -5, "reason": "...", "created_at": "..."}], "next_cursor": "..." }`
- **정렬**: `created_at DESC, id DESC` (커서 기반 페이지네이션 권장)

---

## 7. 운영/보안/테스트

### 7.1 보안 체크(필수)
- **비밀키 관리**: OAuth Client Secret/Apple Key(.p8)/Service Account 등은 `.env`가 아닌 **Secret Manager/CI 변수**로 관리(로컬은 `.env.example`만).
- **검증**: JWT `iss/aud/exp` 필수 검증, Apple `nonce`(가능 시) 검증.
- **로그**: 토큰/코드/액세스토큰 원문을 로그에 남기지 않는다(마스킹).
- **레이트 리밋**: `/api/auth/login`에 IP+device 기준 제한(브루트포스/남용 방지).

### 7.2 테스트(최소 세트)
- 단위: provider 검증 응답 파싱, 계정 연동 정책(자동연동/미연동), idempotency 유니크 충돌 처리
- 통합: 로그인→JWT→`/me/coins` 접근, 신규가입 보너스 1회만 지급

### 7.3 관측(운영 품질)
- 로그인 성공/실패 지표(제공자별), 신규가입률, 연동률
- 코인 원장 이벤트(지급/차감) 카운트 및 이상탐지(급증)

---

## 8. 구현 체크리스트

- [ ] **백엔드**: User 모델 및 마이그레이션
- [ ] **백엔드**: `oauth_identities` 모델 및 마이그레이션(유니크 제약 포함)
- [ ] **백엔드**: OAuthService (Google, Apple, Kakao, Naver) 검증 구현(서명/nonce 등 포함)
- [ ] **백엔드**: JWT 발급 + `get_current_user` 구현 + 레이트리밋
- [ ] **백엔드**: `coin_transactions` idempotency 제약 `(reference_type, reference_id)` 적용
- [ ] **프론트**: LoginScreen UI 및 Social Login 연동
- [ ] **프론트**: AuthService 및 SecureStorage 연동
- [ ] **설정**: 각 Provider 개발자 콘솔 설정 및 .env 키 발급

---

## 9. 원칙 검증 (중복방지/리팩토링/DRY/SSOT/KISS)

### 9.1 중복방지(Idempotency)
- [ ] 코인 지급/차감은 반드시 `(reference_type, reference_id)` 유니크로 중복 처리 방지
- [ ] 신규가입 보너스는 `reference_type=bonus/welcome`로 1회만 지급

### 9.2 DRY
- [ ] 인증 진입점은 `get_current_user` 단일 함수로 통일(035/036에서 재사용)
- [ ] Provider별 검증은 `OAuthService`로만 모으고 라우터에 중복 로직 금지

### 9.3 SSOT
- [ ] “사용자”는 `users`, “로그인 수단”은 `oauth_identities`, “코인 변화”는 `coin_transactions`로 단일화
- [ ] 잔액 캐시가 있더라도 원장에서 재생성 가능해야 함

### 9.4 KISS
- [ ] Phase 1은 Access JWT만으로 구현(Refresh는 Phase 2)
- [ ] 계정 자동 병합은 최소화(보안 리스크 축소)

**관련 문서**:
- `035_IAP_Implementation_Plan.md`: 결제 시스템 (본 문서의 인증 의존)
- `036_AdMob_AdRaven_Implementation_Plan.md`: 광고 시스템
- `099_Coin_Pricing_Analysis.md`: 코인 정책
