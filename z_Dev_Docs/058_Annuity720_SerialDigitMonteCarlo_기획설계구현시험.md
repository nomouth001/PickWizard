# 058. PickWizard Phase G — 연금복권720+ 시리얼 「자리별 3천회」 생성  
## 기획서 · 상세설계 · 구현계획 · 시험명세 · 실행프롬프트

**문서 번호**: 058  
**작성일**: 2026-05-09  
**대상**: PickWizard 오프라인 앱 (`pick_wizard/mobile_app`)  
**선행 완료 요건**: 056 Phase F 전체 완료 (`annuity720` 시리얼, `generateSerial`, UI·시험·analyze 통과)  
**참고 문서**: 051, 052, 053, 055, **056** (Phase F), 057 (요약)

---

## 📋 목차

1. [기획서](#1-기획서)
2. [배경 및 알고리즘 정의](#2-배경-및-알고리즘-정의)
3. [아키텍처 상세설계](#3-아키텍처-상세설계)
4. [구현 단계 계획 (STEP G-0 ~ G-7)](#4-구현-단계-계획)
5. [시험항목 상세 정의](#5-시험항목-상세-정의)
6. [통과/실패 기준](#6-통과실패-기준)
7. [자동시험 설정 및 계획](#7-자동시험-설정-및-계획)
8. [STEP별 모델 선택 가이드 (Auto vs Think)](#8-step별-모델-선택-가이드)
9. [STEP별 실행 지시 프롬프트](#9-step별-실행-지시-프롬프트)

---

## 1. 기획서

### 1.1 목적

연금복권720+(`annuity720`)는 현재 **알고리즘 1(자동/시리얼 퀵픽)** 만 제공한다.  
볼 픽 게임에만 존재하던 **알고리즘 9(만 번 뽑기 상위 빈도)** 의 **개념적 대응물**을 시리얼에 도입한다.

- 로또 6/45의 알고리즘 9는 **풀(1~45)에서 복원 추출 10,000회 후 빈도 상위 6개(중복 없음)** 이므로 시리얼에 **그대로 적용 불가**한다(056·대화 합의).
- 본 Phase G에서는 **각 자리(6곳)마다 0~9를 3,000회 복원 추출**하고, **자리별 출현 횟수 최댓값에 해당하는 숫자**를 채택한다.
- **동률**이면 **더 작은 숫자(0 우선)** 를 채택한다(기존 `generateMonteCarloTop`의 빈도 동률 시 `a.key.compareTo(b.key)`와 동일한 철학).

### 1.2 범위 (In Scope)

| 구분 | 내용 |
|------|------|
| 생성 API | `local_lotto_service.dart` 에 시리얼 전용 신규 함수 추가 |
| 상수 | 자리당 시행 횟수 **3,000** (코드 내 명명 상수, 매직 넘버 금지) |
| 조(Group) | 기존 `generateSerial` 과 **동일 규칙** (`fixedGroup`, `excludeGroups`, `validateSerialParameters`) |
| Provider | `annuity720` 선택 시 `offlineAlgorithmsProvider` 가 **알고리즘 1 + 9** 반환 |
| 생성기 | `OfflineGenerateNotifier` 에서 시리얼 + 알고리즘 9 분기 → 신규 함수 호출 |
| 저장 메타 | `GeneratedNumbers.algorithmId` : 시리얼에서도 **1 또는 9** 로 구분 저장 |
| UI·문구 | 홈 화면 알고리즘 선택·설명·도움말에서 시리얼일 때 **자리별 3천회** 의미 반영 |
| 자동시험 | 단위·위젯·회귀 시험 추가 및 056 문서와 충돌하는 기대값 수정 |

### 1.3 범위 외 (Out of Scope)

- 당첨 확률 개선·실제 복권 통계 연동 (오락용 생성 규칙일 뿐).
- 자리당 시행 횟수를 **사용자가 UI에서 변경**하는 설정 (v1 고정 3,000).
- Hive 스키마·`GameTypeId` 순서 변경.
- 볼 픽 `generateMonteCarloTop` 의 10,000회 상수 변경.

### 1.4 성공 상태 (한 줄)

`annuity720` 에서 사용자가 **알고리즘 9** 를 고르면 **자리별 3천회 빈도 규칙**으로 번호가 생성되고, 테스트·analyze·기존 게임 회귀가 모두 유지된다.

---

## 2. 배경 및 알고리즘 정의

### 2.1 왜 자리당 3,000회인가

- 후보가 10개뿐인 자리에 **10,000회**는 과하며 빈도가 평탄해져 **동률**이 잦아진다.
- **3,000회**는 연산량이 작고(자리당 3,000 × 6 = 18,000회 난수/세트), 빈도 기반 규칙의 “취향용” 설명과도 맞는 타협점이다.

### 2.2 알고리즘 명세 (정규화)

**입력**: `gameType`(반드시 `isSerial == true`), `nSets`, `fixedGroup?`, `excludeGroups?`, 선택적 `Random? random`  
**출력**: `GeneratedNumbers` (기존 `_buildGenerated` 경로와 동일)

**각 세트 `i` (0 .. nSets-1)**:

1. **조(보너스 슬롯)**  
   - `generateSerial` 과 동일: `fixedGroup` 이 있으면 해당 값, 없으면 `excludeGroups` 를 제외한 1~5 중 균등 난수.

2. **6자리 숫자**  
   각 자리 인덱스 `p ∈ {0,1,2,3,4,5}` 에 대해:
   - 길이 10의 정수 배열 `counts[d] = 0` (`d ∈ 0..9`).
   - `trial = 1 .. 3000`: `d = rng.nextInt(10)`; `counts[d]++`.
   - `digit[p] = argmax_d counts[d]`; **복수 최대**이면 **가장 작은 `d`**.

3. **순서**  
   - `digit[0]..digit[5]` 를 **정렬하지 않는다** (연금 자리 의미 유지).

4. **검증**  
   - `validateSerialParameters` 선행. `gameType.isSerial` 아니면 `ArgumentError`.

### 2.3 결정성·테스트 전략

- **프로덕션**: `random ?? Random()` 사용.
- **단위 테스트**: `Random` 구현체를 주입하여 동작 고정.  
  Dart `Random`은 인터페이스가 아닌 클래스이므로 **서브클래싱**으로 주입한다.

```dart
// 테스트 전용 가짜 RNG
class _CyclingRandom implements Random {
  int _i = 0;
  @override
  int nextInt(int max) => (_i++) % max;
  @override
  double nextDouble() => throw UnimplementedError();
  @override
  bool nextBool() => throw UnimplementedError();
}

class _ConstantRandom implements Random {
  final int value;
  _ConstantRandom(this.value);
  @override
  int nextInt(int max) => value % max;
  @override
  double nextDouble() => throw UnimplementedError();
  @override
  bool nextBool() => throw UnimplementedError();
}
```

  - **동률 타이브레이크 검증**: `_CyclingRandom()` 주입 → 3,000회가 10의 배수이므로 각 숫자 정확히 300회 → 모든 자리 결과 **0** 기대.
  - **비동률 검증**: `_ConstantRandom(3)` 주입 → 모든 자리 결과 **3** 기대.

---

## 3. 아키텍처 상세설계

### 3.1 파일 변경 목록

| 파일 | 변경 요약 |
|------|-----------|
| `lib/offline/services/local_lotto_service.dart` | 상수 `_kSerialDigitTrialsPerPosition = 3000`; 함수 `generateSerialDigitMonteCarlo(...)` 추가 |
| `lib/offline/providers/offline_providers.dart` | `offlineAlgorithmsProvider` 시리얼 분기에 `id:9` 추가; `generate()` 시리얼+9 분기 |
| `lib/offline/screens/offline_home_screen.dart` | ① `_canGenerate()` 시리얼 분기에 `algo==null` 체크 추가 ② 알고리즘 목록 `name`/`desc` 시리얼 분기 ③ `_showHelpDialog` `gameType` 파라미터 추가 + 시리얼+9 분기 ④ 옵션 모달 `algoName` 시리얼 분기 |
| `lib/core/localization/app_*.arb` (6개) | 시리얼 전용 알고리즘 9 이름/설명/도움말 키 추가 (또는 기존 키에 `gameType.isSerial` 분기 시 플레이스홀더) |
| `lib/core/localization/generated/*` | `flutter gen-l10n` 재생성 |
| `lib/data/help/algorithm_help_data.dart` | 알고리즘 9 도움말에 시리얼 분기(또는 별도 help id — **구현 시 하나로 통일**) |
| `test/unit/generated_numbers_test.dart` | F2-T04 기대 변경: 시리얼 알고리즘 목록 길이 2 |
| `test/unit/local_lotto_service_test.dart` | G1 시험군 추가 |
| `test/widget/offline_home_screen_test.dart` | F4-T05 제거/대체: 시리얼에서 알고리즘 9 표시 |

### 3.2 API 시그니처 (권장)

```dart
/// 알고리즘 9 (시리얼): 각 자리 0~9를 [_serialDigitTrialsPerPosition]회 뽑아 최빈값(동률 시 최소 숫자).
GeneratedNumbers generateSerialDigitMonteCarlo({
  required GameType gameType,
  required int nSets,
  int? fixedGroup,
  List<int>? excludeGroups,
  Random? random,
});
```

### 3.3 Provider·저장 규칙

| 항목 | 알고리즘 1 | 알고리즘 9 |
|------|-----------|-----------|
| 호출 함수 | `generateSerial` | `generateSerialDigitMonteCarlo` |
| `algorithmId` | `1` | `9` |
| `algorithmName` (영문 저장 필드) | `Serial Quick Pick` | `Serial Digit Monte Carlo` (또는 짧은 고정 문자열; **l10n과 별도**) |

> UI 표시명은 l10n으로, Hive/JSON에 들어가는 `algorithmName` 은 기존 패턴을 따른다.

### 3.4 UI/문구 설계 원칙

- 볼 픽에서 쓰는 `algorithm9NameDisplay` / `algorithm9Desc` 는 **“1~45, 1만 회”** 를 전제로 하므로, 시리얼 선택 시에는 **별도 키**를 쓰는 것을 권장한다.  
  예: `serialAlgorithm9Name`, `serialAlgorithm9Desc`, `serialAlgorithm9HelpOverview`, `serialAlgorithm9HelpHowItWorks`, `serialAlgorithm9HelpWhenToUse`  
- 대안: 기존 키에 `{trials}` `{digits}` 플레이스홀더를 넣어 볼픽/시리얼 공용으로 만들 수 있으나 **번역 난이도 상승** → v1 은 **별도 키** 권장.

### 3.5 `offline_home_screen.dart` 코드 수준 변경 명세

코드베이스 검수 결과 발견된 4곳의 구체적 수정 방향을 명시한다.

#### 3.5.1 `_canGenerate()` — 시리얼 분기에 algo null 체크 추가

```dart
// 현재 (isSerial 분기에서 algo 체크 없음)
bool _canGenerate() {
  if (gameType.isSerial) {
    final excludeGroups = ref.read(offlineSerialExcludeGroupsProvider);
    final fixedGroup = ref.read(offlineSerialFixedGroupProvider);
    // ...
    return available >= 1;   // algo == null 이어도 true 반환 → generate() 실패
  }
  final algo = ref.read(offlineSelectedAlgorithmProvider);
  if (algo == null) return false;  // ← 볼픽에만 존재

// 수정 후
bool _canGenerate() {
  final algo = ref.read(offlineSelectedAlgorithmProvider);
  if (algo == null) return false;  // 시리얼·볼픽 공통으로 앞으로 이동
  if (gameType.isSerial) {
    final excludeGroups = ref.read(offlineSerialExcludeGroupsProvider);
    // ...
    return available >= 1;
  }
  // 볼픽 나머지 로직 동일 ...
}
```

#### 3.5.2 `_showHelpDialog()` — `gameType` 파라미터 추가

```dart
// 현재 시그니처
void _showHelpDialog(BuildContext context, int algorithmId, dynamic help)

// 수정 후 시그니처
void _showHelpDialog(BuildContext context, int algorithmId, dynamic help,
    {required GameType gameType})

// 수정 후 분기 (algorithmId == 9 블록)
: (gameType.isSerial
    ? l10n.serialAlgorithm9Name          // 시리얼용
    : l10n.algorithm9NameDisplay);        // 볼픽용
// overview / howItWorks / whenToUse 동일 패턴 적용
```

`_buildHelpButton` → `_showHelpDialog` 호출부에서 현재 `gameType`을 `named parameter`로 전달한다.

#### 3.5.3 옵션 모달 `algoName` — 시리얼 분기

```dart
// 현재 (_AlgorithmOptionsModalState.build 내)
final algoName = widget.algorithm.id == 1
    ? l10n.algorithm1Name
    : l10n.algorithm9NameDisplay;   // 시리얼+9도 볼픽 이름 그대로

// 수정 후
final algoName = widget.algorithm.id == 1
    ? l10n.algorithm1Name
    : (gameType.isSerial
        ? l10n.serialAlgorithm9Name
        : l10n.algorithm9NameDisplay);
```

`_AlgorithmOptionsModalState` 에서 `gameType`을 읽으려면 `ref.watch(offlineSelectedGameTypeProvider)` 또는 `widget`으로 전달.

#### 3.5.4 알고리즘 목록 `name`/`desc` — 시리얼 분기

```dart
// 현재 (algorithms.map 내부)
final name = algo.id == 1
    ? l10n.algorithm1Name
    : l10n.algorithm9NameDisplay;
final desc = algo.id == 1
    ? l10n.algorithm1DescDynamic(...)
    : l10n.algorithm9DescDynamic(gameType.mainCount);

// 수정 후
final name = algo.id == 1
    ? l10n.algorithm1Name
    : (gameType.isSerial
        ? l10n.serialAlgorithm9Name
        : l10n.algorithm9NameDisplay);
final desc = algo.id == 1
    ? l10n.algorithm1DescDynamic(...)
    : (gameType.isSerial
        ? l10n.serialAlgorithm9Desc
        : l10n.algorithm9DescDynamic(gameType.mainCount));
```

---

### 3.6 `algorithm_help_data.dart` 코드 수준 변경 명세

현재 `AlgorithmHelpData.get(int algorithmId)` 는 게임 타입을 받지 않는다.  
G-5에서 아래 메서드를 **추가**하는 방식을 권장한다(기존 `get()`은 변경 금지).

```dart
/// 시리얼 게임 전용 알고리즘 9 도움말
static AlgorithmHelp getSerial9() {
  return const AlgorithmHelp(
    algorithmId: 9,
    name: '',        // 런타임에 l10n으로 덮어쓰므로 빈 문자열 가능
    overview: '',
    howItWorks: '',
    whenToUse: '',
    parameters: {},
  );
}
```

`_showHelpDialog` 에서 `gameType.isSerial && algorithmId == 9` 조건 시 이 객체를 넘기거나,  
해당 조건에서는 `help` 객체를 아예 사용하지 않고 **l10n 키만 직접 사용**하는 방식도 동일하게 수용 가능.  
**권장: l10n 키 직접 사용**(§3.5.2 방식). `getSerial9()`는 `AlgorithmHelpData.get()` 호출 시 null 반환 방지용 폴백으로만 유지.

---

### 3.7 회귀·호환

- `GameTypeId` / Hive 인덱스 **변경 금지**.
- 기존 저장된 `GeneratedNumbers` (algorithmId 1 시리얼) **읽기 호환** 유지.

---

## 4. 구현 단계 계획

| STEP | 제목 | 주요 산출물 |
|------|------|-------------|
| **G-0** | 사전 기준선 | `flutter test` / `flutter analyze` 전체 PASS 확인 |
| **G-1** | 시리얼 자리별 Monte Carlo 코어 | `generateSerialDigitMonteCarlo` + 단위 시험 |
| **G-2** | Provider·Notifier 연동 | `offlineAlgorithmsProvider`, `OfflineGenerateNotifier` |
| **G-3** | 다국어 ARB 6종 | 신규 키 추가 + `gen-l10n` |
| **G-4** | 홈 화면 UI·생성 가능 조건 | 알고리즘 9 탭·설명·모달·`_canGenerate` |
| **G-5** | 알고리즘 도움말 데이터 | `algorithm_help_data.dart` id 9 시리얼 문구 |
| **G-6** | 결과·내 번호 표시 검증 | 필요 시 알고리즘명 표시 분기·위젯 테스트 |
| **G-7** | 통합 마감 | 전체 테스트·analyze·수동 체크리스트 |

> **순서 설계 의도**: G-3(ARB)이 G-4(홈 화면 UI) 앞에 있으므로 G-4에서 l10n 키를 바로 참조할 수 있다.

---

## 5. 시험항목 상세 정의

### 5.1 G1 — `generateSerialDigitMonteCarlo` 코어 (단위)

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| G1-T01 | `nSets=1` → `results.length == 1`, `numbers.length == 6` | unit |
| G1-T02 | 모든 자리 값 ∈ `0..9` | unit |
| G1-T03 | `bonusBalls.length == 1`, 값 ∈ `1..5` | unit |
| G1-T04 | `nSets=10` → `results.length == 10` | unit |
| G1-T05 | `fixedGroup=4` → 모든 세트 `bonusBalls[i]==4` | unit |
| G1-T06 | `excludeGroups=[5]` → 모든 세트 조 ∈ `{1,2,3,4}` | unit |
| G1-T07 | `validateSerialParameters` 실패 시 `ArgumentError` (기존 시리얼과 동일 케이스 1건 이상) | unit |
| G1-T08 | `gameType == lotto645` 호출 시 `ArgumentError` (또는 동일 정책의 검증 실패) | unit |
| G1-T09 | **동률 타이브레이크**: 순환 `nextInt(10)` 가짜 RNG → 6자리 모두 `0` | unit |
| G1-T10 | **비동률**: `nextInt(10)` 이 항상 `3` → 모든 자리 `3` | unit |
| G1-T11 | `gameTypeId == annuity720` | unit |

### 5.2 G2 — Provider (단위)

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| G2-T01 | `annuity720` 선택 시 `offlineAlgorithmsProvider` 길이 **2**, id `1`·`9` | unit |
| G2-T02 | `lotto645` 선택 시 길이 **2** (회귀) | unit |
| G2-T03 | `annuity720` → `lotto645` 전환 후 다시 `annuity720` → 알고리즘 목록 정상 | unit |
| G2-T04 | `isSerial + algo.id=9` 로 `generate()` 실행 → `result.algorithmId == 9` | unit |
| G2-T05 | `isSerial + algo.id=9` 로 `generate()` 실행 → `result.algorithmName == "Serial Digit Monte Carlo"` | unit |

> **056 F2-T04 수정**: 기대값을 “길이 1”에서 “길이 2”로 변경하고, 테스트 이름/주석 갱신.

### 5.3 G3 — 홈 위젯

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| G3-T01 | `annuity720` + 알고리즘 목록에 **알고리즘 9** 항목 존재 | widget |
| G3-T02 | 시리얼 선택 시 알고리즘 9 설명에 **3,000** 또는 l10n이 정의한 문구 포함 | widget |
| G3-T03 | 알고리즘 미선택 시 생성 버튼 비활성 (기존 ballPick 회귀) | widget |
| G3-T04 | `annuity720` + 알고리즘 9 선택 + `excludeGroups=[1,2,3,4,5]` → 생성 버튼 비활성 | widget |

### 5.4 G4 — 도움말·l10n (자동)

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| G4-T01 | `flutter gen-l10n` 성공 | auto |
| G4-T02 | `flutter analyze` error 0 | auto |

### 5.5 G5 — 통합

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| G5-T01 | `flutter test` 전체 PASS | auto |
| G5-T02 | 기존 `generateMonteCarloTop` 로또645 시험(B-T14~ 등) 회귀 PASS | auto |
| G5-T03 | 기존 `generateSerial` 시험(F3-T01~ 등) 회귀 PASS | auto |

### 5.6 수동 시험 (G7 체크리스트)

| # | 항목 |
|---|------|
| M1 | 연금720+ 선택 → 알고리즘 1·9 모두 보임 |
| M2 | 알고리즘 9 선택 → 옵션 모달·조 고정/제외 정상 |
| M3 | 생성 → 결과 화면에 시리얼 표시·algorithm 표기 9 |
| M4 | 저장 → 내 번호에서 알고리즘명/배지 정상 |
| M5 | 로또6/45로 전환 → 알고리즘 9 설명이 **볼픽용(1만 회)** 으로 돌아옴 |

---

## 6. 통과/실패 기준

### 6.1 PASS (전부 충족)

| 항목 | 기준 |
|------|------|
| 단위/위젯 테스트 | `flutter test` **전부** PASS |
| 정적 분석 | `flutter analyze` — **error 0** (프로젝트 정책상 warning 0이면 동일 적용) |
| l10n | `flutter gen-l10n` 오류 없음 |
| 회귀 | G5-T02, G5-T03 및 기존 Phase A~F 관련 테스트 실패 0 |
| 수동 | §5.6 M1~M5 체크 완료 |

### 6.2 FAIL (하나라도 해당 시 해당 STEP 재작업)

| 항목 | 기준 |
|------|------|
| 시리얼 알고리즘 9 | 자리 밖 값·조 범위(1~5) 외 생성 |
| 잘못된 게임 타입 | 볼 픽 게임에서 `generateSerialDigitMonteCarlo` 호출 경로 존재 |
| UI 회귀 | 볼 픽 알고리즘 9 문구가 시리얼용으로 **오염** |
| 테스트 | G1~G3 또는 기존 테스트 **신규 FAIL** |
| analyze | error ≥ 1 |

### 6.3 권고 (블로킹 아님)

- 영어 외 로케일 문구 MT 품질 검수는 릴리즈 전 별도.

---

## 7. 자동시험 설정 및 계획

### 7.1 작업 디렉터리

```text
h:\_Lotto_picker_app\pick_wizard\mobile_app
```

### 7.2 CI 권장 순서 (056 §7.2와 동일)

```powershell
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test test/unit/
flutter test test/widget/
flutter test
```

### 7.3 STEP별 부분 실행

| STEP | 명령 |
|------|------|
| G-1 | `flutter test test/unit/local_lotto_service_test.dart` |
| G-2 | `flutter test test/unit/generated_numbers_test.dart` |
| G-3 | `flutter gen-l10n && flutter analyze` |
| G-4 | `flutter test test/widget/offline_home_screen_test.dart` |
| G-5 | `flutter analyze` |
| G-6 | `flutter test test/widget/offline_result_screen_test.dart test/widget/offline_my_numbers_screen_test.dart` |
| G-7 | `flutter test && flutter analyze` |

### 7.4 테스트 개수 예측(대략)

| 구분 | 수정 | 신규 | 소계 |
|------|------|------|------|
| unit/local_lotto_service | 0 | +11 (G1-T01~T11) | +11 |
| unit/generated_numbers | 수정 1 (F2-T04 기대값 변경) | +5 (G2-T01~T05) | +5 신규 |
| widget/offline_home_screen | 대체 1 (F4-T05→G3-T01) | +4 (G3-T01~T04) | +4 신규 |
| **합계 증가** | **수정 2건** | **신규 +20건** | **(기존 총 개수는 G-0에서 확인)** |

---

## 8. STEP별 모델 선택 가이드

### Think 모델 권장

| STEP | 이유 |
|------|------|
| **G-1** | RNG 주입 설계, 타이브레이크·`gameType` 검증 정책, `_buildGenerated` 재사용 경계, 기존 `generateSerial` 과 코드 중복 최소화 리팩터 여부 판단 |

### Auto 모델 권장

| STEP | 이유 |
|------|------|
| **G-0** | 명령 실행·결과 보고 |
| **G-2** | Provider 패턴이 056과 동일 축 |
| **G-3** | 기존 홈 화면 알고리즘 UI 복제·분기 |
| **G-4** | ARB 키 추가·번역 문자열 삽입 |
| **G-5** | help 데이터 문자열·분기 |
| **G-6** | 소규모 표시 확인 |
| **G-7** | 전체 테스트·체크리스트 |

> Cursor 제품에서 모델 라벨이 **Auto / Think** 로 표기되는 경우 본 문서의 표기와 대응시킨다.

---

## 9. STEP별 실행 지시 프롬프트

> **사용법**: 한 STEP씩 에이전트에 붙여넣기. 이전 STEP **완료 기준** 충족 후 다음 STEP 진행.  
> **(Think)** 는 Think 모델, 그 외는 Auto 모델.

---

### STEP G-0 — 사전 기준선 (Auto)

```
058 문서 Phase G 작업을 시작한다.

1. 작업 디렉터리: h:\_Lotto_picker_app\pick_wizard\mobile_app
2. flutter test 전체 실행 후 PASS/FAIL 요약
3. flutter analyze 실행 후 error/warning 요약
4. pubspec.yaml 의 version 한 줄 인용

완료 기준: flutter test 전체 PASS, flutter analyze error 0.
실패 시 원인만 보고하고 중단한다.
```

---

### STEP G-1 — `generateSerialDigitMonteCarlo` 코어 (Think)

```
z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md 의 §2.2, §3.2 를 따른다.

[구현] lib/offline/services/local_lotto_service.dart

1. private 상수: 자리당 시행 횟수 3000 (이름: `_kSerialDigitTrialsPerPosition`).

2. 함수 generateSerialDigitMonteCarlo 추가:
   - validateSerialParameters 선행 (generateSerial 과 동일 인자).
   - gameType.isSerial 이 아니면 ArgumentError.
   - Random? random 파라미터, 기본 Random().
   - 각 세트: 조는 generateSerial 과 동일 로직(중복 허용 시 private 헬퍼로 추출해도 됨).
   - 각 자리 0..5: 3000회 nextInt(10) 빈도, 최댓값 동률 시 최소 숫자.
   - numbers 정렬 금지. _buildGenerated 로 반환.

[시험] test/unit/local_lotto_service_test.dart
- G1-T01~G1-T11 을 §5.1 표에 맞게 구현.
- 가짜 Random: §2.3 의 `_CyclingRandom`(순환 0..9, 동률 → 전부 0)·`_ConstantRandom(3)`(항상 3 → 전부 3) 사용.

[실행]
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter test test/unit/local_lotto_service_test.dart
flutter analyze

완료 기준: G1 단위시험 전부 PASS, analyze error 0, generateSerial 기존 테스트 회귀 PASS.
```

---

### STEP G-2 — Provider·Notifier (Auto)

```
058 §3.3 을 따른다. G-1이 완료된 상태다.

[구현] lib/offline/providers/offline_providers.dart

1. offlineAlgorithmsProvider: gt.isSerial 일 때
   [OfflineAlgorithmInfo(id:1), OfflineAlgorithmInfo(id:9)] 반환.

2. OfflineGenerateNotifier.generate():
   - 시리얼 분기 진입 전 기존 `if (algo == null) throw ArgumentError(...)` 위치를
     확인하고, **시리얼 경우에도 algo null이면 동일하게 에러 처리**되도록 로직 정리.
     (현재 코드는 isSerial이면 algo null 체크 없이 바로 generateSerial을 호출함 — 수정 필요)
   - gameType.isSerial 이고 algo.id==1 이면 기존 generateSerial 유지.
   - gameType.isSerial 이고 algo.id==9 이면 generateSerialDigitMonteCarlo 호출
     (fixedGroup, excludeGroups 동일 전달).
   - finalized.copyWith: 시리얼도 algorithmId 는 실제 1 또는 9.
     algorithmName: 1은 "Serial Quick Pick", 9는 "Serial Digit Monte Carlo" (영문 고정).

[시험] test/unit/generated_numbers_test.dart
- 056 F2-T04 를 수정: annuity720 일 때 알고리즘 목록 길이 2, id 1과 9 포함.
- G2-T01~G2-T05 추가 (G2-T04: algorithmId==9 저장 확인, G2-T05: algorithmName=="Serial Digit Monte Carlo" 저장 확인).

[실행]
flutter test test/unit/generated_numbers_test.dart
flutter analyze

완료 기준: 위 테스트 PASS, 볼픽 알고리즘 목록 회귀 유지.
```

---

### STEP G-3 — 다국어 ARB (Auto)

```
058 §3.4 키 설계로 app_ko.arb, app_en.arb, app_ja.arb, app_zh.arb, app_th.arb, app_vi.arb 에 신규 문자열 추가:
- serialAlgorithm9Name, serialAlgorithm9Desc
- serialAlgorithm9HelpOverview, serialAlgorithm9HelpHowItWorks, serialAlgorithm9HelpWhenToUse
한국어: "자리별 3천회 최빈값" 의미를 자연스럽게 설명. 영어: 동일 의미로 번역. 기타 언어는 영어 기반 MT 가능.

flutter gen-l10n 후 컴파일 오류 없이 import 갱신.

완료 기준: gen-l10n 성공, analyze error 0.
```

---

### STEP G-4 — 홈 화면 UI (Auto)

```
G-3 완료 상태 (l10n.serialAlgorithm9* 키 사용 가능). lib/offline/screens/offline_home_screen.dart 수정.
058 §3.5 의 4개 수정 명세를 모두 적용한다.

[구현 — §3.5.1] _canGenerate() 수정
  - `final algo = ref.read(offlineSelectedAlgorithmProvider)` 과
    `if (algo == null) return false;` 를 isSerial 분기 바깥(함수 최상단)으로 이동.
  - 시리얼 분기 내부에는 조 체크만 남긴다.

[구현 — §3.5.2] _showHelpDialog() 시그니처 변경
  - `{required GameType gameType}` named param 추가.
  - algorithmId==9 블록에서:
      name       → gameType.isSerial ? l10n.serialAlgorithm9Name      : l10n.algorithm9NameDisplay
      overview   → gameType.isSerial ? l10n.serialAlgorithm9HelpOverview   : l10n.algorithm9HelpOverview
      howItWorks → gameType.isSerial ? l10n.serialAlgorithm9HelpHowItWorks : l10n.algorithm9HelpHowItWorks
      whenToUse  → gameType.isSerial ? l10n.serialAlgorithm9HelpWhenToUse  : l10n.algorithm9HelpWhenToUse
  - _buildHelpButton 및 모든 _showHelpDialog 호출부에 `gameType: gameType` 전달.

[구현 — §3.5.3] 옵션 모달 algoName
  - _AlgorithmOptionsModalState.build 내:
      final algoName = widget.algorithm.id == 1
          ? l10n.algorithm1Name
          : (gameType.isSerial ? l10n.serialAlgorithm9Name : l10n.algorithm9NameDisplay);
  - gameType 은 ref.watch(offlineSelectedGameTypeProvider) 로 읽는다.

[구현 — §3.5.4] 알고리즘 목록 name/desc
  - algorithms.map 내부:
      name → algo.id==1 ? l10n.algorithm1Name
                        : (gameType.isSerial ? l10n.serialAlgorithm9Name : l10n.algorithm9NameDisplay)
      desc → algo.id==1 ? l10n.algorithm1DescDynamic(...)
                        : (gameType.isSerial ? l10n.serialAlgorithm9Desc : l10n.algorithm9DescDynamic(gameType.mainCount))

[시험] test/widget/offline_home_screen_test.dart 갱신 (§5.3 G3-T01~G3-T04)
  - G3-T01: annuity720 + 알고리즘 9 항목 표시
  - G3-T02: 시리얼 알고리즘 9 설명에 serialAlgorithm9Desc 문구 포함
  - G3-T03: 알고리즘 미선택 시 생성 버튼 비활성 (ballPick 회귀)
  - G3-T04: annuity720 + 알고리즘9 + excludeGroups 전체 → 생성 버튼 비활성

[실행]
flutter test test/widget/offline_home_screen_test.dart
flutter analyze

완료 기준: G3 위젯 테스트 PASS, analyze error 0.
```

---

### STEP G-5 — algorithm_help_data (Auto)

```
058 §3.6 을 따른다.

현재 AlgorithmHelpData.get(int algorithmId) 는 gameType 인자가 없다.
G-4에서 _showHelpDialog 가 이미 gameType.isSerial 분기로 l10n 키를 직접 사용하므로,
algorithm_help_data.dart 에서 별도 분기가 필요하지 않다.

다만 AlgorithmHelpData.get(9) 가 null 을 반환하지 않도록 폴백용 getSerial9() 추가:
- getSerial9() 는 algorithmId:9, name/overview/howItWorks/whenToUse 를 빈 문자열로 설정.
- _buildHelpButton 에서 gameType.isSerial && algorithmId==9 이면 getSerial9() 를 help 인자로 전달.
  (G-4 에서 _showHelpDialog 가 isSerial 분기로 l10n 키를 쓰므로, help 객체 내용은 무시됨)

기존 _getMonteCarloTop6Help() 및 볼픽 9번 도움말 문자열은 변경하지 않는다.

완료 기준: analyze error 0, 홈 화면에서 시리얼+9 도움말 다이얼로그 열림·닫힘 크래시 없음(수동 G7 확인).
```

---

### STEP G-6 — 결과·내 번호 (Auto)

```
lib/offline/screens/offline_result_screen.dart, offline_my_numbers_screen.dart 검토:
- algorithmId 9 및 algorithmName 표시가 시리얼에서 깨지지 않는지.
- 필요 시 l10n으로 "만 번 뽑기" 대신 serialAlgorithm9Name 표시 분기.

위젯 테스트 최소 1건 추가 또는 기존 시리얼 테스트 보강.

완료 기준: 관련 flutter test PASS.
```

---

### STEP G-7 — 통합 마감 (Auto)

```
1. cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
2. flutter test
3. flutter analyze
4. 058 §5.6 수동 체크리스트 M1~M5 수행 후 결과 기록

완료 기준: 전체 테스트 PASS, analyze error 0, 수동 5항 전부 OK.
pubspec.yaml version 패치 레벨 +1 (팀 규칙에 따름) 및 변경 요약 한 단락.
```

---

## 부록 A — 문서·코드 추적

| 항목 | 값 |
|------|-----|
| 문서 경로 | `z_Dev_Docs/058_Annuity720_SerialDigitMonteCarlo_기획설계구현시험.md` |
| 선행 문서 | `056_PhaseF_Annuity720_기획설계구현시험.md` (F2-T04, F4-T05 등 **대체 예정** 명시) |

---

**문서 끝**
