"""
코인 지갑 모델

2026-01-08 08:00:00 EST - 초기 생성
"""

from enum import Enum
from sqlalchemy import Column, Integer, BigInteger, String, ForeignKey, Index, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.base import Base


class CoinTransactionType(str, Enum):
    """코인 거래 타입"""
    WELCOME_BONUS = "welcome_bonus"      # 가입 보너스
    DAILY_LOGIN = "daily_login"          # 일일 로그인
    WATCH_AD = "watch_ad"                # 광고 시청
    PURCHASE = "purchase"                # 구매
    NUMBER_GENERATION = "number_generation"  # 번호 생성
    REFUND = "refund"                    # 환불
    ADMIN_GRANT = "admin_grant"          # 관리자 지급
    ADMIN_DEDUCT = "admin_deduct"        # 관리자 차감


class CoinWallet(Base):
    """사용자 코인 지갑"""
    __tablename__ = "coin_wallets"
    
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey('users.id', ondelete='CASCADE'),
        primary_key=True,
        comment="사용자 ID"
    )
    
    free_coins = Column(
        Integer,
        nullable=False,
        default=0,
        comment="무료 코인 (광고, 이벤트)"
    )
    
    paid_coins = Column(
        Integer,
        nullable=False,
        default=0,
        comment="유료 코인 (구매)"
    )
    
    total_earned = Column(
        BigInteger,
        nullable=False,
        default=0,
        comment="누적 획득 코인"
    )
    
    total_spent = Column(
        BigInteger,
        nullable=False,
        default=0,
        comment="누적 소비 코인"
    )
    
    # 관계
    user = relationship("User", back_populates="wallet")
    transactions = relationship("CoinTransaction", back_populates="wallet", cascade="all, delete-orphan")
    
    @property
    def total_coins(self) -> int:
        """총 코인 (무료 + 유료)"""
        return self.free_coins + self.paid_coins
    
    def deduct_coins(self, amount: int) -> bool:
        """
        코인 차감 (무료 코인 먼저 사용)
        
        Args:
            amount: 차감할 코인 수
            
        Returns:
            성공 여부 (잔액 부족 시 False)
        """
        if self.total_coins < amount:
            return False
        
        remaining = amount
        
        # 1. 무료 코인 먼저 차감
        if self.free_coins > 0:
            deduct_free = min(self.free_coins, remaining)
            self.free_coins -= deduct_free
            remaining -= deduct_free
        
        # 2. 유료 코인 차감
        if remaining > 0:
            self.paid_coins -= remaining
        
        self.total_spent += amount
        return True
    
    def add_free_coins(self, amount: int):
        """무료 코인 추가"""
        self.free_coins += amount
        self.total_earned += amount
    
    def add_paid_coins(self, amount: int):
        """유료 코인 추가"""
        self.paid_coins += amount
        self.total_earned += amount
    
    def __repr__(self) -> str:
        return f"<CoinWallet(user_id={self.user_id}, total={self.total_coins}, free={self.free_coins}, paid={self.paid_coins})>"


class CoinTransaction(Base):
    """코인 거래 내역"""
    __tablename__ = "coin_transactions"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey('coin_wallets.user_id', ondelete='CASCADE'),
        nullable=False,
        index=True,
        comment="사용자 ID"
    )
    
    type = Column(
        String(50),
        nullable=False,
        comment="거래 타입"
    )
    
    amount = Column(
        Integer,
        nullable=False,
        comment="금액 (+ 획득, - 소비)"
    )
    
    balance_after = Column(
        Integer,
        nullable=False,
        comment="거래 후 잔액"
    )
    
    description = Column(
        String(255),
        nullable=True,
        comment="설명"
    )
    
    extra_data = Column(
        String(500),
        nullable=True,
        comment="추가 정보 (JSON)"
    )
    # 034 원장 SSOT: 멱등 처리용 (중복 지급 방지)
    reference_type = Column(String(50), nullable=True, comment="참조 타입: iap, ads/ssv, admin, bonus, welcome 등")
    reference_id = Column(String(255), nullable=True, comment="참조 ID (order_id, transaction_id 등)")

    wallet = relationship("CoinWallet", back_populates="transactions")

    __table_args__ = (
        Index('ix_coin_transactions_user_created', 'user_id', 'created_at'),
        Index('ix_coin_transactions_type', 'type'),
        UniqueConstraint('reference_type', 'reference_id', name='uq_coin_transactions_reference'),
    )
    
    def __repr__(self) -> str:
        sign = '+' if self.amount >= 0 else ''
        return f"<CoinTransaction(id={self.id}, user_id={self.user_id}, {sign}{self.amount} -> {self.balance_after})>"
