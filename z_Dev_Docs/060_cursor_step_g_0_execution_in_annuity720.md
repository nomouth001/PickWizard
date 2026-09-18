# Step g-0 execution in Annuity720 project
_Exported on 5/11/2026 at 14:34:48 EDT from Cursor (3.3.27)_

---

**User**

@z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md:487-495 step g-0를 실행해라.

---

**Cursor**

Phase G-0 실행: `pubspec.yaml`의 version 확인, `flutter test`와 `flutter analyze`를 `pick_wizard/mobile_app`에서 실행합니다.



PowerShell에서는 `cd /d`가 동작하지 않습니다. 올바른 경로로 다시 실행합니다.



테스트 전부 통과. `flutter analyze` 실행 중입니다.



## Phase G-0 결과

### 작업 디렉터리
`h:\_Lotto_picker_app\pick_wizard\mobile_app`

### `pubspec.yaml` version 한 줄

```19:19:h:\_Lotto_picker_app\pick_wizard\mobile_app\pubspec.yaml
version: 1.2.0+3
```

### `flutter test` 요약
- **결과: PASS** (exit code 0)
- 마지막 메시지: `All tests passed!`
- **146개** 테스트 통과 (출력 기준)

### `flutter analyze` 요약
- **error: 0**
- **warning: 0** (분석기 출력: `No issues found!`, exit code 0)

### 완료 기준
문서 기준(`flutter test` 전체 PASS, `flutter analyze` error 0)을 **충족**했습니다.

---

**User**

@z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md:503-526 step g-1을 실행하라.

---

**Cursor**

Step G-1 구현을 바로 진행하겠습니다. 먼저 기존 `generateSerial` 로직과 테스트 구조를 확인한 뒤, `generateSerialDigitMonteCarlo`와 G1 테스트를 추가하고 지정된 명령으로 검증하겠습니다.

기존 동작과 충돌 없이 G-1 범위만 반영하도록 `local_lotto_service.dart`에 상수/헬퍼/신규 생성 함수를 추가하겠습니다. 이어서 `local_lotto_service_test.dart`에 G1-T01~T11을 추가합니다.

G1 테스트까지 추가했습니다. 이제 변경 파일 기준으로 린트 확인 후, 문서에 지정된 명령(`unit test` → `analyze`)을 실행해 완료 기준을 검증하겠습니다.

Step G-1을 완료했습니다. 요청한 범위대로 구현 + 시험 + 분석까지 실행했습니다.

- 구현 파일: `pick_wizard/mobile_app/lib/offline/services/local_lotto_service.dart`
  - 상수 ` _kSerialDigitTrialsPerPosition = 3000` 추가
  - 조 선택 공통 헬퍼 `_pickSerialGroup(...)` 추가
  - 신규 함수 `generateSerialDigitMonteCarlo(...)` 추가
    - `validateSerialParameters(...)` 선행
    - `gameType.isSerial` 아닐 때 `ArgumentError`
    - `Random? random` 주입 지원(기본 `Random()`)
    - 자리별(0~5) 3000회 `nextInt(10)` 빈도 집계
    - 동률 시 작은 숫자 우선
    - 정렬 없이 `_buildGenerated(...)` 반환

- 시험 파일: `pick_wizard/mobile_app/test/unit/local_lotto_service_test.dart`
  - G1-T01~G1-T11 추가
  - 테스트용 RNG `_CyclingRandom`, `_ConstantRandom(3)` 추가
  - 동률(전부 0) / 비동률(전부 3) 케이스 검증 포함

실행 결과:
- `flutter test test/unit/local_lotto_service_test.dart` → **PASS** (`All tests passed!`)
  - G1 신규 테스트 + 기존 `generateSerial` F3 회귀 테스트 모두 통과
- `flutter analyze` → **No issues found** (error 0)

완료 기준(`G1 단위시험 전부 PASS`, `analyze error 0`, `generateSerial 회귀 PASS`)을 충족했습니다.

---

**User**

@z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md:534-559 step g-2를 실행해라.

---

**Cursor**

G-2 구현: `offline_providers.dart`와 `generated_numbers_test.dart`를 읽고 수정합니다.



`test_helpers.dart`에서 `makeContainer` 확인 중.



구현 적용 중입니다.



테스트 파일 수정: F2-T04·F2-T05 업데이트 및 G2 테스트 추가.



G-2로 인해 F4-T05(알고리즘 9 없음)가 더 이상 맞지 않습니다. 문서 G-3에서 이 테스트를 대체하므로, F4-T05를 새 기대로 맞춰 CI를 녹색으로 유지합니다.



G-2 후 홈 화면은 여전히 볼픽용 `algorithm9NameDisplay` 문자열로 알고리즘 9를 표시하므로, F4-T05 기대를 ‘항목 있음’으로 바꿉니다.



## G-2 요약

### 구현 (`offline_providers.dart`)

1. **`offlineAlgorithmsProvider`** — 시리얼(`gt.isSerial`)일 때 알고리즘 **1·9** 두 개를 반환합니다.

```22:31:h:\_Lotto_picker_app\pick_wizard\mobile_app\lib\offline\providers\offline_providers.dart
final offlineAlgorithmsProvider =
    Provider<List<OfflineAlgorithmInfo>>((ref) {
  final gt = ref.watch(offlineSelectedGameTypeProvider);
  if (gt.isSerial) {
    return const [
      OfflineAlgorithmInfo(id: 1),
      OfflineAlgorithmInfo(id: 9),
    ];
  }
  return _kAlgorithms;
});
```

2. **`OfflineGenerateNotifier.generate()`** — `algo == null`이면 시리얼/볼픽 공통으로 먼저 `ArgumentError('알고리즘을 선택해 주세요.')`. 시리얼이면 `algo.id == 1` → `generateSerial`, `algo.id == 9` → `generateSerialDigitMonteCarlo`(동일 `fixedGroup` / `excludeGroups`). `copyWith`는 `algorithmId: algo.id`, 이름은 1 → `"Serial Quick Pick"`, 9 → `"Serial Digit Monte Carlo"`입니다.

### 단위 시험 (`generated_numbers_test.dart`)

- **F2-T04·F2-T05**를 연금 시 알고리즘 목록 길이 **2**, id **1·9** 기준으로 수정했습니다.
- **G2-T01~G2-T05**를 추가했습니다(G2-T04/T05는 `algo.id==9`로 `generate()` 후 저장 필드 검증).

### 회귀 보정 (G-2와 충돌하던 위젯 시험)

`F4-T05`는 이전에 “알고리즘 9 없음”을 검사했는데, Provider가 9를 노출하므로 **“알고리즘 9 항목 표시”**로 기대를 바꿨습니다. (문서 G-3에서 시리얼 전용 문구로 다시 다듬을 예정입니다.)

### 실행 결과

- `flutter test test/unit/generated_numbers_test.dart` → **전부 PASS** (18 tests)
- `flutter analyze` → **No issues found**

볼픽 경로는 **F2-T03 / G2-T02**로 여전히 길이 2·id 1·9를 확인합니다.

---

**User**

<system_notification>
The following task has finished. If you were already aware, ignore this notification and do not restate prior responses.

<task>
kind: shell
status: success
task_id: 311201
title: Wait for background flutter command
output_path: C:\Users\LTH_Laptop\.cursor\projects\h-Lotto-picker-app\terminals\311201.txt
</task>
</system_notification>
<user_query>Briefly inform the user about the task result and perform any follow-up actions (if needed).</user_query>

<system_notification>
The following task has finished. If you were already aware, ignore this notification and do not restate prior responses.

<task>
kind: shell
status: success
task_id: 402377
title: Run generated_numbers tests and flutter analyze
output_path: C:\Users\LTH_Laptop\.cursor\projects\h-Lotto-picker-app\terminals\402377.txt
</task>
</system_notification>
<user_query>Briefly inform the user about the task result and perform any follow-up actions (if needed).</user_query>

---

**Cursor**

## 알림 요약

**백그라운드 작업 결과**

1. **402377** (`flutter test test/unit/generated_numbers_test.dart` → `flutter analyze`)  
   - 단위 테스트 **전부 통과** (`All tests passed!`)  
   - `flutter analyze` **문제 없음** (`No issues found`)

2. **311201** (`Start-Sleep` 대기)  
   - **정상 종료** (추가 조치 없음)

**후속 조치**  
현재 기준으로 추가로 실행할 명령이나 수정할 코드는 없습니다. 전체 `flutter test`나 다음 Phase(G-3 등)를 돌리고 싶으면 알려 주세요.

---

**User**

@z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md:567-574 step g-3 실행해라.

---

**Cursor**

6개 ARB에 시리얼 알고리즘 9 문자열을 추가하고 `flutter gen-l10n` 후 `flutter analyze`를 실행합니다.



6개 ARB에 동일 키를 삽입한 뒤 `flutter gen-l10n`과 `flutter analyze`를 실행합니다.



## G-3 결과

### 한 일
- 아래 6개 ARB에 **`serialAlgorithm9Name`**, **`serialAlgorithm9Desc`**, **`serialAlgorithm9HelpOverview`**, **`serialAlgorithm9HelpHowItWorks`**, **`serialAlgorithm9HelpWhenToUse`** 를 추가했습니다.  
  `app_ko.arb`, `app_en.arb`, `app_ja.arb`, `app_zh.arb`, `app_th.arb`, `app_vi.arb`
- 한국어는 「각 자리마다 0~9를 3,000번 뽑아 최빈값」 의미로 짧게 이름·설명·도움말을 맞춤.
- 영어는 동일 의미로 작성했고, 일·중·태·베트남어는 영어 기준으로 번역했습니다.

### 명령
- `flutter gen-l10n` → **성공** (exit 0)
- `flutter analyze` → **No issues found** (error 0)

### 생성물
- `lib/core/localization/generated/app_localizations*.dart`에 위 키용 getter가 반영되어 있습니다 (예: `serialAlgorithm9Name` 등).

UI에서 아직 이 키를 쓰지 않으면 G-4에서 `offline_home_screen` 등 분기 연동이 이어집니다.

---

**User**

@z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md:582-623 step g-4 실행하라.

---

**Cursor**

G-4 구현: `offline_home_screen.dart`의 `_canGenerate`, `_showHelpDialog`, 알고리즘 모달·목록을 수정하고 위젯 테스트를 추가합니다.



구현 적용: `_canGenerate`, `_showHelpDialog`, 알고리즘 카드·모달, 스낵바 로직 수정. F4-T05는 시리얼 전용 이름으로 갱신하고 G3 테스트를 추가합니다.



F4-T05를 `serialAlgorithm9Name` 기준으로 수정하고, F4-T08에 알고리즘 선택을 추가해 ‘조 전체 제외’만 검증합니다. G3 테스트 그룹을 추가합니다.



원인: `find.widgetWithText(ElevatedButton, …)`가 해당 화면에서 매칭 실패. `Icons.casino`가 있는 생성 버튼으로 찾도록 수정합니다.



비동기 게임 복원 후 레이아웃이 안정화되도록 `pumpAndSettle`을 추가하고, `ElevatedButton.icon`은 `widgetWithIcon`으로 찾습니다.



annuity720 초기 화면에서 `Icons.casino` 매칭이 실패합니다. 생성 버튼에 `ValueKey`를 추가해 테스트가 안정적으로 찾도록 합니다.



annuity720 화면이 더 길어 ListView가 생성 버튼을 지연 빌드합니다. 테스트에서 생성 버튼이 보이도록 스크롤합니다.



## G-4 요약

### `offline_home_screen.dart` (058 §3.5)

1. **`_canGenerate()`** — 맨 앞에서 `offlineSelectedAlgorithmProvider`를 읽고, **`algo == null`이면 즉시 false**. 시리얼 분기에서는 조 고정/제외만 검사합니다.

2. **`_showHelpDialog(..., {required GameType gameType})`** — 알고리즘 9일 때 `gameType.isSerial`이면 `serialAlgorithm9*` l10n, 아니면 기존 `algorithm9*`를 사용합니다. **`_buildHelpButton`**에서 현재 `gameType`을 넘깁니다.

3. **옵션 모달 `algoName`** — id 9일 때 시리얼이면 `serialAlgorithm9Name`, 볼픽이면 `algorithm9NameDisplay`.

4. **알고리즘 카드 name/desc** — 동일 분기 + 시리얼·id 9일 때 `serialAlgorithm9Desc`.

5. **생성 버튼 비활성 스낵바** — `algo == null`이면 항상 `requirementSelectAlgorithm`(시리얼 포함).

6. **테스트·탐색용** — 생성 버튼에 `ValueKey('offline_generate_button')` 추가.

### `offline_home_screen_test.dart`

- **F4-T05**: 시리얼 알고리즘 9 이름 → `serialAlgorithm9Name` 기대.
- **F4-T08**: 알고리즘 1 선택 유지 + 조 전체 제외 시 회색 버튼; ListView 지연 빌드 대비 **`scrollUntilVisible`**.
- **G3-T01~G3-T04** 추가(G3-T02는 전체 `serialAlgorithm9Desc` 텍스트 매칭).

### 실행

- `flutter test test/widget/offline_home_screen_test.dart` → **30개 전부 PASS**
- `flutter analyze` → **No issues found**

---

**User**

@z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md:631-644 step g-5 실행해라.

---

**Cursor**

`algorithm_help_data.dart`와 `_buildHelpButton`을 확인한 뒤 `getSerial9()`를 추가하고 연결합니다.



`getSerial9()` 추가 및 `_buildHelpButton`에서 시리얼·알고리즘 9일 때 해당 헬프 객체를 전달합니다.



## G-5 결과

### `algorithm_help_data.dart`
- **`AlgorithmHelpData.getSerial9()`** 추가: `algorithmId: 9`, `name` / `overview` / `howItWorks` / `whenToUse`는 빈 문자열, `parameters`는 `{}`.
- **`get(9)`**는 기존처럼 `_getMonteCarloTop6Help()`를 쓰므로 여전히 null이 아님. **`_getMonteCarloTop6Help()` 내용은 수정하지 않음.**

### `offline_home_screen.dart` — `_buildHelpButton`
- `gameType.isSerial && algorithmId == 9`이면 **`AlgorithmHelpData.getSerial9()`**를 `help`로 넘기고, 그 외에는 **`AlgorithmHelpData.get(algorithmId)`** 유지.
- `_showHelpDialog`의 시리얼·알고리즘 9 분기에서 이미 l10n만 쓰므로, `help` 필드는 버튼 표시용으로만 쓰이고 본문은 비어 있어도 됨.

### 검증
- `flutter analyze` → **No issues found**
- G3 관련 스모크 테스트(G3-T02) **PASS**

문서의 **수동 G7**(연금 + 알고리즘 9 도움말 열기·닫기)은 기기에서 한 번 확인하면 됩니다.

---

**User**

@z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md:652-658 step g-6 실행해라. 

---

**Cursor**

결과·내 번호 화면에서 알고리즘 9 표시 로직을 검토하고 시리얼 분기와 위젯 테스트를 추가합니다.



공통 표시 헬퍼를 추가하고 두 화면에 적용한 뒤 위젯 테스트를 추가합니다.



## G-6 완료 요약

### 검토·구현 (이미 반영된 상태)
- `offline_algorithm_display.dart`에서 시리얼 + `algorithmId == 9`일 때 `serialAlgorithm9Name`, 그 외 볼픽 9는 `algorithm9NameDisplay`를 쓰도록 분기되어 있습니다.
- 결과·내 번호 화면은 `offlineAlgorithmDisplayLabel`을 통해 동일 규칙으로 라벨을 표시합니다.

### 이번에 추가한 위젯 테스트
1. **`offline_result_screen_test.dart`** — **G6-T01**: `annuity720` + `algorithmId: 9`일 때 헤더에 `serialAlgorithm9Name`만 있고 `algorithm9NameDisplay`는 없음을 검증합니다.
2. **`offline_my_numbers_screen_test.dart`** — **G6-T02**: 저장 목록에 같은 조건의 항목이 있을 때 카드에 `serialAlgorithm9Name`이 표시되고 `algorithm9NameDisplay`는 나오지 않음을 검증합니다.

### 실행 결과
- `flutter test` (위 두 파일): **15개 테스트 모두 통과**
- `flutter analyze`: **No issues found**

058 문서의 G-6 완료 기준(관련 `flutter test` PASS)을 충족했습니다.

---

**User**

@z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md:666-672 step g-7 실행해라.

---

**Cursor**

G-7 실행: 문서 §5.6 수동 체크리스트(M1~M5) 확인, 전체 `flutter test`·`analyze` 실행, `pubspec.yaml` 패치 버전 증가.



전체 테스트 실행 중. 완료 후 `analyze`, 버전 bump, M1~M5는 코드·테스트 근거로 검증합니다.



테스트 168건 통과, analyze 문제 없음. `pubspec.yaml` 패치 버전을 올립니다.



## G-7 실행 결과

### 자동 검증
| 단계 | 결과 |
|------|------|
| `flutter test` (전체) | **168개 모두 PASS** |
| `flutter analyze` | **No issues found** (error 0) |

작업 디렉터리: `h:\_Lotto_picker_app\pick_wizard\mobile_app`

### §5.6 수동 체크리스트 M1~M5 (자동 시험·코드로 동등 확인)

| # | 항목 | 결과 | 근거 |
|---|------|------|------|
| **M1** | 연금720+ → 알고리즘 1·9 노출 | **OK** | 단위 `F2-T04`·`G2-T01`, 위젯 `F4-T05`·`G3-T01` |
| **M2** | 알고리즘 9 → 옵션 모달·조 고정/제외 | **OK** | `F4-T06`~`F4-T08`, `G3-T04` |
| **M3** | 생성 후 결과 시리얼 표시·algorithm 9 | **OK** | `F6-T01`, `G6-T01` |
| **M4** | 저장 후 내 번호 알고리즘명·배지 | **OK** | `F7-T01` 등, `G6-T02` |
| **M5** | 로또6/45 전환 시 알고리즘 9 설명이 볼픽(만 회) 쪽 | **OK** | `offline_home_screen.dart`에서 `gameType.isSerial`이 아니면 `algorithm9DescDynamic`으로 분기 |

```255:263:h:\_Lotto_picker_app\pick_wizard\mobile_app\lib\offline\screens\offline_home_screen.dart
              final desc = algo.id == 1
                  ? l10n.algorithm1DescDynamic(
                      gameType.mainMin,
                      gameType.mainMax,
                      gameType.mainCount,
                    )
                  : (gameType.isSerial
                      ? l10n.serialAlgorithm9Desc
                      : l10n.algorithm9DescDynamic(gameType.mainCount));
```

실제 기기에서 한 번 더 탭 동작을 확인하면 릴리즈 전 QA에 도움이 됩니다.

### 버전
- **`pubspec.yaml`**: `1.2.0+3` → **`1.2.1+4`** (패치 +1, 빌드 번호 +1)

### 변경 요약 (한 단락)

G-7 마감으로 전체 `flutter test`·`analyze`를 통과했고, §5.6 항목은 기존 Phase F/G 위젯·단위 시험과 홈 화면 설명 분기 코드로 M1~M5를 충족함을 확인했다. 앱 패키지 버전은 팀 규칙에 따라 **1.2.1+4**로 올려 두었다.

058 문서 본문에 체크표를 직접 적어 두지는 않았다. 파일에 기록이 필요하면 알려 달라.

---

**User**

@z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md 의 g-0에서 g-7까지 실행을 완료했다. 코드베이스가 설계대로 됐는지, 기획의도대로 됐는지 검토, 미비점와 오류가 있으면 보완 정정해라.

---

**Cursor**

설계 문서를 전부 확인했습니다. 이제 핵심 구현 파일들을 일괄 검토합니다.

주요 미비점을 파악했습니다. 검토 결과를 정리하고 수정합니다.

**발견된 문제들:**

1. **`algorithm1` 시리얼 컨텍스트에서 도움말 본문 오류**: `_showHelpDialog`에서 algorithmId==1일 때 `l10n.algorithm1HelpHowItWorks`가 "1부터 45까지의 숫자 중 무작위로 6개를 선택합니다"를 반환해 annuity720(0~9 자리별)과 맞지 않음.
2. **결과/내번호 화면에서 algorithm1 시리얼 표시명**: `offlineAlgorithmDisplayLabel`이 algorithmId==1이면 무조건 "자동선택 (Quick Pick)" — 시리얼 컨텍스트에서 "시리얼 자동선택"이어야 함.
3. **파일 헤더 주석 2곳 outdated**: `local_lotto_service.dart`, `offline_providers.dart`.

ARB 파일 6종에 `serialAlgorithm1Name`, `serialAlgorithm1HelpHowItWorks` 키를 추가합니다.

gen-l10n 성공. 이제 `offline_algorithm_display.dart` 분기 추가, `_showHelpDialog` 수정, 주석 정리를 합니다.

이제 `_showHelpDialog` 안에서 algorithmId==1 시리얼 분기를 추가합니다.

주석 2곳을 업데이트합니다.

**168 테스트 전부 PASS, analyze: No issues found.**

---

## 검토 결과 요약

### Phase G (G-0 ~ G-7) 설계 대비 구현 상태

| 항목 | 상태 | 비고 |
|------|------|------|
| `generateSerialDigitMonteCarlo` 코어 | ✅ 설계 일치 | 상수 3000, 동률 최소 숫자, 정렬 없음 |
| `offlineAlgorithmsProvider` 시리얼 분기 | ✅ | 시리얼·볼픽 모두 id 1·9 반환 |
| `OfflineGenerateNotifier.generate()` | ✅ | algo==null 체크가 isSerial 분기 앞에 위치 |
| algorithmName 저장 필드 | ✅ | "Serial Digit Monte Carlo" 저장 |
| ARB 키 (`serialAlgorithm9*`) 6개 언어 | ✅ | |
| `_canGenerate()` algo null 체크 앞이동 | ✅ | |
| `_showHelpDialog` gameType 파라미터 | ✅ | algorithmId==9 시리얼 분기 적용 |
| 옵션 모달 `algoName` 시리얼 분기 | ✅ | |
| `AlgorithmHelpData.getSerial9()` | ✅ | |
| 결과·내번호 화면 `offlineAlgorithmDisplayLabel` | ✅ | |

### 발견·보완한 미비점

**1. algorithm1 시리얼 컨텍스트에서 도움말 본문 오류 (Phase F 잔존 버그)**
- `_showHelpDialog`에서 algorithmId==1일 때 `l10n.algorithm1HelpHowItWorks` = "**1부터 45**까지의 숫자 중 무작위로 6개를 선택합니다"가 annuity720(0~9 자리별)에 그대로 표시되는 오류
- → `_showHelpDialog`에 `algorithmId==1 && gameType.isSerial` 분기 추가, `serialAlgorithm1HelpHowItWorks` 키 사용

**2. 결과·내번호 화면의 algorithm1 시리얼 표시명 불일치**
- `offlineAlgorithmDisplayLabel`이 algorithmId==1이면 항상 "자동선택 (Quick Pick)"을 반환해, 저장 필드("Serial Quick Pick")와 불일치
- → `offlineAlgorithmDisplayLabelFor`에 serial 분기 추가, `serialAlgorithm1Name` 키 사용

**3. 파일 헤더 주석 2곳 outdated**
- `local_lotto_service.dart`: "알고리즘 9(만 번 뽑기 6개)만 Dart로 구현"
- `offline_providers.dart`: "알고리즘 1(자동선택), 9(만 번 뽑기)만 제공"
- → 시리얼 알고리즘 1·9 모두 반영한 표현으로 업데이트

---

**User**

버전번호 올려라

---

**Cursor**

`pubspec.yaml` 버전 확인 후 패치 레벨을 1 올리겠습니다.

`pubspec.yaml` 버전 올렸습니다.

- 변경: `1.2.1+4` → `1.2.2+5`
- 파일: `pick_wizard/mobile_app/pubspec.yaml`

