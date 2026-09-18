# LuckyAI 645 - 실행 스크립트 가이드

## 🚀 빠른 시작 (Quick Start)

```powershell
# 1. 백엔드 의존성 수정 (최초 1회)
cd pick_wizard\backend
.\venv\Scripts\Activate.ps1
pip install psycopg2-binary

# 2. 전체 실행
cd ..\deployment\scripts
.\run_all.ps1
```

**결과**: 백엔드 (http://localhost:8000) + Flutter (Chrome) 자동 실행

---

## 📋 스크립트 목록

### 1. `run_all.ps1` - 통합 실행 (권장)
백엔드와 프론트엔드를 한 번에 실행하는 메인 스크립트

**사용법**:
```powershell
cd pick_wizard\deployment\scripts
.\run_all.ps1
```

**기능**:
- ✅ 자동 사전 확인 (Python venv, Flutter 설치)
- ✅ 백엔드 FastAPI 서버 시작 (새 창)
- ✅ Flutter 앱 실행 (새 창)
- ✅ 상세한 로그 출력
- ✅ 자동 가상환경 생성 옵션

**실행 결과**:
- 백엔드: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Flutter: 모바일 앱 실행

---

### 2. `dev_start.ps1` - 개발 모드 빠른 시작
간단한 명령어로 빠르게 실행

**사용법**:
```powershell
# 전체 실행 (기본값)
.\dev_start.ps1

# 백엔드만
.\dev_start.ps1 backend

# 프론트엔드만
.\dev_start.ps1 frontend

# 전체 실행 (명시적)
.\dev_start.ps1 all
```

**시나리오**:
- 백엔드 API만 테스트할 때
- Flutter UI만 개발할 때
- 전체 통합 테스트할 때

---

### 3. `stop_all.ps1` - 모든 프로세스 종료
실행 중인 모든 LuckyAI 645 프로세스를 종료

**사용법**:
```powershell
.\stop_all.ps1
```

**기능**:
- Uvicorn (FastAPI) 프로세스 종료
- Flutter 프로세스 종료
- Python 관련 프로세스 확인

---

## 🚀 빠른 시작 가이드

### 초기 설정 (최초 1회)

1. **Python 가상환경 생성** (백엔드)
   ```powershell
   cd pick_wizard\backend
   python -m venv venv
   .\venv\Scripts\Activate.ps1
   pip install -r requirements.txt
   ```

2. **Flutter 의존성 설치** (프론트엔드)
   ```powershell
   cd pick_wizard\mobile_app
   flutter pub get
   ```

### 일반 사용

```powershell
# 1. 프로젝트 루트로 이동
cd C:\_PythonWorkspace\_Lotto_picker

# 2. 실행 스크립트로 이동
cd pick_wizard\deployment\scripts

# 3. 통합 실행
.\run_all.ps1

# 4. 개발 완료 후 종료 (선택)
.\stop_all.ps1
```

---

## 🔧 문제 해결

### 실행 정책 오류
```powershell
# 오류: 이 시스템에서 스크립트를 실행할 수 없습니다.
# 해결:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Flutter를 찾을 수 없음
```powershell
# Flutter 설치 확인
flutter --version

# PATH에 추가 (시스템 환경 변수)
$env:PATH += ";C:\flutter\bin"
```

### Python 가상환경 오류
```powershell
# 가상환경 재생성
cd pick_wizard\backend
Remove-Item -Recurse -Force venv
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 포트 이미 사용 중
```powershell
# 8000 포트 사용 프로세스 확인
netstat -ano | findstr :8000

# 프로세스 강제 종료 (PID 확인 후)
Stop-Process -Id <PID> -Force
```

---

## 📊 스크립트 비교

| 스크립트 | 사전 확인 | 새 창 실행 | 로그 상세 | 선택 실행 |
|----------|-----------|------------|-----------|-----------|
| `run_all.ps1` | ✅ | ✅ | ✅ | ❌ |
| `dev_start.ps1` | ❌ | ✅ | ❌ | ✅ |
| `stop_all.ps1` | - | - | ✅ | - |

**권장**:
- 일반 개발: `run_all.ps1`
- 빠른 테스트: `dev_start.ps1 <mode>`
- 프로세스 정리: `stop_all.ps1`

---

## 🎯 추천 워크플로우

### 1. 일일 개발 시작
```powershell
cd pick_wizard\deployment\scripts
.\run_all.ps1
```

### 2. 백엔드 API만 수정할 때
```powershell
.\dev_start.ps1 backend
```

### 3. Flutter UI만 수정할 때
```powershell
.\dev_start.ps1 frontend
```

### 4. 개발 종료
```powershell
# 각 창에서:
# - 백엔드: Ctrl+C
# - Flutter: q

# 또는 한 번에:
.\stop_all.ps1
```

---

## 📝 스크립트 커스터마이징

### 백엔드 포트 변경
`run_all.ps1` 또는 `dev_start.ps1`에서:
```powershell
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
# → 8000을 원하는 포트로 변경
```

### Flutter 디바이스 지정
`run_all.ps1` 또는 `dev_start.ps1`에서:
```powershell
flutter run
# → flutter run -d <device_id>
```

---

## 📞 지원

문제가 발생하면:
1. `stop_all.ps1`로 모든 프로세스 종료
2. 터미널 재시작
3. `run_all.ps1` 재실행
4. 여전히 문제 시 위의 "문제 해결" 섹션 참고

---

**생성일**: 2026-01-05 16:50:00 EST  
**버전**: 1.0.0

