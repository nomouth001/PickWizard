# PickWizard

복권 번호 추천 보조 Flutter 앱과 FastAPI 백엔드 프로젝트입니다.

## 폴더 구조

- `pick_wizard/mobile_app/`: Flutter 모바일 앱 및 테스트
- `pick_wizard/backend/`: FastAPI 백엔드 및 테스트
- `pick_wizard/deployment/`: 배포 설정
- `z_Dev_Docs/`: 설계, 개발 및 배포 문서
- `z_Past_codes/`: 이전 실험 코드와 분석 자료
- `scripts/`: 프로젝트 관리 스크립트

## 모바일 앱 실행

Flutter SDK를 설치한 뒤 프로젝트 루트에서 실행합니다.

```sh
cd pick_wizard/mobile_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

`*.g.dart`, `*.freezed.dart` 파일은 Git에서 제외되므로 새로 내려받은 환경에서는
위 코드 생성 과정이 필요합니다. Android 배포 서명에는 별도로 보관한 키스토어와
`android/key.properties`를 사용합니다.

## 백엔드 실행 (PowerShell)

```powershell
cd pick_wizard/backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
# .env에서 데이터베이스, Redis 및 인증 설정을 구성합니다.
uvicorn app.main:app --reload
```

환경변수 `DEBUG`는 `true` 또는 `false`로 설정해야 합니다.

## 보관 및 제외 항목

환경변수, 서명 키, 비밀번호 문서, 대화 백업, 로컬 캐시, 빌드 산출물 및
학습 모델 파일은 업로드하지 않습니다. 해당 파일은 원래 작업 폴더에 보존됩니다.

2026-09-18 업로드 준비 중 기존 `.git`의 메타데이터 및 일부 객체 유실을 확인하여
현재 파일을 기준으로 Git 이력을 새로 시작했습니다. 기존 Git 원본과 조사 자료는
로컬 `.recovery/`에 보존했으며 저장소에는 포함하지 않습니다.
남아 있는 기록만으로 삭제 전 파일 전체의 완전성을 보증할 수는 없습니다.

검증 결과 (2026-09-18, 기존 로컬 의존성 환경):

- `flutter analyze --no-pub`: 문제 없음
- `flutter test --no-pub`: 168개 통과
- 백엔드 `DEBUG=false`, `python -m pytest tests/unit -q`: 58개 통과

배포용 빌드와 외부 데이터베이스를 사용하는 통합 테스트는 수행하지 않았습니다.
