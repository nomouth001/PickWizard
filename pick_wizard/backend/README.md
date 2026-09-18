# LuckyAI 645 Backend API

AI 기반 로또 번호 생성 서비스 백엔드

## 기술 스택
- **Framework**: FastAPI 0.110+
- **Database**: PostgreSQL 15
- **Cache**: Redis 7.2
- **Task Queue**: Celery 5.3

## 빠른 시작

### 1. 가상 환경 설정
```bash
python -m venv venv
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac
```

### 2. 의존성 설치
```bash
pip install -r requirements.txt
```

### 3. 환경 변수 설정
```bash
cp .env.example .env
# .env 파일 편집
```

### 4. 데이터베이스 초기화
```bash
python scripts/init_db.py
python scripts/load_data.py
```

### 5. API 서버 실행
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 6. Swagger UI 접근
http://localhost:8000/docs

## 프로젝트 구조
```
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
```

## API 엔드포인트
- `GET /api/draws/latest` - 최신 회차 조회
- `POST /api/generate` - 번호 생성
- `GET /api/algorithms` - 알고리즘 목록

## 개발
```bash
# 테스트 실행
pytest

# 코드 포맷팅
black app/

# Linting
flake8 app/
```

## 2026-01-04 EST - Phase 0 초기 설정 완료
- 프로젝트 구조 생성
- 의존성 파일 작성
- 환경 변수 템플릿 작성

