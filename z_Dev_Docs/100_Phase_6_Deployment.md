# Phase 6: 배포 준비
## Docker, CI/CD, AWS Lightsail, Flutter 빌드

---

**Phase**: 6 - Deployment & Production  
**예상 기간**: 2일 (16시간)  
**선행 조건**: Phase 5 완료 (모든 기능 구현)  
**목표**: 프로덕션 환경 배포 및 최종 테스트

---

## 📋 Phase 개요

### 주요 산출물
- [x] Docker 컨테이너화
- [x] CI/CD 파이프라인 (GitHub Actions)
- [x] AWS Lightsail 배포
- [x] Flutter APK/AAB 빌드
- [x] 통합 테스트 및 최적화

### 시간 배분
| 작업 | 예상 시간 | 누적 시간 |
|------|-----------|-----------|
| 6.1 Docker 컨테이너화 | 4시간 | 4h |
| 6.2 CI/CD 파이프라인 | 3시간 | 7h |
| 6.3 AWS Lightsail 배포 | 4시간 | 11h |
| 6.4 Flutter 앱 빌드 | 3시간 | 14h |
| 6.5 통합 테스트 & 최적화 | 2시간 | 16h |

---

## 작업 6.1: Docker 컨테이너화 (4시간)

### Step 6.1.1: 백엔드 Dockerfile

**파일**: `backend/Dockerfile`

```dockerfile
FROM python:3.11-slim

# 작업 디렉토리
WORKDIR /app

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 소스 코드 복사
COPY . .

# 포트 노출
EXPOSE 8000

# 환경 변수
ENV PYTHONUNBUFFERED=1

# 실행 명령
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

### Step 6.1.2: Docker Compose

**파일**: `deployment/docker/docker-compose.yml`

```yaml
version: '3.8'

services:
  # PostgreSQL
  postgres:
    image: postgres:15-alpine
    container_name: lotto645_postgres
    environment:
      POSTGRES_USER: ${DB_USER:-lotto_user}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-lotto_pass}
      POSTGRES_DB: ${DB_NAME:-lotto645_prod}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-lotto_user}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - lotto_network

  # Redis
  redis:
    image: redis:7-alpine
    container_name: lotto645_redis
    command: redis-server --appendonly yes
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - lotto_network

  # FastAPI Backend
  backend:
    build:
      context: ../../backend
      dockerfile: Dockerfile
    container_name: lotto645_backend
    environment:
      DATABASE_URL: postgresql://${DB_USER:-lotto_user}:${DB_PASSWORD:-lotto_pass}@postgres:5432/${DB_NAME:-lotto645_prod}
      REDIS_URL: redis://redis:6379/0
      JWT_SECRET_KEY: ${JWT_SECRET_KEY}
      DEBUG: ${DEBUG:-False}
    ports:
      - "8000:8000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ../../backend/data:/app/data
      - ../../backend/results:/app/results
    networks:
      - lotto_network
    restart: unless-stopped

  # Celery Worker
  celery_worker:
    build:
      context: ../../backend
      dockerfile: Dockerfile
    container_name: lotto645_celery_worker
    command: celery -A app.workers.celery_app worker --loglevel=info
    environment:
      DATABASE_URL: postgresql://${DB_USER:-lotto_user}:${DB_PASSWORD:-lotto_pass}@postgres:5432/${DB_NAME:-lotto645_prod}
      REDIS_URL: redis://redis:6379/0
      CELERY_BROKER_URL: redis://redis:6379/0
      CELERY_RESULT_BACKEND: redis://redis:6379/1
    depends_on:
      - postgres
      - redis
      - backend
    volumes:
      - ../../backend/data:/app/data
    networks:
      - lotto_network
    restart: unless-stopped

  # Celery Beat (스케줄러)
  celery_beat:
    build:
      context: ../../backend
      dockerfile: Dockerfile
    container_name: lotto645_celery_beat
    command: celery -A app.workers.celery_app beat --loglevel=info
    environment:
      DATABASE_URL: postgresql://${DB_USER:-lotto_user}:${DB_PASSWORD:-lotto_pass}@postgres:5432/${DB_NAME:-lotto645_prod}
      REDIS_URL: redis://redis:6379/0
      CELERY_BROKER_URL: redis://redis:6379/0
      CELERY_RESULT_BACKEND: redis://redis:6379/1
      CELERY_TIMEZONE: Asia/Seoul
    depends_on:
      - postgres
      - redis
      - celery_worker
    volumes:
      - ../../backend/data:/app/data
    networks:
      - lotto_network
    restart: unless-stopped

  # Nginx (Reverse Proxy)
  nginx:
    image: nginx:alpine
    container_name: lotto645_nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - backend
    networks:
      - lotto_network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:

networks:
  lotto_network:
    driver: bridge
```

---

### Step 6.1.3: Nginx 설정

**파일**: `deployment/docker/nginx.conf`

```nginx
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:8000;
    }
    
    server {
        listen 80;
        server_name api.luckyai645.com;
        
        # HTTPS 리다이렉트
        return 301 https://$server_name$request_uri;
    }
    
    server {
        listen 443 ssl;
        server_name api.luckyai645.com;
        
        # SSL 인증서
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        
        # 프록시 설정
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Websocket 지원 (선택)
        location /ws {
            proxy_pass http://backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
```

---

### Step 6.1.4: 환경 변수

**파일**: `deployment/docker/.env.production`

```bash
# Database
DB_USER=lotto_user
DB_PASSWORD=CHANGE_ME_STRONG_PASSWORD
DB_NAME=lotto645_prod

# JWT
JWT_SECRET_KEY=CHANGE_ME_RANDOM_SECRET_KEY_MIN_32_CHARS

# Debug
DEBUG=False

# Other
ENVIRONMENT=production
```

---

### Step 6.1.5: Docker 실행

```bash
# 프로덕션 빌드 및 실행
cd deployment/docker
docker-compose --env-file .env.production up -d --build

# 로그 확인
docker-compose logs -f backend

# 상태 확인
docker-compose ps

# 중지
docker-compose down

# 데이터까지 삭제
docker-compose down -v
```

### 완료 기준 체크리스트
- [ ] `docker-compose up` 성공
- [ ] 모든 컨테이너 healthy 상태
- [ ] http://localhost:8000/docs 접근 가능
- [ ] Celery Worker/Beat 실행 확인

---

## 작업 6.2: CI/CD 파이프라인 (3시간)

### Step 6.2.1: GitHub Actions - 백엔드 테스트

**파일**: `.github/workflows/backend_ci.yml`

```yaml
name: Backend CI

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'backend/**'
  pull_request:
    branches: [ main, develop ]
    paths:
      - 'backend/**'

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_pass
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Cache pip
      uses: actions/cache@v3
      with:
        path: ~/.cache/pip
        key: ${{ runner.os }}-pip-${{ hashFiles('backend/requirements.txt') }}
    
    - name: Install dependencies
      working-directory: backend
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install pytest pytest-asyncio pytest-cov
    
    - name: Run tests
      working-directory: backend
      env:
        DATABASE_URL: postgresql://test_user:test_pass@localhost:5432/test_db
        REDIS_URL: redis://localhost:6379/0
        JWT_SECRET_KEY: test_secret_key_for_ci
      run: |
        pytest tests/ -v --cov=app --cov-report=xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: backend/coverage.xml
```

---

### Step 6.2.2: GitHub Actions - Flutter 빌드

**파일**: `.github/workflows/flutter_ci.yml`

```yaml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
    paths:
      - 'mobile_app/**'
  pull_request:
    branches: [ main, develop ]
    paths:
      - 'mobile_app/**'

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Get dependencies
      working-directory: mobile_app
      run: flutter pub get
    
    - name: Run analyzer
      working-directory: mobile_app
      run: flutter analyze
    
    - name: Run tests
      working-directory: mobile_app
      run: flutter test
    
    - name: Build APK
      working-directory: mobile_app
      run: flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-release.apk
        path: mobile_app/build/app/outputs/flutter-apk/app-release.apk
```

### 완료 기준 체크리스트
- [ ] GitHub Actions 워크플로우 실행 성공
- [ ] 백엔드 테스트 통과
- [ ] Flutter 빌드 성공
- [ ] Artifact 업로드 확인

---

## 작업 6.3: AWS Lightsail 배포 (4시간)

### Step 6.3.1: Lightsail 인스턴스 생성

**AWS Console**:
1. Lightsail → "인스턴스 생성"
2. OS: Ubuntu 22.04 LTS
3. 플랜: $10/월 (2GB RAM, 1 vCPU)
4. 인스턴스 이름: `luckyai645-backend`

---

### Step 6.3.2: 서버 초기 설정

```bash
# SSH 접속
ssh ubuntu@YOUR_INSTANCE_IP

# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Git 설치
sudo apt install -y git

# 재부팅
sudo reboot
```

---

### Step 6.3.3: 프로젝트 배포

```bash
# 프로젝트 클론
cd ~
git clone https://github.com/YOUR_USERNAME/luckyai645.git
cd luckyai645

# 환경 변수 설정
cd deployment/docker
cp .env.production.example .env.production
nano .env.production  # 실제 값 입력

# SSL 인증서 (Let's Encrypt)
sudo apt install -y certbot
sudo certbot certonly --standalone -d api.luckyai645.com
sudo cp /etc/letsencrypt/live/api.luckyai645.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/api.luckyai645.com/privkey.pem ssl/key.pem

# Docker Compose 실행
docker-compose --env-file .env.production up -d --build

# 로그 확인
docker-compose logs -f backend
```

---

### Step 6.3.4: 데이터베이스 초기화

```bash
# 컨테이너 내부 접속
docker exec -it lotto645_backend bash

# 마이그레이션
alembic upgrade head

# 초기 데이터 로드
python scripts/init_algorithm_pricing.py
python scripts/load_initial_data.py

# 종료
exit
```

---

### Step 6.3.5: 방화벽 설정

**Lightsail Console**:
1. 인스턴스 → 네트워킹 탭
2. 방화벽 규칙 추가:
   - HTTP (80)
   - HTTPS (443)
   - Custom TCP (8000) - API 직접 접근 (선택)

---

### Step 6.3.6: 도메인 연결

**DNS 설정** (Cloudflare/Route53):
```
A 레코드:
api.luckyai645.com → YOUR_INSTANCE_IP
```

### 완료 기준 체크리스트
- [ ] Lightsail 인스턴스 실행 중
- [ ] Docker Compose 모든 컨테이너 healthy
- [ ] https://api.luckyai645.com/docs 접근 가능
- [ ] Celery Worker/Beat 실행 확인
- [ ] 데이터베이스 초기화 완료

---

## 작업 6.4: Flutter 앱 빌드 (3시간)

### Step 6.4.1: Android APK 빌드

```bash
cd mobile_app

# 1. 프로덕션 환경 변수 설정
# lib/core/constants/api_endpoints.dart에서
# _prodBaseUrl = 'https://api.luckyai645.com' 확인

# 2. 릴리스 빌드
flutter build apk --release

# 3. App Bundle (Google Play 업로드용)
flutter build appbundle --release

# 출력:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

---

### Step 6.4.2: Android 서명 설정

**파일**: `android/key.properties` (생성)

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=luckyai645
storeFile=../keystore.jks
```

**파일**: `android/app/build.gradle` (수정)

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

**키스토어 생성**:
```bash
keytool -genkey -v -keystore ~/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias luckyai645
```

---

### Step 6.4.3: iOS 빌드 (macOS 필요)

```bash
# 1. Pod 설치
cd ios
pod install
cd ..

# 2. Xcode로 서명 설정
open ios/Runner.xcworkspace

# 3. 빌드
flutter build ios --release

# 4. Archive 생성 (Xcode)
# Product → Archive → Distribute App
```

---

### Step 6.4.4: 앱 버전 관리

**파일**: `pubspec.yaml`

```yaml
version: 1.0.0+1
# 1.0.0: 버전 이름
# +1: 빌드 번호
```

**버전 업데이트**:
```bash
# 버전 변경
flutter pub run cider version 1.0.1+2

# 또는 수동으로 pubspec.yaml 수정
```

### 완료 기준 체크리스트
- [ ] APK 빌드 성공
- [ ] AAB 빌드 성공 (Google Play용)
- [ ] 테스트 디바이스에 설치 및 동작 확인
- [ ] 프로덕션 API 연결 확인

---

## 작업 6.5: 통합 테스트 & 최적화 (2시간)

### Step 6.5.1: 전체 플로우 테스트

**테스트 체크리스트**:

1. **사용자 인증**
   - [ ] 앱 첫 실행 → 게스트 자동 생성
   - [ ] 웰컴 보너스 100코인 지급
   - [ ] 앱 재실행 → 동일 사용자 ID 유지

2. **코인 시스템**
   - [ ] 일일 로그인 보상 받기
   - [ ] 광고 시청 보상 받기 (5회)
   - [ ] 코인 잔액 표시 정확

3. **번호 생성**
   - [ ] 무료 알고리즘 (0코인) 생성
   - [ ] 유료 알고리즘 (1코인) 생성 후 차감
   - [ ] 잔액 부족 시 오류 메시지
   - [ ] 생성된 번호 표시

4. **내 번호 관리**
   - [ ] 번호 저장
   - [ ] 내 번호 목록 조회
   - [ ] 당첨 확인

5. **자동 당첨 확인**
   - [ ] Celery Worker 실행 중
   - [ ] 스케줄 작업 정상 동작
   - [ ] 로그 확인

---

### Step 6.5.2: 성능 최적화

**백엔드**:
```python
# 1. DB 쿼리 최적화
# - Eager loading 사용
# - 인덱스 확인

# 2. Redis 캐싱 활용
# - 최신 회차 캐싱 (1시간)
# - 알고리즘 목록 캐싱 (24시간)

# 3. API 응답 최적화
# - Gzip 압축
# - 필요한 필드만 반환
```

**Flutter**:
```dart
// 1. 이미지 캐싱
// - CachedNetworkImage 사용

// 2. 리스트 최적화
// - ListView.builder 사용
// - 페이지네이션

// 3. 상태 관리 최적화
// - 불필요한 rebuild 방지
// - Provider 세분화
```

---

### Step 6.5.3: 모니터링 설정

**Sentry (선택)**:
```python
# backend/app/main.py
import sentry_sdk

sentry_sdk.init(
    dsn="YOUR_SENTRY_DSN",
    traces_sample_rate=0.1,
)
```

```dart
// lib/main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

await SentryFlutter.init(
  (options) {
    options.dsn = 'YOUR_SENTRY_DSN';
  },
  appRunner: () => runApp(MyApp()),
);
```

---

### Step 6.5.4: 백업 전략

```bash
# PostgreSQL 자동 백업 (cron)
0 2 * * * docker exec lotto645_postgres pg_dump -U lotto_user lotto645_prod > /backup/lotto645_$(date +\%Y\%m\%d).sql

# S3 업로드 (선택)
aws s3 cp /backup/ s3://luckyai645-backups/ --recursive
```

### 완료 기준 체크리스트
- [ ] 전체 플로우 테스트 통과
- [ ] 성능 최적화 완료
- [ ] 모니터링 설정 (선택)
- [ ] 백업 전략 수립

---

## Phase 6 최종 체크리스트

### 인프라
- [ ] Docker Compose 전체 스택 실행
- [ ] Nginx Reverse Proxy 동작
- [ ] SSL 인증서 설정
- [ ] Celery Worker/Beat 실행

### 배포
- [ ] AWS Lightsail 인스턴스 실행
- [ ] 프로덕션 DB 초기화
- [ ] 도메인 연결 (api.luckyai645.com)
- [ ] HTTPS 접근 가능

### 앱
- [ ] Android APK/AAB 빌드
- [ ] iOS 빌드 (선택)
- [ ] 테스트 디바이스 설치
- [ ] 프로덕션 API 연결

### 테스트
- [ ] 전체 기능 동작 확인
- [ ] 에러 처리 확인
- [ ] 성능 테스트
- [ ] 보안 점검

---

## 프로덕션 체크리스트

### 보안
- [ ] 환경 변수 보안 (JWT Secret, DB Password)
- [ ] HTTPS 강제
- [ ] Rate Limiting 설정
- [ ] SQL Injection 방어 (SQLAlchemy 사용)
- [ ] XSS 방어

### 성능
- [ ] Redis 캐싱 활용
- [ ] DB 인덱스 최적화
- [ ] Gzip 압축
- [ ] CDN (선택)

### 모니터링
- [ ] 로그 수집 (Sentry/CloudWatch)
- [ ] 에러 추적
- [ ] 성능 모니터링
- [ ] 알림 설정

### 백업
- [ ] DB 자동 백업 (일 1회)
- [ ] 코드 버전 관리 (Git)
- [ ] 설정 파일 백업

---

## 런칭 후 작업

### Week 1
- [ ] 사용자 피드백 수집
- [ ] 버그 수정
- [ ] 성능 모니터링

### Week 2-4
- [ ] 통계 분석
- [ ] 기능 개선
- [ ] 마케팅 시작

### Month 2+
- [ ] 소셜 로그인 추가 (Google, Apple, Kakao)
- [ ] IAP 결제 연동
- [ ] ML 알고리즘 추가 (LSTM, GAN)
- [ ] 프리미엄 기능

---

## 🧪 Phase 6 테스트 (필수)

### 자동 테스트 스크립트

**파일**: `scripts/test_phase6_deployment.sh`

```bash
#!/bin/bash
# Phase 6 배포 통합 테스트

echo "=== Phase 6 배포 테스트 시작 ==="

# 1. Docker Compose 빌드
echo "[1] Docker Compose 빌드..."
cd deployment/docker
docker-compose build
if [ $? -eq 0 ]; then
    echo "✓ 빌드 성공"
else
    echo "✗ 빌드 실패"
    exit 1
fi

# 2. 전체 스택 실행
echo "[2] 전체 스택 실행..."
docker-compose up -d
sleep 10

# 3. 컨테이너 상태 확인
echo "[3] 컨테이너 상태 확인..."
docker-compose ps

# 4. Backend 헬스 체크
echo "[4] Backend 헬스 체크..."
curl -f http://localhost:8000/health
if [ $? -eq 0 ]; then
    echo "✓ Backend 응답 정상"
else
    echo "✗ Backend 응답 없음"
fi

# 5. Celery Worker 확인
echo "[5] Celery Worker 확인..."
docker-compose logs celery_worker | grep "ready"

echo "=== Phase 6 테스트 완료 ==="
```

---

### 수동 테스트 체크리스트

#### 1. Docker 전체 스택 실행
```bash
cd deployment/docker
docker-compose --env-file .env.production up -d
```
**확인 사항**:
- [ ] 모든 컨테이너 시작 (postgres, redis, backend, celery_worker, celery_beat, nginx)
- [ ] `docker-compose ps` 모두 healthy
- [ ] `docker-compose logs -f backend` 오류 없음

#### 2. Nginx Reverse Proxy 테스트
```bash
curl http://localhost/api/algorithms
curl https://localhost/api/algorithms  # SSL
```
**확인 사항**:
- [ ] HTTP → HTTPS 리다이렉트
- [ ] API 요청 프록시 동작
- [ ] SSL 인증서 정상

#### 3. AWS Lightsail 배포 확인
**SSH 접속**:
```bash
ssh ubuntu@YOUR_IP
```
**확인 사항**:
- [ ] Docker 설치 완료
- [ ] 프로젝트 클론 완료
- [ ] Docker Compose 실행 중
- [ ] 방화벽 설정 (80, 443 오픈)

**API 접근**:
```bash
curl https://api.luckyai645.com/docs
```
- [ ] Swagger UI 접근 가능
- [ ] HTTPS 정상 동작

#### 4. Flutter APK 테스트
**APK 설치**:
```bash
cd mobile_app
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```
**확인 사항**:
- [ ] 앱 설치 성공
- [ ] 프로덕션 API 연결 (https://api.luckyai645.com)
- [ ] 모든 기능 정상 동작

#### 5. 전체 플로우 테스트 (End-to-End)
1. **사용자 가입**:
   - [ ] 앱 첫 실행 → 게스트 생성
   - [ ] 웰컴 보너스 100코인

2. **코인 획득**:
   - [ ] 일일 로그인 5코인
   - [ ] 광고 시청 5코인

3. **번호 생성**:
   - [ ] 무료 알고리즘 (0코인)
   - [ ] 유료 알고리즘 (1코인)
   - [ ] 코인 차감 확인

4. **내 번호 저장 & 확인**:
   - [ ] 번호 저장
   - [ ] 당첨 확인

5. **자동 당첨 확인**:
   - [ ] Celery 스케줄 작업 동작
   - [ ] 매주 토요일 22:00 자동 확인

#### 6. 성능 & 보안 테스트
**부하 테스트** (선택):
```bash
ab -n 1000 -c 10 https://api.luckyai645.com/api/algorithms
```
- [ ] 1000 요청 처리
- [ ] 평균 응답 시간 < 200ms

**보안 체크**:
- [ ] .env 파일 외부 노출 안 됨
- [ ] JWT Secret 안전
- [ ] SQL Injection 방어 (SQLAlchemy)
- [ ] Rate Limiting 설정

#### 7. 모니터링 & 로그
**로그 확인**:
```bash
docker-compose logs -f --tail=100 backend
docker-compose logs -f --tail=100 celery_worker
```
- [ ] 로그 정상 출력
- [ ] 오류 로그 없음

**Sentry** (선택):
- [ ] Sentry 연동 완료
- [ ] 에러 추적 동작

---

## 🎯 프로덕션 체크리스트 (최종)

### 인프라
- [ ] AWS Lightsail 인스턴스 실행
- [ ] Docker Compose 전체 스택 healthy
- [ ] Nginx Reverse Proxy 동작
- [ ] SSL 인증서 설정 (Let's Encrypt)
- [ ] 도메인 연결 (api.luckyai645.com)

### 백엔드
- [ ] PostgreSQL 데이터 초기화
- [ ] Redis 캐싱 동작
- [ ] Celery Worker/Beat 실행
- [ ] API 모든 엔드포인트 정상
- [ ] 로그 수집 설정

### 앱
- [ ] Android APK/AAB 빌드
- [ ] 앱 서명 설정
- [ ] 프로덕션 API 연결
- [ ] 전체 기능 테스트 통과

### 보안
- [ ] 환경 변수 보안
- [ ] HTTPS 강제
- [ ] JWT 인증 동작
- [ ] SQL Injection 방어

### 백업
- [ ] DB 자동 백업 (일 1회)
- [ ] 백업 스크립트 설정
- [ ] 복구 테스트 완료

---

**Phase 6 완료! 🎉**

**전체 Phase 0-6 구현 완료!**

다음: 런칭 및 사용자 피드백 수집

