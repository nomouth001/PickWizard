"""
로또 회차 모델

2026-01-04 EST - 초기 생성
"""

from sqlalchemy import Column, Integer, Date, BigInteger, Index
from sqlalchemy.orm import validates

from app.db.base import Base


class LottoDraw(Base):
    """
    로또 회차 당첨번호
    
    각 회차의 당첨번호 6개 + 보너스 번호 1개 저장
    """
    __tablename__ = "lotto_draws"
    
    # === 기본 정보 ===
    draw_no = Column(
        Integer,
        primary_key=True,
        comment="회차 번호"
    )
    draw_date = Column(
        Date,
        nullable=False,
        unique=True,
        comment="추첨일"
    )
    
    # === 당첨번호 (6개) ===
    num1 = Column(Integer, nullable=False, comment="번호 1")
    num2 = Column(Integer, nullable=False, comment="번호 2")
    num3 = Column(Integer, nullable=False, comment="번호 3")
    num4 = Column(Integer, nullable=False, comment="번호 4")
    num5 = Column(Integer, nullable=False, comment="번호 5")
    num6 = Column(Integer, nullable=False, comment="번호 6")
    bonus = Column(Integer, nullable=False, comment="보너스 번호")
    
    # === 당첨 정보 ===
    first_prize_amount = Column(
        BigInteger,
        nullable=True,
        comment="1등 당첨금 (원)"
    )
    first_winner_count = Column(
        Integer,
        nullable=True,
        comment="1등 당첨자 수"
    )
    
    # === 인덱스 ===
    __table_args__ = (
        Index('idx_draw_date', 'draw_date'),
        Index('idx_created_at', 'created_at'),
    )
    
    @validates('num1', 'num2', 'num3', 'num4', 'num5', 'num6', 'bonus')
    def validate_number_range(self, key: str, value: int) -> int:
        """번호 범위 검증 (1~45)"""
        if not 1 <= value <= 45:
            raise ValueError(f"{key} must be between 1 and 45, got {value}")
        return value
    
    def get_numbers(self) -> list[int]:
        """당첨번호 6개를 리스트로 반환"""
        return [self.num1, self.num2, self.num3, 
                self.num4, self.num5, self.num6]
    
    def get_all_numbers(self) -> dict[str, list[int]]:
        """당첨번호 + 보너스를 딕셔너리로 반환"""
        return {
            'numbers': self.get_numbers(),
            'bonus': self.bonus
        }
    
    def __repr__(self) -> str:
        nums = ', '.join(map(str, self.get_numbers()))
        return f"<LottoDraw(draw_no={self.draw_no}, numbers=[{nums}], bonus={self.bonus})>"

