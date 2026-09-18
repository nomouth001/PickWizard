# Phase 0-6 테스트 가이드 완성 보고서

**작성일**: 2026-01-08 EST  
**작성자**: AI 코딩 어시스턴트  
**목적**: 각 Phase 완료 시 자동/수동 테스트 항목 명확화

---

## 📋 변경 사항 요약

마스터의 요청에 따라 **모든 Phase 문서(0-6)에 자동/수동 테스트 섹션을 추가**했습니다.

### 추가된 섹션

각 Phase 문서 말미에 다음 3가지 섹션 추가:

1. **🧪 자동 테스트 스크립트**
   - Python pytest 또는 Flutter test 코드
   - 복사/붙여넣기 가능한 완전한 테스트 코드
   - 각 Phase의 핵심 기능 검증

2. **✅ 자동 테스트 체크리스트**
   - pytest/flutter test 명령으로 실행
   - 각 테스트 함수별 체크박스
   - 예상 통과 개수 명시

3. **📝 수동 테스트 체크리스트**
   - 개발자가 직접 확인해야 할 항목
   - 명령어 및 URL 제시
   - 확인 사항 명시

4. **🔄 통합 테스트 스크립트** (일부 Phase)
   - PowerShell 또는 Bash 스크립트
   - 자동 + 수동 테스트 일부 자동화

---

## 📊 Phase별 테스트 항목

### Phase 0: 환경 설정

**자동 테스트** (7개):
- ✅ 디렉토리 구조 검증
- ✅ 백엔드 필수 파일 검증
- ✅ Flutter 필수 파일 검증
- ✅ PostgreSQL 연결
- ✅ Redis 연결
- ✅ Docker Compose 상태
- ✅ 환경 변수 파일 검증

**수동 테스트** (8개 항목):
1. Docker 컨테이너 상태 확인
2. PostgreSQL 수동 접속
3. Redis 수동 접속
4. pgAdmin 웹 접속
5. Backend Python 환경
6. Flutter 환경
7. Git 저장소 확인
8. 디렉토리 구조 확인

**통합 스크립트**: `scripts/test_phase0.ps1`

---

### Phase 1: 백엔드 Core

**자동 테스트** (5개):
- ✅ LottoDraw 모델 테스트
- ✅ User 모델 테스트
- ✅ 크롤러 최신 회차 조회
- ✅ 크롤러 단일 회차 크롤링
- ✅ 데이터 검증기 테스트

**수동 테스트** (7개 항목):
1. 데이터베이스 마이그레이션 확인
2. 크롤러 수동 실행
3. PostgreSQL 데이터 확인
4. Redis 캐싱 테스트
5. CSV 파일 생성 확인
6. 설정 파일 로드
7. 로그 파일 확인

**통합 스크립트**: `scripts/test_phase1.ps1`

---

### Phase 2: 백엔드 알고리즘 & API

**자동 테스트** (8개):
- ✅ 알고리즘 로딩
- ✅ 랜덤 알고리즘
- ✅ API 헬스 체크
- ✅ /api/algorithms 엔드포인트
- ✅ /api/generate 엔드포인트
- ✅ /api/draws/latest 엔드포인트
- ✅ /api/draws/{draw_no} 엔드포인트
- ✅ API 입력 검증

**수동 테스트** (8개 항목):
1. FastAPI 서버 실행
2. Swagger UI 접속 (http://localhost:8000/docs)
3. /api/algorithms 수동 테스트
4. /api/generate 수동 테스트
5. 다양한 알고리즘 테스트 (ID 1-6)
6. curl 명령으로 API 테스트
7. 에러 처리 테스트
8. 로그 확인

**통합 스크립트**: `scripts/test_phase2.ps1`

---

### Phase 3: Flutter 앱

**자동 테스트** (2개):
- ✅ LottoDraw fromJson
- ✅ GenerateRequest toJson

**수동 테스트** (5개 항목):
1. Flutter 앱 빌드 및 실행
2. 홈 화면 확인
3. 번호 생성 화면 확인
4. 히스토리 화면 확인
5. API 연동 테스트

---

### Phase 4: 비즈니스 로직 (인증 & 코인)

**자동 테스트** (3개):
- ✅ 게스트 사용자 생성
- ✅ 일일 로그인 보상
- ✅ 코인 차감

**수동 테스트** (4개 그룹):
1. 게스트 계정 생성 (앱 첫 실행)
2. 코인 획득 (일일 로그인, 광고 시청)
3. 번호 생성 & 코인 차감
4. 데이터 영속성 (앱 재시작)

---

### Phase 5: 고급 기능

**자동 테스트** (3개):
- ✅ 1등 판정 테스트
- ✅ 2등 판정 테스트
- ✅ 미당첨 판정 테스트

**수동 테스트** (4개 항목):
1. 내 번호 저장
2. 수동 당첨 확인
3. Celery 백그라운드 작업 (Worker, Beat, Task)
4. Push 알림 (선택)

---

### Phase 6: 배포 준비

**자동 테스트** (5개 체크):
- ✅ Docker Compose 빌드
- ✅ 전체 스택 실행
- ✅ 컨테이너 상태
- ✅ Backend 헬스 체크
- ✅ Celery Worker 확인

**수동 테스트** (7개 그룹):
1. Docker 전체 스택 실행
2. Nginx Reverse Proxy 테스트
3. AWS Lightsail 배포 확인
4. Flutter APK 테스트
5. 전체 플로우 테스트 (End-to-End)
6. 성능 & 보안 테스트
7. 모니터링 & 로그

**프로덕션 체크리스트**:
- 인프라 (5개 항목)
- 백엔드 (5개 항목)
- 앱 (4개 항목)
- 보안 (4개 항목)
- 백업 (3개 항목)

---

## 🗂️ 테스트 파일 구조

```
프로젝트/
├── backend/
│   ├── tests/
│   │   ├── test_phase0_setup.py       # Phase 0 자동 테스트
│   │   ├── test_phase1_core.py        # Phase 1 자동 테스트
│   │   ├── test_phase2_algorithms.py  # Phase 2 자동 테스트
│   │   ├── test_phase4_business.py    # Phase 4 자동 테스트
│   │   └── test_phase5_advanced.py    # Phase 5 자동 테스트
│   └── ...
│
├── mobile_app/
│   ├── test/
│   │   └── phase3_test.dart           # Phase 3 자동 테스트
│   └── ...
│
└── scripts/
    ├── test_phase0.ps1                 # Phase 0 통합 테스트
    ├── test_phase1.ps1                 # Phase 1 통합 테스트
    ├── test_phase2.ps1                 # Phase 2 통합 테스트
    └── test_phase6_deployment.sh       # Phase 6 배포 테스트
```

---

## 🚀 실행 방법

### 자동 테스트 실행

**백엔드**:
```bash
cd backend

# Phase 0
pytest tests/test_phase0_setup.py -v

# Phase 1
pytest tests/test_phase1_core.py -v

# Phase 2
pytest tests/test_phase2_algorithms.py -v

# Phase 4
pytest tests/test_phase4_business.py -v

# Phase 5
pytest tests/test_phase5_advanced.py -v

# 전체 실행
pytest tests/ -v
```

**Flutter**:
```bash
cd mobile_app

# Phase 3
flutter test test/phase3_test.dart

# 전체 실행
flutter test
```

---

### 통합 테스트 실행

```powershell
# Phase 0
.\scripts\test_phase0.ps1

# Phase 1
.\scripts\test_phase1.ps1

# Phase 2
.\scripts\test_phase2.ps1

# Phase 6 (Bash)
bash scripts/test_phase6_deployment.sh
```

---

## 📈 테스트 커버리지

| Phase | 자동 테스트 | 수동 테스트 | 통합 스크립트 | 총 검증 항목 |
|-------|-------------|-------------|---------------|--------------|
| Phase 0 | 7개 | 8개 | ✅ | **15개** |
| Phase 1 | 5개 | 7개 | ✅ | **12개** |
| Phase 2 | 8개 | 8개 | ✅ | **16개** |
| Phase 3 | 2개 | 5개 | - | **7개** |
| Phase 4 | 3개 | 4개 | - | **7개** |
| Phase 5 | 3개 | 4개 | - | **7개** |
| Phase 6 | 5개 | 7개 | ✅ | **12개** |
| **총계** | **33개** | **43개** | **4개** | **76개** |

---

## ✅ 개선 효과

### Before (개선 전)
- ❌ 테스트 항목이 혼재 (자동/수동 구분 없음)
- ❌ 테스트 방법 불명확
- ❌ 완료 기준 애매

### After (개선 후)
- ✅ **자동 테스트**: pytest/flutter test로 즉시 실행 가능
- ✅ **수동 테스트**: 명령어와 확인 방법 명시
- ✅ **통합 스크립트**: 한 번에 Phase 전체 검증
- ✅ **체크리스트**: 완료 기준 명확

---

## 🎯 사용 시나리오

### 개발자 A (Phase 2 완료 후)
1. 자동 테스트 실행:
   ```bash
   pytest tests/test_phase2_algorithms.py -v
   ```
   → 8 passed 확인

2. 통합 스크립트 실행:
   ```powershell
   .\scripts\test_phase2.ps1
   ```
   → 모든 체크 통과

3. 수동 테스트 진행:
   - Swagger UI 접속
   - API 수동 테스트
   - curl 명령 테스트
   
4. **Phase 2 완료 확정** → Phase 3 진행

---

### QA 엔지니어 B (전체 검증)
1. 각 Phase별 자동 테스트 실행:
   ```bash
   pytest backend/tests/ -v
   flutter test mobile_app/test/
   ```

2. 통합 스크립트 순차 실행:
   ```powershell
   .\scripts\test_phase0.ps1
   .\scripts\test_phase1.ps1
   .\scripts\test_phase2.ps1
   bash scripts/test_phase6_deployment.sh
   ```

3. 수동 테스트 체크리스트 순회

4. **전체 검증 완료** → 배포 승인

---

## 📝 문서 변경 내역

- `008_Phase_0_Environment_Setup.md` - 테스트 섹션 추가 (500줄)
- `009_Phase_1_Backend_Core.md` - 테스트 섹션 추가 (450줄)
- `010_Phase_2_Backend_Algorithms.md` - 테스트 섹션 추가 (500줄)
- `012_Phase_3_Flutter_App_Part2.md` - 테스트 섹션 추가 (200줄)
- `014_Phase_4_Business_Logic_Part2.md` - 테스트 섹션 추가 (300줄)
- `015_Phase_5_Advanced_Features.md` - 테스트 섹션 추가 (250줄)
- `016_Phase_6_Deployment.md` - 테스트 섹션 추가 (400줄)
- `.cursor/code_change_log.md` - 변경 이력 기록

**총 추가 분량**: 약 2,600줄

---

## 🎉 결론

**모든 Phase 문서에 자동/수동 테스트 섹션 추가 완료!**

이제 각 Phase 완료 시:
1. **자동 테스트 실행** → 즉시 결과 확인
2. **통합 스크립트 실행** → 한 번에 검증
3. **수동 테스트 체크리스트** → 빠짐없이 확인

개발자와 QA 엔지니어 모두 명확한 완료 기준을 가지고 진행 가능합니다!

---

**문서 위치**: `z_Dev_Docs/018_Testing_Guide_Complete.md`  
**작성 완료**: 2026-01-08 EST

