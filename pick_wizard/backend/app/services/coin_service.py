"""
코인 원장 서비스 (034 SSOT)

- 잔액 진실: coin_transactions 원장 집계
- 지급/차감 시 reference_type + reference_id 로 멱등 보장
"""

import logging
from uuid import UUID

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.db.models.coin_wallet import CoinTransaction, CoinWallet, CoinTransactionType

logger = logging.getLogger(__name__)


def get_balance_from_ledger(db: Session, user_id: UUID) -> int:
    """원장(coin_transactions) 집계로 잔액 계산 (SSOT)."""
    row = (
        db.query(func.coalesce(func.sum(CoinTransaction.amount), 0))
        .filter(CoinTransaction.user_id == user_id)
        .scalar()
    )
    return int(row) if row is not None else 0


def grant_coins(
    db: Session,
    user_id: UUID,
    amount: int,
    reason: str,
    reference_type: str,
    reference_id: str,
    transaction_type: str = CoinTransactionType.WELCOME_BONUS.value,
) -> bool:
    """
    코인 지급 (멱등).
    (reference_type, reference_id) 유니크로 이미 기록되어 있으면 무시하고 True 반환.
    amount는 양수만 허용.
    """
    if amount <= 0:
        raise ValueError("grant_coins: amount must be positive")
    existing = (
        db.query(CoinTransaction)
        .filter(
            CoinTransaction.reference_type == reference_type,
            CoinTransaction.reference_id == reference_id,
        )
        .first()
    )
    if existing:
        logger.info("grant_coins idempotent skip: %s/%s", reference_type, reference_id)
        return True
    balance_before = get_balance_from_ledger(db, user_id)
    balance_after = balance_before + amount
    tx = CoinTransaction(
        user_id=user_id,
        type=transaction_type,
        amount=amount,
        balance_after=balance_after,
        description=reason,
        reference_type=reference_type,
        reference_id=reference_id,
    )
    db.add(tx)
    # 캐시(CoinWallet) 동기화: 없으면 생성 후 free_coins 증가
    wallet = db.query(CoinWallet).filter(CoinWallet.user_id == user_id).first()
    if not wallet:
        wallet = CoinWallet(
            user_id=user_id,
            free_coins=0,
            paid_coins=0,
            total_earned=0,
            total_spent=0,
        )
        db.add(wallet)
        db.flush()
    wallet.add_free_coins(amount)
    db.commit()
    return True
