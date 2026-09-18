"""
인증 API 라우터

2026-01-08 08:10:00 EST - 초기 생성
034 - OAuth 로그인 (POST /login) 추가
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.db.models.user import User, AuthProvider
from app.db.models.coin_wallet import CoinWallet, CoinTransaction, CoinTransactionType
from app.schemas.auth import (
    GuestCreateRequest,
    GuestCreateResponse,
    UserResponse,
    LoginRequest,
    LoginResponse,
)
from app.services.auth_service import OAuthService, link_or_create_user_with_oauth_identity
from app.services.coin_service import grant_coins
from app.api.deps import create_jwt_token

router = APIRouter(prefix="/auth", tags=["Authentication"])

# 웰컴 보너스 설정
WELCOME_BONUS_COINS = 100
# 034 OAuth 신규 가입 웰컴 보너스 (reference_type=bonus/welcome 로 1회만)
WELCOME_BONUS_OAUTH_COINS = 5
WELCOME_BONUS_REFERENCE_TYPE = "bonus"
WELCOME_BONUS_REFERENCE_ID = "welcome"


@router.post("/login", response_model=LoginResponse)
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    """
    034 OAuth 로그인.
    Provider별 code/id_token/access_token 검증 후 계정 연동/생성, JWT 발급.
    """
    provider = request.provider.lower()
    if provider == "google":
        if not request.code or not request.redirect_uri:
            raise HTTPException(status_code=400, detail="Google 로그인에는 code와 redirect_uri가 필요합니다")
        info = await OAuthService.verify_google_token(request.code, request.redirect_uri)
    elif provider == "apple":
        if request.id_token:
            info = await OAuthService.verify_apple_token(id_token=request.id_token)
        elif request.code:
            info = await OAuthService.verify_apple_token(code=request.code)
        else:
            raise HTTPException(status_code=400, detail="Apple 로그인에는 id_token 또는 code가 필요합니다")
    elif provider == "kakao":
        if not request.access_token:
            raise HTTPException(status_code=400, detail="Kakao 로그인에는 access_token이 필요합니다")
        info = await OAuthService.verify_kakao(request.access_token)
    elif provider == "naver":
        if not request.access_token:
            raise HTTPException(status_code=400, detail="Naver 로그인에는 access_token이 필요합니다")
        info = await OAuthService.verify_naver(request.access_token)
    else:
        raise HTTPException(status_code=400, detail="지원하지 않는 provider입니다")

    user, is_new = link_or_create_user_with_oauth_identity(db, info)
    if is_new:
        try:
            grant_coins(
                db,
                user.id,
                WELCOME_BONUS_OAUTH_COINS,
                "Welcome Bonus",
                WELCOME_BONUS_REFERENCE_TYPE,
                WELCOME_BONUS_REFERENCE_ID,
            )
        except Exception:
            db.rollback()
            raise

    token = create_jwt_token(user.id)
    return LoginResponse(
        access_token=token,
        user_id=user.id,
        email=user.email,
        display_name=user.display_name,
        is_new_user=is_new,
    )


@router.post("/guest", response_model=GuestCreateResponse, status_code=status.HTTP_201_CREATED)
async def create_guest_user(
    request: GuestCreateRequest,
    db: Session = Depends(get_db)
):
    """
    게스트 사용자 생성 또는 조회
    
    동일한 device_id가 이미 있으면 기존 사용자 반환
    """
    # 1. 기존 사용자 확인 (device_id 또는 user_id)
    existing_user = None
    
    if request.user_id:
        existing_user = db.query(User).filter(
            User.id == request.user_id
        ).first()
    
    if not existing_user and request.device_id:
        existing_user = db.query(User).filter(
            User.device_id == request.device_id,
            User.is_guest == True
        ).first()
    
    # 2. 기존 사용자가 있으면 반환
    if existing_user:
        wallet = db.query(CoinWallet).filter(
            CoinWallet.user_id == existing_user.id
        ).first()
        
        # FCM 토큰 업데이트
        if request.fcm_token and existing_user.fcm_token != request.fcm_token:
            existing_user.fcm_token = request.fcm_token
            db.commit()
        
        return GuestCreateResponse(
            user_id=existing_user.id,
            device_id=existing_user.device_id,
            is_new_user=False,
            welcome_bonus=0,
            total_coins=wallet.total_coins if wallet else 0
        )
    
    # 3. 신규 사용자 생성
    new_user = User(
        device_id=request.device_id,
        auth_provider=AuthProvider.GUEST,
        is_guest=True,
        is_active=True,
        fcm_token=request.fcm_token
    )
    
    db.add(new_user)
    db.flush()  # user.id 생성
    
    # 4. 코인 지갑 생성 + 웰컴 보너스
    new_wallet = CoinWallet(
        user_id=new_user.id,
        free_coins=WELCOME_BONUS_COINS,
        paid_coins=0,
        total_earned=WELCOME_BONUS_COINS,
        total_spent=0
    )
    
    db.add(new_wallet)
    db.flush()
    
    # 5. 웰컴 보너스 거래 기록
    welcome_transaction = CoinTransaction(
        user_id=new_user.id,
        type=CoinTransactionType.WELCOME_BONUS.value,
        amount=WELCOME_BONUS_COINS,
        balance_after=WELCOME_BONUS_COINS,
        description="가입 환영 보너스"
    )
    
    db.add(welcome_transaction)
    db.commit()
    db.refresh(new_user)
    db.refresh(new_wallet)
    
    return GuestCreateResponse(
        user_id=new_user.id,
        device_id=new_user.device_id,
        is_new_user=True,
        welcome_bonus=WELCOME_BONUS_COINS,
        total_coins=new_wallet.total_coins
    )


@router.get("/me", response_model=UserResponse)
async def get_current_user(
    user_id: str,
    db: Session = Depends(get_db)
):
    """
    현재 사용자 정보 조회
    """
    user = db.query(User).filter(User.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="사용자를 찾을 수 없습니다"
        )
    
    wallet = db.query(CoinWallet).filter(CoinWallet.user_id == user.id).first()
    
    if not wallet:
        # 지갑이 없으면 생성 (마이그레이션용)
        wallet = CoinWallet(
            user_id=user.id,
            free_coins=0,
            paid_coins=0,
            total_earned=0,
            total_spent=0
        )
        db.add(wallet)
        db.commit()
        db.refresh(wallet)
    
    return UserResponse(
        user_id=user.id,
        device_id=user.device_id,
        email=user.email,
        is_guest=user.is_guest,
        is_active=user.is_active,
        auth_provider=user.auth_provider.value,
        total_coins=wallet.total_coins,
        free_coins=wallet.free_coins,
        paid_coins=wallet.paid_coins,
        created_at=user.created_at
    )
