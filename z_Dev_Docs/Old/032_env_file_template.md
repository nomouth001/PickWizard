# .env 파일 설정 가이드

## 📋 현황

기존 `.env` 파일이 이미 존재하며 정상 작동 중입니다.
**AI Selection 알고리즘 구현을 위해 Google Gemini API 설정만 추가하면 됩니다.**

---

## ✅ 간단 작업: 기존 파일에 추가만 하기

기존 `luckyai_645/backend/.env` 파일의 **맨 아래에** 다음 내용을 복사-붙여넣기 하세요:

```bash
# ===================================================================
# Google Gemini API 설정 (AI Selection 알고리즘용)
# ===================================================================
# 2026-01-17 EST - AI Selection 알고리즘 구현을 위해 추가
# API 키 발급: https://aistudio.google.com/app/apikey
GOOGLE_API_KEY=your-gemini-api-key-here

# AI Selection 알고리즘 설정
AI_SELECTION_MODEL=gemini-2.5-flash-latest
AI_SELECTION_TEMPERATURE=0.7
AI_SELECTION_MAX_TOKENS=1000
AI_SELECTION_TIMEOUT=30
AI_SELECTION_WINDOW_SIZE=200
```

**작업 순서**:
1. `luckyai_645/backend/.env` 파일 열기 (메모장 또는 VS Code)
2. 파일 맨 아래로 이동
3. 위 7줄 복사하여 붙여넣기
4. `GOOGLE_API_KEY=your-gemini-api-key-here` 부분에 실제 API 키 입력
5. 저장 후 닫기

---

## 🔍 기존 .env vs 추가할 내용 비교

### 기존 파일 (변경 불필요)
```bash
# === Application Settings ===
APP_NAME=LuckyAI 645
APP_VERSION=1.0.0
DEBUG=True                                    # ✅ 개발 환경이므로 True 유지
ENVIRONMENT=development

# === Database ===
DATABASE_URL=postgresql://...                 # ✅ 이미 PostgreSQL 설정됨

# === File Paths ===
LOTTO_CSV_PATH=data/raw/lotto_data.csv       # ✅ 기존 설정 유지
MODEL_DIR=data/models

# === CORS ===
CORS_ORIGINS=["http://localhost:3000","..."] # ✅ 구체적으로 설정됨
```

### 추가할 내용 (신규)
```bash
# === Google Gemini API 설정 ===               # 🆕 AI Selection 알고리즘용
GOOGLE_API_KEY=...                            # 🆕 발급받아 입력 필요
AI_SELECTION_MODEL=gemini-2.5-flash-latest    # 🆕 모델 이름
AI_SELECTION_TEMPERATURE=0.7                  # 🆕 샘플링 온도
AI_SELECTION_MAX_TOKENS=1000                  # 🆕 최대 출력 토큰
AI_SELECTION_TIMEOUT=30                       # 🆕 타임아웃 (초)
AI_SELECTION_WINDOW_SIZE=200                  # 🆕 분석 회차 수
```

---

## 📝 최종 .env 파일 구조 (참고용)

추가 후 전체 파일 구조는 다음과 같이 됩니다:

```bash
# === Application Settings ===
APP_NAME=LuckyAI 645
APP_VERSION=1.0.0
DEBUG=True
ENVIRONMENT=development

# === Server Settings ===
HOST=0.0.0.0
PORT=8000

# === Database ===
DATABASE_URL=postgresql://lotto_user:lotto_pass@localhost:5432/lotto645_dev

# === Redis ===
REDIS_URL=redis://localhost:6379/0
CACHE_TTL=3600

# === Celery ===
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/1
CELERY_TIMEZONE=Asia/Seoul

# === Security ===
JWT_SECRET_KEY=your-secret-key-change-in-production-min-32-characters
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# === Lotto Crawler ===
LOTTO_CRAWLER_URL=https://www.dhlottery.co.kr/gameResult.do?method=byWin
CRAWLER_TIMEOUT=10
CRAWLER_RETRY=3

# === File Paths ===
LOTTO_CSV_PATH=data/raw/lotto_data.csv
MODEL_DIR=data/models

# === Logging ===
LOG_LEVEL=INFO
LOG_FILE=logs/app.log

# === CORS ===
CORS_ORIGINS=["http://localhost:3000","http://localhost:8080"]

# ===================================================================
# Google Gemini API 설정 (AI Selection 알고리즘용)
# ===================================================================
# 2026-01-17 EST - AI Selection 알고리즘 구현을 위해 추가
# API 키 발급: https://aistudio.google.com/app/apikey
GOOGLE_API_KEY=your-gemini-api-key-here

# AI Selection 알고리즘 설정
AI_SELECTION_MODEL=gemini-2.5-flash-latest
AI_SELECTION_TEMPERATURE=0.7
AI_SELECTION_MAX_TOKENS=1000
AI_SELECTION_TIMEOUT=30
AI_SELECTION_WINDOW_SIZE=200
```

---

## 🔑 API 키 발급 방법

1. **https://aistudio.google.com/app/apikey** 접속
2. Google 계정 로그인
3. "Create API Key" 또는 "Get API Key" 클릭
4. 새 프로젝트 생성 또는 기존 프로젝트 선택
5. 생성된 키 복사 (예: `YOUR_GOOGLE_API_KEY`)
6. `.env` 파일의 `GOOGLE_API_KEY=` 뒤에 붙여넣기

**예시**:
```bash
GOOGLE_API_KEY=YOUR_GOOGLE_API_KEY
```

---

## ⚠️ 보안 주의사항

1. **`.env` 파일은 절대 Git에 커밋하지 마세요!**
   - 이미 `.gitignore`에 포함되어 자동 제외됨
   
2. **API 키가 노출되면**:
   - 다른 사람이 무단으로 사용 가능
   - Google Cloud 비용 청구 가능
   - 즉시 키를 삭제하고 재발급

3. **확인 방법**:
   ```powershell
   # Git 상태 확인 (.env가 추적되지 않는지 확인)
   cd C:\_PythonWorkspace\_Lotto_picker\luckyai_645
   git status
   
   # .env가 나타나면 안 됨!
   ```

---

## ✅ 작업 완료 체크리스트

- [ ] `.env` 파일 열기
- [ ] 파일 맨 아래에 Gemini API 설정 7줄 추가
- [ ] `GOOGLE_API_KEY`에 실제 API 키 입력
- [ ] 저장 후 닫기
- [ ] `git status`로 .env가 추적 안 되는지 확인
- [ ] (선택) Python에서 불러오기 테스트:
  ```python
  from app.config import settings
  print(settings.GOOGLE_API_KEY[:10] + "...")  # 처음 10자만 출력
  ```

---

## 🎯 요약

**기존 `.env` 파일은 그대로 두고, 맨 아래에 Google Gemini API 설정 7줄만 추가하면 됩니다.**

복사-붙여넣기 후 API 키만 입력하면 끝!
