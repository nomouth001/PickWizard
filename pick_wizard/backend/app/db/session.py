"""
데이터베이스 세션 관리

2026-01-04 EST - 초기 생성
"""

from contextlib import contextmanager
from typing import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session

from app.config import settings


# === Engine 생성 ===
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
    echo=settings.DEBUG,
)

# === Session Factory ===
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)


def get_db() -> Generator[Session, None, None]:
    """
    데이터베이스 세션 의존성 주입용
    
    FastAPI Depends에서 사용:
    @router.get("/")
    def endpoint(db: Session = Depends(get_db)):
        ...
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@contextmanager
def get_db_context() -> Generator[Session, None, None]:
    """
    컨텍스트 매니저로 세션 사용
    
    with get_db_context() as db:
        result = db.query(Model).all()
    """
    db = SessionLocal()
    try:
        yield db
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()

