# 050-4. PickWizard 전환 — 패키지명·앱 ID·디렉터리 통일 계획표 및 체크리스트

**목적**: 스토어 미등록 상태이므로, **표시명(PickWizard)과 별도로 남아 있는 기술 식별자**를 한 번에 정리해 이후 유지보수·브랜드 혼선을 줄인다.

**전제**: Play/App Store에 **동일 `applicationId`/번들 ID로 출시한 이력이 없음**. (이미 출시 후에는 ID 변경이 “새 앱”이 되거나 마이그레이션이 필요해 난이도가 크게 올라간다.)

---

## 1. 현재 상태 요약 (참고)

| 구분 | 현재 예시 | 비고 |
|------|-----------|------|
| Dart `pubspec.yaml` `name` | `luckyai_645` | `import 'package:luckyai_645/...'` 전부 이 이름에 의존 |
| 저장소 경로 | `_Lotto_picker_app/luckyai_645/` | 문서·스크립트 경로에 박혀 있을 수 있음 |
| Android `applicationId` / `namespace` | `com.example.mobile_app` | 예제용 ID — 출시 전 교체 권장 |
| Android Kotlin 패키지 경로 | `.../kotlin/com/example/mobile_app/MainActivity.kt` | `namespace`와 일치 필요 |
| iOS 번들 ID | Xcode 프로젝트 설정 (`PRODUCT_BUNDLE_IDENTIFIER`) | 별도 확인·통일 |

표시명(런처/스토어)은 이미 PickWizard 계열로 정리된 상태이므로, 본 문서는 **코드·빌드·스토어 기술 ID** 중심이다.

---

## 2. 권장 명명 규칙 (사전 결정)

실제 값은 팀이 보유한 **역도메인**에 맞게 치환한다.

| 항목 | 권장 패턴 | 예시 (placeholder) |
|------|-----------|---------------------|
| Dart 패키지 `name` | 소문자+언더스코어, 짧게 | `pick_wizard` |
| Dart import | `package:<name>/` | `package:pick_wizard/...` |
| Android `applicationId` | 역도메인 | `com.yourcompany.pickwizard` |
| Android `namespace` | `applicationId`와 동일 권장 | 동일 |
| Kotlin 패키지·폴더 | `namespace`와 동일한 점 표기 | `com.yourcompany.pickwizard` |
| iOS 번들 ID | Android와 동일해도 됨 | `com.yourcompany.pickwizard` |

**주의**: `com.example.*` 는 스토어·서명·외부 콘솔에서 **실사용 금지에 가깝게 취급**되므로, 이번 전환에서 반드시 교체하는 것을 권장한다.

---

## 3. 전환 단계별 계획표 (순서 고정 권장)

아래 순서는 **되돌리기 비용**을 줄이기 위한 권장 순서다.

| 단계 | 작업 묶음 | 목적 |
|:----:|-----------|------|
| **0** | 범위 확정, 브랜치·백업, 검색 기준 문자열 목록 작성 | 안전한 일괄 변경 |
| **1** | Android `namespace` / `applicationId` / Kotlin 경로·패키지 선언 / `MainActivity` 패키지 | 네이티브 빌드 일관성 |
| **2** | iOS 번들 ID, Runner 관련 설정, 필요 시 Xcode 프로젝트 검색 | iOS 빌드 일관성 |
| **3** | `pubspec.yaml` `name` 변경 → **전역** `package:luckyai_645` → `package:pick_wizard` 치환 | Dart 컴파일 복구 |
| **4** | `flutter pub get` → `dart run build_runner build` (코드 생성 프로젝트인 경우) → `flutter gen-l10n` | 생성 코드·의존성 동기화 |
| **5** | (선택) 상위 폴더 `luckyai_645` → `pick_wizard` 등 이름 변경 + 경로 참조 문서/스크립트 수정 | 저장소 구조 정리 |
| **6** | 백엔드·Docker·배포 스크립트·`.env.example`·CI에서 경로/이름 참조 정리 | 팀 환경 통일 |
| **7** | 외부 콘솔 재등록·키 재연동이 필요한 항목 처리 | 실서비스 연동 |
| **8** | `flutter analyze`, Android/iOS/Web 릴리스 빌드, 스모크 테스트 | 회귀 방지 |

---

## 4. 상세 체크리스트

### 4.0 사전 준비 (단계 0)

- [ ] 전용 작업 브랜치 생성 (예: `chore/rename-pick-wizard-package`)
- [ ] 변경 전 `flutter analyze` / (가능하면) `flutter build apk --release` 기준 로그 보관
- [ ] 검색 키워드 목록 작성 후 각각 건수 기록  
  - `luckyai_645`  
  - `package:luckyai_645`  
  - `com.example.mobile_app`  
  - `LuckyAI` / `luckyai` (문서·스크립트 잔여)
- [ ] **최종 `applicationId`/번들 ID** 한 줄로 문서화 (팀 합의)

### 4.1 Android (단계 1)

- [ ] `android/app/build.gradle` 의 `namespace`, `applicationId` 를 최종 ID로 변경
- [ ] `MainActivity.kt` 의 `package` 선언을 새 패키지로 변경
- [ ] 디렉터리 이동:  
  `android/app/src/main/kotlin/com/example/mobile_app/`  
  → `.../kotlin/com/yourcompany/pickwizard/` (실제 ID에 맞게)
- [ ] `AndroidManifest.xml` 내 `android:name` 등이 옛 패키지를 가리키지 않는지 확인
- [ ] (ProGuard/R8, 서명, flavor 있으면) 동일 검토
- [ ] 변경 후 `flutter build apk` 또는 `appbundle` 로컬 검증

### 4.2 iOS (단계 2)

- [ ] Xcode / `project.pbxproj` 에서 `PRODUCT_BUNDLE_IDENTIFIER` 를 최종 번들 ID로 통일
- [ ] 기존 번들로 등록된 **푸시/Sign in with Apple/Associated Domains** 등이 없다면 이후 단계에서 새 번들로 재설정 예정임을 메모
- [ ] `flutter build ios` (또는 CI) 로컬 검증

### 4.3 Dart 패키지명·import (단계 3~4)

- [ ] `pubspec.yaml` 의 `name:` 를 `pick_wizard` (또는 합의된 이름)로 변경
- [ ] 전역 치환: `package:luckyai_645/` → `package:pick_wizard/` (오타 방지: 끝의 `/` 포함 권장)
- [ ] `import 'package:luckyai_645` 형태 동일 처리
- [ ] `flutter pub get` 성공
- [ ] `flutter gen-l10n` 실행 (생성물이 저장소에 포함되는 정책이면 재생성 후 커밋)
- [ ] `build_runner` 사용 시: `dart run build_runner build --delete-conflicting-outputs` 등으로 재생성
- [ ] `flutter analyze` 무오류

### 4.4 저장소 디렉터리명 (단계 5, 선택)

- [ ] `luckyai_645/` 폴더명 변경 시, 아래를 **전부** 검색해 수정  
  - 문서(`z_Dev_Docs`, README)  
  - PowerShell / bash 스크립트  
  - CI 설정 (GitHub Actions, 등)  
  - 팀원 로컬 안내(위키, 채널)
- [ ] 변경 후 클론·빌드 절차를 한 번 처음부터 재현

### 4.5 백엔드·배포 (단계 6)

- [ ] CORS 허용 오리진, 딥링크, OAuth 리다이렉트 URL에 **옛 번들/applicationId**가 박혀 있지 않은지 확인
- [ ] Docker/compose 경로, 볼륨 마운트 경로에 옛 폴더명이 있으면 수정
- [ ] `.env.example`, 배포 스크립트의 `APP_NAME` 등은 이미 PickWizard로 정리됨 — **경로만** 추가 점검

### 4.6 외부 콘솔·키 재연동 (단계 7)

스토어 미등록이라도, **개발 중에 이미 만든 리소스**가 있으면 재매핑이 필요할 수 있다.

- [ ] **Firebase** `google-services.json` / `GoogleService-Info.plist` — 패키지명·번들 ID 기준으로 앱 등록이 묶임 → 새 ID용 앱 추가 또는 기존 설정 수정
- [ ] **Google Sign-In / OAuth** — Android SHA-1, iOS 번들 ID, 웹 클라이언트 ID 설정 일치
- [ ] **AdMob** — 앱 ID가 스토어 패키지와 연동되는 흐름이 있으면 새 패키지 기준 앱 생성 검토
- [ ] **기타 SDK** (Analytics, Crashlytics 등) 동일 원칙

### 4.7 검증 (단계 8)

- [ ] `flutter analyze`
- [ ] `flutter test` (테스트 존재 시)
- [ ] `flutter build appbundle` (Android 릴리스)
- [ ] `flutter build ios --release` (Mac 환경 시)
- [ ] 실기기 설치 후: 최초 실행, 광고, (켜져 있다면) 로그인, 오프라인 타깃 `-t lib/offline/main_offline.dart` 빌드 스모크

---

## 5. 예상 리스크·완화

| 리스크 | 완화 |
|--------|------|
| 대량 치환으로 오타·누락 | `package:luckyai_645/` 같이 **고정 패턴**으로 검색, PR 전 `grep` 잔여 0건 확인 |
| Kotlin 경로와 `namespace` 불일치 | Android Studio/Gradle 오류로 즉시 드러남 — 단계 1에서 한 번에 맞춤 |
| 생성 코드 커밋 정책 혼선 | 팀 규칙에 따라 gen-l10n / build_runner 결과물 포함 여부 합의 |
| 외부 콘솔 누락 | 단계 7 체크리스트를 “출시 전 필수”로 반복 |

---

## 6. 완료 정의 (Definition of Done)

- [ ] `grep -r "luckyai_645"` / `package:luckyai_645` 가 **의도된 예외 없이 0건** (문서 아카이브 제외 여부는 팀 규칙)
- [ ] `com.example.mobile_app` **0건** (또는 팀이 허용한 범위 명시)
- [ ] Android·iOS 릴리스 빌드가 **로컬 또는 CI에서 성공**
- [ ] `050_Play_Console_등록_절차_및_산출물_가이드.md` 의 예시 패키지명이 **실제 최종 ID**와 일치하도록 갱신

---

## 7. 관련 문서

- `050_Play_Console_등록_절차_및_산출물_가이드.md`
- `050-1_Play_Store_설명.md`
- `049_Android_iOS_Asset_Requirements.md`

---

## 8. 적용 완료 기록 (2026-04-02)

아래는 본 저장소에 **실제 반영된 값**이다. (§1 표는 “전환 전” 참고용으로 유지)

| 항목 | 적용 값 |
|------|---------|
| 저장소 경로 | `_Lotto_picker_app/pick_wizard/` |
| Dart `pubspec.yaml` `name` | `pick_wizard` |
| Dart import | `package:pick_wizard/...` |
| Android `namespace` / `applicationId` | `com.pickwizard.app` |
| Android `MainActivity` 패키지 | `com.pickwizard.app` |
| iOS / macOS `PRODUCT_BUNDLE_IDENTIFIER` | `com.pickwizard.app` (테스트 타깃은 `com.pickwizard.app.RunnerTests`) |
| Linux `APPLICATION_ID` | `com.pickwizard.app` |
| Windows 리소스 (회사명/저작권) | `com.pickwizard.app` / PickWizard |

**추가로 팀에서 직접 확인할 항목**

- [ ] `pick_wizard/mobile_app` 에서 `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` (필요 시) → `flutter gen-l10n` → `flutter analyze` → `flutter build appbundle`
- [ ] Firebase / AdMob / Google Sign-In 등 **외부 콘솔**에 새 패키지명·번들 ID 등록 및 설정 파일 교체
- [ ] 로컬 실행 안내: `z_Dev_Docs/luckyai로컬실행명령어.txt` 는 경로를 `pick_wizard` 기준으로 갱신됨

---

본 문서는 **실행 순서와 누락 방지**에 초점을 둔다. 전환 전 placeholder는 `com.yourcompany.pickwizard`였으며, 본 저장소에는 **`com.pickwizard.app`** 로 확정·적용되었다.
