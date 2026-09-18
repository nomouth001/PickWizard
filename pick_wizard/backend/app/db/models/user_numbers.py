"""
사용자 번호 관리 모델

2026-01-16 04:10:00 EST - 초기 생성 (간소화 버전)
"""

from enum import Enum
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Index
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.orm import relationship

from app.db.base import Base


class WinningRank(str, Enum):
    """당첨 등수"""
    RANK_1 = "1등"
    RANK_2 = "2등"
    RANK_3 = "3등"
    RANK_4 = "4등"
    RANK_5 = "5등"
    NO_WIN = "미당첨"


class UserSavedNumber(Base):
    """사용자가 저장한 번호"""
    __tablename__ = "user_saved_numbers"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey('users.id', ondelete='CASCADE'),
        nullable=False,
        index=True,
        comment="사용자 ID"
    )
    
    # 번호 정보 (SQLite는 ARRAY 지원 안 함, JSON으로 저장)
    numbers = Column(String(100), nullable=False, comment="번호 6개 (JSON)")
    
    # 생성 정보
    algorithm_id = Column(Integer, comment="생성 알고리즘 ID")
    algorithm_name = Column(String(100), comment="알고리즘 이름")
    
    # 당첨 확인
    is_checked = Column(Boolean, default=False, comment="당첨 확인 여부")
    checked_draw_no = Column(Integer, comment="확인한 회차")
    winning_rank = Column(String(10), comment="당첨 등수")
    matched_count = Column(Integer, default=0, comment="맞은 개수")
    
    # 메모
    memo = Column(String(255), comment="사용자 메모")
    
    # 인덱스
    __table_args__ = (
        Index('ix_user_saved_numbers_user_created', 'user_id', 'created_at'),
        Index('ix_user_saved_numbers_unchecked', 'is_checked', 'user_id'),
    )
    
    def __repr__(self) -> str:
        return f"<UserSavedNumber(id={self.id}, user_id={self.user_id}, numbers={self.numbers})>"


class WinningCheckResult(Base):
    """당첨 확인 결과"""
    __tablename__ = "winning_check_results"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey('users.id', ondelete='CASCADE'),
        nullable=False,
        index=True,
        comment="사용자 ID"
    )
    
    user_number_id = Column(
        Integer,
        ForeignKey('user_saved_numbers.id', ondelete='CASCADE'),
        nullable=False,
        comment="사용자 번호 ID"
    )
    
    # 회차 정보
    draw_no = Column(Integer, nullable=False, comment="확인한 회차")
    winning_numbers = Column(String(100), nullable=False, comment="당첨번호 (JSON)")
    bonus_number = Column(Integer, nullable=False, comment="보너스 번호")
    
    # 결과
    matched_count = Column(Integer, nullable=False, comment="맞은 개수")
    has_bonus = Column(Boolean, default=False, comment="보너스 포함")
    winning_rank = Column(String(10), nullable=False, comment="등수")
    
    # 인덱스
    __table_args__ = (
        Index('ix_winning_check_results_user', 'user_id', 'created_at'),
        Index('ix_winning_check_results_draw', 'draw_no', 'user_id'),
    )
    
    def __repr__(self) -> str:
        return f"<WinningCheckResult(id={self.id}, rank={self.winning_rank}, matched={self.matched_count})>"
