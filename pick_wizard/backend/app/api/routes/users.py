"""
034 사용자/코인 API (JWT 인증)

- GET /users/me: 현재 사용자 정보
- GET /users/me/coins: 잔액 (원장 집계 SSOT)
- GET /users/me/coin-transactions: 원장 조회 (커서 페이지네이션)
"""

from typing import Annotated, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy import desc
from sqlalchemy.orm import Session

from app.api.deps import get_current_user
from app.db.session import get_db
from app.db.models.user import User
from app.db.models.coin_wallet import CoinWallet, CoinTransaction
from app.services.coin_service import get_balance_from_ledger

router = APIRouter(prefix="/users", tags=["Users (034 JWT)"])


@router.get("/me")
async def me(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Session = Depends(get_db),
):
    """JWT로 인증된 현재 사용자 정보."""
    wallet = db.query(CoinWallet).filter(CoinWallet.user_id == current_user.id).first()
    total_coins = get_balance_from_ledger(db, current_user.id) if not wallet else wallet.total_coins
    return {
        "user_id": current_user.id,
        "email": current_user.email,
        "display_name": current_user.display_name,
        "is_guest": current_user.is_guest,
        "is_active": current_user.is_active,
        "auth_provider": current_user.auth_provider.value,
        "total_coins": total_coins,
        "created_at": current_user.created_at,
    }


@router.get("/me/coins")
async def me_coins(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Session = Depends(get_db),
):
    """034 SSOT: 원장(coin_transactions) 집계 잔액."""
    coins = get_balance_from_ledger(db, current_user.id)
    return {"coins": coins}


@router.get("/me/coin-transactions")
async def me_coin_transactions(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Session = Depends(get_db),
    cursor: Optional[str] = Query(None, description="다음 페이지 커서 (id)"),
    limit: int = Query(20, ge=1, le=100),
):
    """034 원장 조회. created_at DESC, id DESC 커서 페이지네이션."""
    q = (
        db.query(CoinTransaction)
        .filter(CoinTransaction.user_id == current_user.id)
        .order_by(desc(CoinTransaction.created_at), desc(CoinTransaction.id))
    )
    if cursor:
        try:
            cursor_id = int(cursor)
            q = q.filter(CoinTransaction.id < cursor_id)
        except ValueError:
            pass
    items = q.limit(limit + 1).all()
    has_more = len(items) > limit
    if has_more:
        items = items[:limit]
    next_cursor = str(items[-1].id) if items and has_more else None
    return {
        "items": [
            {
                "id": t.id,
                "delta": t.amount,
                "reason": t.description,
                "reference_type": t.reference_type,
                "reference_id": t.reference_id,
                "created_at": t.created_at.isoformat() if t.created_at else None,
            }
            for t in items
        ],
        "next_cursor": next_cursor,
    }
