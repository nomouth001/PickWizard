"""
FastAPI 메인 애플리케이션

2026-01-04 EST - 초기 생성
"""

from contextlib import asynccontextmanager

from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import RedirectResponse
from loguru import logger

from app.config import settings
from app.db.base import Base, engine
from app.core.cache_manager import cache_manager
from app.core.data_manager import data_manager
from app.algorithms import load_all_algorithms
from app.api.routes import generation, draws, algorithms, pricing, auth, coins, my_numbers, users, admin, ads
from app.services.pricing_service import get_pricing_service


@asynccontextmanager
async def lifespan(app: FastAPI):
    """애플리케이션 수명 주기 이벤트"""
    
    # === 시작 시 ===
    logger.info("[START] PickWizard 서버 시작 중...")
    
    try:
        # 1. 데이터베이스 테이블 생성
        logger.info("데이터베이스 초기화 중...")
        Base.metadata.create_all(bind=engine)
        logger.success("[INFO] 데이터베이스 준비 완료")
        
        # 2. Redis 연결
        logger.info("Redis 연결 중...")
        cache_manager.connect()
        
        # 3. 가격 정책 로드
        logger.info("가격 정책 로드 중...")
        get_pricing_service()
        
        # 4. 알고리즘 로드
        logger.info("알고리즘 로드 중...")
        load_all_algorithms()
        
        # 5. 데이터 매니저 초기화
        logger.info("데이터 매니저 초기화 중...")
        try:
            await data_manager.initialize()
        except Exception as e:
            logger.warning(f"[WARN] 데이터 매니저 초기화 실패 (개발 모드에서는 무시): {e}")
            logger.info("크롤링 없이 서버 시작 (수동으로 데이터 추가 가능)")
        
        logger.success("[SUCCESS] 서버 시작 완료!")
        
    except Exception as e:
        logger.error(f"[ERROR] 서버 시작 실패: {e}")
        raise
    
    yield
    
    # === 종료 시 ===
    logger.info("서버 종료 중...")


# FastAPI 앱 생성
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="AI 기반 로또 번호 생성 백엔드 API",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS 설정
# 2026-01-07 13:15:00 EST - Flutter Web CORS 문제 해결
# 개발 환경: 모든 origin 허용 (credential=True와 "*" 충돌 방지)
# 프로덕션: 화이트리스트만 허용
if settings.DEBUG or settings.ENVIRONMENT == "development":
    # 개발 환경: 모든 origin 허용
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
    )
else:
    # 프로덕션: 화이트리스트만
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

# 라우터 등록
# 2026-01-07 16:35:00 EST - Flutter 앱과 경로 일치를 위해 /v1 제거
# 2026-01-08 03:40:00 EST - Pricing API 추가
# 2026-01-08 08:25:00 EST - Auth, Coins API 추가
# 2026-01-16 04:30:00 EST - My Numbers API 추가
app.include_router(auth.router, prefix="/api")
app.include_router(users.router, prefix="/api")
app.include_router(coins.router, prefix="/api", tags=["코인"])
app.include_router(my_numbers.router, prefix="/api", tags=["내 번호"])
app.include_router(generation.router, prefix="/api/generation", tags=["번호 생성"])
app.include_router(draws.router, prefix="/api/draws", tags=["회차 정보"])
app.include_router(algorithms.router, prefix="/api/algorithms", tags=["알고리즘"])
app.include_router(pricing.router, prefix="/api/pricing", tags=["가격 정책"])
# 2026-02-14 EST - 035 Admin 웹 진입·인증 설계 구현
app.include_router(admin.router, prefix="/api", tags=["Admin"])
# 041 AdMob SSV callback
app.include_router(ads.router, prefix="/api", tags=["Ads"])


@app.get("/")
async def root():
    """루트 엔드포인트"""
    return {
        "service": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "running"
    }


@app.get("/health")
async def health_check():
    """헬스 체크"""
    return {"status": "healthy"}


# 2026-02-14 EST - 035 Admin 정적 파일 서빙 (redirect 먼저 등록하여 /admin 정확 매칭)
@app.get("/admin", include_in_schema=False)
async def admin_redirect():
    """ /admin → /admin/ (index.html 서빙) """
    return RedirectResponse(url="/admin/", status_code=302)

_admin_static_dir = Path(__file__).resolve().parent / "static" / "admin"
if _admin_static_dir.exists():
    app.mount("/admin", StaticFiles(directory=str(_admin_static_dir), html=True), name="admin_static")

