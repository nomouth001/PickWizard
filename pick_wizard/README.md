# PickWizard

복권 번호 추천 보조 모바일 앱(PickWizard) 및 백엔드

## 프로젝트 구조

```
pick_wizard/
├── mobile_app/        # Flutter 모바일 앱
├── backend/           # FastAPI 백엔드 API
├── deployment/        # Docker & K8s 설정
└── shared/            # 공유 리소스
```

## 빠른 시작

### 백엔드 실행
```bash
cd backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Flutter 앱 실행
```bash
cd mobile_app
flutter pub get
flutter run
```

### Docker로 전체 스택 실행
```bash
cd deployment/docker
docker-compose up -d
```

## 문서
- [구현 로드맵](../../z_Dev_Docs/007_Implementation_Roadmap.md)
- [시스템 설계](../../z_Dev_Docs/005_Implementation_Logic_and_Module_Design.md)
- [Phase 0 환경 설정](../../z_Dev_Docs/008_Phase_0_Environment_Setup.md)

## 기술 스택

### 백엔드
- FastAPI 0.110+
- PostgreSQL 15
- Redis 7.2
- Celery 5.3

### 프론트엔드 (모바일)
- Flutter 3.16+
- Riverpod 2.4
- Dio 5.4
- Hive 2.2

## 개발 진행 상황

### Phase 0: 환경 설정 ✅ (2026-01-04 완료)
- [x] 디렉토리 구조 생성
- [x] 백엔드 설정 파일 작성
- [x] Docker Compose 설정
- [x] Git 저장소 초기화
- [ ] Flutter 프로젝트 생성 (Flutter SDK 필요)

### Phase 1: 백엔드 Core (진행 예정)
- [ ] 데이터베이스 모델 정의
- [ ] 로또 크롤러 구현
- [ ] 데이터 매니저 구축

## 라이선스
MIT

## 2026-01-04 EST - Phase 0 초기 설정
프로젝트 기본 구조 및 설정 파일 생성 완료

