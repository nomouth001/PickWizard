# Codebase implementation review
_Exported on 5/9/2026 at 17:47:13 EDT from Cursor (3.3.27)_

---

**User**

@z_Dev_Docs/053_Agent_Execution_Prompts.md 대로 끝까지 auto로 실행시켰거든. step1,3,4였나? 네다 think모델 권했던 step은 think 모델로 했고.  현재의 코드베이스가 설계대로 구현됐는지, 오류는 없는지, 리팩토링의 필요성은 없는지 검토해라.

---

**Cursor**

지금까지 구현된 파일들을 전반적으로 검토하겠습니다.

이제 결과 화면, 내 번호 화면, 테스트 파일들을 확인합니다.

이제 실제 테스트를 실행해서 통과 여부를 확인하겠습니다.

테스트 결과에서 중복 실행되는 테스트가 발견됩니다. 위젯 테스트 파일들을 확인합니다.

이제 LottoConstants 파일과 NumberCard 위젯도 확인합니다.

이제 충분히 파악했습니다. 전체 검토 결과를 정리합니다.

---

## 검토 결과

### ✅ 전체 구현 완료 상태 확인

**테스트**: 90개 전체 PASS  
**분석**: `flutter analyze` — 오류 0개  
**구현 범위**: STEP 0~14 전체 (GameType 모델 → Hive 마이그레이션 → Provider → 생성 로직 → UI/UX → 다국어까지)

---

### 🐛 버그 1건

**`offline_splash_screen.dart` DB 초기화 다이얼로그 제목 오류**

```48:45:pick_wizard/mobile_app/lib/offline/screens/offline_splash_screen.dart
        title: Text(context.l10n.confirm),   // "확인" — 버튼 텍스트가 제목으로 들어감
        content: const Text('앱 업데이트로 저장된 번호가 초기화되었습니다.'),
```

`context.l10n.confirm`은 "확인" 버튼 레이블인데 AlertDialog의 `title`에 쓰여 있습니다. 설계 명세(STEP 4)에는 단순히 AlertDialog를 띄우라고만 명시했지만 UX상 제목이 "확인"이면 이상합니다.

---

### 💀 죽은 코드 2건

**1. `OfflineAlgorithmInfo.name` / `.description` 미사용**

```22:38:pick_wizard/mobile_app/lib/offline/providers/offline_providers.dart
final offlineAlgorithmsProvider = Provider<List<OfflineAlgorithmInfo>>((ref) {
  final gt = ref.watch(offlineSelectedGameTypeProvider);  // 게임 변경 시 재계산
  return [
    OfflineAlgorithmInfo(
      id: 1,
      name: '자동선택 (Quick Pick)',          // 사용되지 않음
      description: '${gt.mainMin}~...',      // 사용되지 않음
    ),
```

`offline_home_screen.dart`에서는 `algo.name`, `algo.description`을 전혀 사용하지 않고 l10n 문자열을 직접 생성합니다:

```245:254:pick_wizard/mobile_app/lib/offline/screens/offline_home_screen.dart
final name = algo.id == 1
    ? l10n.algorithm1Name
    : l10n.algorithm9NameDisplay;
final desc = algo.id == 1
    ? l10n.algorithm1DescDynamic(...)
    : l10n.algorithm9DescDynamic(gameType.mainCount);
```

결과적으로 `offlineAlgorithmsProvider`가 `offlineSelectedGameTypeProvider`를 `watch`하며 매 게임 변경 시 재계산하지만, 그 결과물(name/description)은 아무 데도 쓰이지 않습니다. `OfflineAlgorithmInfo`의 `id` 필드만 실제로 사용됩니다.

**2. `lotto_constants.dart` — 파일 전체 미사용**

`lib/` 전체에서 `lotto_constants`를 import하는 파일이 **단 하나도 없습니다**. `GameType`으로 완전 대체되었으므로 이 파일은 삭제 대상입니다.

---

### 🔧 코드 스멜 2건

**1. `_Random` 래퍼 클래스 무의미**

```311:314:pick_wizard/mobile_app/lib/offline/services/local_lotto_service.dart
/// Random wrapper for deterministic tests (optional); use Random() in production
class _Random {
  final _r = Random();
  int nextInt(int max) => _r.nextInt(max);
}
```

주석에 "deterministic tests를 위한 래퍼"라고 적혀 있지만 실제 주입 메커니즘(생성자 파라미터, mock 교체 등)이 없어 테스트에서도 `Random()`과 동일합니다. 없애거나 실제 주입 가능하게 만들어야 합니다.

**2. `test_helpers.dart` — STEP 0 스텁이 정리되지 않음**

```11:16:pick_wizard/mobile_app/test/helpers/test_helpers.dart
GeneratedNumbers makeGeneratedNumbers(
  Object? gameTypeStub,   // STEP 1 완료 후 GameType?으로 교체 예정이었으나 방치됨
  ...
) {
  identityHashCode(gameTypeStub);  // 미사용 경고 방지용 해킹
```

STEP 0 명세에 "STEP 1 완료 후 타입 교체"라고 명시되어 있었지만 그대로 `Object?`로 남아 있습니다.

---

### 📋 설계 준수 여부 체크

| STEP | 설명 | 상태 |
|------|------|------|
| 0 | 테스트 인프라 | ✅ |
| 1 (A1) | GameType 모델 + 15개 테스트 | ✅ |
| 2 (A2) | 하드코딩 상수 제거 | ✅ |
| 3 (A3) | GeneratedNumbers 확장 + 4개 테스트 | ✅ |
| 4 (A4) | Hive 어댑터 + DB 마이그레이션 + 4개 테스트 | ✅ (제목 버그 제외) |
| 5 (A5·A6) | Provider 3개 추가 + 4개 테스트 | ✅ |
| 6 (B) | 로또645 회귀 17개 테스트 | ✅ |
| 7 (C) | 게임 타입별 생성 로직 + 15개 테스트 | ✅ |
| 8 (D1·D2·D6) | 게임·언어 드롭다운 + 초기화 | ✅ |
| 9 (D3) | SharedPreferences 저장/복원 | ✅ |
| 10 (D4·D5·D11) | 옵션 모달 보너스 볼 섹션 | ✅ |
| 11 (D7) | LottoBall 위젯 + 6개 테스트 | ✅ |
| 12 (D8) | 결과 화면 5+1 분리 + 2개 테스트 | ✅ |
| 13 (D9·D10) | 내 번호 배지 + 필터 + 4개 테스트 | ✅ |
| 14 (E) | ARB 키 19개 + gen-l10n | ✅ |

---

### 우선순위 요약

| 우선순위 | 항목 |
|---------|------|
| 즉시 수정 | 스플래시 DB 리셋 다이얼로그 title 버그 |
| 정리 권장 | `lotto_constants.dart` 파일 삭제 |
| 리팩토링 권장 | `OfflineAlgorithmInfo.name/.description` 제거 또는 사용 / `_Random` 제거 / `test_helpers.dart` 타입 정리 |

버그와 정리 항목을 수정할까요?

---

**User**

진행해라.

---

**Cursor**

이제 ARB 파일에 키를 추가합니다.

6개 ARB 파일에 새 키를 추가합니다.

ARB 파일은 JSON 형식이라 `//` 주석을 지원하지 않습니다. 주석을 제거합니다.

이제 `OfflineAlgorithmInfo`의 미사용 필드를 제거합니다.

이제 전체 테스트와 분석을 다시 실행해서 모든 것이 정상인지 확인합니다.

`algo.name`이 `generate()` 내부에서도 쓰이고 있었습니다. `OfflineGenerateNotifier.generate()`에서 id 기반으로 이름을 직접 유도하도록 수정합니다.

**90개 테스트 전체 PASS, flutter analyze 오류 0개** 확인 완료.

---

## 변경 내역 요약

### 버그 수정
- **`offline_splash_screen.dart`**: DB 초기화 다이얼로그 title이 버튼 레이블 `l10n.confirm`("확인")이던 것을 `l10n.dbResetDialogTitle`("알림")으로 교체. 본문도 하드코딩 한국어에서 `l10n.dbResetDialogMessage`로 교체.
- **6개 ARB 파일** (`app_ko/en/ja/zh/th/vi.arb`): `dbResetDialogTitle`, `dbResetDialogMessage` 키 추가 (일본어·중국어·태국어·베트남어는 기계번역 적용)

### 불필요한 코드 제거
- **`lotto_constants.dart` 삭제**: `lib/` 전체에서 단 하나도 import 하지 않는 파일. `GameType`으로 완전 대체된 상태였으므로 삭제.
- **`OfflineAlgorithmInfo.name/.description` 제거**: 프로바이더에서 계산하지만 화면에서는 l10n 문자열을 직접 사용해 실제로 쓰이지 않던 필드와 연산 제거. `offlineAlgorithmsProvider`는 `offlineSelectedGameTypeProvider` watch를 중단하고 `const` 리스트를 반환하도록 단순화.
- **`_Random` 래퍼 클래스 제거** (`local_lotto_service.dart`): "deterministic tests용"이라는 주석이 있으나 주입 메커니즘이 없어 `Random()`과 동일하던 무의미한 클래스 제거. 직접 `Random()`을 사용하도록 교체.

### 타입 정리
- **`test_helpers.dart`**: `Object? gameTypeStub` + `identityHashCode()` 해킹을 `GameType? gameType`으로 교체. 생성되는 더미 번호도 `gt.mainCount`에 맞춰 정확히 생성하도록 수정.

---

**User**

버전 올려라.

---

**Cursor**

현재 `1.0.0+1`. 게임 타입 확장(파워볼/메가밀리언/Win for Life 추가), 보너스 볼, 필터, DB 마이그레이션 등 기능이 대거 추가되었으므로 **minor** 버전을 올립니다.

`1.0.0+1` → **`1.1.0+2`** 로 올렸습니다.

- **version code** `+2`: Play Store 내부 빌드 번호
- **version name** `1.1.0`: 기존 1.0.0 대비 게임 타입 확장(파워볼·메가밀리언·Win for Life), 보너스 볼 포함/제외, 내 번호 필터, DB 스키마 마이그레이션 등 신기능이 추가되었으므로 minor 버전 증가

`flutter analyze` 이상 없음.

---

**User**

이것만 바꾸면 되니? 안드로이드 빌드버전, 내부버전, ios버전 전부 안바꾸고?

---

**Cursor**

Android와 iOS 네이티브 설정을 확인합니다.

`pubspec.yaml`만 바꾸면 됩니다.

- **Android** `build.gradle`: `versionCode = flutter.versionCode`, `versionName = flutter.versionName` — Flutter가 pubspec에서 자동으로 읽어옴
- **iOS** `Info.plist`: `$(FLUTTER_BUILD_NAME)`, `$(FLUTTER_BUILD_NUMBER)` — 마찬가지로 빌드 시 Flutter가 주입

두 플랫폼 모두 네이티브 파일에 하드코딩이 없고 pubspec 값을 참조하는 구조입니다. `pubspec.yaml`의 `version: 1.1.0+2` 하나만 변경하면 Android(`versionName=1.1.0`, `versionCode=2`)와 iOS(`CFBundleShortVersionString=1.1.0`, `CFBundleVersion=2`) 모두 자동 반영됩니다.

---

**User**

그러면 여기서 로컬깃에 백업하고, aab 빌드해라.

---

**Cursor**

먼저 git 상태와 최근 커밋 메시지를 확인합니다.

커밋 완료. 이제 AAB 빌드합니다. 키스토어 설정을 먼저 확인합니다.

`key.properties`가 없습니다. 키스토어 파일 위치를 확인합니다.

키스토어 파일이 `mobile_app/upload-keystore.jks`에 있습니다. `key.properties`를 생성하고 빌드합니다.

빌드가 진행 중입니다. 완료될 때까지 모니터링합니다.

경로가 틀렸습니다. Gradle의 `file()`은 `android/app/` 기준으로 해석합니다. 키스토어가 `mobile_app/` 루트에 있으므로 `../../upload-keystore.jks`가 맞습니다.

경로는 맞지만 비밀번호 오류입니다. 키스토어 비밀번호를 직접 검증합니다.

키스토어 비밀번호가 문서(`Password!@`)와 일치하지 않습니다. 키스토어를 직접 생성하신 분이시니 실제 입력하신 비밀번호를 알고 계실 것입니다.

실제 사용하신 키스토어 비밀번호를 알려주시면 즉시 `key.properties`를 수정하고 빌드를 재개하겠습니다.

---

**User**

<timestamp>Saturday, May 9, 2026, 2:47 PM (UTC-4)</timestamp>
<system_notification>
The following task has finished. If you were already aware, ignore this notification and do not restate prior responses.

<task>
kind: shell
status: error
task_id: 656998
title: AAB 릴리즈 빌드
detail: exit_code=1
output_path: C:\Users\LTH_Laptop\.cursor\projects\h-Lotto-picker-app\terminals\656998.txt
</task>
</system_notification>
<user_query>Briefly inform the user about the task result and perform any follow-up actions (if needed).</user_query>

<timestamp>Saturday, May 9, 2026, 2:47 PM (UTC-4)</timestamp>
<system_notification>
The following task has finished. If you were already aware, ignore this notification and do not restate prior responses.

<task>
kind: shell
status: error
task_id: 788163
title: AAB 릴리즈 빌드 재시도
detail: exit_code=1
output_path: C:\Users\LTH_Laptop\.cursor\projects\h-Lotto-picker-app\terminals\788163.txt
</task>
</system_notification>
<user_query>Briefly inform the user about the task result and perform any follow-up actions (if needed).</user_query>

---

**Cursor**

빌드 두 번 모두 실패했으며, 이미 원인을 파악했습니다.

**진행 상황:**
- ✅ 로컬 git 커밋 완료 (90개 파일, `feat: GameType 확장 — v1.1.0`)
- ✅ `key.properties` 생성 및 키스토어 경로 수정 완료
- ❌ AAB 빌드 실패 — **키스토어 비밀번호 불일치**

문서(`PickWizard_KeystorePW_20260408.txt`)에 기록된 `Password!@`로 `upload-keystore.jks`를 열려 했으나 keytool에서 직접 검증해도 오류가 발생합니다.

실제 키스토어 생성 시 입력하셨던 비밀번호를 알려주시면 바로 `key.properties`를 수정하고 빌드를 재시도하겠습니다.

---

**User**

flutter pub get
flutter build appbundle --release --target lib/offline/main_offline.dart
==> 이 명령어 맞지

---

**Cursor**

현재 `key.properties`를 보고 계신 것 같으니 비밀번호를 직접 수정하셨나요? 먼저 파일 내용을 확인합니다.

비밀번호가 아직 그대로네요. 명령어 자체는 **맞습니다** — `--target lib/offline/main_offline.dart`를 지정하는 것이 오프라인 전용 빌드의 올바른 방식입니다.

다만 비밀번호가 틀린 상태로 빌드하면 동일한 오류가 납니다. 올바른 비밀번호를 `key.properties`에 직접 입력하신 후 아래 명령어를 실행하시면 됩니다:

```powershell
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter pub get
flutter build appbundle --release --target lib/offline/main_offline.dart
```

비밀번호를 알려주시면 제가 `key.properties`를 수정하고 빌드까지 바로 실행하겠습니다.

---

**User**

키파일@pick_wizard/mobile_app/upload-keystore.jks @pick_wizard/mobile_app/android/key.properties:4-5 키파일 디렉토리 맞지?

---

**Cursor**

Gradle에서 `storeFile` 경로 해석 방식을 확인합니다.



**키 파일 위치**는 `pick_wizard/mobile_app/upload-keystore.jks`가 맞습니다.

다만 **`storeFile=../upload-keystore.jks`는 Gradle 기준으로는 맞지 않습니다.**

`storeFile`은 `android/app/build.gradle` 안에서 `file(keystoreProperties["storeFile"])`로 열리므로, **기준 디렉터리는 `android/app/`**입니다.

| 설정 | 실제로 가리키는 경로 |
|------|---------------------|
| `../upload-keystore.jks` | `pick_wizard/mobile_app/android/upload-keystore.jks` (키 파일과 다름) |
| `../../upload-keystore.jks` | `pick_wizard/mobile_app/upload-keystore.jks` (원하는 위치) |

그래서 **`storeFile`에는 `../../upload-keystore.jks`가 맞습니다.**  
`key.properties`가 `android/`에 있어도, 그 안의 상대 경로는 **`key.properties` 파일 위치가 아니라 `app` 모듈의 `build.gradle` 기준**으로 해석된다고 보면 됩니다.

요약: 키는 `mobile_app/` 루트에 두는 것이 맞고, `storeFile`은 **`../../upload-keystore.jks`**로 두는 것이 맞습니다.

---

**User**

@pick_wizard/mobile_app/upload-keystore.jks 이거 @pick_wizard/mobile_app/android/key.properties:1-4 패스워드 뭔지 기억이 안나는데

---

**Cursor**

비밀번호는 키스토어 파일 안에 **평문으로 저장되지 않습니다**. 기억이 나지 않으면 도구로 “읽어내는” 방법은 없고, **맞는 비밀번호를 입력했을 때만** 열립니다.

**할 수 있는 것**

1. **예전에 쓴 비밀번호 후보**  
   메모, 비밀번호 관리자, 다른 PC 백업, 팀 공유 문서 등에서 찾아보는 수밖에 없습니다.  
   문서에 적힌 `Password!@`는 이전에 `keytool`로 검증했을 때 **이 `.jks`와는 맞지 않았습니다** (다른 키용이거나 오타일 수 있음).

2. **Play 스토어에 이미 올린 앱인 경우**  
   Google Play **앱 서명(App Signing)** 을 쓰면, 업로드용 키는 나중에 **재설정 요청**이 가능한 경우가 많습니다. Play Console → 앱 → 설정 → 앱 무결성 / 앱 서명에서 안내를 확인하면 됩니다.

3. **아직 스토어에 안 올렸거나, 새 키로 해도 되는 경우**  
   새 `upload-keystore.jks`를 만들고, 비밀번호를 **안전한 곳에만** 보관한 뒤 `key.properties`를 그에 맞게 바꿉니다.  
   (이미 Play에 등록된 키와 다르면 업데이트 배포가 막힐 수 있으니, **이미 배포한 앱이면** 새 키만 만들지 말고 Console 정책부터 확인하는 게 좋습니다.)

**정리:** 지금 `.jks`에 대해 “패스워드가 뭔지”는 코드나 파일에서 알 수 없고, **기억·기록·Play Console의 키 재설정** 중 하나로만 해결할 수 있습니다.

---

**User**

@z_Dev_Docs/PickWizard_KeystorePW_20260408.txt 키스토어 파일 ㅣ밀번호가 이게 맞는데?

---

**Cursor**

파일 전체를 다시 확인하고 `keytool`로 검증합니다.



문서에는 **`Password!@`** 로 적혀 있고, 그 문구 자체는 분명합니다. 다만 **지금 워크스페이스에 있는** `pick_wizard/mobile_app/upload-keystore.jks`를 같은 비밀번호로 열어보면 Java `keytool`이 계속 **`keystore password was incorrect`** 를 반환합니다. 즉 **“문서에 적힌 값”과 “현재 디스크의 그 `.jks` 파일”이 서로 맞지 않는 상태**입니다.

가능한 경우는 대략 이렇게 정리할 수 있습니다.

1. **키스토어를 나중에 다시 만들었는데**, 메모(`PickWizard_KeystorePW_20260408.txt`)는 예전 생성 과정만 남아 있는 경우  
2. **다른 PC·백업 폴더의 `upload-keystore.jks`** 와 지금 프로젝트 안 파일이 **서로 다른 파일**인 경우 (이름만 같음)  
3. 메모의 비밀번호는 맞는데, **실제로 서명에 쓰는 파일이 다른 경로**인 경우  

그래서 “문서가 맞다”고 느끼시더라도, **현재 이 경로의 `.jks`가 그 비밀번호로 열리지는 않는다**는 점만큼은 확실합니다.

**다음에 하시면 좋은 것**

- 예전에 빌드가 성공했던 PC·폴더에서 **`upload-keystore.jks` 바이너리를 비교**해 보거나 (파일 크기·수정 시각·해시),  
- Play Console에 이미 올린 앱이면 **업로드 키 재설정** 절차를 Console 안내에 따라 진행하거나,  
- 아직 스토어만 배포 전이면 **새 키스토어 생성 + 비밀번호만 안전하게 보관** 후 `key.properties` 갱신  

원하시면, 같은 머신에서 **`Get-FileHash`** 로 현재 `upload-keystore.jks` 해시를 찍어 두고, 다른 백업본과 비교하는 방법도 짧게 적어 드리겠습니다.

---

**User**

keystore파일 암호 찾았고, 빌드했어. 그런데, @pick_wizard/mobile_app/android/key.properties pw를 이렇게 파일에 텍스트 평서문형태로 써놓아도 괜찮은건가?

---

**Cursor**

보안 관점에서 요약합니다. `.gitignore`에 `key.properties` 포함 여부를 확인합니다.



**결론부터 말하면:** Gradle/Android에서 흔히 쓰는 방식이긴 하지만, **“평문이라도 괜찮다”가 아니라 “로컬 전용 + 버전 관리에 안 올린다”는 전제가 있을 때만** 그나마 관행적으로 받아들여지는 패턴입니다.

**위험**

- 디렉터리를 통째로 클라우드에 올리거나, 백업·공유하거나, 다른 사람과 프로젝트 폴더를 나누면 **비밀번호와 같은 폴더의 `upload-keystore.jks`와 함께 노출**될 수 있습니다.
- 레포에 커밋되면 히스토리에 영구적으로 남을 수 있습니다.

**지금 프로젝트 설정**

`pick_wizard/mobile_app/.gitignore`에 **`/android/key.properties`** 와 **`/upload-keystore.jks`** 가 들어 있어서, **규칙대로라면 Git에는 안 올라가게 되어 있습니다.**  
즉, **평문을 쓰되 “이 PC의 로컬 파일로만 두고, 커밋하지 않는다”** 가 Flutter 공식 문서에서도 안내하는 일반적인 운용입니다.

**더 안전하게 하려면**

- `key.properties`는 그대로 두되 **절대 커밋하지 않기** (지금처럼 ignore 유지).
- 팀 CI에서는 **환경 변수나 비밀 저장소**에서 값을 주입하고, 로컬만 `key.properties` 사용.
- 노트북 분실·공유 PC 걱정이 있으면 디스크 암호화 등 OS 수준 보호.

**요약:** 평문 저장 자체는 이상적이지 않지만, **Flutter/Android에서 로컬 빌드용으로 쓰는 일반적인 방법**이고, **중요한 건 Git·공개 채널에 같이 올리지 않는 것**입니다. 지금처럼 `.gitignore`에 포함된 상태를 유지하는 것이 핵심입니다.

---

**User**

@z_Dev_Docs/051_GameType_Expansion_Plan.md 처음의 확장계획에서 이제 path forward느느 어떤 것이 있니?

---

**Cursor**

문서를 읽어 초기 계획과 남은 진행 방향을 정리합니다.



`051_GameType_Expansion_Plan.md` 기준으로 정리하면 다음과 같습니다.

## 이미 다룬 범위 (문서상 Phase A~E)

문서의 핵심은 **볼 픽 방식 4종**(로또 6/45, 파워볼, 메가밀리언, Win for Life / Lucky for Life)과 그에 맞는 모델·생성·UI·다국어까지입니다. 구현이 여기까지 왔다면 **문서가 정한 “이번 단계” 목표는 사실상 달성**한 상태로 보시면 됩니다.

## 문서에서 정한 다음 단계 (path forward)

1. **Phase F — 연금복권720+ (`annuity720`)**  
   볼 픽과 구조가 다르다고 명시되어 있고, **별도 기획·구현**으로 미루어 두었습니다.  
   조(1~5) + 6자리(각 0~9), 시리얼 형식 UI·저장·표시, 그리고 문서에 나온 대로 **`GameType` 한 단계 더 위의 “시리얼 타입” 레이어**까지 검토하는 작업이 다음 큰 덩어리입니다.

2. **방향 2 (문서 1절·8절)**  
   게임 타입 확장이 끝나면, 문서는 **과거 당첨번호 다운로드 + 통계 알고리즘**을 게임별로 붙일 수 있는 **밑판이 된다**고 적어 두었습니다. 관련 계획은 **`052` 등 “방향 2” 기획** 쪽이 이어지는 길입니다.

3. **세부 정리(선택)**  
   Phase E에 **사용하지 않는 ARB 키 정리** 같은 항목은 “선택”으로만 적혀 있어, 필요할 때만 하면 됩니다.

**한 줄 요약:** 볼 픽 4종 계획은 여기까지가 본편이고, **앞으로의 path forward는 (1) Phase F 연금복권720+, (2) 방향 2(당첨·통계 알고리즘)** 순으로 문서가 가리키는 방향입니다.

