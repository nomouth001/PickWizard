# Step f-0 implementation details
_Exported on 5/11/2026 at 12:18:36 EDT from Cursor (3.3.27)_

---

**User**

@z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md:669-680 step f-0 진행해라.

---

**Cursor**

Step F-0을 진행합니다. `flutter test`와 `flutter analyze`를 동시에 실행합니다.

이제 `flutter test`와 `flutter analyze`를 실행합니다.

---

## Step F-0 결과 보고

### flutter test
- **총 테스트 수: 90개**
- **PASS: 90개 / FAIL: 0개**
- 모든 테스트 통과 (`All tests passed!`)

### flutter analyze
- **오류: 0개 / 경고: 0개**
- `No issues found!`

### pubspec.yaml version
- **`1.1.0+2`**

---

### 완료 기준 충족 여부

| 기준 | 결과 |
|------|------|
| flutter test 전체 PASS (90개) | ✅ 90/90 PASS |
| flutter analyze 오류 0 | ✅ 오류 0 |

**완료 기준 모두 만족. 다음 단계로 진행 가능합니다.**

---

**User**

<timestamp>Saturday, May 9, 2026, 6:10 PM (UTC-4)</timestamp>
<system_notification>
The following task has finished. If you were already aware, ignore this notification and do not restate prior responses.

<task>
kind: shell
status: success
task_id: 356214
title: flutter analyze 실행
output_path: C:\Users\LTH_Laptop\.cursor\projects\h-Lotto-picker-app\terminals\356214.txt
</task>
</system_notification>
<user_query>Briefly inform the user about the task result and perform any follow-up actions (if needed).</user_query>

---

**Cursor**

`flutter analyze` 완료 — **No issues found!** (오류/경고 0개). 별도 후속 조치 불필요합니다.

---

**User**

@z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md:688-727 step f-1 진행해라.

---

**Cursor**

Step F-1 바로 진행합니다. 먼저 관련 구현 위치를 확인한 뒤 `game_type.dart`와 단위 테스트를 수정하고, 지정된 테스트/분석까지 실행해 완료 기준을 검증하겠습니다.

요구된 F1-T01~T15 항목을 정확히 맞추기 위해 문서의 5.1 시험 목록을 먼저 읽고 동일하게 테스트를 추가하겠습니다.

이제 `game_type.dart`에 `GameCategory`, `annuity720`, `category/isSerial/isBallPick`를 반영해 기존 호출 호환(기본값)까지 유지하겠습니다.

테스트 코드를 추가했습니다. 이제 지시된 대로 `game_type_test.dart` 단독 테스트와 `flutter analyze`를 실행해 기준 충족 여부를 확인하겠습니다.

`F1` 테스트는 전부 통과했지만, `analyze`에서 새 enum 값(`annuity720`) 미처리 스위치 3건이 발생했습니다. 해당 3개 지점만 최소 수정해 `analyze` 0으로 맞추겠습니다.

스위치 누락 3건을 보완했습니다. 다시 `game_type_test`와 `flutter analyze`를 재실행해 완료 기준 충족 여부를 최종 확인합니다.

Step F-1 완료했습니다. 완료 기준까지 맞추기 위해 구현 + 시험 + 보정(스위치 누락 처리)까지 반영했습니다.

- `lib/core/models/game_type.dart`
  - `GameCategory { ballPick, serial }` 추가
  - `GameTypeId`에 `annuity720`를 **마지막 값**으로 추가
  - `GameType.category` 필드 추가 (기본값 `GameCategory.ballPick`)
  - `isSerial`, `isBallPick` getter 추가
  - `GameTypes.annuity720` 상수 추가
  - `GameTypes.all` 끝에 `annuity720` 추가

- `test/unit/game_type_test.dart`
  - 기존 A1-T01~T15 아래에 `F1-T01~F1-T15` 15개 추가 완료
  - 문서 5.1 항목과 일치하게 검증 구현

- `flutter analyze` 보정
  - 새 enum 값으로 인해 발생한 비포괄 switch 3건 처리:
    - `lib/offline/screens/offline_home_screen.dart`
    - `lib/offline/screens/offline_my_numbers_screen.dart`

검증 결과:
- `flutter test test/unit/game_type_test.dart` → **30/30 PASS**
  - 기존 A1-T01~T15 회귀 PASS
  - 신규 F1-T01~T15 PASS
- `flutter analyze` → **No issues found (오류 0)**
- `ReadLints` 확인 → 편집 파일 기준 추가 린트 이슈 없음

다음 Step(F-2) 진행 가능합니다.

---

**User**

@z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md:735-762 step f-2 진행해라.

---

**Cursor**

F-2 구현: `offline_providers.dart`와 문서 5.2의 테스트 항목을 확인합니다.



`offline_providers.dart` 수정 및 `generated_numbers_test.dart`에 F2 테스트 추가 중입니다.



## Step F-2 요약

### 구현 (`lib/offline/providers/offline_providers.dart`)
- **`offlineAlgorithmsProvider`**: `offlineSelectedGameTypeProvider`를 watch하고, `gt.isSerial`이면 `[OfflineAlgorithmInfo(id: 1)]`만, 아니면 기존 `_kAlgorithms`(1, 9) 반환.
- **파일 하단**에 문서와 동일한 시리얼 전용 Provider 2개 추가:
  - `offlineSerialFixedGroupProvider` → 초기 `null`
  - `offlineSerialExcludeGroupsProvider` → 초기 `[]`

### 시험 (`test/unit/generated_numbers_test.dart`)
- **F2-T01~T02**: 기본 `ProviderContainer`로 초기값 검증.
- **F2-T03**: `offlineSelectedGameTypeProvider`를 `lotto645`로 override → 알고리즘 길이 2, id `[1, 9]`.
- **F2-T04**: `annuity720`로 override → 길이 1, id `1`만.
- **F2-T05**: 컨테이너에서 `annuity720`로 바꾼 뒤 `lotto645`로 전환 → 다시 길이 2, id `[1, 9]`.

### 실행 결과
- `flutter test test/unit/generated_numbers_test.dart` → **13개 전부 PASS** (기존 4 + A5~A6 4 + F2 5).
- `flutter analyze` → **No issues found**.

다음 Step(F-3)로 넘어가도 됩니다.

---

**User**

@z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md:770-834 step f-3 진행해라.

---

**Cursor**

Step F-3 진행합니다. 먼저 `local_lotto_service.dart`의 현재 생성/검증 구조를 확인한 뒤, 문서 요구사항대로 시리얼 생성 로직과 F3 테스트 14개를 추가하고 실행 검증까지 진행하겠습니다.

이제 `local_lotto_service.dart`에 `validateSerialParameters`/`generateSerial`를 추가하고, `OfflineGenerateNotifier.generate()`를 시리얼 우선 분기로 바꾸겠습니다.

F3 테스트 추가를 완료했습니다. এখন 지정된 `local_lotto_service_test`와 `flutter analyze`를 실행해 완료 기준 충족 여부를 확인하겠습니다.

Step F-3 완료했습니다. 요청한 구현/시험/실행 기준 모두 충족했습니다.

- 구현 반영
  - `lib/offline/services/local_lotto_service.dart`
    - `validateSerialParameters(...)` 추가
      - `nSets` 1~100
      - `fixedGroup` null 또는 1~5
      - `excludeGroups` 각 원소 1~5, 중복 없음, 최대 4개
      - `fixedGroup`과 `excludeGroups` 충돌 검사
      - `fixedGroup == null`일 때만 사용 가능한 조 수(>=1) 검사
    - `generateSerial(...)` 추가
      - 검증 실패 시 `ArgumentError`
      - 그룹 풀: `[1,2,3,4,5] - excludeGroups`
      - 각 세트: 6자리(0~9) 무작위, 그룹은 `fixedGroup` 또는 그룹 풀 랜덤
      - `_buildGenerated`로 `results`/`bonusBalls` 생성
  - `lib/offline/providers/offline_providers.dart`
    - `OfflineGenerateNotifier.generate()`에서 **시리얼 타입 우선 분기** 추가
    - 시리얼은 `algo` 선택 여부와 무관하게 `generateSerial(...)` 사용
    - 시리얼 결과 `algorithmName = 'Serial Quick Pick'`, `algorithmId = 1` 설정

- 시험 반영
  - `test/unit/local_lotto_service_test.dart`
    - `F3-T01 ~ F3-T14` 14개 추가
    - 기존 `B-T01~T17`, `C-T01~T15` 그대로 유지

- 실행 결과
  - `flutter test test/unit/local_lotto_service_test.dart`  
    - **B + C + F3 전체 PASS (46개)**
  - `flutter analyze`  
    - **No issues found**
  - `ReadLints`  
    - 수정 파일 기준 **린트 오류 없음**

다음 Step(F-4) 진행 가능합니다.

---

**User**

@z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md:842-888 step f-4 진행해라.

---

**Cursor**

F-4 구현: `offline_home_screen.dart`, l10n, 위젯 테스트를 확인합니다.



구현 중: l10n 키 추가, `offline_home_screen.dart`의 시리얼 UI·`_canGenerate`·드롭다운 수정, 테스트 추가 및 D1-T03을 5개 항목으로 업데이트합니다.



`offline_home_screen.dart`에 import·`_canGenerate`·드롭다운·플래그 수정 후, 옵션 시트에 시리얼 분기와 컨트롤러를 추가합니다.



스낵바 분기 수정. `D1-T03`을 5개로 업데이트하고 `F4-T01`~`F4-T08` 테스트 추가 중입니다.



생성 버튼은 `canGenerate`이 false여도 스낵바용 `onPressed`가 남아 있어 `onPressed == null` 검사가 부적절합니다. 배경색이 `Colors.grey`인지 검사하도록 F4-T08을 수정합니다.



## Step F-4 요약

### `offline_home_screen.dart`
- **드롭다운**: `GameTypes.all` 그대로 사용. `annuity720`은 `l10n.gameAnnuity720`, 플래그 `🇰🇷` (`_flagEmojiForGame`에 `annuity720` 추가).
- **`_onGameTypeChanged`**: 게임 바뀔 때 `offlineSerialFixedGroupProvider` → `null`, `offlineSerialExcludeGroupsProvider` → `[]` 초기화.
- **`_canGenerate`**: `gameType.isSerial`이면 조 제외·고정 겹침·가용 조 수(≥1)만 검사. 볼 픽은 기존처럼 알고리즘·포함/제외·보너스 검증.
- **옵션 모달** (`_AlgorithmOptionsSheetContent`): 시리얼이면 **조 고정** / **조 제외** 필드만 표시하고, 메인·보너스 볼 UI는 숨김. `canConfirm`은 `validateSerialParameters`로 판단. 비시리얼은 기존 UI·로직 유지.
- **스낵바**: 시리얼일 때는 “알고리즘 미선택” 문구가 나오지 않도록, 비시리얼이고 알고리즘이 없을 때만 `requirementSelectAlgorithm` 사용.

### l10n
- `app_ko.arb` / `app_en.arb` 및 ja·zh·vi·th에 추가: `gameAnnuity720`, `serialFixedGroupLabel`, `serialFixedGroupHint`, `serialExcludeGroupsLabel`, `serialExcludeGroupsHint`.
- `flutter gen-l10n` 반영됨.

### 테스트 `offline_home_screen_test.dart`
- **D1-T03**: 게임 항목 수 **5개**로 수정(회귀).
- **F4-T01~T08**: 문서 5.4에 맞춰 추가. **F4-T08**은 생성 버튼이 `onPressed`로 스낵바만 바뀌는 구조라, 비활성 표시는 **`Colors.grey` 배경**으로 검증.

### 실행 결과
- `flutter test test/widget/offline_home_screen_test.dart` — 전부 통과  
- `flutter analyze` — 이슈 없음  
- `flutter test` (전체) — **132개** 전부 통과  

다음 Step(F-5)로 진행하면 됩니다.

---

**User**

<system_notification>
The following task has finished. If you were already aware, ignore this notification and do not restate prior responses.

<task>
kind: shell
status: success
task_id: 199109
title: 위젯 테스트 및 analyze 재실행
output_path: C:\Users\LTH_Laptop\.cursor\projects\h-Lotto-picker-app\terminals\199109.txt
</task>
</system_notification>
<user_query>Briefly inform the user about the task result and perform any follow-up actions (if needed).</user_query>

---

**Cursor**

**F-4 결과:** `offline_home_screen`에 연금복권720+ 드롭다운·시리얼 Provider 초기화·`_canGenerate` 시리얼 분기·옵션 모달(조 고정/조 제외)과 l10n 키를 반영했고, `offline_home_screen_test`에 F4-T01~T08과 D1-T03(5개 게임) 수정까지 반영했습니다. `flutter test`(전체)·`flutter analyze` 모두 통과했습니다.

**후속 조치:** 없습니다. 필요하면 F-5(위젯 등 다음 단계)만 이어서 진행하면 됩니다.

---

**User**

@z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md:896-942 step f-5진행해라.

---

**Cursor**

F-5 구현: 문서 5.5의 테스트 항목과 l10n 키를 확인합니다.



`annuity720GroupBadge` l10n 추가 후 위젯과 테스트를 구현합니다.



## Step F-5 결과

### 구현
- **`lib/presentation/widgets/digit_box.dart`**  
  - 36×36, 모서리 4dp, 배경 `#F5F5F5` / 하이라이트 `#7B1FA2`, 숫자 16sp 볼드, 하이라이트 시 흰 글자.
- **`lib/presentation/widgets/serial_number_row.dart`**  
  - 조 배지(패딩 8×4, 배경 `#7B1FA2`, `context.l10n.annuity720GroupBadge(group)`), 오른쪽 8dp 후 `DigitBox` 6개(사이 4dp 패딩, 마지막만 패딩 없음).

### l10n
- **`annuity720GroupBadge`** (`{group}` 플레이스홀더): `ko`는 `{group}조`, `en` 및 ja·zh·vi·th는 `Group {group}` 형태로 추가 후 `flutter gen-l10n` 반영.

### 시험
- **`test/widget/digit_box_test.dart`** 신규: F5-T01~T07 (문서 5.5와 동일).

### 실행
- `flutter test test/widget/digit_box_test.dart` → **7/7 PASS**
- `flutter analyze` → **No issues found**

후속 작업은 없습니다. 다음은 F-6(결과 화면 시리얼 분기)입니다.

---

**User**

@z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md:950-980 step f-6 진행하라.

---

**Cursor**

오프라인 결과 화면과 기존 테스트를 확인한 뒤 시리얼 분기와 F6 테스트를 추가합니다.



`isSerial` 분기를 `hasBonus`보다 먼저 두고, 시리얼 결과 카드와 F6 테스트를 추가합니다.



## Step F-6 요약

### `offline_result_screen.dart`
- `GameTypes.fromId`로 얻은 `gameType` 기준으로 **먼저 `isSerial` 분기**를 두었습니다.
- 시리얼이면 `_SerialResultCard`로 세트마다 `SerialNumberRow(group: bonusBalls[setIndex], digits: result.numbers)`를 표시하고, `bonusBalls`가 짧을 때는 조를 `1`로 두는 방어 로직을 넣었습니다.
- 그다음 기존처럼 `hasBonus` → `_FivePlusOneResultCard`, 아니면 `NumberCard`입니다.
- 시리얼 카드에 **`ValueKey('offline_serial_result_set_$setIndex')`**를 붙여 테스트에서 찾을 수 있게 했습니다.

### `offline_result_screen_test.dart`
- **F6-T01**: `annuity720` 샘플 데이터로 `SerialNumberRow` 1개 + 위 `ValueKey` 존재 확인.
- **F6-T02 / F6-T03**: 각각 D8-T01·D8-T02와 동일한 검증(회귀용 복제).

### 실행
- `flutter test test/widget/offline_result_screen_test.dart` → **5개 전부 PASS** (D8-T01~02 + F6-T01~03).
- `flutter analyze` → **이슈 없음**.

다음은 F-7(내 번호 화면)이면 됩니다.

---

**User**

@z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md:988-1015  step f-7 진행해라.

---

**Cursor**

`offline_my_numbers_screen.dart`와 관련 테스트를 읽고 F-7 구현을 진행합니다.



배지·시리얼 번호 표시·상세 시트 분기를 추가하고, `_localizedGameName`과 플래그 이모지를 수정합니다.



## Step F-7 요약

### `offline_my_numbers_screen.dart`
1. **배지**  
   - `GameTypeId.annuity720` → `l10n.gameAnnuity720`, Chip 배경 `0xFF7B1FA2`, 라벨 흰색·굵게.  
   - `_localizedGameName` / `_gameFlagEmoji`에 `annuity720` 반영(한국 게임·🇰🇷).

2. **시리얼 번호 표시**  
   - `_serialSetDisplayLine(group, digits)` → `'$group조  ${digits.join()}'` (조 뒤 공백 2칸).  
   - 카드 미리보기·상세 바텀시트 모두 `gameType.isSerial`이면 `LottoBall`/`NumberCard` 대신 위 형식 `Text`(굵게), 세트마다 한 줄.

3. **필터**  
   - 기존처럼 `GameTypes.all`로 항목 구성 → `annuity720`이 자동 포함되며, 위 l10n/이모지로 라벨 통일.

### `offline_my_numbers_screen_test.dart`
- **F7-T01~T04** 추가 (문서 5.7).  
- **D9-T01, D10-T01~T03** 그대로 통과.

### 실행
- `flutter test test/widget/offline_my_numbers_screen_test.dart` → **8/8 PASS**  
- `flutter analyze` → **이슈 없음**

다음은 F-8(다국어) 단계입니다.

---

**User**

@z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md:1023-1086  step f-8 진행해라.

---

**Cursor**

6개 ARB 파일 상태를 확인한 뒤 F-8 요구사항에 맞게 키를 정리·추가합니다.



6개 ARB에 누락된 `annuity720FullFormat`, `serialGroupRange`, `serialDigitRange`를 추가하고, ja·zh·th·vi의 `gameAnnuity720` 등 MT 문자열과 `@…` 설명을 문서대로 반영합니다.



## Step F-8 요약

### ARB 6개 (`app_ko`, `app_en`, `app_ja`, `app_zh`, `app_th`, `app_vi`) 정리

| 키 | ko / en | ja · zh · th · vi |
|----|---------|-------------------|
| **gameAnnuity720** | 문서 문구 유지 | `年金くじ720+` / `年金彩票720+` / `ลอตเตอรี่บำนาญ720+` / `Xổ số hưu trí 720+` + `@gameAnnuity720` MT 설명 |
| **annuity720GroupBadge** | `{group}조` / `Group {group}` | MT로 `Group {group}` + `@`에 placeholder·MT 설명 |
| **annuity720FullFormat** | `{group}조 {digits}` / `Group {group}: {digits}` | MT로 `Group {group}: {digits}` + `@`에 `group`(int), `digits`(String)·MT 설명 |
| **serialFixedGroupLabel/Hint**, **serialExcludeGroupsLabel/Hint** | 문서 문구 | MT는 영문 문구 + 각 `@…` MT 설명 |
| **serialGroupRange**, **serialDigitRange** | ko/en 문서 문구 | MT는 영문 + `@…` MT 설명 |

- `ja`·`zh`·`th`·`vi`는 요청대로 **`"description": "MT(미검수) - 검토 필요"`**를 해당 `@키`에 넣었습니다.  
- `ko`·`en`은 확정 번역만 두고, 플레이스홀더가 있는 키는 **`@…` + `placeholders`**만 유지했습니다.

### 실행
- `flutter gen-l10n` — 성공  
- `flutter analyze` — **No issues found**  
- 관련 위젯 테스트 샘플 — **통과**

앱 코드에서 `annuity720FullFormat` / `serialGroupRange` / `serialDigitRange`를 아직 쓰지 않으면, 이후 옵션 모달·도움말 등에 연결하면 됩니다.

---

**User**

@z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md:1094-1136  step f-9 실행해라.

---

**Cursor**

전체 `flutter test`와 `flutter analyze` 실행 중입니다.



검증 통과. `pubspec.yaml` 버전을 `1.2.0+3`으로 올립니다.



## F-9 자동 검증 결과

| 항목 | 결과 |
|------|------|
| **총 테스트** | **146개** |
| **PASS** | **146** |
| **FAIL** | **0** |
| **flutter analyze** | **오류 0 / 경고 0** (`No issues found!`) |

기존 회귀 포함 전부 통과했습니다. FAIL 없음.

---

## 버전 업

`pick_wizard/mobile_app/pubspec.yaml`의 `version`을 **`1.1.0+2` → `1.2.0+3`**으로 반영했습니다.

---

## 수동 체크리스트 (에뮬레이터·실기기에서 확인 부탁)

문서 기준 10항목입니다. 직접 체크해 주세요.

- [ ] 게임 드롭다운에서 **「연금복권720+」** 선택 가능 (5번째 항목)
- [ ] 선택 시 스낵바로 **포함/제외 초기화** 메시지 표시
- [ ] 옵션 모달에 **「조 고정」**, **「조 제외」**만 보이고 **볼 포함/제외·보너스 섹션 없음**
- [ ] 알고리즘 목록에 **「만 번 뽑기 6개」(알고리즘 9) 없음**, **「자동선택」만** 표시
- [ ] 자동선택으로 **5세트 생성** → 결과 화면에 **`{N}조` + 6자리** 형식이 **5줄** 표시
- [ ] **조 고정 = 3** 후 생성 → 모든 결과 줄이 **「3조」**로 통일
- [ ] **내 번호로 저장** 후 내 번호 화면 → **「연금복권720+」** 보라색 배지
- [ ] 내 번호 필터 **「연금복권720+」** 선택 시 **다른 게임 카드 숨김**
- [ ] **앱 재시작** 후에도 **annuity720** 선택이 유지되는지 (`SharedPreferences`)
- [ ] **로또 6/45·파워볼** 등 기존 게임 동작 이상 없음 (회귀)

위 10개를 모두 확인하셨으면 알려 주시면 됩니다.

---

**User**

ok 잘되네.

---

**Cursor**

잘 동작한다니 다행입니다. Phase F·F-9까지 반영된 상태이고, `pubspec.yaml`은 **1.2.0+3**입니다. 이후에 빌드·스토어 배포나 추가 수정이 필요하면 말씀해 주세요.

---

**User**

연금복권 추첨도 만번 뽑기가 가능할 것 같은데?

---

**Cursor**

**기술적으로는** 연금복권720+처럼 “조 + 6자리(0~9)” 구조에도, “각 자리별로 1만 번 뽑아 빈도 상위를 고른다” 같은 **별도 시뮬레이션 규칙**을 정의하면 만 번 뽑기(알고리즘 9)를 **만들 수는** 있습니다. 다만 지금 앱 설계는 **의도적으로 빼 둔 상태**입니다.

**현재 동작(Phase F 기준)**  
- 시리얼(`annuity720`)일 때 `offlineAlgorithmsProvider`는 **자동선택(id:1)만** 노출합니다.  
- 생성은 `generateSerial` 한 경로이고, **만 번 뽑기 분기는 없습니다.**

**왜 단순히 “기존 만 번 뽑기”를 그대로 쓰기 어렵냐**  
- 기존 `generateMonteCarloTop`은 **볼 픽 풀(메인 번호 후보)**·세트당 개수·보너스 볼 로직이 **연금 구조(6자리 0~9 + 조)**와 다릅니다.  
- 연금용으로 쓰려면 **“만 번”을 어디에 적용할지**를 다시 정해야 합니다. 예:  
  - 자리마다 0~9를 1만 번 샘플링해 상위 1개씩?  
  - 6자리 전체를 1만 번 뽑아 패턴 통계?  
  - 조(1~5)도 시뮬레이션에 넣을지, 고정/제외와 어떻게 맞출지?  

즉 **“가능해 보인다”는 감각은 맞고**, 다만 **규격을 한 번 더 정의한 뒤** 구현하는 게 맞습니다.

**다음에 하려면**  
1) 기획 문서에 연금용 알고리즘 9의 **정확한 규칙**을 적고  
2) `local_lotto_service`에 시리얼 전용 몬테카를로(또는 기존 함수 확장)  
3) 시리얼일 때 알고리즘 목록에 9 다시 노출 + 옵션/검증/테스트  

원하시면 “연금에서 만 번 뽑기 = 이렇게 동작한다”를 한두 문장으로만 정해 주시면, 그에 맞춰 코드 쪽 설계까지 구체화해 드리겠습니다.

---

**User**

조를 빼고서 6자리만 생각해보면 000000에서 999999에서 숫자하나를 뽑는 거니까 1백만분의 1 확률에 조가 5개니까, 당첨확률은 5백만분의 1이라고 생각할 수 있는건가?

---

**Cursor**

완전히 그렇게 단정하긴 어렵고, **“티켓이 무엇을 하나의 ‘당첨 단위’로 삼느냐”**에 따라 달라집니다.

### 1) 말씀하신 모델: **조(5가지) × 6자리(000000~999999)** 를 한 번에 맞추는 경우  
한 번의 당첨 번호가 **(조, 6자리)** 조합 하나로 정해지고, 모든 조합이 **균등**이라면  
- 경우의 수 = \(5 \times 10^6 = 5\,000\,000\)  
- **그 전체를 하나로 잡은 티켓 1장**이면 당첨 확률은 **\(1/5\,000\,000\)** 로 보는 게 맞습니다.

즉, “6자리만 보면 100만 분의 1인데 조가 5개라서 **당첨 ‘조합’ 수가 500만 개**이니, **그 조합 전체를 맞히는 확률은 500만 분의 1**”이라는 식의 이해는 **위 가정(한 추첨 = 조+6자리 하나)** 에서는 타당합니다.

### 2) 다만 실제 연금복권720+는 **규칙이 이렇게 단순한 ‘한 덩어리 균등 추첨’인지**가 중요합니다  
- 티켓이 **항상 “조 + 6자리” 한 쌍**인지,  
- 추첨이 **조마다 따로** 나가는지, **조는 고정·6자리만 무작위**인지,  
- 순위·등수·보너스 규칙이 있는지  

에 따라 “500만 분의 1” 같은 숫자가 **공식 당첨 확률과 일치하지 않을 수** 있습니다.  
정확한 수치·표현은 **동행복권이 공개한 당첨 구조·확률**을 보는 게 맞습니다.

### 3) 요약  
- **“조를 포함한 (조, 6자리) 한 방울을 균등하게 하나 뽑는다”**는 가정이면 → **당첨 확률 \(1/(5 \times 10^6)\)** 로 보는 게 자연스럽습니다.  
- **“조는 빼고 6자리만 100만 분의 1”**은 **6자리만 맞추는 이벤트**에 대한 이야기이고, 조까지 포함한 **전체 일치**와는 다른 질문입니다.

원하시면, 실제 앱에 넣은 규칙(조 고정/제외, 세트 수)만 기준으로 **“우리 코드가 만드는 한 세트의 표본 공간”**이 몇 가지인지도 따로 짚어 드리겠습니다.

보내주신 표가 말씀하신 이해와 **같은 방향**입니다.

### 1등 (표 기준)
- **당첨조건**: 1등 당첨번호와 **연속 7자리 전부** 일치 → 티켓 구성이 **조(1~5) 1자리 + 뒤 6자리**이면, 경우의 수는 \(5 \times 10^6 = 5\,000\,000\)가지입니다.
- **당첨확률**: 표에 **\(1/5\,000\,000\)** 로 적혀 있으므로, “조 5가지 × 6자리 100만 가지 → **500만 분의 1**”이라고 보는 것이 **공식 설명과 일치**합니다.

### 참고 (표에 나온 다른 등)
- **2등** \(1/1\,250\,000\): 1등 번호 기준으로 **오른쪽부터 6자리**는 같고 **조만 다름** → 그런 티켓은 조가 5개 중 4개이므로 \(4/5\,000\,000 = 1/1\,250\,000\)으로 이해할 수 있습니다.
- **보너스** \(1/1\,000\,000\): 보너스 당첨번호는 **6자리만** 맞추는 구조라서 \(1/10^6\)로 표에 나온 값과 맞습니다.

정리하면, **“6자리만 보면 100만 분의 1이고, 조까지 포함한 완전 일치(1등)는 500만 분의 1”**이라는 생각은 이 표와 **같습니다.**

---

**User**

그럼 만번 추첨 알고리즘을 여기에는 어떻게 적용해 볼까?

---

**Cursor**

연금복권(시리얼)과 만 번 추첨 알고리즘 구현을 코드에서 확인합니다.



코드 기준으로 보면, **지금 있는 `generateMonteCarloTop`은 연금복권720+에 그대로 쓰기 어렵습니다.** 이유는 알고리즘 9가 **“풀에서 번호를 한 개씩 뽑고, 나온 횟수 상위 6개를 **서로 다른** 6개로 고른 뒤 정렬”**하는 구조이기 때문입니다 (`local_lotto_service.dart`의 `generateMonteCarloTop`).

연금720+는  
- 각 **자리마다 0~9**이고 **같은 숫자가 여러 번 나와도 됨**  
- **자리 순서(왼쪽→오른쪽)**가 의미 있어서, 로또처럼 끝에 **정렬**해 버리면 안 됩니다  

그래서 “만 번 추첨”을 쓰려면 **의미를 새로 정의**하는 편이 맞습니다.

---

### 적용 방향 1: **자리별 만 번 (로또 9번과 가장 비슷한 비유)**

1. **한 세트**를 만들 때마다, 예를 들어 **10,000번** 반복한다.  
2. 매번 **6자리 전부**를 균등 난수로 뽑는다 (각 자리 `0~9`).  
3. **자리 1~6 각각**에 대해, 그 자리에 나온 `0~9`의 **출현 횟수**를 센다.  
4. 각 자리에서 **가장 많이 나온 숫자**를 그 자리의 최종 숫자로 쓴다 (동률이면 작은 숫자 등 **고정 규칙**).

이렇게 하면 “만 번 시뮬한 뒤, **자리마다** ‘이번엔 이 숫자가 많이 나왔다’를 반영한다”는 식으로 **로또 9번의 ‘빈도 상위’ 개념**과 맞물립니다.  
(실제 당첨 확률과 무관하고, **취향용 생성 규칙**입니다.)

---

### 적용 방향 2: **조(1~5)만 만 번**

6자리는 기존처럼 **단순 랜덤**이나 다른 규칙으로 두고, **조만** `1~5`를 10,000번 뽑아 **최빈 조** 하나를 쓰는 식도 가능합니다. 다만 조는 값이 5개뿐이라 **만 번이 과한** 면은 있습니다.

---

### 적용 방향 3: **구현 층면 (앱에서)**

- **`generateMonteCarloTop`을 확장**하기보다는, `generateSerial` 옆에 **`generateSerialMonteCarlo`** 같은 **시리얼 전용 함수**를 두는 게 깔끔합니다.  
- UI에서는 연금 선택 시 지금은 알고리즘이 **1번만** 나오는데 (`offline_providers.dart`에서 `isSerial`이면 `[id:1]`만), 여기에 **9번을 열고** 시리얼일 때는 위 **자리별 만 번** 경로로 분기하면 됩니다.  
- 저장·표시용 `algorithmId` / 이름은 시리얼용으로 **별도 표기**(예: “시리얼·자리별 만번”)를 두면 나중에 로또 9번과 혼동이 없습니다.

---

### 한 줄 요약

연금720+에 “만 번 추첨”을 논리적으로 붙이려면 **“6개 **다른** 번호의 빈도 상위”가 아니라, “10,000번 **6자리 통째**로 뽑은 뒤 **각 자리(6곳)별로 0~9 빈도 최댓값**을 고른다”**는 식으로 정의하는 것이 자연스럽습니다.  

원하시면 다음 단계로 **동률 처리·`nSets`마다 독립 시뮬·조 처리**까지 포함한 구체 스펙을 짧게 적어 드리거나, 그 스펙에 맞춰 실제 `dart` 분기까지 짜 드릴 수 있습니다.

---

**User**

1000000에서 5999999에서 10만번 뽑기하면 의미잇는 중복횟수가 나올까?

---

**Cursor**

**결론부터 말하면:**  
`1_000_000` ~ `5_999_999` 구간은 **정수 500만 개**이고, 여기서 **복원 추출로 10만 번** 뽑으면, **“특정 한 번호가 여러 번 크게 나온다”** 식의 **눈에 띄는 중복 횟수**는 거의 나오지 않습니다.  
다만 **“서로 다른 두 번 뽑기가 같은 숫자를 가리킨다”**는 식의 **충돌**은 오히려 **꽤 많이** 생깁니다. 둘은 다른 이야기입니다.

---

### 1) 한 칸(한 번호)에 몇 번 나올까?

한 번 뽑을 때마다 각 번호가 나올 확률은 \(1/5\,000\,000\)입니다.  
10만 번이면 **기대 출현 횟수**는  
\[
\frac{100\,000}{5\,000\,000} = 0.02
\]
즉, **임의로 고른 한 번호**에 대해 평균 **0.02번** 수준입니다.  
그래서 **어떤 특정 번호가 5번, 10번** 이렇게 쌓일 확률은 **극히 낮고**, “의미 있게 큰 중복 횟수”가 나온다고 보기 어렵습니다.  
(최댓값도 보통 **아주 작은 정수**에 머무는 쪽이 일반적입니다.)

---

### 2) 그런데 “중복이 전혀 없다”는 것도 거의 불가능에 가깝다

10만 번을 뽑을 때 **서로 전부 다른 번호**일 확률은, 생일 역설과 같은 식으로 대략  
\[
\approx \exp\left(-\frac{n(n-1)}{2N}\right)
\]
에 가깝습니다.  
여기서 \(n=100\,000\), \(N=5\,000\,000\)이면 지수는 대략 **\(-1000\)** 근처라,  
**전부 서로 다름** 확률은 사실상 **0에 가깝습니다.**

그래서 **“같은 값이 두 번 이상 나온 적이 있다”**는 사건은 **거의 항상** 일어납니다.  
다만 그건 **“어느 한 번호가 폭발적으로 많이 나왔다”**가 아니라,  
**100만 개가 아닌 5백만 칸에 10만 개만 떨어지니** 여러 칸에 **0번 또는 1번**씩 퍼지고, **일부 칸만 2번 이상** 나눠 갖는 그림에 가깝습니다.

---

### 3) 질문에 대한 직접 답

- **“특정 번호의 중복 횟수가 크게 의미 있게 나올까?”**  
  → **거의 아니다.** 기대값이 0.02/번호라서, **한 번호에 쏠린 빈도**로 해석할 만한 건 기대하기 어렵습니다.

- **“10만 번이면 빈도표가 뭔가 패턴을 드러낼까?”**  
  → **거의 균등에 가깝게 보일 것**이고, “이 번호가 유독 많이 나왔다”는 식의 **통계적으로 강한 신호**는 나오기 어렵습니다.

원하시면 “**동일 번호가 정확히 k번 나올 확률**”이나 “**충돌이 한 번이라도 있을 확률**”을 이항분포·근사로 수치 예시까지 적어 드릴 수 있습니다.

---

**User**

0-9를 1만번 뽑는 건 확실히 과하기는 해서. 

---

**Cursor**

맞습니다. **후보가 10개뿐인데 1만 번**이면 “통계적으로 안정시키겠다”는 취지로는 **과한 편**에 가깝습니다.

- **이론적으로**: 자리 하나당 `0~9`를 \(m\)번 뽑으면, 각 숫자의 출현 비율은 \(m\)이 커질수록 **거의 균등(약 \(m/10\)번)**에 가까워집니다. 그래서 **빈도 최댓값**도 금방 **동률**이 많아지고, 1만 번이면 **거의 항상 비슷한 빈도**라서 “만 번 뽑기”의 차별력이 작아집니다.
- **실용적으로**: 자리별로라면 **수백 번~천 번**만 해도, 이미 **최빈값이 자주 동률**이라 “의미 있는 차이”는 줄어듭니다.

그래서 연금720+에 비슷한 느낌을 주려면 예를 들면 이런 식이 더 자연스럽습니다.

1. **자리당 시행 횟수 줄이기**  
   예: `200~1000`회 정도로 “가벼운 만 번 느낌”만 주기.

2. **시행 횟수를 게임에 맞추기**  
   예: **720**회, **500**회처럼 **이름·규모와 맞는 숫자**로 브랜딩 (수학적 필연은 없고 UX 선택).

3. **아예 다른 규칙**  
   “만 번” 대신 **한 번에 6자리 통째로 여러 세트 뽑고 그중 하나 고르기**처럼, **표본 공간이 큰 쪽**에서만 많이 뽑는 편이 낫습니다.

정리하면, **0~9만 대상이면 1만 번은 과하고**, 줄이거나 **의미 있는 표본 공간(6자리 전체 등)**에 시행 횟수를 쓰는 쪽이 설계상 더 맞습니다.

---

**User**

각 자리를 3천번씩 뽑는다면 어떨까?

---

**Cursor**

**괜찮은 선택**입니다. 구현·성능 측면에서는 **자리당 3천 번 × 6자리 = 1만 8천 번** 정도라 부담도 거의 없습니다.

**의미(통계) 쪽만 짚으면:**

- 자리 하나당 `0~9`를 **3천 번**이면, 각 숫자의 **기대 출현은 300번** 수준이라 **충분히 “많이 뽑았다”**는 느낌은 갖춥니다.
- **1만 번**보다는 **변동(위아래 차이)이 조금 더 큰** 편이라, 빈도 최댓값이 **동률로 묶일 확률**은 오히려 **조금 줄어들 수** 있습니다. (많이 뽑을수록 전부 비슷해져서 동률이 잦아지는 쪽에 가깝습니다.)
- 반대로 말하면, **3천 번도** 여전히 **최빈값이 둘 이상 동률**인 경우는 꽤 나오므로, 앱에서는 **동률일 때 작은 숫자 우선** 같은 **고정 타이브레이크**를 두는 게 안전합니다.

**요약:** “0~9에 1만 번은 과하다”는 판단이면 **자리당 3천 번**은 **타협으로 타당**하고, 로또 9번의 “1만”과 숫자를 맞출 필요는 없습니다. **720회·1000회**처럼 더 줄여도 되고, **3천**은 “과하지 않으면서도 빈도 놀이”로는 무난한 구간입니다.

---

**User**

그럼 그렇게 구현하는 방향으로 하자. 058문서에 해당 기능 구현을 위한 기획, 상세설계, 상세구현계획, 상세 시험항목 정의, 통과/실패 기준 설정, 자동시험설정 및 계획 설계, 각 구현단계별 커서 ide의 오토모델에 시킬지, think모델에 시킬지와 각 단계별 시행지시 프롬프트작성까지 전부 작성하라.

---

**Cursor**

056·057 문서 형식과 연금 시리얼 생성 코드를 확인한 뒤 058 문서를 작성합니다.



058 문서 작성: 056 문서 형식에 맞춰 Phase G(연금 시리얼·자리별 3천회) 전 범위를 정리합니다.



다음 파일에 요청하신 내용을 모두 반영해 두었습니다.

**경로**: `z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md`

### 문서에 포함된 구성

| 섹션 | 내용 |
|------|------|
| **§1 기획** | 목적, In/Out of scope, 성공 한 줄 정의 |
| **§2 알고리즘** | 자리당 3,000회·최빈값·동률 시 최소 숫자·조는 `generateSerial` 과 동일 |
| **§3 상세설계** | 변경 파일 목록, API 시그니처, `Random?` 주입, Provider·`algorithmId`/`algorithmName`, l10n 키 권장안(`serialAlgorithm9*`) |
| **§4 구현 단계** | **G-0 ~ G-7** (8단계) |
| **§5 시험** | G1~G5 표준 ID, **056 F2-T04·F4-T05 수정** 명시, 수동 M1~M5 |
| **§6 통과/실패** | PASS/FAIL/권고 |
| **§7 자동시험** | CI 순서, STEP별 `flutter test` 명령, 테스트 개수 대략 |
| **§8 모델** | **G-1 = Think**, **G-0,2~7 = Auto** 및 이유 |
| **§9 프롬프트** | G-0~G-7 각각 **붙여넣기용** 블록 (`[구현]`/`[시험]`/`[실행]`/완료 기준) |
| **부록 A** | G-3+G-4 한 번에 돌릴 때용 통합 프롬프트 |
| **부록 B** | 문서 경로·056과의 추적 관계 |

G-3 단계 안에는 ARB가 없으면 UI만으로는 막히므로, 문서 안에서 **G-4를 먼저 하거나 부록 A처럼 G-3+G-4를 묶어 실행**하라고 적어 두었습니다.

실제 구현은 이 문서의 **STEP G-0**부터 순서대로 진행하면 됩니다.

---

**User**

@z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md 오토 모델이 작성한 문서를 검수해라.

---

**Cursor**

전체 검수 완료했습니다. 분야별로 결함과 개선 권고 사항을 분리해 정리합니다.

---

## 검수 결과 요약

**판정: 구조·방향은 양호, 수정 필수 항목 5건, 보강 권고 항목 5건**

---

## 🔴 수정 필수 (오류·불일치)

### 1) §3.1 — 시험군 ID 오탈자

`test/unit/local_lotto_service_test.dart` 행에 **"G3 시험군 추가"** 라고 적혀 있으나, §5.1 시험 ID는 모두 **G1-T01~G1-T11** 입니다. G3는 홈 위젯 테스트군입니다.

수정 방향:
```
(현재) G3 시험군 추가
(수정) G1 시험군 추가
```

---

### 2) §9 G-1 프롬프트 — 상수 이름 불일치

§3.1에서 상수 이름을 `_serialDigitTrialsPerPosition`으로 정의했는데, G-1 프롬프트 본문에서는 `_kSerialDigitMonteCarloTrialsPerPosition`으로 다르게 씁니다. 에이전트가 둘 중 하나를 임의로 고를 경우 문서 내 추적이 깨집니다.

수정 방향: 두 곳을 **하나로 통일** (권장: `_kSerialDigitTrialsPerPosition`—프로젝트 `_k` 접두사 관례 적용).

---

### 3) §9 G-1 프롬프트 — 하이픈 누락

```
(현재) G1-T01~G1-11
(수정) G1-T01~G1-T11
```

---

### 4) §9 G-7 프롬프트 — 상대 경로

G-0, G-1은 절대 경로 `"h:\_Lotto_picker_app\pick_wizard\mobile_app"` 을 쓰는데 G-7만 `cd pick_wizard/mobile_app` 상대 경로입니다. 에이전트가 다른 디렉터리에서 시작하면 실패합니다.

수정 방향:
```
(현재) cd pick_wizard/mobile_app
(수정) cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
```

---

### 5) §7.3 — G-5, G-6 STEP별 실행 명령 누락

표에 G-5, G-6이 빠져 있습니다.

추가 필요:
| STEP | 명령 |
|------|------|
| G-5 | `flutter analyze` |
| G-6 | `flutter test test/widget/offline_result_screen_test.dart` |

---

## 🟡 보강 권고 (블로킹 아님)

### A) G-3 → G-4 순서 문제 미해결

G-3 프롬프트 안에서 "ARB 키가 없으면 하드코딩 금지"라고 쓰면서 동시에 "G-3에서 ARB를 직접 추가해도 된다"고 해서 G-4 역할과 겹칩니다. 부록 A에서 통합 프롬프트를 제시했으나, **§4 구현 단계 표에서 G-4를 G-3 앞으로 올리고 부록 A를 폐기**하는 것이 더 깔끔합니다.

```
(현재) G-3 홈 화면 UI → G-4 ARB
(권장) G-4 ARB → G-3 홈 화면 UI
```

---

### B) Dart `Random` 주입 방법 미명시

§2.3에서 "가짜 `Random` 구현체를 주입"이라고 했으나, Dart `Random`은 인터페이스가 아닌 클래스입니다. 에이전트가 서브클래싱으로 구현할 수 있도록 아래 수준의 힌트가 있으면 G-1 혼선이 줄어듭니다.

추가 권고:
```dart
// 테스트용: Random 서브클래스
class _CyclingRandom implements Random {
  int _i = 0;
  @override int nextInt(int max) => (_i++) % max;
  // nextBool, nextDouble 은 throw UnimplementedError() 허용
}
```

---

### C) G2 시험군 — `algorithmId`/`algorithmName` 저장 검증 없음

G-2 Provider 시험에서 `offlineAlgorithmsProvider` 길이만 검증하고, `OfflineGenerateNotifier` 실행 후 `finalized.algorithmId == 9` 및 `algorithmName == "Serial Digit Monte Carlo"` 검증이 빠져 있습니다. 내 번호 화면에서 알고리즘 표시가 깨지는 시나리오를 미리 막을 수 있는 핵심 시험입니다.

추가 권고:
```
G2-T04: isSerial + algo.id=9 → generated.algorithmId == 9
G2-T05: isSerial + algo.id=9 → generated.algorithmName == "Serial Digit Monte Carlo"
```

---

### D) G3 시험군 — 조 전부 제외 + 알고리즘9 조합 비활성화 케이스 누락

현재 G3-T03은 "알고리즘 미선택 시 비활성"만 봅니다. "시리얼 + 알고리즘 9 선택 + 조 전부 제외" 조합에서도 생성 버튼이 비활성인지 별도로 확인하는 케이스가 없습니다.

추가 권고:
```
G3-T04: annuity720 + 알고리즘9 + excludeGroups=[1,2,3,4,5] → 생성 버튼 비활성
```

---

### E) §7.4 테스트 개수 표현 모호

`"F2-T04 수정 + G2"` 대신 신규/수정을 구분해서 쓰는 편이 나중에 기준선 파악에 유리합니다.

```
(현재) unit/generated_numbers: F2-T04 수정 + G2
(권장) unit/generated_numbers: 수정 1건(F2-T04) + 신규 5건(G2-T01~G2-T05)
```

---

## 수정 항목별 위치 정리

| # | 심각도 | 위치 | 내용 |
|---|--------|------|------|
| 1 | 오탈자 | §3.1 파일 변경 목록 | `G3 시험군` → `G1 시험군` |
| 2 | 불일치 | §3.1 + §9 G-1 프롬프트 | 상수 이름 통일 |
| 3 | 오탈자 | §9 G-1 프롬프트 | `G1-11` → `G1-T11` |
| 4 | 실행 오류 | §9 G-7 프롬프트 | `cd` 절대 경로로 수정 |
| 5 | 누락 | §7.3 표 | G-5, G-6 명령 추가 |

수정을 반영하면 이 문서는 구현 지시에 바로 사용할 수 있는 수준입니다. 수정 적용을 원하시면 말씀 주십시오.

---

**User**

수정적용해라.

---

**Cursor**

검수 결과 5건 필수 수정 + 5건 보강 권고를 모두 적용합니다.

§4 단계 순서 변경 + §9 프롬프트 순서 교체 + 부록 A 폐기를 한 번에 적용합니다.

§7.3 표도 순서에 맞춰 G-3/G-4 라벨을 교체합니다.

§9 프롬프트 블록 순서를 G-3(ARB) → G-4(홈 화면 UI) 로 교체하고 부록 A를 제거합니다.

이제 부록 A를 제거합니다.

G-1 프롬프트의 가짜 RNG 설명도 구체화합니다.

G-2 프롬프트에도 G2-T04~T05 지시 추가합니다.

모든 수정이 완료됐습니다. 변경 내역을 정리합니다.

---

## 적용 완료 요약

### 필수 수정 5건
| # | 위치 | 변경 내용 |
|---|------|-----------|
| 1 | §3.1 | `G3 시험군` → `G1 시험군` 오탈자 수정 |
| 2 | §3.1 + §9 G-1 | 상수 이름 `_kSerialDigitTrialsPerPosition` 으로 통일 |
| 3 | §9 G-1 | `G1-11` → `G1-T11` 오탈자 수정 |
| 4 | §9 G-7 | `cd` 상대 경로 → 절대 경로 수정 |
| 5 | §7.3 | G-5, G-6 STEP 실행 명령 추가 |

### 보강 권고 5건
| # | 위치 | 변경 내용 |
|---|------|-----------|
| A | §4 + §9 + 부록 | G-3(ARB) ↔ G-4(홈 화면 UI) 순서 교체, 부록 A 폐기 |
| B | §2.3 + §9 G-1 | `_CyclingRandom` / `_ConstantRandom` Dart 서브클래스 코드 힌트 추가 |
| C | §5.2 + §9 G-2 | G2-T04(algorithmId 저장), G2-T05(algorithmName 저장) 시험 추가 |
| D | §5.3 + §9 G-4 | G3-T04(조 전부 제외+알고리즘9 비활성) 시험 추가 |
| E | §7.4 | 테스트 개수 표를 수정건/신규건 구분하여 명확화 |

---

**User**

지금 기획,설계서가 현재의 코드베이스에 잘 녹아들어가게끔 작성됐나?

---

**Cursor**

코드베이스 핵심 파일들을 직접 확인하겠습니다.

핵심 파일 4개를 확인했습니다. 코드베이스와 대조한 결과를 정리합니다.

---

## 검수 결과: 대부분 맞지만 **구체적 코드 연결이 빠진 구간 4곳** 발견

---

### 1) `_showHelpDialog` — 시그니처 미명시 🔴

**현재 코드** (`offline_home_screen.dart` 427~441행):
```dart
void _showHelpDialog(BuildContext context, int algorithmId, dynamic help) {
  final useL10n = algorithmId == 1 || algorithmId == 9;
  final name = useL10n
      ? (algorithmId == 1 ? l10n.algorithm1Name : l10n.algorithm9NameDisplay)  // ← 무조건 볼픽용
      : help.name;
```

`algorithmId == 9`이면 게임 타입에 상관없이 **항상 볼픽용** `l10n.algorithm9NameDisplay`·`l10n.algorithm9HelpOverview`를 씁니다. 시리얼+알고리즘9를 넣으면 **볼픽 문구가 그대로 나옵니다.**

058 문서 §9 G-4에는 "serialAlgorithm9Help* 키 사용"이라고만 있고, **이 함수에 `GameType` 파라미터를 어떻게 추가하는지** 지시가 없습니다. 에이전트가 어디를 손대야 하는지 알 수 없습니다.

---

### 2) `_canGenerate()` — 시리얼 + 알고리즘 미선택 미처리 🔴

**현재 코드** (472~498행):
```dart
bool _canGenerate() {
  if (gameType.isSerial) {
    // 조(group) 체크만 하고 algo == null 체크가 없음
    return available >= 1;
  }
  final algo = ref.read(offlineSelectedAlgorithmProvider);
  if (algo == null) return false;   // ← 볼픽에만 존재
```

G-2에서 알고리즘 선택지가 1→2개로 늘어나면, **시리얼에서도 알고리즘 미선택 상태**가 생깁니다. 지금 코드는 시리얼일 때 `algo == null`을 체크하지 않아서 **생성 버튼은 활성인데 `generate()` 내부에서 `ArgumentError`가 터지는** 구간이 생깁니다.

058 문서 G3-T04에서 "알고리즘9도 알고리즘 선택 필수"라고 했으나, **`_canGenerate()` 시리얼 분기를 어떻게 수정하라는 지시**가 없습니다.

---

### 3) 옵션 모달 상단 `algoName` — 분기 누락 🟡

**현재 코드** (819~821행):
```dart
final algoName = widget.algorithm.id == 1
    ? l10n.algorithm1Name
    : l10n.algorithm9NameDisplay;   // ← 시리얼+9도 볼픽 이름 그대로
```

시리얼+알고리즘9가 모달 상단에 볼픽용 이름("만 번 뽑기 6개")으로 표시됩니다. 058 문서에서 이 라인에 대한 수정 지시가 없습니다.

---

### 4) `AlgorithmHelpData.get()` — 게임 타입 인자 없음 🟡

**현재 코드** (`algorithm_help_data.dart` 55~57행):
```dart
static AlgorithmHelp? get(int algorithmId) {
  return getAll()[algorithmId];   // algorithmId만 받음, gameType 없음
}
```

058 §9 G-5에서 "help 빌더에 게임 타입 인자가 있다면 분기"라고 했는데 **실제로는 인자가 없습니다.** 에이전트가 이 메서드를 어떻게 확장해야 하는지(새 메서드 추가인지, 호출부 분기인지) 문서에서 정하지 않아 구현이 제각각이 될 수 있습니다.

---

## 문서에 추가해야 할 내용 (4곳)

추가가 필요한 내용을 한 곳에 정리하면 아래와 같습니다:

```
§3.1 및 §9 G-4 프롬프트에 추가:

[홈 화면 - 알고리즘 도움말]
_showHelpDialog(BuildContext, int algorithmId, dynamic help) →
  gameType 파라미터 추가 후, algorithmId==9 && gameType.isSerial 조건으로 분기:
    name      → l10n.serialAlgorithm9Name
    overview  → l10n.serialAlgorithm9HelpOverview
    howItWorks→ l10n.serialAlgorithm9HelpHowItWorks
    whenToUse → l10n.serialAlgorithm9HelpWhenToUse

[홈 화면 - 옵션 모달 상단 algoName]
final algoName = widget.algorithm.id == 1
    ? l10n.algorithm1Name
    : (gameType.isSerial ? l10n.serialAlgorithm9Name : l10n.algorithm9NameDisplay);

[홈 화면 - _canGenerate()]
if (gameType.isSerial) {
  final algo = ref.read(offlineSelectedAlgorithmProvider);
  if (algo == null) return false;   // ← 추가 필요
  final excludeGroups = ...
  return available >= 1;
}

[algorithm_help_data.dart - G-5]
AlgorithmHelpData.get()에 gameType 인자가 없으므로,
getSerial(int algorithmId) 별도 메서드 추가하거나
_showHelpDialog 호출부에서 분기(위 방식 권장).
```

수정을 지금 바로 058 문서에 반영할까요?

---

**User**

진행해라.

---

**Cursor**

현재 문서 상태를 확인하고 4곳을 정확히 반영합니다.

**§3.1 파일 변경 목록 — `offline_home_screen.dart` 항목 상세화**

**§3.4 뒤에 §3.5(코드 수준 변경 명세) 신규 추가**

**G-2 프롬프트 — `algo` null 체크 명시**

**G-4 프롬프트 — 코드 라인 단위로 구체화**

**G-5 프롬프트 — `getSerial9()` 추가 방식 및 권장 전략 명시**

전부 완료됐습니다. 최종 변경 내용을 정리합니다.

---

## 적용 완료 — 코드베이스 정합 수정 4건

### §3.1 파일 변경 목록
`offline_home_screen.dart` 항목에 4가지 수정 대상 코드 위치를 번호로 명시했습니다.

### §3.5 (신규 섹션) — `offline_home_screen.dart` 코드 수준 변경 명세
| 소절 | 내용 |
|------|------|
| **3.5.1** | `_canGenerate()` — `algo == null` 체크를 시리얼/볼픽 공통 최상단으로 이동 |
| **3.5.2** | `_showHelpDialog()` — `gameType` named param 추가, `isSerial+9` 분기로 `serialAlgorithm9Help*` 사용 |
| **3.5.3** | 옵션 모달 `algoName` — `gameType.isSerial` 삼항 분기 추가 |
| **3.5.4** | 알고리즘 목록 `name`/`desc` — `isSerial` 삼항 분기 추가 |

### §3.6 (신규 섹션) — `algorithm_help_data.dart` 변경 명세
`getSerial9()` 폴백 메서드 추가 방식과 **l10n 키 직접 사용 권장** 방향을 명시했습니다.

### §9 프롬프트 업데이트
- **G-2**: `OfflineGenerateNotifier`의 `algo null` 처리 수정 지시 추가
- **G-4**: 4개 수정 항목을 코드 라인 단위로 지시 (before/after 명시)
- **G-5**: `getSerial9()` 추가 방식과 "l10n 키 직접 사용이므로 help 내용 무시" 설명 추가

