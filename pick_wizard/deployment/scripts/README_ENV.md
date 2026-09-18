# Environment Configuration Guide

## 데이터베이스 자동 선택

LuckyAI 645 백엔드는 환경에 따라 자동으로 데이터베이스를 선택합니다.

### 개발 환경 (기본값)

**SQLite 자동 사용**
- 별도 설치 불필요
- 파일 기반 데이터베이스
- 경로: `backend/data/database/luckyai645.db`

```env
ENVIRONMENT=development
USE_SQLITE=True
```

### 프로덕션 환경

**PostgreSQL 사용**
```env
ENVIRONMENT=production
USE_SQLITE=False
DATABASE_URL=postgresql://username:password@localhost:5432/luckyai645
```

---

## 환경 변수 설정

### 방법 1: .env 파일 생성 (권장)

```powershell
# backend 디렉토리로 이동
cd pick_wizard\backend

# .env 파일 생성
notepad .env
```

**.env 파일 내용**:
```env
# 개발 환경 (SQLite)
ENVIRONMENT=development
USE_SQLITE=True
JWT_SECRET_KEY=dev-secret-key

# 또는 프로덕션 환경 (PostgreSQL)
# ENVIRONMENT=production
# USE_SQLITE=False
# DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
# JWT_SECRET_KEY=your-production-secret-key
```

### 방법 2: 환경 변수로 직접 설정

```powershell
# PowerShell
$env:ENVIRONMENT="development"
$env:USE_SQLITE="True"
```

---

## 데이터베이스 전환

### SQLite → PostgreSQL

1. PostgreSQL 설치 및 실행
2. 데이터베이스 생성:
   ```sql
   CREATE DATABASE luckyai645;
   CREATE USER lotto_user WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE luckyai645 TO lotto_user;
   ```

3. .env 파일 수정:
   ```env
   ENVIRONMENT=production
   USE_SQLITE=False
   DATABASE_URL=postgresql://lotto_user:your_password@localhost:5432/luckyai645
   ```

4. 서버 재시작

### PostgreSQL → SQLite

1. .env 파일 수정:
   ```env
   ENVIRONMENT=development
   USE_SQLITE=True
   ```

2. 서버 재시작 (SQLite 파일 자동 생성)

---

## 데이터베이스 초기화

```powershell
cd pick_wizard\backend

# 가상환경 활성화
.\venv\Scripts\Activate.ps1

# Alembic 마이그레이션 (선택)
# alembic upgrade head

# 서버 시작 (테이블 자동 생성)
uvicorn app.main:app --reload
```

---

## 문제 해결

### SQLite 사용 시

**장점**:
- ✅ 설치 불필요
- ✅ 빠른 시작
- ✅ 파일 하나로 관리

**제한 사항**:
- 동시 쓰기 제한
- 프로덕션 부적합

### PostgreSQL 사용 시

**장점**:
- ✅ 프로덕션 준비 완료
- ✅ 동시성 지원
- ✅ 확장성

**필요 사항**:
- PostgreSQL 서버 필수
- 네트워크 설정

---

## 현재 설정 확인

```powershell
cd pick_wizard\backend
.\venv\Scripts\Activate.ps1
python -c "from app.config import settings; print(f'Database: {settings.DATABASE_URL}')"
```

---

**Last Updated**: 2026-01-07 16:00:00 EST

