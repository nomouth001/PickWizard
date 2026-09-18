# .env 환경 변수 설정 가이드

## 📍 파일 위치
```
C:\_PythonWorkspace\_Lotto_picker\pick_wizard\backend\.env
```

## 📝 필수 설정 내용

```bash
# === 애플리케이션 설정 ===
APP_NAME=LuckyAI 645
APP_VERSION=1.0.0
DEBUG=True
ENVIRONMENT=development

# === 서버 설정 ===
HOST=0.0.0.0
PORT=8000

# === 데이터베이스 ===
# 개발 환경 (로컬 Docker)
DATABASE_URL=postgresql://lotto_user:lotto_pass@localhost:5432/lotto645_dev

# 프로덕션 환경 (AWS RDS) - 나중에 설정
# DATABASE_URL=postgresql://user:pass@rds-endpoint:5432/lotto645_prod

# === Redis ===
REDIS_URL=redis://localhost:16379/0
CACHE_TTL=3600

# === Celery ===
CELERY_BROKER_URL=redis://localhost:16379/0
CELERY_RESULT_BACKEND=redis://localhost:16379/1
CELERY_TIMEZONE=Asia/Seoul

# === 보안 ===
# 중요: 프로덕션에서는 반드시 변경하세요!
JWT_SECRET_KEY=your-secret-key-change-in-production-min-32-characters-long-string-here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# === 로또 크롤링 ===
LOTTO_CRAWLER_URL=https://www.dhlottery.co.kr/gameResult.do?method=byWin
CRAWLER_TIMEOUT=10
CRAWLER_RETRY=3

# === 파일 경로 ===
LOTTO_CSV_PATH=data/raw/lotto_data.csv
MODEL_DIR=data/models

# === Firebase (Push 알림) - 선택 사항 ===
# FIREBASE_CREDENTIALS_PATH=path/to/firebase-credentials.json
# FIREBASE_CREDENTIALS_JSON={}

# === 인앱 결제 (IAP) - 선택 사항 ===
# GOOGLE_SERVICE_ACCOUNT_KEY=path/to/google-service-account.json
# APPLE_SHARED_SECRET=your_apple_shared_secret

# === 광고 (AdMob) - 선택 사항 ===
# ADMOB_SECRET_KEY=your_admob_ssv_secret_key

# === 소셜 로그인 - 선택 사항 ===
# GOOGLE_CLIENT_ID=your-google-oauth-client-id.apps.googleusercontent.com
# GOOGLE_CLIENT_SECRET=GOCSPX-xxxxxxxxxxxxxxxxxxxxxxxxx
# APPLE_CLIENT_ID=com.luckyai.luckyai645
# KAKAO_REST_API_KEY=your_kakao_rest_api_key
# NAVER_CLIENT_ID=your_naver_client_id
# NAVER_CLIENT_SECRET=your_naver_client_secret

# === 로깅 ===
LOG_LEVEL=INFO
LOG_FILE=logs/app.log

# === CORS ===
CORS_ORIGINS=["http://localhost:3000","http://localhost:8080"]
```

## ⚠️ 중요 사항

1. **파일 생성 방법**:
   ```bash
   cd C:\_PythonWorkspace\_Lotto_picker\pick_wizard\backend
   Copy-Item .env.example .env
   # 그리고 위 내용으로 수정
   ```

2. **필수 변경 항목**:
   - `JWT_SECRET_KEY`: 최소 32자 이상의 랜덤 문자열
   - `DATABASE_URL`: Docker 실행 후 PostgreSQL 연결 정보 확인

3. **Docker 실행 후 확인**:
   ```bash
   # Docker Compose 실행
   cd deployment/docker
   docker-compose up -d
   
   # PostgreSQL 연결 확인
   docker exec -it lotto645_postgres psql -U lotto_user -d lotto645_dev
   ```

4. **보안**:
   - `.env` 파일은 `.gitignore`에 포함되어 있어 Git에 커밋되지 않음
   - 절대 공개 저장소에 올리지 말 것
   - 프로덕션 환경에서는 반드시 다른 비밀키 사용

## 🔍 설정 확인 방법

```bash
cd backend
python -c "from app.config import settings; print(f'DB: {settings.DATABASE_URL}'); print(f'Redis: {settings.REDIS_URL}')"
```

정상적으로 출력되면 설정 완료!

---

**작성일**: 2026-01-04 EST  
**작성자**: AI Assistant

