"""
SQLAlchemy Base 클래스 및 공통 모델

2026-01-04 EST - 초기 생성
"""

from datetime import datetime
from typing import Any

from sqlalchemy import Column, DateTime, create_engine
from sqlalchemy.orm import declarative_base, declared_attr

from app.config import settings


class CustomBase:
    """공통 컬럼 및 메서드를 제공하는 베이스 클래스"""
    
    @declared_attr
    def __tablename__(cls) -> str:
        """테이블명 자동 생성 (클래스명의 소문자)"""
        return cls.__name__.lower() + 's'
    
    # 공통 컬럼
    created_at = Column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
        comment="생성 일시"
    )
    updated_at = Column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False,
        comment="수정 일시"
    )
    
    def to_dict(self) -> dict[str, Any]:
        """모델을 딕셔너리로 변환"""
        return {
            c.name: getattr(self, c.name)
            for c in self.__table__.columns
        }


Base = declarative_base(cls=CustomBase)

# SQLAlchemy Engine
# SQLite와 PostgreSQL 모두 지원
if settings.DATABASE_URL.startswith("sqlite"):
    # SQLite 설정
    engine = create_engine(
        settings.DATABASE_URL,
        echo=settings.DEBUG,
        connect_args={"check_same_thread": False}  # SQLite용
    )
else:
    # PostgreSQL 설정
    engine = create_engine(
        settings.DATABASE_URL,
        echo=settings.DEBUG,
        pool_pre_ping=True,
        pool_size=10,
        max_overflow=20
    )

