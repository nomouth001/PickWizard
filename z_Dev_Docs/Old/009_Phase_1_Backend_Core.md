# Phase 1: 백엔드 Core 모듈
## 상세 개발 로드맵

---

**Phase**: 1 - Backend Core Modules  
**예상 기간**: 3-4일 (24-32시간)  
**선행 조건**: Phase 0 완료 (환경 설정)  
**목표**: 데이터 수집 및 관리 시스템 완전 구축

---

## 📋 Phase 개요

### 주요 산출물
- [x] 데이터베이스 모델 정의 및 마이그레이션
- [x] 로또 크롤러 구현 (동행복권)
- [x] 데이터 검증 시스템
- [x] 데이터 매니저 (CSV/DB 동기화)
- [x] 캐시 매니저 (Redis)
- [x] Repository 패턴 구현

### 시간 배분
| 작업 | 예상 시간 | 누적 시간 |
|------|-----------|-----------|
| 1.1 DB 모델 정의 | 4시간 | 4h |
| 1.2 설정 관리 | 2시간 | 6h |
| 1.3 로또 크롤러 | 8시간 | 14h |
| 1.4 데이터 검증기 | 4시간 | 18h |
| 1.5 데이터 매니저 | 8시간 | 26h |
| 1.6 캐시 매니저 | 2-4시간 | 28-30h |
| 1.7 통합 테스트 | 2시간 | 30-32h |

---

## 작업 1.1: 데이터베이스 모델 정의 (4시간)

### 목표
SQLAlchemy ORM 모델 정의 및 Alembic 마이그레이션

### Step 1.1.1: SQLAlchemy Base 클래스 작성

**파일**: `backend/app/db/base.py`

```python
"""
SQLAlchemy Base 클래스 및 공통 모델

2026-01-04 EST - 초기 생성
"""

from datetime import datetime
from typing import Any

from sqlalchemy import Column, DateTime
from sqlalchemy.ext.declarative import declared_attr, declarative_base


class CustomBase:
    """공통 컬럼 및 메서드를 제공하는 베이스 클래스"""
    
    @declared_attr
    def __tablename__(cls) -> str:
        """테이블명 자동 생성 (클래스명의 소문자 + 's')"""
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
```

---

### Step 1.1.2: 데이터베이스 세션 관리

**파일**: `backend/app/db/session.py`

```python
"""
데이터베이스 세션 관리

2026-01-04 EST - 초기 생성
"""

from contextlib import contextmanager
from typing import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import NullPool

from app.config import settings


# === Engine 생성 ===
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
    echo=settings.DEBUG,
    # 비동기 지원 시 poolclass=NullPool 사용
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
```

---

### Step 1.1.3: 로또 회차 모델

**파일**: `backend/app/db/models/lotto_draw.py`

```python
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
```

---

### Step 1.1.4: 사용자 모델 (기본)

**파일**: `backend/app/db/models/user.py`

```python
"""
사용자 모델

2026-01-04 EST - 초기 생성 (게스트 모드)
"""

from enum import Enum
from uuid import uuid4

from sqlalchemy import Column, String, Boolean, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from app.db.base import Base


class AuthProvider(str, Enum):
    """인증 제공자"""
    GUEST = "guest"
    GOOGLE = "google"
    APPLE = "apple"
    KAKAO = "kakao"
    NAVER = "naver"


class User(Base):
    """
    사용자 계정 (게스트/정식)
    """
    __tablename__ = "users"
    
    # === 기본 정보 ===
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
        comment="사용자 ID (UUID)"
    )
    
    device_id = Column(
        String(255),
        unique=True,
        nullable=True,
        comment="디바이스 ID (게스트 식별용)"
    )
    
    # === 인증 정보 ===
    auth_provider = Column(
        SQLEnum(AuthProvider),
        nullable=False,
        default=AuthProvider.GUEST,
        comment="인증 제공자"
    )
    
    social_id = Column(
        String(255),
        nullable=True,
        comment="소셜 로그인 ID"
    )
    
    email = Column(
        String(255),
        unique=True,
        nullable=True,
        comment="이메일"
    )
    
    # === 상태 ===
    is_active = Column(
        Boolean,
        default=True,
        nullable=False,
        comment="활성 여부"
    )
    
    is_guest = Column(
        Boolean,
        default=True,
        nullable=False,
        comment="게스트 여부"
    )
    
    # === FCM 토큰 (Push 알림) ===
    fcm_token = Column(
        String(255),
        nullable=True,
        comment="Firebase Cloud Messaging 토큰"
    )
    
    def __repr__(self) -> str:
        user_type = "Guest" if self.is_guest else "User"
        return f"<User({user_type}, id={self.id}, email={self.email})>"
```

---

### Step 1.1.5: 모델 Export

**파일**: `backend/app/db/models/__init__.py`

```python
"""
데이터베이스 모델 Export

2026-01-04 EST - 초기 생성
"""

from app.db.base import Base
from app.db.models.lotto_draw import LottoDraw
from app.db.models.user import User, AuthProvider


__all__ = [
    "Base",
    "LottoDraw",
    "User",
    "AuthProvider",
]
```

---

### Step 1.1.6: Alembic 초기화 및 마이그레이션

#### Alembic 설정

**파일**: `backend/alembic.ini`

```ini
[alembic]
script_location = alembic
prepend_sys_path = .
version_path_separator = os

sqlalchemy.url = 

[post_write_hooks]

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualname =

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
```

**파일**: `backend/alembic/env.py`

```python
"""Alembic 환경 설정"""

from logging.config import fileConfig

from sqlalchemy import engine_from_config
from sqlalchemy import pool

from alembic import context

from app.config import settings
from app.db.base import Base
from app.db.models import *  # 모든 모델 import

# Alembic Config 객체
config = context.config

# DB URL 설정
config.set_main_option('sqlalchemy.url', settings.DATABASE_URL)

# 로깅 설정
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# 메타데이터
target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """오프라인 마이그레이션"""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """온라인 마이그레이션"""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

#### 마이그레이션 생성 및 적용

```powershell
cd backend

# Alembic 초기화 (이미 완료)
# alembic init alembic

# 첫 마이그레이션 생성
alembic revision --autogenerate -m "Initial tables: lotto_draws, users"

# 마이그레이션 적용
alembic upgrade head

# 마이그레이션 롤백 (필요 시)
# alembic downgrade -1
```

### 완료 기준 체크리스트
- [ ] `app/db/base.py` 작성 완료
- [ ] `LottoDraw`, `User` 모델 작성
- [ ] Alembic 마이그레이션 생성
- [ ] `alembic upgrade head` 성공
- [ ] PostgreSQL에 테이블 생성 확인

---

## 작업 1.2: 설정 관리 (2시간)

### Step 1.2.1: Pydantic Settings 작성

**파일**: `backend/app/config.py`

```python
"""
애플리케이션 설정 관리

2026-01-04 EST - 초기 생성
"""

from pathlib import Path
from typing import Optional

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    환경 변수 기반 설정 클래스
    
    .env 파일에서 자동 로드
    """
    
    # === 애플리케이션 ===
    APP_NAME: str = "LuckyAI 645"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    ENVIRONMENT: str = "development"
    
    # === 서버 ===
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    
    # === 데이터베이스 ===
    DATABASE_URL: str
    
    # === Redis ===
    REDIS_URL: str = "redis://localhost:6379/0"
    CACHE_TTL: int = 3600
    
    # === Celery ===
    CELERY_BROKER_URL: str = "redis://localhost:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/1"
    CELERY_TIMEZONE: str = "Asia/Seoul"
    
    # === 보안 ===
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # === 로또 크롤링 ===
    LOTTO_CRAWLER_URL: str = "https://www.dhlottery.co.kr/gameResult.do?method=byWin"
    CRAWLER_TIMEOUT: int = 10
    CRAWLER_RETRY: int = 3
    
    # === 파일 경로 ===
    BASE_DIR: Path = Path(__file__).resolve().parent.parent
    LOTTO_CSV_PATH: Path = BASE_DIR / "data" / "raw" / "lotto_data.csv"
    MODEL_DIR: Path = BASE_DIR / "data" / "models"
    
    # === Firebase (Push 알림) ===
    FIREBASE_CREDENTIALS_PATH: Optional[str] = None
    FIREBASE_CREDENTIALS_JSON: Optional[str] = None
    
    # === 인앱 결제 ===
    GOOGLE_SERVICE_ACCOUNT_KEY: Optional[str] = None
    APPLE_SHARED_SECRET: Optional[str] = None
    
    # === 광고 ===
    ADMOB_SECRET_KEY: Optional[str] = None
    
    # === 소셜 로그인 ===
    GOOGLE_CLIENT_ID: Optional[str] = None
    GOOGLE_CLIENT_SECRET: Optional[str] = None
    APPLE_CLIENT_ID: Optional[str] = None
    KAKAO_REST_API_KEY: Optional[str] = None
    NAVER_CLIENT_ID: Optional[str] = None
    NAVER_CLIENT_SECRET: Optional[str] = None
    
    # === 로깅 ===
    LOG_LEVEL: str = "INFO"
    LOG_FILE: Optional[str] = "logs/app.log"
    
    # === CORS ===
    CORS_ORIGINS: list[str] = ["http://localhost:3000", "http://localhost:8080"]
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True
    )
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # 디렉토리 생성
        self.LOTTO_CSV_PATH.parent.mkdir(parents=True, exist_ok=True)
        self.MODEL_DIR.mkdir(parents=True, exist_ok=True)


# 전역 설정 인스턴스
settings = Settings()
```

### 완료 기준 체크리스트
- [ ] `config.py` 작성 완료
- [ ] `.env` 파일에서 설정 로드 확인
- [ ] `settings.DATABASE_URL` 접근 가능

---

## 작업 1.3: 로또 크롤러 구현 (8시간)

### Step 1.3.1: 크롤러 베이스 구조

**파일**: `backend/app/core/crawler.py`

```python
"""
로또 당첨번호 크롤러

동행복권 웹사이트에서 당첨번호 수집

2026-01-04 EST - 초기 생성
"""

import asyncio
import re
from datetime import datetime
from typing import Dict, List, Optional

import aiohttp
from bs4 import BeautifulSoup
from loguru import logger

from app.config import settings


class LottoCrawler:
    """
    로또 당첨번호 크롤러
    
    동행복권 사이트에서 회차별 당첨번호 크롤링
    """
    
    def __init__(self):
        self.base_url = settings.LOTTO_CRAWLER_URL
        self.timeout = aiohttp.ClientTimeout(total=settings.CRAWLER_TIMEOUT)
        self.retry_count = settings.CRAWLER_RETRY
        self.session: Optional[aiohttp.ClientSession] = None
    
    async def __aenter__(self):
        """비동기 컨텍스트 매니저 진입"""
        self.session = aiohttp.ClientSession(timeout=self.timeout)
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """비동기 컨텍스트 매니저 종료"""
        if self.session:
            await self.session.close()
    
    async def get_latest_draw_number(self) -> Optional[int]:
        """
        최신 회차 번호 조회
        
        Returns:
            최신 회차 번호 또는 None (실패 시)
        """
        try:
            if not self.session:
                self.session = aiohttp.ClientSession(timeout=self.timeout)
            
            params = {'method': 'getLast'}
            async with self.session.get(self.base_url, params=params) as response:
                if response.status == 200:
                    html = await response.text()
                    draw_no = self._parse_draw_number(html)
                    logger.info(f"✅ 최신 회차: {draw_no}회")
                    return draw_no
                else:
                    logger.error(f"❌ HTTP {response.status} 오류")
                    return None
                    
        except asyncio.TimeoutError:
            logger.error("❌ 최신 회차 조회 타임아웃")
            return None
        except Exception as e:
            logger.error(f"❌ 최신 회차 조회 실패: {e}")
            return None
    
    def _parse_draw_number(self, html: str) -> Optional[int]:
        """HTML에서 회차 번호 추출"""
        try:
            soup = BeautifulSoup(html, 'html.parser')
            
            # 회차 번호 파싱
            draw_no_elem = soup.select_one('.win_result h4 strong')
            if draw_no_elem:
                text = draw_no_elem.text.strip()
                # "1169회" -> 1169
                match = re.search(r'(\d+)', text)
                if match:
                    return int(match.group(1))
            
            return None
        except Exception as e:
            logger.error(f"회차 번호 파싱 실패: {e}")
            return None
    
    async def crawl_single(self, draw_no: int) -> Optional[Dict]:
        """
        단일 회차 크롤링
        
        Args:
            draw_no: 회차 번호
            
        Returns:
            Dict: {
                'draw_no': int,
                'draw_date': str,
                'num1'~'num6': int,
                'bonus': int,
                'first_prize_amount': int,
                'first_winner_count': int
            }
        """
        for attempt in range(self.retry_count):
            try:
                if not self.session:
                    self.session = aiohttp.ClientSession(timeout=self.timeout)
                
                params = {'drwNo': draw_no}
                async with self.session.get(self.base_url, params=params) as response:
                    if response.status == 200:
                        html = await response.text()
                        data = self._parse_draw_data(html, draw_no)
                        
                        if data:
                            logger.debug(f"✅ {draw_no}회 크롤링 성공")
                            return data
                        else:
                            logger.warning(f"⚠️  {draw_no}회 파싱 실패")
                            
            except asyncio.TimeoutError:
                logger.warning(
                    f"⚠️  {draw_no}회 타임아웃 "
                    f"(시도 {attempt + 1}/{self.retry_count})"
                )
            except Exception as e:
                logger.warning(
                    f"⚠️  {draw_no}회 크롤링 오류 "
                    f"(시도 {attempt + 1}/{self.retry_count}): {e}"
                )
            
            # Exponential backoff
            if attempt < self.retry_count - 1:
                await asyncio.sleep(2 ** attempt)
        
        logger.error(f"❌ {draw_no}회 크롤링 최종 실패")
        return None
    
    def _parse_draw_data(self, html: str, draw_no: int) -> Optional[Dict]:
        """
        HTML에서 당첨번호 데이터 추출
        
        Args:
            html: HTML 문자열
            draw_no: 회차 번호
            
        Returns:
            Dict: 당첨번호 데이터
        """
        try:
            soup = BeautifulSoup(html, 'html.parser')
            
            # === 당첨번호 추출 (6개) ===
            numbers = []
            ball_elements = soup.select('.win .ball_645')
            
            if len(ball_elements) < 7:
                logger.error(f"{draw_no}회: 번호 요소 부족 ({len(ball_elements)}개)")
                return None
            
            for elem in ball_elements[:6]:
                try:
                    num = int(elem.text.strip())
                    if not 1 <= num <= 45:
                        logger.error(f"{draw_no}회: 범위 초과 번호 {num}")
                        return None
                    numbers.append(num)
                except ValueError:
                    logger.error(f"{draw_no}회: 번호 파싱 실패")
                    return None
            
            # === 보너스 번호 ===
            bonus = int(ball_elements[6].text.strip())
            
            # === 추첨일 추출 ===
            draw_date = self._parse_draw_date(soup, draw_no)
            
            # === 당첨금 정보 ===
            first_prize_amount = self._parse_prize_amount(soup)
            first_winner_count = self._parse_winner_count(soup)
            
            return {
                'draw_no': draw_no,
                'draw_date': draw_date,
                'num1': numbers[0],
                'num2': numbers[1],
                'num3': numbers[2],
                'num4': numbers[3],
                'num5': numbers[4],
                'num6': numbers[5],
                'bonus': bonus,
                'first_prize_amount': first_prize_amount,
                'first_winner_count': first_winner_count,
            }
            
        except Exception as e:
            logger.error(f"{draw_no}회 데이터 파싱 실패: {e}")
            return None
    
    def _parse_draw_date(self, soup: BeautifulSoup, draw_no: int) -> Optional[str]:
        """추첨일 파싱"""
        try:
            date_elem = soup.select_one('.win_result .desc')
            if date_elem:
                text = date_elem.text.strip()
                # "2024년 12월 30일 추첨" -> "2024-12-30"
                match = re.search(r'(\d{4})년\s*(\d{1,2})월\s*(\d{1,2})일', text)
                if match:
                    year, month, day = match.groups()
                    return f"{year}-{month.zfill(2)}-{day.zfill(2)}"
            
            logger.warning(f"{draw_no}회: 추첨일 파싱 실패")
            return None
        except Exception as e:
            logger.error(f"{draw_no}회: 추첨일 파싱 오류: {e}")
            return None
    
    def _parse_prize_amount(self, soup: BeautifulSoup) -> Optional[int]:
        """1등 당첨금 파싱"""
        try:
            prize_elem = soup.select_one('.tbl_data tbody tr:first-child td:nth-child(2)')
            if prize_elem:
                text = prize_elem.text.strip()
                # "1,234,567,890원" -> 1234567890
                amount_str = re.sub(r'[^\d]', '', text)
                return int(amount_str) if amount_str else None
            return None
        except Exception as e:
            logger.debug(f"당첨금 파싱 오류: {e}")
            return None
    
    def _parse_winner_count(self, soup: BeautifulSoup) -> Optional[int]:
        """1등 당첨자 수 파싱"""
        try:
            count_elem = soup.select_one('.tbl_data tbody tr:first-child td:nth-child(3)')
            if count_elem:
                text = count_elem.text.strip()
                count_str = re.sub(r'[^\d]', '', text)
                return int(count_str) if count_str else None
            return None
        except Exception as e:
            logger.debug(f"당첨자 수 파싱 오류: {e}")
            return None
    
    async def crawl_range(
        self,
        start_draw: int,
        end_draw: int,
        batch_size: int = 10
    ) -> List[Dict]:
        """
        범위 크롤링 (배치 처리)
        
        Args:
            start_draw: 시작 회차
            end_draw: 종료 회차
            batch_size: 동시 처리 개수
            
        Returns:
            List[Dict]: 크롤링된 데이터 리스트
        """
        results = []
        total = end_draw - start_draw + 1
        
        logger.info(f"📥 범위 크롤링 시작: {start_draw}~{end_draw}회 (총 {total}회)")
        
        for batch_start in range(start_draw, end_draw + 1, batch_size):
            batch_end = min(batch_start + batch_size - 1, end_draw)
            batch_draws = range(batch_start, batch_end + 1)
            
            # 배치 단위로 비동기 처리
            tasks = [self.crawl_single(draw_no) for draw_no in batch_draws]
            batch_results = await asyncio.gather(*tasks)
            
            # 성공한 결과만 추가
            valid_results = [r for r in batch_results if r is not None]
            results.extend(valid_results)
            
            success_count = len(valid_results)
            batch_size_actual = batch_end - batch_start + 1
            logger.info(
                f"  배치 완료: {batch_start}~{batch_end}회 "
                f"({success_count}/{batch_size_actual}개 성공)"
            )
            
            # 과부하 방지 딜레이
            await asyncio.sleep(0.5)
        
        logger.success(f"✅ 범위 크롤링 완료: {len(results)}/{total}개 성공")
        return results
```

### Step 1.3.2: 크롤러 테스트 스크립트

**파일**: `backend/scripts/test_crawler.py`

```python
"""
크롤러 테스트 스크립트

Usage:
    python scripts/test_crawler.py
"""

import asyncio
import sys
from pathlib import Path

# 프로젝트 루트를 Python 경로에 추가
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.core.crawler import LottoCrawler
from loguru import logger


async def main():
    """크롤러 테스트"""
    
    async with LottoCrawler() as crawler:
        # 테스트 1: 최신 회차 조회
        logger.info("=== 테스트 1: 최신 회차 조회 ===")
        latest = await crawler.get_latest_draw_number()
        logger.info(f"최신 회차: {latest}회\n")
        
        # 테스트 2: 단일 회차 크롤링
        logger.info("=== 테스트 2: 단일 회차 크롤링 ===")
        if latest:
            data = await crawler.crawl_single(latest)
            if data:
                logger.info(f"데이터: {data}\n")
        
        # 테스트 3: 범위 크롤링 (최근 5회)
        logger.info("=== 테스트 3: 범위 크롤링 (최근 5회) ===")
        if latest:
            results = await crawler.crawl_range(latest - 4, latest)
            logger.info(f"크롤링 성공: {len(results)}개")
            for r in results:
                logger.info(f"  {r['draw_no']}회: {r['num1']}, {r['num2']}, ...")


if __name__ == "__main__":
    asyncio.run(main())
```

### 완료 기준 체크리스트
- [ ] `crawler.py` 작성 완료
- [ ] `test_crawler.py` 실행 성공
- [ ] 최신 회차 조회 성공
- [ ] 단일 회차 크롤링 성공
- [ ] 범위 크롤링 (10회) 성공

---

## 작업 1.4: 데이터 검증기 (4시간)

**파일**: `backend/app/core/data_validator.py`

```python
"""
데이터 무결성 검증기

2026-01-04 EST - 초기 생성
"""

from typing import Dict, List, Any

import pandas as pd
from loguru import logger


class DataValidator:
    """
    로또 데이터 검증 클래스
    
    CSV/DataFrame의 무결성 검증
    """
    
    def validate_dataframe(self, df: pd.DataFrame) -> Dict[str, Any]:
        """
        DataFrame 전체 검증
        
        Args:
            df: 검증할 DataFrame
            
        Returns:
            Dict: {
                'valid': bool,
                'errors': List[str],
                'warnings': List[str],
                'fatal': bool
            }
        """
        errors = []
        warnings = []
        fatal = False
        
        # 1. 필수 컬럼 확인
        required_cols = ['회차', '추첨일', '번호1', '번호2', '번호3', 
                        '번호4', '번호5', '번호6', '보너스']
        missing_cols = [col for col in required_cols if col not in df.columns]
        
        if missing_cols:
            errors.append(f"필수 컬럼 누락: {missing_cols}")
            fatal = True
            return {
                'valid': False,
                'errors': errors,
                'warnings': [],
                'fatal': True
            }
        
        # 2. 회차 연속성 확인
        missing_draws = self._check_missing_draws(df)
        if missing_draws:
            warnings.append(f"누락된 회차: {missing_draws}")
        
        # 3. 번호 범위 확인
        invalid_numbers = self._check_number_ranges(df)
        if invalid_numbers:
            errors.append(f"범위 초과 번호 발견: {invalid_numbers}")
        
        # 4. 중복 회차 확인
        duplicates = self._check_duplicates(df)
        if duplicates:
            errors.append(f"중복 회차: {duplicates}")
        
        # 5. 날짜 형식 확인
        invalid_dates = self._check_date_format(df)
        if invalid_dates:
            warnings.append(f"잘못된 날짜 형식: {len(invalid_dates)}개")
        
        # 6. 번호 정렬 확인
        unsorted = self._check_number_sorting(df)
        if unsorted:
            warnings.append(f"정렬 안된 번호: {len(unsorted)}개 회차")
        
        valid = len(errors) == 0
        
        return {
            'valid': valid,
            'errors': errors,
            'warnings': warnings,
            'fatal': fatal
        }
    
    def _check_missing_draws(self, df: pd.DataFrame) -> List[int]:
        """누락된 회차 확인"""
        draws = sorted(df['회차'].tolist())
        if not draws:
            return []
        
        expected = set(range(draws[0], draws[-1] + 1))
        actual = set(draws)
        missing = sorted(expected - actual)
        
        return missing
    
    def _check_number_ranges(self, df: pd.DataFrame) -> List[Dict]:
        """번호 범위 확인 (1~45)"""
        invalid = []
        
        for idx, row in df.iterrows():
            for i in range(1, 7):
                num = row[f'번호{i}']
                if not (1 <= num <= 45):
                    invalid.append({
                        'draw_no': row['회차'],
                        'field': f'번호{i}',
                        'value': num
                    })
            
            bonus = row['보너스']
            if not (1 <= bonus <= 45):
                invalid.append({
                    'draw_no': row['회차'],
                    'field': '보너스',
                    'value': bonus
                })
        
        return invalid
    
    def _check_duplicates(self, df: pd.DataFrame) -> List[int]:
        """중복 회차 확인"""
        duplicates = df[df.duplicated(subset=['회차'], keep=False)]
        return duplicates['회차'].tolist()
    
    def _check_date_format(self, df: pd.DataFrame) -> List[int]:
        """날짜 형식 확인"""
        invalid = []
        
        for idx, row in df.iterrows():
            try:
                pd.to_datetime(row['추첨일'])
            except:
                invalid.append(row['회차'])
        
        return invalid
    
    def _check_number_sorting(self, df: pd.DataFrame) -> List[int]:
        """번호 정렬 확인"""
        unsorted = []
        
        for idx, row in df.iterrows():
            numbers = [row[f'번호{i}'] for i in range(1, 7)]
            if numbers != sorted(numbers):
                unsorted.append(row['회차'])
        
        return unsorted
```

### 완료 기준 체크리스트
- [ ] `data_validator.py` 작성 완료
- [ ] 샘플 DataFrame 검증 테스트
- [ ] 모든 검증 로직 동작 확인

---

## 작업 1.5: 데이터 매니저 (6시간)

### 목표
CSV와 PostgreSQL 간 데이터 동기화 관리

### Step 1.5.1: 데이터 매니저 구현

**파일**: `backend/app/core/data_manager.py`

```python
"""
데이터 매니저 - CSV ↔ PostgreSQL 동기화

2026-01-08 EST - 초기 생성
"""

import pandas as pd
from pathlib import Path
from typing import Optional, Dict
from sqlalchemy.orm import Session
from loguru import logger

from app.db.session import get_db
from app.db.models.lotto_draw import LottoDraw
from app.core.crawler import LottoCrawler
from app.core.data_validator import DataValidator


class DataManager:
    """로또 데이터 통합 관리"""
    
    def __init__(self, csv_path: str = "backend/data/raw/lotto_draws.csv"):
        self.csv_path = Path(csv_path)
        self.csv_path.parent.mkdir(parents=True, exist_ok=True)
        self.validator = DataValidator()
        self._df: Optional[pd.DataFrame] = None
    
    async def initialize(self) -> Dict:
        """
        데이터 매니저 초기화
        
        Returns:
            초기화 결과 딕셔너리
        """
        logger.info("📊 데이터 매니저 초기화 시작")
        
        result = {
            'csv_loaded': False,
            'db_synced': False,
            'total_draws': 0,
            'latest_draw': None
        }
        
        try:
            # 1. CSV 파일 확인 및 로드
            if self.csv_path.exists():
                self._df = pd.read_csv(self.csv_path)
                logger.info(f"✓ CSV 로드: {len(self._df)}행")
                result['csv_loaded'] = True
            else:
                logger.warning("CSV 파일 없음, 크롤링 시작")
                await self._initial_crawl()
                result['csv_loaded'] = True
            
            # 2. 데이터 검증
            validation = self.validator.validate(self._df)
            if validation['status'] == 'failed':
                logger.error(f"데이터 검증 실패: {validation['errors']}")
                return result
            
            # 3. PostgreSQL 동기화
            await self._sync_to_database()
            result['db_synced'] = True
            
            # 4. 결과 업데이트
            result['total_draws'] = len(self._df)
            result['latest_draw'] = int(self._df['회차'].max())
            
            logger.success(f"✅ 데이터 매니저 초기화 완료: {result['total_draws']}회차")
            return result
            
        except Exception as e:
            logger.error(f"데이터 매니저 초기화 오류: {e}")
            raise
    
    async def _initial_crawl(self):
        """초기 데이터 크롤링"""
        async with LottoCrawler() as crawler:
            # 최신 회차 확인
            latest = await crawler.get_latest_draw_number()
            if not latest:
                raise Exception("최신 회차 조회 실패")
            
            logger.info(f"최신 회차: {latest}회")
            
            # 최근 100회차 크롤링 (초기 데이터)
            start_no = max(1, latest - 99)
            draws = await crawler.crawl_range(start_no, latest)
            
            # DataFrame 생성
            self._df = pd.DataFrame(draws)
            
            # CSV 저장
            await self._save_to_csv()
    
    async def _save_to_csv(self):
        """DataFrame을 CSV로 저장"""
        self._df.to_csv(self.csv_path, index=False, encoding='utf-8-sig')
        logger.info(f"CSV 저장: {self.csv_path}")
    
    async def _sync_to_database(self):
        """PostgreSQL에 동기화"""
        db: Session = next(get_db())
        
        try:
            synced_count = 0
            
            for _, row in self._df.iterrows():
                draw_no = int(row['회차'])
                
                # 이미 존재하는지 확인
                existing = db.query(LottoDraw).filter_by(draw_no=draw_no).first()
                if existing:
                    continue
                
                # 새 레코드 생성
                draw = LottoDraw(
                    draw_no=draw_no,
                    draw_date=pd.to_datetime(row['추첨일']),
                    num1=int(row['번호1']),
                    num2=int(row['번호2']),
                    num3=int(row['번호3']),
                    num4=int(row['번호4']),
                    num5=int(row['번호5']),
                    num6=int(row['번호6']),
                    bonus=int(row['보너스']),
                    prize_amount=int(row['1등당첨금']) if '1등당첨금' in row else 0
                )
                
                db.add(draw)
                synced_count += 1
            
            db.commit()
            logger.info(f"PostgreSQL 동기화: {synced_count}건 추가")
            
        except Exception as e:
            db.rollback()
            logger.error(f"DB 동기화 오류: {e}")
            raise
        finally:
            db.close()
    
    def get_dataframe(self) -> pd.DataFrame:
        """전체 데이터 DataFrame 반환"""
        if self._df is None:
            raise Exception("데이터가 로드되지 않았습니다")
        return self._df.copy()
    
    async def check_for_updates(self) -> Dict:
        """
        최신 회차 확인 및 업데이트
        
        Returns:
            업데이트 결과
        """
        result = {
            'has_update': False,
            'new_draws': [],
            'latest_draw': None
        }
        
        try:
            # 현재 최신 회차
            current_latest = int(self._df['회차'].max())
            
            # 웹에서 최신 회차 확인
            async with LottoCrawler() as crawler:
                web_latest = await crawler.get_latest_draw_number()
                
                if web_latest > current_latest:
                    logger.info(f"새 회차 발견: {current_latest + 1} ~ {web_latest}")
                    
                    # 새 회차 크롤링
                    new_draws = await crawler.crawl_range(current_latest + 1, web_latest)
                    
                    # DataFrame 업데이트
                    new_df = pd.DataFrame(new_draws)
                    self._df = pd.concat([self._df, new_df], ignore_index=True)
                    
                    # CSV 저장
                    await self._save_to_csv()
                    
                    # DB 동기화
                    await self._sync_to_database()
                    
                    result['has_update'] = True
                    result['new_draws'] = new_draws
                    result['latest_draw'] = web_latest
                    
                    logger.success(f"✅ 업데이트 완료: {len(new_draws)}건")
                else:
                    logger.info("이미 최신 상태")
            
            return result
            
        except Exception as e:
            logger.error(f"업데이트 확인 오류: {e}")
            raise


# 전역 인스턴스
data_manager = DataManager()
```

### 완료 기준 체크리스트
- [ ] `data_manager.py` 작성 완료
- [ ] `initialize()` 메서드 동작 확인
- [ ] CSV ↔ PostgreSQL 동기화 확인
- [ ] `check_for_updates()` 메서드 동작 확인

---

## 작업 1.6: 캐시 매니저 (2시간)

### 목표
Redis를 이용한 캐싱 구현

### Step 1.6.1: 캐시 매니저 구현

**파일**: `backend/app/core/cache_manager.py`

```python
"""
캐시 매니저 - Redis 캐싱

2026-01-08 EST - 초기 생성
"""

import json
from typing import Optional, Any
from redis import Redis
from loguru import logger

from app.config import settings


class CacheManager:
    """Redis 캐시 관리"""
    
    def __init__(self):
        self.redis: Optional[Redis] = None
    
    def connect(self):
        """Redis 연결"""
        try:
            self.redis = Redis.from_url(
                settings.REDIS_URL,
                decode_responses=True
            )
            self.redis.ping()
            logger.info("✓ Redis 연결 성공")
        except Exception as e:
            logger.error(f"Redis 연결 실패: {e}")
            self.redis = None
    
    def get(self, key: str) -> Optional[Any]:
        """캐시 조회"""
        if not self.redis:
            return None
        
        try:
            value = self.redis.get(key)
            if value:
                return json.loads(value)
            return None
        except Exception as e:
            logger.error(f"캐시 조회 오류 ({key}): {e}")
            return None
    
    def set(self, key: str, value: Any, ttl: int = 3600):
        """
        캐시 저장
        
        Args:
            key: 캐시 키
            value: 저장할 값
            ttl: 만료 시간 (초), 기본 1시간
        """
        if not self.redis:
            return
        
        try:
            self.redis.setex(
                key,
                ttl,
                json.dumps(value, ensure_ascii=False)
            )
            logger.debug(f"캐시 저장: {key} (TTL={ttl}s)")
        except Exception as e:
            logger.error(f"캐시 저장 오류 ({key}): {e}")
    
    def delete(self, key: str):
        """캐시 삭제"""
        if not self.redis:
            return
        
        try:
            self.redis.delete(key)
            logger.debug(f"캐시 삭제: {key}")
        except Exception as e:
            logger.error(f"캐시 삭제 오류 ({key}): {e}")
    
    def clear_pattern(self, pattern: str):
        """패턴 매칭 캐시 삭제"""
        if not self.redis:
            return
        
        try:
            keys = self.redis.keys(pattern)
            if keys:
                self.redis.delete(*keys)
                logger.info(f"캐시 삭제: {len(keys)}개 ({pattern})")
        except Exception as e:
            logger.error(f"패턴 캐시 삭제 오류 ({pattern}): {e}")


# 전역 인스턴스
cache_manager = CacheManager()
```

---

### Step 1.6.2: FastAPI에 통합

**파일**: `backend/app/main.py` (수정)

```python
"""
FastAPI 메인 애플리케이션

2026-01-08 EST - 캐시 매니저 통합
"""

from fastapi import FastAPI
from contextlib import asynccontextmanager

from app.core.data_manager import data_manager
from app.core.cache_manager import cache_manager


@asynccontextmanager
async def lifespan(app: FastAPI):
    """앱 생명주기 관리"""
    # Startup
    print("🚀 FastAPI 시작...")
    
    # Redis 연결
    cache_manager.connect()
    
    # 데이터 매니저 초기화
    await data_manager.initialize()
    
    yield
    
    # Shutdown
    print("👋 FastAPI 종료...")


app = FastAPI(
    title="LuckyAI 645 API",
    version="1.0.0",
    lifespan=lifespan
)


@app.get("/health")
async def health_check():
    """헬스 체크"""
    return {
        "status": "healthy",
        "service": "LuckyAI 645 API"
    }
```

### 완료 기준 체크리스트
- [ ] `cache_manager.py` 작성 완료
- [ ] Redis 연결 확인
- [ ] 캐시 저장/조회 테스트
- [ ] FastAPI에 통합 완료

---

## 작업 1.7: 통합 테스트 스크립트 (1시간)

### 크롤러 테스트 스크립트

**파일**: `backend/scripts/test_crawler.py`

```python
"""
크롤러 테스트 스크립트

2026-01-08 EST - 초기 생성
"""

import asyncio
from app.core.crawler import LottoCrawler


async def main():
    print("=== 로또 크롤러 테스트 ===\n")
    
    async with LottoCrawler() as crawler:
        # 1. 최신 회차 조회
        print("[1] 최신 회차 조회...")
        latest = await crawler.get_latest_draw_number()
        print(f"   최신 회차: {latest}회\n")
        
        # 2. 특정 회차 크롤링 (1회)
        print("[2] 1회차 크롤링...")
        draw = await crawler.crawl_single(1)
        if draw:
            print(f"   회차: {draw['draw_no']}")
            print(f"   날짜: {draw['draw_date']}")
            print(f"   번호: {draw['numbers']}")
            print(f"   보너스: {draw['bonus']}\n")
        
        # 3. 범위 크롤링 (최근 10회)
        print(f"[3] {latest-9}~{latest}회 크롤링...")
        draws = await crawler.crawl_range(latest - 9, latest)
        print(f"   크롤링 완료: {len(draws)}건\n")
    
    print("=== 테스트 완료 ===")


if __name__ == "__main__":
    asyncio.run(main())
```

**실행**:
```bash
cd backend
python scripts/test_crawler.py
```

---

### 데이터 매니저 테스트 스크립트

**파일**: `backend/scripts/test_data_manager.py`

```python
"""
데이터 매니저 테스트 스크립트

2026-01-08 EST - 초기 생성
"""

import asyncio
from app.core.data_manager import data_manager


async def main():
    print("=== 데이터 매니저 테스트 ===\n")
    
    # 1. 초기화
    print("[1] 초기화...")
    result = await data_manager.initialize()
    print(f"   CSV 로드: {result['csv_loaded']}")
    print(f"   DB 동기화: {result['db_synced']}")
    print(f"   총 회차: {result['total_draws']}")
    print(f"   최신 회차: {result['latest_draw']}\n")
    
    # 2. DataFrame 조회
    print("[2] DataFrame 조회...")
    df = data_manager.get_dataframe()
    print(f"   행 수: {len(df)}")
    print(f"   컬럼: {list(df.columns)}\n")
    
    # 3. 업데이트 확인
    print("[3] 업데이트 확인...")
    update_result = await data_manager.check_for_updates()
    print(f"   업데이트 있음: {update_result['has_update']}")
    if update_result['has_update']:
        print(f"   새 회차: {len(update_result['new_draws'])}건\n")
    
    print("=== 테스트 완료 ===")


if __name__ == "__main__":
    asyncio.run(main())
```

**실행**:
```bash
cd backend
python scripts/test_data_manager.py
```

### 완료 기준 체크리스트
- [ ] `test_crawler.py` 실행 성공
- [ ] `test_data_manager.py` 실행 성공
- [ ] 크롤링 → CSV → PostgreSQL 전체 플로우 동작 확인

---

## 🧪 Phase 1 테스트 (필수)

### 자동 테스트 스크립트

**파일**: `backend/tests/test_phase1_core.py`

```python
"""
Phase 1 백엔드 Core 자동 테스트

2026-01-08 EST - 초기 생성
"""

import pytest
import asyncio
from datetime import datetime
from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from app.db.base import Base
from app.db.models.lotto_draw import LottoDraw
from app.db.models.user import User
from app.core.crawler import LottoCrawler
from app.core.data_validator import DataValidator
from app.config import settings


@pytest.fixture
def test_db():
    """테스트용 DB 생성"""
    engine = create_engine('sqlite:///:memory:')
    Base.metadata.create_all(engine)
    session = Session(engine)
    yield session
    session.close()


def test_lotto_draw_model(test_db):
    """LottoDraw 모델 테스트"""
    draw = LottoDraw(
        draw_no=1,
        draw_date=datetime(2024, 1, 1),
        num1=1, num2=2, num3=3, num4=4, num5=5, num6=6,
        bonus=7,
        prize_amount=1000000000
    )
    
    test_db.add(draw)
    test_db.commit()
    
    # 조회 테스트
    result = test_db.query(LottoDraw).filter_by(draw_no=1).first()
    assert result is not None
    assert result.num1 == 1
    assert result.get_numbers() == [1, 2, 3, 4, 5, 6]


def test_user_model(test_db):
    """User 모델 테스트"""
    user = User(
        email='test@example.com',
        username='testuser'
    )
    
    test_db.add(user)
    test_db.commit()
    
    result = test_db.query(User).filter_by(email='test@example.com').first()
    assert result is not None
    assert result.username == 'testuser'


@pytest.mark.asyncio
async def test_crawler_get_latest():
    """크롤러 최신 회차 조회 테스트"""
    async with LottoCrawler() as crawler:
        latest = await crawler.get_latest_draw_number()
        assert latest is not None
        assert isinstance(latest, int)
        assert latest > 1000  # 최소 1000회 이상


@pytest.mark.asyncio
async def test_crawler_single_draw():
    """크롤러 단일 회차 크롤링 테스트"""
    async with LottoCrawler() as crawler:
        # 1회 크롤링 (확실히 존재하는 회차)
        data = await crawler.crawl_single(1)
        
        assert data is not None
        assert data['draw_no'] == 1
        assert len(data['numbers']) == 6
        assert all(1 <= n <= 45 for n in data['numbers'])
        assert 1 <= data['bonus'] <= 45


def test_data_validator():
    """데이터 검증기 테스트"""
    import pandas as pd
    
    validator = DataValidator()
    
    # 정상 데이터
    valid_df = pd.DataFrame({
        '회차': [1, 2, 3],
        '추첨일': ['2024-01-01', '2024-01-08', '2024-01-15'],
        '번호1': [1, 2, 3],
        '번호2': [2, 3, 4],
        '번호3': [3, 4, 5],
        '번호4': [4, 5, 6],
        '번호5': [5, 6, 7],
        '번호6': [6, 7, 8],
        '보너스': [7, 8, 9],
    })
    
    result = validator.validate(valid_df)
    assert result['status'] == 'passed'
    assert len(result['errors']) == 0
    
    # 비정상 데이터 (범위 초과)
    invalid_df = valid_df.copy()
    invalid_df.loc[0, '번호1'] = 50  # 45 초과
    
    result = validator.validate(invalid_df)
    assert result['status'] == 'failed'
    assert len(result['errors']) > 0


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
```

**실행 방법**:
```bash
cd backend
pytest tests/test_phase1_core.py -v
```

---

### 자동 테스트 체크리스트

**실행 명령**: `pytest tests/test_phase1_core.py -v`

- [ ] ✅ `test_lotto_draw_model` - LottoDraw 모델
- [ ] ✅ `test_user_model` - User 모델
- [ ] ✅ `test_crawler_get_latest` - 최신 회차 조회
- [ ] ✅ `test_crawler_single_draw` - 단일 회차 크롤링
- [ ] ✅ `test_data_validator` - 데이터 검증

**예상 결과**: 5 passed (20-30초 소요)

---

### 수동 테스트 체크리스트

#### 1. 데이터베이스 마이그레이션 확인
```bash
cd backend
alembic current
alembic history
```
**확인 사항**:
- [ ] 마이그레이션 파일 생성 완료
- [ ] 현재 리비전 표시
- [ ] `lotto_draws`, `users` 테이블 존재

#### 2. 크롤러 수동 실행
```bash
python scripts/test_crawler.py
```
**확인 사항**:
- [ ] 최신 회차 조회 성공
- [ ] 단일 회차 크롤링 성공
- [ ] 배치 크롤링 성공 (10개 회차)
- [ ] 콘솔에 데이터 출력

#### 3. PostgreSQL 데이터 확인
```bash
docker exec -it lotto645_postgres psql -U lotto_user -d lotto645_dev
```
**SQL**:
```sql
-- 테이블 목록
\dt

-- lotto_draws 스키마 확인
\d lotto_draws

-- 샘플 데이터 확인
SELECT * FROM lotto_draws LIMIT 5;

-- 데이터 개수
SELECT COUNT(*) FROM lotto_draws;
```
**확인 사항**:
- [ ] `lotto_draws` 테이블 존재
- [ ] `users` 테이블 존재
- [ ] 크롤링된 데이터 저장 확인

#### 4. Redis 캐싱 테스트
```bash
docker exec -it lotto645_redis redis-cli
```
**Redis 명령**:
```redis
# 캐시 키 목록
KEYS *

# 최신 회차 캐시 확인
GET latest_draw

# TTL 확인
TTL latest_draw
```
**확인 사항**:
- [ ] 캐시 키 존재
- [ ] TTL이 설정되어 있음 (3600초 = 1시간)
- [ ] 캐시 데이터 정상

#### 5. CSV 파일 생성 확인
```powershell
cd backend\data\raw
ls
cat lotto_draws.csv | head -10
```
**확인 사항**:
- [ ] `lotto_draws.csv` 파일 존재
- [ ] CSV 헤더 정상 (회차,추첨일,번호1-6,보너스,...)
- [ ] 데이터 행 존재

#### 6. 설정 파일 로드 테스트
```bash
cd backend
python -c "from app.config import settings; print(settings.DATABASE_URL)"
```
**확인 사항**:
- [ ] DATABASE_URL 출력
- [ ] 오류 없음

#### 7. 로그 파일 확인
```bash
cd backend/results/logs
ls
tail -50 crawler.log
```
**확인 사항**:
- [ ] 로그 파일 생성
- [ ] 크롤링 로그 기록
- [ ] 오류 로그 없음 (또는 예상된 오류만)

---

### Phase 1 통합 테스트 스크립트

**파일**: `scripts/test_phase1.ps1`

```powershell
# Phase 1 통합 테스트 스크립트

Write-Host "=== Phase 1 통합 테스트 시작 ===" -ForegroundColor Cyan

# 1. 자동 테스트 실행
Write-Host "`n[1] 자동 테스트 실행..." -ForegroundColor Yellow
cd backend
pytest tests/test_phase1_core.py -v
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ 자동 테스트 실패" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ 자동 테스트 통과" -ForegroundColor Green
cd ..

# 2. 마이그레이션 확인
Write-Host "`n[2] 마이그레이션 확인..." -ForegroundColor Yellow
cd backend
$currentRev = alembic current 2>&1
if ($currentRev -match "head") {
    Write-Host "  ✓ 마이그레이션 최신" -ForegroundColor Green
} else {
    Write-Host "  ! 마이그레이션 필요" -ForegroundColor Yellow
}
cd ..

# 3. 크롤러 테스트
Write-Host "`n[3] 크롤러 테스트..." -ForegroundColor Yellow
cd backend
python scripts/test_crawler.py > $null 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ 크롤러 동작 정상" -ForegroundColor Green
} else {
    Write-Host "  ✗ 크롤러 오류" -ForegroundColor Red
}
cd ..

# 4. DB 데이터 확인
Write-Host "`n[4] DB 데이터 확인..." -ForegroundColor Yellow
$count = docker exec lotto645_postgres psql -U lotto_user -d lotto645_dev -t -c "SELECT COUNT(*) FROM lotto_draws;"
if ($count -gt 0) {
    Write-Host "  ✓ 데이터 저장됨 ($count 행)" -ForegroundColor Green
} else {
    Write-Host "  ! 데이터 없음 (정상일 수 있음)" -ForegroundColor Yellow
}

# 5. Redis 캐시 확인
Write-Host "`n[5] Redis 캐시 확인..." -ForegroundColor Yellow
$keys = docker exec lotto645_redis redis-cli KEYS "*"
if ($keys) {
    Write-Host "  ✓ 캐시 키 존재: $keys" -ForegroundColor Green
} else {
    Write-Host "  ! 캐시 없음 (정상일 수 있음)" -ForegroundColor Yellow
}

# 6. CSV 파일 확인
Write-Host "`n[6] CSV 파일 확인..." -ForegroundColor Yellow
if (Test-Path "backend\data\raw\lotto_draws.csv") {
    $lines = (Get-Content "backend\data\raw\lotto_draws.csv").Count
    Write-Host "  ✓ CSV 파일 존재 ($lines 행)" -ForegroundColor Green
} else {
    Write-Host "  ! CSV 파일 없음 (정상일 수 있음)" -ForegroundColor Yellow
}

Write-Host "`n=== Phase 1 테스트 완료! ===" -ForegroundColor Cyan
Write-Host "Phase 2로 진행 가능합니다." -ForegroundColor Green
```

**실행**:
```powershell
.\scripts\test_phase1.ps1
```

---

**Phase 1 완료**

다음: [Phase 2 - 백엔드 알고리즘 & API](010_Phase_2_Backend_Algorithms.md)

