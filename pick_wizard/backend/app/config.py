"""
애플리케이션 설정 관리

2026-01-04 EST - 초기 생성
"""

from pathlib import Path
from typing import Optional, Dict, Any, ClassVar

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    환경 변수 기반 설정 클래스
    
    .env 파일에서 자동 로드
    """
    
    # === 애플리케이션 ===
    APP_NAME: str = "PickWizard"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    ENVIRONMENT: str = "development"
    
    # === 서버 ===
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    
    # === 데이터베이스 ===
    # 개발: None (자동으로 SQLite 사용)
    # 프로덕션: .env에 PostgreSQL URL 설정 필수
    DATABASE_URL: Optional[str] = None
    USE_SQLITE: bool = True  # 개발: true, 프로덕션: .env에서 false
    
    # === Redis ===
    # 개발: 아래 기본값 사용
    # 프로덕션: .env에 인증 포함된 URL 설정 권장
    REDIS_URL: str = "redis://localhost:6379/0"
    CACHE_TTL: int = 3600
    
    # === Celery ===
    # 개발: 아래 기본값 사용
    # 프로덕션: .env에서 REDIS_URL과 함께 설정 권장
    CELERY_BROKER_URL: str = "redis://localhost:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/1"
    CELERY_TIMEZONE: str = "Asia/Seoul"
    
    # === 보안 ===
    # 🔴 프로덕션 필수: .env에 JWT_SECRET_KEY 설정
    # 개발 환경: 아래 기본값 사용 (보안 취약, 프로덕션 사용 금지)
    # 프로덕션: .env에 안전한 랜덤 문자열 설정 (최소 32자)
    JWT_SECRET_KEY: str = "INSECURE_DEV_KEY_CHANGE_IN_PRODUCTION"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    # 034 Phase 1: OAuth Access JWT 단일 토큰 만료 (7일)
    ACCESS_TOKEN_EXPIRE_DAYS: int = 7
    
    # === 로또 크롤링 ===
    LOTTO_CRAWLER_URL: str = "https://www.dhlottery.co.kr/gameResult.do?method=byWin"
    CRAWLER_TIMEOUT: int = 10
    CRAWLER_RETRY: int = 3
    
    # === 파일 경로 ===
    BASE_DIR: Path = Path(__file__).resolve().parent.parent
    LOTTO_CSV_PATH: Path = BASE_DIR / "data" / "raw" / "lotto_data.csv"
    MODEL_DIR: Path = BASE_DIR / "data" / "models"
    
    # === Firebase (Push 알림) ===
    # 🔴 필수: .env에 설정
    FIREBASE_CREDENTIALS_PATH: Optional[str] = None
    FIREBASE_CREDENTIALS_JSON: Optional[str] = None
    
    # === 인앱 결제 ===
    # 🔴 필수: .env에 설정
    GOOGLE_SERVICE_ACCOUNT_KEY: Optional[str] = None
    APPLE_SHARED_SECRET: Optional[str] = None
    
    # === 광고 ===
    # 🔴 필수: .env에 설정
    ADMOB_SECRET_KEY: Optional[str] = None
    
    # === 소셜 로그인 ===
    # 🔴 SECRET 필수: .env에 설정
    # ⚠️ CLIENT_ID 권장: .env에 설정
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
    # 2026-01-07 16:35:00 EST - 개발 환경에서 모든 origin 허용 (Flutter Web CORS 문제 해결)
    CORS_ORIGINS: list[str] = ["*"]

    # === Admin 웹 (035 설계) ===
    # 2026-02-14 EST - Admin 진입·레이아웃·인증 설계안(035) 구현
    # X-Admin-Token 검증용. 프로덕션: .env에 안전한 랜덤 문자열 필수
    ADMIN_SECRET_TOKEN: Optional[str] = None

    # === 코인/지갑 (043: 수익모델 광고 전용화) ===
    # 2026-02-20 - false: 코인 차감/지갑 미사용(광고만 수익), true: 코인·지갑 사용
    COIN_WALLET_ENABLED: bool = False
    
    # === Google Gemini API (AI Selection 알고리즘) ===
    # 2026-01-18 EST - AI Selection 알고리즘 (Algorithm 8) 구현
    # 2026-01-18 EST - max_tokens 1000 → 2000 (응답 잘림 방지)
    # 2026-01-18 EST - timeout 30 → 60초 (AI 응답 시간 충분히 확보)
    # 2026-01-18 EST - window_size 200 → 100 (입력 토큰 절반, 출력 여유 확보)
    # 
    # 🔴 필수: .env에 GOOGLE_API_KEY만 설정
    GOOGLE_API_KEY: Optional[str] = None
    # 
    # ⚠️ 주의: 아래 설정들은 절대 .env에 넣지 마세요!
    # config.py에서만 관리합니다. 값 변경은 이 파일을 직접 수정하세요.
    # .env에 있으면 이 값들을 오버라이드하여 혼란을 초래합니다.
    AI_SELECTION_MODEL: str = "gemini-2.5-flash"
    AI_SELECTION_TEMPERATURE: float = 0.7
    AI_SELECTION_MAX_TOKENS: int = 8000
    AI_SELECTION_TIMEOUT: int = 60
    AI_SELECTION_WINDOW_SIZE: int = 100
    
    # === Google Gemini API 비용 설정 ===
    # 2026-01-18 21:30:00 EST - Google Gemini 2.5 Flash 공식 가격표 (as-of-20260118)
    # Source: https://ai.google.dev/pricing
    # 
    # Paid Tier, per 1M tokens in USD:
    # - Input price: $0.30 (text/image/video), $1.00 (audio)
    # - Output price: $2.50 (including thinking tokens)
    # 
    # ⚠️ 이전 코드 오류: 1/100로 잘못 계산 중이었음
    # - 잘못된 값: input $0.00001/1K, output $0.00003/1K
    # - 올바른 값: input $0.30/1M, output $2.50/1M
    # 
    # 2026-01-18 22:00:00 EST - ClassVar 사용 (Pydantic 타입 어노테이션 필수)
    GEMINI_PRICING: ClassVar[Dict[str, Dict[str, Any]]] = {
        "gemini-2.5-flash": {
            "input_per_1m": 0.30,         # $/1M tokens (text/image/video)
            "output_per_1m": 2.50,        # $/1M tokens (including thinking tokens)
            "audio_input_per_1m": 1.00,   # $/1M tokens (audio, if used)
            "updated": "2026-01-18"
        }
    }
    
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
        
        # 데이터베이스 URL 자동 설정
        if not self.DATABASE_URL:
            if self.USE_SQLITE or self.ENVIRONMENT == "development":
                # SQLite 사용 (개발 환경)
                db_dir = self.BASE_DIR / "data" / "database"
                db_dir.mkdir(parents=True, exist_ok=True)
                db_path = db_dir / "luckyai645.db"
                self.DATABASE_URL = f"sqlite:///{db_path}"
                print(f"Using SQLite: {self.DATABASE_URL}")
            else:
                # PostgreSQL 사용 (프로덕션 환경)
                raise ValueError(
                    "DATABASE_URL must be set for production environment. "
                    "Example: postgresql://user:password@localhost:5432/dbname"
                )


# 전역 설정 인스턴스
settings = Settings()

