"""
코인 시스템 API 라우터

2026-01-08 08:15:00 EST - 초기 생성
"""

from datetime import datetime, timedelta
from typing import Optional
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc

from app.db.session import get_db
from app.db.models.user import User
from app.db.models.coin_wallet import CoinWallet, CoinTransaction, CoinTransactionType
from app.schemas.coins import (
    CoinBalanceResponse,
    DailyLoginRequest,
    DailyLoginResponse,
    WatchAdRequest,
    WatchAdResponse,
    CoinTransactionResponse,
    CoinHistoryResponse,
)

router = APIRouter(prefix="/coins", tags=["Coins"])

# 보상 설정
DAILY_LOGIN_REWARD = 10  # 일일 로그인 보상
WATCH_AD_REWARD = 5      # 광고 시청 보상
MAX_ADS_PER_DAY = 10     # 하루 최대 광고 시청 횟수


@router.get("/balance", response_model=CoinBalanceResponse)
async def get_coin_balance(
    user_id: str,
    db: Session = Depends(get_db)
):
    """
    사용자 코인 잔액 조회
    """
    try:
        # UUID 변환
        user_uuid = UUID(user_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="잘못된 사용자 ID 형식입니다"
        )
    
    wallet = db.query(CoinWallet).filter(CoinWallet.user_id == user_uuid).first()
    
    if not wallet:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="코인 지갑을 찾을 수 없습니다"
        )
    
    return CoinBalanceResponse(
        user_id=wallet.user_id,
        free_coins=wallet.free_coins,
        paid_coins=wallet.paid_coins,
        total_coins=wallet.total_coins,
        total_earned=wallet.total_earned,
        total_spent=wallet.total_spent
    )


@router.post("/daily-login", response_model=DailyLoginResponse)
async def claim_daily_login(
    request: DailyLoginRequest,
    db: Session = Depends(get_db)
):
    """
    일일 로그인 보상 받기
    
    하루 1회 제한
    """
    # 1. 사용자 및 지갑 확인
    wallet = db.query(CoinWallet).filter(CoinWallet.user_id == request.user_id).first()
    
    if not wallet:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="코인 지갑을 찾을 수 없습니다"
        )
    
    # 2. 오늘 이미 받았는지 확인
    today_start = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    
    existing_claim = db.query(CoinTransaction).filter(
        CoinTransaction.user_id == request.user_id,
        CoinTransaction.type == CoinTransactionType.DAILY_LOGIN.value,
        CoinTransaction.created_at >= today_start
    ).first()
    
    if existing_claim:
        return DailyLoginResponse(
            success=False,
            coins_earned=0,
            message="오늘 이미 로그인 보상을 받았습니다",
            new_balance=wallet.total_coins
        )
    
    # 3. 코인 지급
    wallet.add_free_coins(DAILY_LOGIN_REWARD)
    
    # 4. 거래 기록 생성
    transaction = CoinTransaction(
        user_id=request.user_id,
        type=CoinTransactionType.DAILY_LOGIN.value,
        amount=DAILY_LOGIN_REWARD,
        balance_after=wallet.total_coins,
        description=f"일일 로그인 보상"
    )
    
    db.add(transaction)
    db.commit()
    db.refresh(wallet)
    
    return DailyLoginResponse(
        success=True,
        coins_earned=DAILY_LOGIN_REWARD,
        message=f"일일 로그인 보상 {DAILY_LOGIN_REWARD}코인을 받았습니다!",
        new_balance=wallet.total_coins
    )


@router.post("/watch-ad", response_model=WatchAdResponse)
async def watch_ad(
    request: WatchAdRequest,
    db: Session = Depends(get_db)
):
    """
    광고 시청 보상 받기
    
    하루 최대 10회 제한
    """
    # 1. 사용자 및 지갑 확인
    wallet = db.query(CoinWallet).filter(CoinWallet.user_id == request.user_id).first()
    
    if not wallet:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="코인 지갑을 찾을 수 없습니다"
        )
    
    # 2. 오늘 광고 시청 횟수 확인
    today_start = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    
    today_ads = db.query(CoinTransaction).filter(
        CoinTransaction.user_id == request.user_id,
        CoinTransaction.type == CoinTransactionType.WATCH_AD.value,
        CoinTransaction.created_at >= today_start
    ).count()
    
    if today_ads >= MAX_ADS_PER_DAY:
        return WatchAdResponse(
            success=False,
            coins_earned=0,
            message=f"오늘 광고 시청 한도({MAX_ADS_PER_DAY}회)를 모두 사용했습니다",
            new_balance=wallet.total_coins,
            remaining_ads=0
        )
    
    # 3. 코인 지급
    wallet.add_free_coins(WATCH_AD_REWARD)
    
    # 4. 거래 기록 생성
    transaction = CoinTransaction(
        user_id=request.user_id,
        type=CoinTransactionType.WATCH_AD.value,
        amount=WATCH_AD_REWARD,
        balance_after=wallet.total_coins,
        description=f"광고 시청 보상",
        extra_data=f'{{"ad_id": "{request.ad_id}", "ad_provider": "{request.ad_provider}"}}'
    )
    
    db.add(transaction)
    db.commit()
    db.refresh(wallet)
    
    remaining = MAX_ADS_PER_DAY - today_ads - 1
    
    return WatchAdResponse(
        success=True,
        coins_earned=WATCH_AD_REWARD,
        message=f"광고 시청 보상 {WATCH_AD_REWARD}코인을 받았습니다!",
        new_balance=wallet.total_coins,
        remaining_ads=remaining
    )


@router.get("/history", response_model=CoinHistoryResponse)
async def get_coin_history(
    user_id: str,
    limit: int = Query(default=20, le=100),
    offset: int = Query(default=0, ge=0),
    db: Session = Depends(get_db)
):
    """
    코인 거래 내역 조회
    """
    try:
        # UUID 변환
        user_uuid = UUID(user_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="잘못된 사용자 ID 형식입니다"
        )
    
    # 1. 총 개수
    total = db.query(CoinTransaction).filter(
        CoinTransaction.user_id == user_uuid
    ).count()
    
    # 2. 거래 내역 조회 (최신순)
    transactions = db.query(CoinTransaction).filter(
        CoinTransaction.user_id == user_uuid
    ).order_by(
        desc(CoinTransaction.created_at)
    ).offset(offset).limit(limit).all()
    
    return CoinHistoryResponse(
        total=total,
        transactions=[
            CoinTransactionResponse(
                id=t.id,
                user_id=t.user_id,
                type=t.type,
                amount=t.amount,
                balance_after=t.balance_after,
                description=t.description,
                metadata=t.extra_data,
                created_at=t.created_at
            )
            for t in transactions
        ]
    )
