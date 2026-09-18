# Phase 0: 프로젝트 환경 설정
## 상세 개발 로드맵

---

**Phase**: 0 - Environment Setup  
**예상 기간**: 1일 (8시간)  
**선행 조건**: 없음  
**목표**: 프로젝트 뼈대 구축 및 개발 환경 완전 준비

---

## 📋 Phase 개요

### 주요 산출물
- [x] 디렉토리 구조 완성
- [x] 백엔드 의존성 설치 가능
- [x] Flutter 프로젝트 생성 및 실행 가능
- [x] Docker Compose로 PostgreSQL, Redis 실행
- [x] Git 저장소 초기화

### 시간 배분
| 작업 | 예상 시간 | 누적 시간 |
|------|-----------|-----------|
| 0.1 디렉토리 구조 생성 | 0.5시간 | 0.5h |
| 0.2 백엔드 설정 파일 | 2시간 | 2.5h |
| 0.3 Flutter 프로젝트 초기화 | 2시간 | 4.5h |
| 0.4 Docker Compose 설정 | 1.5시간 | 6h |
| 0.5 Git 저장소 설정 | 1시간 | 7h |
| 0.6 통합 테스트 및 검증 | 1시간 | 8h |

---

## 작업 0.1: 디렉토리 구조 생성 (0.5시간)

### 목표
프로젝트 전체 폴더 구조 생성

### 작업 단계

#### Step 1.1: PowerShell 스크립트 작성

**파일**: `scripts/create_project_structure.ps1`

```powershell
# LuckyAI 645 프로젝트 구조 생성 스크립트
# 작성일: 2026-01-04 EST

Write-Host "🚀 LuckyAI 645 프로젝트 구조 생성 시작..." -ForegroundColor Green

# 루트 디렉토리 생성
$rootDir = "luckyai_645"
if (!(Test-Path $rootDir)) {
    New-Item -ItemType Directory -Path $rootDir
    Write-Host "✓ 루트 디렉토리 생성: $rootDir" -ForegroundColor Green
}

Set-Location $rootDir

# === 백엔드 디렉토리 구조 ===
$backendDirs = @(
    "backend",
    "backend/app",
    "backend/app/api",
    "backend/app/api/routes",
    "backend/app/core",
    "backend/app/algorithms",
    "backend/app/models",
    "backend/app/validation",
    "backend/app/db",
    "backend/app/db/models",
    "backend/app/db/repositories",
    "backend/app/services",
    "backend/app/schemas",
    "backend/app/utils",
    "backend/app/workers",
    "backend/data",
    "backend/data/raw",
    "backend/data/processed",
    "backend/data/models",
    "backend/results",
    "backend/results/validation",
    "backend/results/reports",
    "backend/results/logs",
    "backend/tests",
    "backend/tests/test_algorithms",
    "backend/tests/test_api",
    "backend/tests/test_validation",
    "backend/scripts"
)

foreach ($dir in $backendDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-Host "✓ 백엔드 디렉토리 구조 생성 완료 (${backendDirs.Count}개)" -ForegroundColor Green

# __init__.py 파일 생성 (Python 패키지)
$initDirs = @(
    "backend/app",
    "backend/app/api",
    "backend/app/api/routes",
    "backend/app/core",
    "backend/app/algorithms",
    "backend/app/models",
    "backend/app/validation",
    "backend/app/db",
    "backend/app/db/models",
    "backend/app/db/repositories",
    "backend/app/services",
    "backend/app/schemas",
    "backend/app/utils",
    "backend/app/workers"
)

foreach ($dir in $initDirs) {
    $initFile = Join-Path $dir "__init__.py"
    if (!(Test-Path $initFile)) {
        New-Item -ItemType File -Path $initFile -Force | Out-Null
    }
}
Write-Host "✓ Python __init__.py 파일 생성 완료" -ForegroundColor Green

# === 공유 리소스 디렉토리 ===
$sharedDirs = @(
    "shared",
    "shared/docs",
    "shared/api_specs",
    "shared/assets"
)

foreach ($dir in $sharedDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-Host "✓ 공유 리소스 디렉토리 생성 완료" -ForegroundColor Green

# === 배포 디렉토리 ===
$deployDirs = @(
    "deployment",
    "deployment/docker",
    "deployment/k8s",
    "deployment/scripts"
)

foreach ($dir in $deployDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-Host "✓ 배포 디렉토리 생성 완료" -ForegroundColor Green

# === CI/CD 디렉토리 ===
$cicdDirs = @(
    ".github",
    ".github/workflows"
)

foreach ($dir in $cicdDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-Host "✓ CI/CD 디렉토리 생성 완료" -ForegroundColor Green

Write-Host "`n✅ 프로젝트 구조 생성 완료!" -ForegroundColor Green
Write-Host "다음 단계: Flutter 프로젝트 생성 (flutter create mobile_app)" -ForegroundColor Yellow
```

#### Step 1.2: 스크립트 실행

```powershell
# 실행
cd C:\_PythonWorkspace\_Lotto645_picker_workingFolder
powershell -ExecutionPolicy Bypass -File scripts/create_project_structure.ps1
```

#### Step 1.3: Flutter 프로젝트 생성

```powershell
cd luckyai_645
flutter create mobile_app --org com.luckyai --project-name luckyai_645
```

**옵션**:
- `--org com.luckyai`: 패키지명 접두사
- `--project-name luckyai_645`: 프로젝트 이름 (스네이크 케이스)

### 완료 기준 체크리스트
- [ ] `luckyai_645/backend/app/` 폴더 존재
- [ ] 모든 `__init__.py` 파일 생성
- [ ] `luckyai_645/mobile_app/lib/main.dart` 파일 존재
- [ ] `flutter run` 실행 시 샘플 앱 표시

---

## 작업 0.2: 백엔드 기본 설정 파일 작성 (2시간)

### Step 2.1: requirements.txt 작성

**파일**: `backend/requirements.txt`

```txt
# === Core Framework ===
fastapi==0.110.0
uvicorn[standard]==0.27.0
pydantic==2.5.3
pydantic-settings==2.1.0
python-dotenv==1.0.0

# === Database ===
sqlalchemy==2.0.25
alembic==1.13.1
psycopg2-binary==2.9.9
asyncpg==0.29.0

# === Caching & Queue ===
redis==5.0.1
celery==5.3.6
celery-beat==2.5.0

# === HTTP & Web Scraping ===
aiohttp==3.9.3
beautifulsoup4==4.12.3
lxml==5.1.0
httpx==0.26.0

# === Data Processing ===
pandas==2.1.4
numpy==1.26.3
scikit-learn==1.3.2

# === ML/AI (선택) ===
torch==2.1.2
transformers==4.37.0

# === Logging & Monitoring ===
loguru==0.7.2
python-json-logger==2.0.7

# === Security ===
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6

# === Testing ===
pytest==7.4.4
pytest-asyncio==0.23.3
pytest-cov==4.1.0
httpx==0.26.0

# === Utilities ===
python-dateutil==2.8.2
pytz==2023.4
```

**설치**:
```powershell
cd backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```

---

### Step 2.2: .env.example 작성

**파일**: `backend/.env.example`

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
# 개발 환경 (로컬)
DATABASE_URL=postgresql://lotto_user:lotto_pass@localhost:5432/lotto645_dev

# 프로덕션 환경 (AWS RDS)
# DATABASE_URL=postgresql://user:pass@rds-endpoint:5432/lotto645_prod

# === Redis ===
REDIS_URL=redis://localhost:6379/0
CACHE_TTL=3600

# === Celery ===
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/1
CELERY_TIMEZONE=Asia/Seoul

# === 보안 ===
JWT_SECRET_KEY=your-secret-key-change-in-production-min-32-characters
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# === 로또 크롤링 ===
LOTTO_CRAWLER_URL=https://www.dhlottery.co.kr/gameResult.do?method=byWin
CRAWLER_TIMEOUT=10
CRAWLER_RETRY=3

# === 파일 경로 ===
LOTTO_CSV_PATH=data/raw/lotto_data.csv
MODEL_DIR=data/models

# === Firebase (Push 알림) ===
FIREBASE_CREDENTIALS_PATH=path/to/firebase-credentials.json
# 또는 JSON 문자열
FIREBASE_CREDENTIALS_JSON={}

# === 인앱 결제 (IAP) ===
GOOGLE_SERVICE_ACCOUNT_KEY=path/to/google-service-account.json
APPLE_SHARED_SECRET=your_apple_shared_secret

# === 광고 (AdMob) ===
ADMOB_SECRET_KEY=your_admob_ssv_secret_key

# === 소셜 로그인 ===
GOOGLE_CLIENT_ID=your-google-oauth-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-xxxxxxxxxxxxxxxxxxxxxxxxx
APPLE_CLIENT_ID=com.luckyai.luckyai645
KAKAO_REST_API_KEY=your_kakao_rest_api_key
NAVER_CLIENT_ID=your_naver_client_id
NAVER_CLIENT_SECRET=your_naver_client_secret

# === 로깅 ===
LOG_LEVEL=INFO
LOG_FILE=logs/app.log

# === CORS ===
CORS_ORIGINS=["http://localhost:3000","http://localhost:8080"]
```

**실제 .env 파일 생성**:
```powershell
cp .env.example .env
# .env 파일 편집하여 실제 값 입력
```

---

### Step 2.3: pyproject.toml 작성

**파일**: `backend/pyproject.toml`

```toml
[tool.poetry]
name = "luckyai-645-backend"
version = "1.0.0"
description = "LuckyAI 645 로또 번호 생성 백엔드 API"
authors = ["Your Team <team@luckyai645.com>"]
license = "MIT"
readme = "README.md"

[tool.poetry.dependencies]
python = "^3.11"
fastapi = "^0.110.0"
uvicorn = {extras = ["standard"], version = "^0.27.0"}
sqlalchemy = "^2.0.25"
alembic = "^1.13.1"
# ... (requirements.txt 내용 동일)

[tool.poetry.group.dev.dependencies]
pytest = "^7.4.4"
pytest-asyncio = "^0.23.3"
pytest-cov = "^4.1.0"
black = "^23.12.1"
flake8 = "^7.0.0"
mypy = "^1.8.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.black]
line-length = 88
target-version = ['py311']

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = "-v --cov=app --cov-report=html"
```

---

### Step 2.4: .gitignore 작성

**파일**: `backend/.gitignore`

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/
*.egg-info/
dist/
build/

# 환경 변수
.env
.env.local
.env.*.local

# 데이터베이스
*.db
*.sqlite3
*.sql

# 로그
*.log
logs/

# 데이터 파일
data/raw/*.csv
data/processed/
!data/raw/.gitkeep

# 모델 파일
data/models/*.pth
data/models/*.pkl
!data/models/.gitkeep

# 검증 결과
results/
!results/.gitkeep

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Pytest
.pytest_cache/
.coverage
htmlcov/

# Alembic
alembic/versions/*.pyc
```

---

### Step 2.5: README.md 작성

**파일**: `backend/README.md`

```markdown
# LuckyAI 645 Backend API

AI 기반 로또 번호 생성 서비스 백엔드

## 기술 스택
- **Framework**: FastAPI 0.110+
- **Database**: PostgreSQL 15
- **Cache**: Redis 7.2
- **Task Queue**: Celery 5.3

## 빠른 시작

### 1. 가상 환경 설정
\`\`\`bash
python -m venv venv
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac
\`\`\`

### 2. 의존성 설치
\`\`\`bash
pip install -r requirements.txt
\`\`\`

### 3. 환경 변수 설정
\`\`\`bash
cp .env.example .env
# .env 파일 편집
\`\`\`

### 4. 데이터베이스 초기화
\`\`\`bash
python scripts/init_db.py
python scripts/load_data.py
\`\`\`

### 5. API 서버 실행
\`\`\`bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
\`\`\`

### 6. Swagger UI 접근
http://localhost:8000/docs

## 프로젝트 구조
\`\`\`
backend/
├── app/
│   ├── api/          # API 라우터
│   ├── core/         # 핵심 비즈니스 로직
│   ├── algorithms/   # 번호 생성 알고리즘
│   ├── db/           # 데이터베이스 모델
│   └── main.py       # FastAPI 엔트리포인트
├── data/             # 데이터 파일
├── tests/            # 테스트
└── scripts/          # 유틸리티 스크립트
\`\`\`

## API 엔드포인트
- `GET /api/draws/latest` - 최신 회차 조회
- `POST /api/generate` - 번호 생성
- `GET /api/algorithms` - 알고리즘 목록

## 개발
\`\`\`bash
# 테스트 실행
pytest

# 코드 포맷팅
black app/

# Linting
flake8 app/
\`\`\`
```

### 완료 기준 체크리스트
- [ ] `pip install -r requirements.txt` 성공
- [ ] `.env` 파일 생성 및 편집
- [ ] 모든 `__init__.py` 파일 존재

---

## 작업 0.3: Flutter 프로젝트 초기 설정 (2시간)

### Step 3.1: pubspec.yaml 작성

**파일**: `mobile_app/pubspec.yaml`

```yaml
name: luckyai_645
description: AI 기반 로또 번호 생성 모바일 앱
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # === 상태 관리 ===
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # === 네트워킹 ===
  dio: ^5.4.0
  retrofit: ^4.0.3
  pretty_dio_logger: ^1.3.1
  connectivity_plus: ^5.0.2
  
  # === 로컬 저장소 ===
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  
  # === JSON 직렬화 ===
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  
  # === UI/차트 ===
  fl_chart: ^0.66.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.9
  lottie: ^3.0.0
  
  # === 유틸리티 ===
  intl: ^0.19.0
  qr_flutter: ^4.1.0
  share_plus: ^7.2.1
  url_launcher: ^6.2.2
  path_provider: ^2.1.2
  
  # === Firebase ===
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  firebase_analytics: ^10.8.0
  
  # === 인앱 결제 ===
  in_app_purchase: ^3.1.13
  
  # === 광고 ===
  google_mobile_ads: ^4.0.0
  
  # === 기타 ===
  logger: ^2.0.2
  equatable: ^2.0.5
  dartz: ^0.10.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  
  # === 코드 생성 ===
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  freezed: ^2.4.6
  riverpod_generator: ^2.3.9
  retrofit_generator: ^8.0.6
  hive_generator: ^2.0.1
  
  # === 테스트 ===
  mockito: ^5.4.4
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/lottie/
  
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.ttf
        - asset: assets/fonts/Pretendard-Bold.ttf
          weight: 700
```

---

### Step 3.2: analysis_options.yaml 작성

**파일**: `mobile_app/analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  
  errors:
    invalid_annotation_target: ignore
    
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    # 스타일
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - prefer_final_locals
    
    # 가독성
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - avoid_print
    - avoid_unnecessary_containers
    
    # 에러 방지
    - avoid_empty_else
    - avoid_returning_null_for_void
    - no_duplicate_case_values
    - prefer_is_empty
    - prefer_is_not_empty
```

---

### Step 3.3: 기본 상수 파일 작성

**파일**: `mobile_app/lib/core/constants/api_endpoints.dart`

```dart
/// API 엔드포인트 상수
/// 
/// 2026-01-04 EST - 초기 생성
class ApiEndpoints {
  ApiEndpoints._();
  
  // === 기본 URL ===
  static const String _devBaseUrl = 'http://localhost:8000';
  static const String _prodBaseUrl = 'https://api.luckyai645.com';
  
  static String get baseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? _prodBaseUrl : _devBaseUrl;
  }
  
  // === 인증 ===
  static const String guestLogin = '/api/auth/guest';
  static const String socialLogin = '/api/auth/social';
  
  // === 로또 데이터 ===
  static const String latestDraw = '/api/draws/latest';
  static const String drawByNumber = '/api/draws/{draw_no}';
  static const String drawRange = '/api/draws/range';
  
  // === 번호 생성 ===
  static const String generate = '/api/generate';
  static const String algorithms = '/api/algorithms';
  
  // === 코인 ===
  static const String coinBalance = '/api/coins/balance';
  static const String dailyLogin = '/api/coins/daily-login';
  static const String watchAd = '/api/coins/watch-ad';
  
  // === 내 번호 ===
  static const String myNumbers = '/api/my-numbers';
  static const String saveNumber = '/api/my-numbers/save';
  static const String checkWinning = '/api/my-numbers/check';
}
```

**파일**: `mobile_app/lib/core/constants/app_colors.dart`

```dart
import 'package:flutter/material.dart';

/// 앱 색상 상수
class AppColors {
  AppColors._();
  
  // === 주요 색상 ===
  static const Color primary = Color(0xFF667EEA);
  static const Color secondary = Color(0xFF764BA2);
  static const Color accent = Color(0xFFF093FB);
  
  // === 배경 ===
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // === 텍스트 ===
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFADB5BD);
  
  // === 상태 ===
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // === 로또 공 색상 (번호 범위별) ===
  static const Color ball1to10 = Color(0xFFFFC107);    // 노란색
  static const Color ball11to20 = Color(0xFF2196F3);   // 파란색
  static const Color ball21to30 = Color(0xFFEF5350);   // 빨간색
  static const Color ball31to40 = Color(0xFF757575);   // 회색
  static const Color ball41to45 = Color(0xFF66BB6A);   // 초록색
  static const Color ballBonus = Color(0xFF9C27B0);    // 보라색
  
  /// 번호에 따른 로또 공 색상 반환
  static Color getLottoBallColor(int number) {
    if (number <= 10) return ball1to10;
    if (number <= 20) return ball11to20;
    if (number <= 30) return ball21to30;
    if (number <= 40) return ball31to40;
    return ball41to45;
  }
}
```

---

### Step 3.4: .gitignore 작성

**파일**: `mobile_app/.gitignore`

```gitignore
# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
*.g.dart
*.freezed.dart

# IntelliJ
*.iml
.idea/

# VS Code
.vscode/

# Android
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java
**/android/key.properties
*.jks

# iOS
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/.last_build_id
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# 환경 변수
.env
.env.local

# Firebase
**/google-services.json
**/GoogleService-Info.plist
firebase_app_id_file.json

# 로그
*.log

# Coverage
coverage/
```

### 완료 기준 체크리스트
- [ ] `flutter pub get` 성공
- [ ] `dart run build_runner build --delete-conflicting-outputs` 준비
- [ ] `flutter run` 실행 가능

---

## 작업 0.4: Docker Compose 설정 (1.5시간)

### Step 4.1: Docker Compose 파일 작성

**파일**: `deployment/docker/docker-compose.yml`

```yaml
version: '3.8'

services:
  # === PostgreSQL 데이터베이스 ===
  postgres:
    image: postgres:15-alpine
    container_name: lotto645_postgres
    environment:
      POSTGRES_USER: lotto_user
      POSTGRES_PASSWORD: lotto_pass
      POSTGRES_DB: lotto645_dev
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --locale=C"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U lotto_user -d lotto645_dev"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - lotto_network

  # === Redis 캐시 ===
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

  # === pgAdmin (DB 관리 도구, 선택) ===
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: lotto645_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@luckyai645.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    depends_on:
      - postgres
    networks:
      - lotto_network
    profiles:
      - tools

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local

networks:
  lotto_network:
    driver: bridge
```

---

### Step 4.2: PostgreSQL 초기화 스크립트

**파일**: `deployment/docker/init-db.sql`

```sql
-- LuckyAI 645 데이터베이스 초기화
-- 2026-01-04 EST

-- 확장 설치
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 시간대 설정
SET timezone = 'Asia/Seoul';

-- 테이블 생성은 Alembic에서 처리
-- 여기서는 초기 설정만

-- 초기 관리자 계정 (선택)
-- INSERT INTO users (id, username, email, ...) VALUES (...);

-- 알고리즘 비용 초기 데이터
CREATE TABLE IF NOT EXISTS algorithm_pricing (
    id SERIAL PRIMARY KEY,
    algorithm_id INT NOT NULL UNIQUE,
    algorithm_name VARCHAR(100) NOT NULL,
    cost_per_set INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO algorithm_pricing (algorithm_id, algorithm_name, cost_per_set) VALUES
(1, '순수 랜덤', 0),
(2, 'LSTM AI', 3),
(3, '앙상블', 2),
(4, '패턴 분석', 2),
(5, '가중치 조합', 1),
(6, '빈도 기반', 1),
(7, '핫/콜드 넘버', 1),
(8, 'GAN', 5),
(9, '강화학습', 5)
ON CONFLICT (algorithm_id) DO NOTHING;
```

---

### Step 4.3: Docker Compose 실행

```powershell
# Docker Compose 디렉토리로 이동
cd deployment/docker

# 서비스 시작 (백그라운드)
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 상태 확인
docker-compose ps

# pgAdmin 포함 시작 (선택)
docker-compose --profile tools up -d

# 종료
docker-compose down

# 데이터까지 삭제
docker-compose down -v
```

---

### Step 4.4: 연결 테스트

**Python에서 PostgreSQL 연결 테스트**:

```python
# test_db_connection.py
import psycopg2

try:
    conn = psycopg2.connect(
        host="localhost",
        port=5432,
        database="lotto645_dev",
        user="lotto_user",
        password="lotto_pass"
    )
    print("✅ PostgreSQL 연결 성공!")
    conn.close()
except Exception as e:
    print(f"❌ PostgreSQL 연결 실패: {e}")
```

**Redis 연결 테스트**:

```python
# test_redis_connection.py
import redis

try:
    r = redis.Redis(host='localhost', port=6379, db=0)
    r.ping()
    print("✅ Redis 연결 성공!")
except Exception as e:
    print(f"❌ Redis 연결 실패: {e}")
```

### 완료 기준 체크리스트
- [ ] `docker-compose up -d` 성공
- [ ] PostgreSQL 5432 포트 연결 가능
- [ ] Redis 6379 포트 연결 가능
- [ ] pgAdmin http://localhost:5050 접근 가능 (선택)

---

## 작업 0.5: Git 저장소 설정 (1시간)

### Step 5.1: Git 초기화

```powershell
cd luckyai_645

# Git 초기화
git init

# 루트 .gitignore 작성
echo "# OS" > .gitignore
echo ".DS_Store" >> .gitignore
echo "Thumbs.db" >> .gitignore
echo "" >> .gitignore
echo "# IDE" >> .gitignore
echo ".vscode/" >> .gitignore
echo ".idea/" >> .gitignore

# 첫 커밋
git add .
git commit -m "chore: 초기 프로젝트 구조 생성

- 백엔드 디렉토리 구조
- Flutter 프로젝트 생성
- Docker Compose 설정
- 기본 설정 파일
"
```

---

### Step 5.2: 브랜치 전략 설정

```powershell
# develop 브랜치 생성
git branch develop
git checkout develop

# feature 브랜치 템플릿 (예시)
# git checkout -b feature/phase-1-crawler
```

**브랜치 전략**:
- `main`: 프로덕션 배포용
- `develop`: 개발 통합 브랜치
- `feature/*`: 기능 개발 브랜치
- `bugfix/*`: 버그 수정 브랜치
- `release/*`: 릴리스 준비 브랜치

---

### Step 5.3: 루트 README.md 작성

**파일**: `luckyai_645/README.md`

```markdown
# 🍀 LuckyAI 645

AI 기반 로또 번호 생성 모바일 앱

## 프로젝트 구조

\`\`\`
luckyai_645/
├── mobile_app/        # Flutter 모바일 앱
├── backend/           # FastAPI 백엔드 API
├── deployment/        # Docker & K8s 설정
└── shared/            # 공유 리소스
\`\`\`

## 빠른 시작

### 백엔드 실행
\`\`\`bash
cd backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
\`\`\`

### Flutter 앱 실행
\`\`\`bash
cd mobile_app
flutter pub get
flutter run
\`\`\`

### Docker로 전체 스택 실행
\`\`\`bash
cd deployment/docker
docker-compose up -d
\`\`\`

## 문서
- [구현 로드맵](../../z_Dev_Docs/007_Implementation_Roadmap.md)
- [시스템 설계](../../z_Dev_Docs/005_Implementation_Logic_and_Module_Design.md)

## 라이선스
MIT
```

### 완료 기준 체크리스트
- [ ] Git 저장소 초기화
- [ ] 첫 커밋 완료
- [ ] develop 브랜치 생성

---

## 작업 0.6: 통합 테스트 및 검증 (1시간)

### 최종 체크리스트

#### 백엔드
- [ ] `backend/app/` 모든 `__init__.py` 존재
- [ ] `pip install -r requirements.txt` 성공
- [ ] `.env` 파일 생성 및 편집
- [ ] PostgreSQL 연결 테스트 통과
- [ ] Redis 연결 테스트 통과

#### Flutter
- [ ] `mobile_app/lib/main.dart` 존재
- [ ] `flutter pub get` 성공
- [ ] `flutter run` 실행 가능 (샘플 앱)

#### Docker
- [ ] `docker-compose up -d` 성공
- [ ] `docker-compose ps` 모든 서비스 healthy

#### Git
- [ ] Git 저장소 초기화
- [ ] 첫 커밋 완료
- [ ] `develop` 브랜치 존재

---

## 🧪 Phase 0 테스트 (필수)

### 자동 테스트 스크립트

**파일**: `backend/tests/test_phase0_setup.py`

```python
"""
Phase 0 환경 설정 자동 테스트

2026-01-08 EST - 초기 생성
"""

import pytest
import os
from pathlib import Path
import subprocess
import psycopg2
import redis


def test_directory_structure():
    """디렉토리 구조 검증"""
    required_dirs = [
        'backend/app/api/routes',
        'backend/app/core',
        'backend/app/db/models',
        'backend/data',
        'mobile_app/lib/core',
        'mobile_app/lib/data',
        'mobile_app/lib/presentation',
    ]
    
    for dir_path in required_dirs:
        assert Path(dir_path).exists(), f"필수 디렉토리 누락: {dir_path}"


def test_backend_files():
    """백엔드 필수 파일 검증"""
    required_files = [
        'backend/requirements.txt',
        'backend/.env.example',
        'backend/pyproject.toml',
        'backend/.gitignore',
        'backend/app/__init__.py',
    ]
    
    for file_path in required_files:
        assert Path(file_path).exists(), f"필수 파일 누락: {file_path}"


def test_flutter_files():
    """Flutter 필수 파일 검증"""
    required_files = [
        'mobile_app/pubspec.yaml',
        'mobile_app/analysis_options.yaml',
        'mobile_app/lib/main.dart',
    ]
    
    for file_path in required_files:
        assert Path(file_path).exists(), f"필수 파일 누락: {file_path}"


def test_postgres_connection():
    """PostgreSQL 연결 테스트"""
    try:
        conn = psycopg2.connect(
            host='localhost',
            port=5432,
            user='lotto_user',
            password='lotto_pass',
            database='lotto645_dev'
        )
        conn.close()
        assert True
    except Exception as e:
        pytest.fail(f"PostgreSQL 연결 실패: {e}")


def test_redis_connection():
    """Redis 연결 테스트"""
    try:
        r = redis.Redis(host='localhost', port=6379, db=0)
        r.ping()
        assert True
    except Exception as e:
        pytest.fail(f"Redis 연결 실패: {e}")


def test_docker_compose():
    """Docker Compose 상태 검증"""
    result = subprocess.run(
        ['docker-compose', 'ps', '--format', 'json'],
        capture_output=True,
        text=True,
        cwd='deployment/docker'
    )
    
    assert result.returncode == 0, "Docker Compose 실행 오류"
    # 모든 서비스가 healthy 상태여야 함


def test_env_file():
    """.env 파일 필수 변수 검증"""
    env_path = Path('backend/.env')
    assert env_path.exists(), ".env 파일이 없습니다"
    
    with open(env_path) as f:
        content = f.read()
        required_vars = [
            'DATABASE_URL',
            'REDIS_URL',
            'JWT_SECRET_KEY',
            'DEBUG',
        ]
        
        for var in required_vars:
            assert var in content, f"필수 환경 변수 누락: {var}"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
```

**실행 방법**:
```bash
cd backend
pytest tests/test_phase0_setup.py -v
```

---

### 자동 테스트 체크리스트

**실행 명령**: `pytest tests/test_phase0_setup.py -v`

- [ ] ✅ `test_directory_structure` - 디렉토리 구조
- [ ] ✅ `test_backend_files` - 백엔드 파일
- [ ] ✅ `test_flutter_files` - Flutter 파일
- [ ] ✅ `test_postgres_connection` - PostgreSQL 연결
- [ ] ✅ `test_redis_connection` - Redis 연결
- [ ] ✅ `test_docker_compose` - Docker Compose 상태
- [ ] ✅ `test_env_file` - 환경 변수 파일

**예상 결과**: 7 passed

---

### 수동 테스트 체크리스트

#### 1. Docker 컨테이너 상태 확인
```bash
cd deployment/docker
docker-compose ps
```
**확인 사항**:
- [ ] postgres: healthy, Up
- [ ] redis: healthy, Up
- [ ] pgadmin: healthy, Up (선택)

#### 2. PostgreSQL 수동 접속 테스트
```bash
docker exec -it lotto645_postgres psql -U lotto_user -d lotto645_dev
```
**확인 사항**:
- [ ] 접속 성공
- [ ] `\l` 명령으로 DB 목록 표시
- [ ] `\q`로 종료

#### 3. Redis 수동 접속 테스트
```bash
docker exec -it lotto645_redis redis-cli
```
**확인 사항**:
- [ ] `PING` → `PONG` 응답
- [ ] `exit`로 종료

#### 4. pgAdmin 웹 접속 (선택)
**URL**: http://localhost:5050
**확인 사항**:
- [ ] 로그인 성공 (admin@luckyai.com / admin)
- [ ] 서버 연결 가능

#### 5. Backend Python 환경 테스트
```bash
cd backend
python -c "import fastapi; print(fastapi.__version__)"
python -c "import sqlalchemy; print(sqlalchemy.__version__)"
```
**확인 사항**:
- [ ] FastAPI 버전 출력 (0.110.0+)
- [ ] SQLAlchemy 버전 출력 (2.0.25+)

#### 6. Flutter 환경 테스트
```bash
cd mobile_app
flutter doctor
flutter pub get
flutter run -d windows  # 또는 android, ios
```
**확인 사항**:
- [ ] `flutter doctor` 모든 항목 ✓ (또는 경고만)
- [ ] `flutter pub get` 성공
- [ ] 샘플 앱 실행 확인 (Counter 앱)

#### 7. Git 저장소 확인
```bash
git status
git branch
git log --oneline
```
**확인 사항**:
- [ ] Git 초기화 완료
- [ ] `main`, `develop` 브랜치 존재
- [ ] 첫 커밋 존재

#### 8. 디렉토리 구조 확인
```bash
tree -L 3 backend  # Windows: tree /F backend
tree -L 3 mobile_app
```
**확인 사항**:
- [ ] 백엔드 디렉토리 구조 일치
- [ ] Flutter 디렉토리 구조 일치

---

### Phase 0 통합 테스트 스크립트

**파일**: `scripts/test_phase0.sh` (Linux/Mac) 또는 `scripts/test_phase0.ps1` (Windows)

```powershell
# scripts/test_phase0.ps1
# Phase 0 통합 테스트 스크립트

Write-Host "=== Phase 0 통합 테스트 시작 ===" -ForegroundColor Cyan

# 1. 디렉토리 구조 확인
Write-Host "`n[1] 디렉토리 구조 확인..." -ForegroundColor Yellow
$dirs = @(
    "backend\app\api\routes",
    "backend\app\core",
    "backend\data",
    "mobile_app\lib\core",
    "mobile_app\lib\data"
)
foreach ($dir in $dirs) {
    if (Test-Path $dir) {
        Write-Host "  ✓ $dir" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $dir 누락" -ForegroundColor Red
        exit 1
    }
}

# 2. Docker 컨테이너 확인
Write-Host "`n[2] Docker 컨테이너 확인..." -ForegroundColor Yellow
cd deployment\docker
$containers = docker-compose ps --format json | ConvertFrom-Json
foreach ($c in $containers) {
    $status = if ($c.State -eq "running") { "✓" } else { "✗" }
    $color = if ($c.State -eq "running") { "Green" } else { "Red" }
    Write-Host "  $status $($c.Service): $($c.State)" -ForegroundColor $color
}
cd ..\..

# 3. PostgreSQL 연결 테스트
Write-Host "`n[3] PostgreSQL 연결 테스트..." -ForegroundColor Yellow
$pgResult = docker exec lotto645_postgres pg_isready -U lotto_user
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ PostgreSQL 연결 성공" -ForegroundColor Green
} else {
    Write-Host "  ✗ PostgreSQL 연결 실패" -ForegroundColor Red
    exit 1
}

# 4. Redis 연결 테스트
Write-Host "`n[4] Redis 연결 테스트..." -ForegroundColor Yellow
$redisResult = docker exec lotto645_redis redis-cli ping
if ($redisResult -eq "PONG") {
    Write-Host "  ✓ Redis 연결 성공" -ForegroundColor Green
} else {
    Write-Host "  ✗ Redis 연결 실패" -ForegroundColor Red
    exit 1
}

# 5. Backend 의존성 확인
Write-Host "`n[5] Backend 의존성 확인..." -ForegroundColor Yellow
cd backend
python -c "import fastapi; import sqlalchemy; import redis" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Backend 의존성 설치 완료" -ForegroundColor Green
} else {
    Write-Host "  ✗ Backend 의존성 오류" -ForegroundColor Red
    exit 1
}
cd ..

# 6. Flutter 환경 확인
Write-Host "`n[6] Flutter 환경 확인..." -ForegroundColor Yellow
cd mobile_app
flutter pub get > $null 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Flutter 의존성 설치 완료" -ForegroundColor Green
} else {
    Write-Host "  ✗ Flutter 의존성 오류" -ForegroundColor Red
    exit 1
}
cd ..

# 7. 자동 테스트 실행
Write-Host "`n[7] 자동 테스트 실행..." -ForegroundColor Yellow
cd backend
pytest tests/test_phase0_setup.py -v
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ 자동 테스트 통과" -ForegroundColor Green
} else {
    Write-Host "  ✗ 자동 테스트 실패" -ForegroundColor Red
    exit 1
}
cd ..

Write-Host "`n=== Phase 0 테스트 완료! ===" -ForegroundColor Cyan
Write-Host "모든 테스트를 통과했습니다. Phase 1로 진행하세요." -ForegroundColor Green
```

**실행**:
```powershell
.\scripts\test_phase0.ps1
```

---

## 🎯 Phase 0 완료 후 다음 단계

**Phase 1로 이동**:
- 데이터베이스 모델 정의
- 로또 크롤러 구현
- 데이터 매니저 구축

**예상 작업 시작**: Phase 0 완료 즉시

---

## 문제 해결 (Troubleshooting)

### PostgreSQL 연결 오류
```
Error: could not connect to server
```
**해결책**:
1. Docker가 실행 중인지 확인: `docker ps`
2. 포트 충돌 확인: `netstat -ano | findstr :5432`
3. 컨테이너 재시작: `docker-compose restart postgres`

### Redis 연결 오류
```
Error: Connection refused
```
**해결책**:
1. Redis 컨테이너 상태 확인: `docker-compose logs redis`
2. 포트 확인: `netstat -ano | findstr :6379`

### Flutter pub get 오류
```
Error: version solving failed
```
**해결책**:
1. Flutter 버전 확인: `flutter --version`
2. 캐시 클리어: `flutter clean && flutter pub get`
3. pubspec.yaml 의존성 버전 확인

---

**Phase 0 문서 종료**

다음: [Phase 1 - 백엔드 Core 모듈](009_Phase_1_Backend_Core.md)

