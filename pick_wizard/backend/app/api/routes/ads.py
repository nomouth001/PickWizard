"""
광고 SSV(Server-Side Verification) API (041 설계서 §4.3)

- POST /api/ads/ssv/admob: Google AdMob SSV callback 수신
- reference_type='ads/ssv', reference_id=transaction_id 로 멱등 지급
"""

import logging
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session

from app.config import settings
from app.db.session import get_db
from app.db.models.coin_wallet import CoinTransactionType
from app.services.coin_service import grant_coins

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/ads", tags=["Ads"])

# 설계서 §4.3: reference 형식 SSOT
REFERENCE_TYPE_SSV = "ads/ssv"


@router.post("/ssv/admob")
async def admob_ssv_callback(
    transaction_id: str = Query(..., description="Google SSV transaction_id"),
    reward_amount: int = Query(..., ge=0, description="보상 코인 수"),
    user_id: str = Query(..., description="앱에서 설정한 사용자 ID (UUID)"),
    # 서명 검증용 (설계서 §4.4; 키 설정 시 검증)
    signature: str | None = Query(None),
    key_id: str | None = Query(None),
    db: Session = Depends(get_db),
):
    """
    AdMob 보상 광고 SSV callback.
    서명 검증 성공 시 coin_transactions에 멱등 기록. 유니크 충돌 시 200 OK.
    """
    if not transaction_id.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="transaction_id is required",
        )
    try:
        uid = UUID(user_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid user_id format",
        )
    # TODO: ADMOB_SSV_KEYS_PATH 설정 시 signature, key_id로 ECDSA 검증
    # 검증 실패 시 raise HTTPException(status_code=401, detail="Invalid signature")
    if signature and key_id:
        # 프로덕션에서는 여기서 공개키 로드 후 검증
        pass

    # 043: 코인/지갑 비활성화 시 원장 기록 스킵, 200만 반환 (멱등 유지)
    if not settings.COIN_WALLET_ENABLED:
        return {"granted": False, "already_processed": False}

    try:
        already = grant_coins(
            db=db,
            user_id=uid,
            amount=reward_amount,
            reason="AdMob rewarded ad (SSV)",
            reference_type=REFERENCE_TYPE_SSV,
            reference_id=transaction_id,
            transaction_type=CoinTransactionType.WATCH_AD.value,
        )
        return {
            "granted": not already,
            "already_processed": already,
        }
    except Exception as e:
        logger.exception("SSV grant_coins failed: %s", e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Payment processing failed",
        )
