# 052. PickWizard 게임 타입 확장 — 단계별 구현·시험 체크리스트

**문서 번호**: 052  
**작성일**: 2026-05-06  
**대상**: PickWizard 오프라인 앱 (Flutter)  
**목적**: 051 기획서의 Phase A~E를 실제로 구현·검증하기 위한 상세 설계, 구현 체크리스트, 시험 항목·결과 정의, 자동 시험 구현 계획  
**참조**: 051_GameType_Expansion_Plan.md

---

## 📋 목차

0. [시험 인프라 사전 설정](#0-시험-인프라-사전-설정)
1. [Phase A — 아키텍처 기반](#phase-a--아키텍처-기반)
2. [Phase B — 로또645 회귀 검증](#phase-b--로또645-회귀-검증)
3. [Phase C — 게임 타입별 생성 로직](#phase-c--게임-타입별-생성-로직)
4. [Phase D — UI 구현](#phase-d--ui-구현)
5. [Phase E — 다국어](#phase-e--다국어)
6. [자동 시험 파일 맵 및 실행 방법](#6-자동-시험-파일-맵-및-실행-방법)

---

## 0. 시험 인프라 사전 설정

### 0.1 디렉터리 구조 생성

```
pick_wizard/mobile_app/test/
  unit/
    game_type_test.dart                  ← Phase A
    generated_numbers_test.dart          ← Phase A
    hive_adapter_test.dart               ← Phase A
    local_lotto_service_test.dart        ← Phase B + C
  widget/
    offline_home_screen_test.dart        ← Phase D (홈)
    offline_result_screen_test.dart      ← Phase D (결과)
    offline_my_numbers_screen_test.dart  ← Phase D (내 번호)
  helpers/
    test_helpers.dart                    ← 공통 헬퍼
```

### 0.2 `pubspec.yaml` dev_dependencies 추가

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.8
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  retrofit_generator: ^8.1.0
  riverpod_generator: ^2.3.11
  hive_generator: ^2.0.1
  # ─ 추가 항목 ─
  mocktail: ^1.0.4            # Provider·서비스 모킹
  hive_test: ^1.0.1           # Hive 인메모리 테스트 지원
```

### 0.3 공통 헬퍼 (`test/helpers/test_helpers.dart`)

**설계 내용**

```dart
// 테스트용 Riverpod ProviderContainer 생성 (override 포함)
ProviderContainer makeContainer({List<Override> overrides = const []});

// GameType 기반 더미 GeneratedNumbers 생성
GeneratedNumbers makeGeneratedNumbers(GameType gt, {int nSets = 3});
```

**구현 체크리스트**

- [ ] `test/helpers/test_helpers.dart` 파일 생성
- [ ] `makeContainer()` 함수 구현 (ProviderContainer 래퍼)
- [ ] `makeGeneratedNumbers()` 함수 구현

### 0.4 사전 설정 완료 기준

- [ ] `flutter test` 실행 시 기존 `widget_test.dart` placeholder 통과
- [ ] `test/unit/`, `test/widget/`, `test/helpers/` 디렉터리 존재

---

## Phase A — 아키텍처 기반

### A1. `GameType` 모델 신규 생성

**파일**: `lib/core/models/game_type.dart`

#### 설계 상세

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | `GameTypeId` | 고유 열거값 |
| `mainMin` | `int` | 메인 볼 최솟값 |
| `mainMax` | `int` | 메인 볼 최댓값 |
| `mainCount` | `int` | 메인 볼 선택 수 |
| `bonusMin` | `int?` | 보너스 볼 최솟값 (null = 없음) |
| `bonusMax` | `int?` | 보너스 볼 최댓값 (null = 없음) |
| `bonusCount` | `int` | 보너스 볼 선택 수 (0 = 없음) |
| `bonusBallColorArgb` | `int` | 보너스 볼 배경색 ARGB (0 = 해당 없음) |
| `colorZoneBounds` | `List<int>` | 메인 볼 5구간 경계값 목록 (길이=5) |

| 메서드 | 반환 | 설명 |
|--------|------|------|
| `hasBonus` | `bool` | `bonusCount > 0` |
| `mainPoolSize` | `int` | `mainMax - mainMin + 1` |
| `bonusPoolSize` | `int?` | null 또는 `bonusMax! - bonusMin! + 1` |
| `colorZoneFor(int n)` | `int` | 번호 n의 색상 구간 인덱스 (0~4) |
| `fromId(GameTypeId id)` | `GameType` | 정적: id로 GameType 조회 |

#### 구현 체크리스트

- [ ] `enum GameTypeId { lotto645, powerball, megaMillions, winForLife }` 정의
- [ ] `class GameType` 정의 (const constructor, 모든 필드)
- [ ] `hasBonus`, `mainPoolSize`, `bonusPoolSize`, `colorZoneFor()` 구현
- [ ] `class GameTypes` 정의 — 4개 상수 (`lotto645`, `powerball`, `megaMillions`, `winForLife`)
- [ ] `GameTypes.all` (List), `GameTypes.fromId()` 구현
- [ ] `colorZoneBounds` 값 확인 (섹션 2.4 테이블과 일치 여부)

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 입력 | 기대 결과 | 방법 |
|---|-----------|------|-----------|------|
| A1-T01 | lotto645 mainMax | `GameTypes.lotto645.mainMax` | `45` | 자동 |
| A1-T02 | powerball mainCount | `GameTypes.powerball.mainCount` | `5` | 자동 |
| A1-T03 | powerball hasBonus | `GameTypes.powerball.hasBonus` | `true` | 자동 |
| A1-T04 | lotto645 hasBonus | `GameTypes.lotto645.hasBonus` | `false` | 자동 |
| A1-T05 | megaMillions bonusMax | `GameTypes.megaMillions.bonusMax` | `25` | 자동 |
| A1-T06 | winForLife bonusMax | `GameTypes.winForLife.bonusMax` | `18` | 자동 |
| A1-T07 | colorZoneFor 로또645 구간 경계 | `lotto645.colorZoneFor(1)` | `0` (노랑) | 자동 |
| A1-T08 | colorZoneFor 로또645 구간 경계 | `lotto645.colorZoneFor(10)` | `0` | 자동 |
| A1-T09 | colorZoneFor 로또645 구간 경계 | `lotto645.colorZoneFor(11)` | `1` (파랑) | 자동 |
| A1-T10 | colorZoneFor 로또645 구간 경계 | `lotto645.colorZoneFor(45)` | `4` (초록) | 자동 |
| A1-T11 | colorZoneFor 파워볼 구간 | `powerball.colorZoneFor(57)` | `4` (초록) | 자동 |
| A1-T12 | fromId 조회 | `GameTypes.fromId(GameTypeId.megaMillions)` | `GameTypes.megaMillions` | 자동 |
| A1-T13 | fromId 전체 순회 | 4개 id 모두 fromId 조회 | 각각 올바른 GameType 반환 | 자동 |
| A1-T14 | colorZoneBounds 길이 | 모든 GameType의 `colorZoneBounds.length` | `5` | 자동 |
| A1-T15 | colorZoneBounds 마지막 값 == mainMax | 모든 GameType | 일치 | 자동 |

**자동 시험 파일**: `test/unit/game_type_test.dart`

---

### A2. `LottoConstants` 의존 코드 리팩토링

**대상 파일**: `local_lotto_service.dart`, `offline_home_screen.dart`

#### 구현 체크리스트

- [ ] `local_lotto_service.dart` 최상단 하드코딩 상수 6개 (`_minNumber`, `_maxNumber`, `_numbersPerDraw`, `_maxExclude`, `_maxInclude`, `_monteCarloTrials`) 중 게임 타입 종속 상수 4개 제거 (`_monteCarloTrials`는 유지)
- [ ] `_hasInvalidOrDuplicate()` 함수에 min/max 파라미터 추가
- [ ] `getAvailableNumbers()` 함수에 `GameType` 파라미터 추가
- [ ] `offline_home_screen.dart` `_canGenerate()` 내 `poolSize = 45 - ...` 를 `gameType.mainMax - gameType.mainMin + 1 - ...` 로 교체
- [ ] `offline_home_screen.dart` `_parseNumberList()` 내 `max = 45` 를 `gameType.mainMax` 로 교체
- [ ] `LottoConstants` 클래스 파일 자체는 **그대로 유지** (삭제 금지, 하위 호환)

---

### A3. `GeneratedNumbers` 모델 변경

**파일**: `lib/data/models/generated_numbers.dart`

#### 설계 상세

추가 필드:

| 필드 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| `gameTypeId` | `GameTypeId` | `GameTypeId.lotto645` | 게임 타입 식별자 |
| `bonusBalls` | `List<int>` | `[]` | 세트별 보너스 볼 (길이 = nSets, 보너스 없으면 빈 리스트) |

변경 필드:

| 기존 | 변경 | 이유 |
|------|------|------|
| `results` (유지) | — | 기존 메인 볼 결과 목록 그대로 유지 |

> `results`의 필드명은 유지. `mainSets` 으로의 이름 변경은 불필요—기존 freezed 구조와 어댑터가 복잡해지므로, `bonusBalls` 추가만 진행한다.

#### 구현 체크리스트

- [ ] `GeneratedNumbers` freezed factory에 `gameTypeId` 필드 추가 (`@Default(GameTypeId.lotto645)`)
- [ ] `GeneratedNumbers` freezed factory에 `bonusBalls` 필드 추가 (`@Default([]) List<int>`)
- [ ] `build_runner` 재실행: `dart run build_runner build --delete-conflicting-outputs`
- [ ] 생성된 `generated_numbers.freezed.dart`, `generated_numbers.g.dart` 이상 없는지 확인

---

### A4. Hive 어댑터 재생성 + DB 초기화 마이그레이션

**파일**: `lib/data/data_sources/local/adapters/generated_numbers_adapter.dart`, `lib/data/data_sources/local/hive_database.dart`

#### 설계 상세 (마이그레이션 전략: 옵션 B — DB 초기화)

앱 업데이트로 어댑터 필드 순서가 바뀌므로 기존 저장 데이터 호환성이 깨진다.  
버전 체크를 통해 앱 첫 실행 시 DB를 초기화하고 사용자에게 경고 다이얼로그를 표시한다.

| 단계 | 처리 |
|------|------|
| 앱 시작 시 | SharedPreferences에서 `db_schema_version` 읽기 |
| 버전 < 2 이면 | `HiveDatabase.clearAll()` 호출 후 버전을 2로 저장 |
| 버전 == 2 이면 | 정상 진행 |
| 경고 다이얼로그 | "앱 업데이트로 저장된 번호가 초기화되었습니다. 죄송합니다." |

#### 구현 체크리스트

- [ ] `GeneratedNumbersAdapter.write()` 에 `gameTypeId` (int로 직렬화: `gameTypeId.index`), `bonusBalls` (List<int>) 쓰기 추가
- [ ] `GeneratedNumbersAdapter.read()` 에 `gameTypeId`, `bonusBalls` 읽기 추가
- [ ] `HiveDatabase` 에 `dbSchemaVersion = 2` 상수 추가
- [ ] `HiveDatabase.initialize()` 에 버전 체크 + 초기화 로직 추가
- [ ] `offline_splash_screen.dart` (또는 앱 초기화 지점)에 초기화 경고 다이얼로그 추가
- [ ] `HiveDatabase.clearAll()` 호출 후 `db_schema_version = 2` SharedPreferences에 저장

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 입력 | 기대 결과 | 방법 |
|---|-----------|------|-----------|------|
| A4-T01 | 어댑터 write/read 라운드트립 — lotto645 | lotto645 GeneratedNumbers, bonusBalls=[] | read 후 모든 필드 동일 | 자동 |
| A4-T02 | 어댑터 write/read 라운드트립 — powerball | powerball, bonusBalls=[18] | read 후 gameTypeId=powerball, bonusBalls=[18] | 자동 |
| A4-T03 | 어댑터 write/read 라운드트립 — 다중 세트 | megaMillions, 5세트, bonusBalls=[3,7,11,22,24] | read 후 bonusBalls 길이=5, 값 일치 | 자동 |
| A4-T04 | gameTypeId 직렬화 순서 | 4개 GameTypeId 모두 write→read | index 기반 역직렬화 정확 | 자동 |
| A4-T05 | DB 버전 체크 — 버전 없음 | SharedPreferences 비어있을 때 초기화 | `clearAll()` 호출됨, 버전=2 저장 | 자동(mock) |
| A4-T06 | DB 버전 체크 — 버전=2 | 버전 이미 2 | `clearAll()` 호출 안 됨 | 자동(mock) |

**자동 시험 파일**: `test/unit/hive_adapter_test.dart`

---

### A5–A6. Provider 신규 추가

**파일**: `lib/offline/providers/offline_providers.dart`

#### 구현 체크리스트

- [ ] `offlineSelectedGameTypeProvider = StateProvider<GameType>((ref) => GameTypes.lotto645)` 추가
- [ ] `offlineBonusIncludeNumberProvider = StateProvider<int?>((ref) => null)` 추가
- [ ] `offlineBonusExcludeNumbersProvider = StateProvider<List<int>>((ref) => [])` 추가
- [ ] `offlineAlgorithmsProvider` 내 description 문자열을 하드코딩("1~45 중 6개") 대신 gameType 기반으로 동적 생성하도록 수정 (`ref.watch(offlineSelectedGameTypeProvider)` 참조)
- [ ] `OfflineGenerateNotifier.generate()` 에서 `offlineSelectedGameTypeProvider`, `offlineBonusIncludeNumberProvider`, `offlineBonusExcludeNumbersProvider` 읽기 추가

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 입력 | 기대 결과 | 방법 |
|---|-----------|------|-----------|------|
| A6-T01 | 기본값 — gameType | 초기 상태 | `GameTypes.lotto645` | 자동 |
| A6-T02 | 기본값 — bonusInclude | 초기 상태 | `null` | 자동 |
| A6-T03 | 기본값 — bonusExclude | 초기 상태 | `[]` | 자동 |
| A6-T04 | gameType 변경 | powerball으로 변경 | `GameTypes.powerball` | 자동 |

**자동 시험 파일**: `test/unit/generated_numbers_test.dart` (Provider 초기값 포함)

---

## Phase B — 로또645 회귀 검증

> **목적**: Phase A 리팩토링 후 기존 로또6/45 동작이 완전히 보존됨을 보증.

### B1. `local_lotto_service.dart` — 기존 동작 회귀 시험

#### 시험 항목 및 기대 결과 (자동)

| # | 시험 항목 | 입력 | 기대 결과 |
|---|-----------|------|-----------|
| B-T01 | QuickPick 출력 개수 | gameType=lotto645, nSets=5 | results 길이=5 |
| B-T02 | QuickPick 번호 범위 | gameType=lotto645, nSets=10 | 모든 번호 1~45 이내 |
| B-T03 | QuickPick 세트 내 중복 없음 | nSets=50 | 각 세트 Set 변환 후 길이=6 |
| B-T04 | QuickPick 정렬 | nSets=5 | 각 세트 오름차순 정렬됨 |
| B-T05 | QuickPick 포함 번호 보장 | include=[7,13,22], nSets=5 | 모든 세트에 7,13,22 포함 |
| B-T06 | QuickPick 제외 번호 배제 | exclude=[1,2,3,4,5], nSets=10 | 모든 세트에 1~5 없음 |
| B-T07 | QuickPick 포함+제외 동시 | include=[5], exclude=[10..45] 35개 | 각 세트에 5 포함, 나머지 6~9에서 선택 |
| B-T08 | validateParameters — nSets 범위 초과 | nSets=101 | 예외 발생 |
| B-T09 | validateParameters — 포함 번호 초과 | include 7개 | 예외 발생 |
| B-T10 | validateParameters — 제외 번호 초과 | exclude 40개 | 예외 발생 |
| B-T11 | validateParameters — 포함/제외 겹침 | include=[5], exclude=[5] | 예외 발생 |
| B-T12 | validateParameters — 가용 번호 부족 | include=[], exclude 39개 (1~39) | 유효 (나머지 6개로 가능) |
| B-T13 | validateParameters — 가용 번호 0개 | exclude 39개 + include가 나머지 6개 모두 | 유효 (정확히 부족하지 않음) |
| B-T14 | MonteCarlo 출력 개수 | nSets=3 | results 길이=3 |
| B-T15 | MonteCarlo 번호 범위 | nSets=10 | 모든 번호 1~45 이내 |
| B-T16 | MonteCarlo 세트 내 중복 없음 | nSets=10 | 각 세트 Set 변환 후 길이=6 |
| B-T17 | MonteCarlo 포함 번호 보장 | include=[3,7] | 모든 세트에 3,7 포함 |

**자동 시험 파일**: `test/unit/local_lotto_service_test.dart` (lotto645 그룹)

### B2. 위젯 회귀 시험

#### 시험 항목 및 기대 결과 (자동)

| # | 시험 항목 | 기대 결과 |
|---|-----------|-----------|
| B-W01 | 앱 기동 후 홈 화면 렌더링 | 오류 없이 화면 표시 |
| B-W02 | 알고리즘 선택 안 하고 생성 버튼 | 스낵바 메시지 표시 |
| B-W03 | 알고리즘 1 선택 후 생성 | 결과 화면 이동 |
| B-W04 | 결과 화면 번호 6개 표시 | 6개 LottoBall 위젯 존재 |

**자동 시험 파일**: `test/widget/offline_home_screen_test.dart` (regression 그룹)

---

## Phase C — 게임 타입별 생성 로직

### C1–C3. `local_lotto_service.dart` 확장

#### 설계 상세

**함수 시그니처 (최종)**

```dart
GeneratedNumbers generateQuickPick({
  required GameType gameType,
  required int nSets,
  List<int>? excludeNumbers,
  List<int>? includeNumbers,
  int? bonusIncludeNumber,         // 보너스 볼 고정값 (null = 랜덤)
  List<int>? bonusExcludeNumbers,  // 보너스 볼 제외 목록
});

GeneratedNumbers generateMonteCarloTop({
  required GameType gameType,
  required int nSets,
  List<int>? excludeNumbers,
  List<int>? includeNumbers,
  int? bonusIncludeNumber,
  List<int>? bonusExcludeNumbers,
});
```

**보너스 볼 생성 규칙**

```
보너스 볼이 있는 게임 (gameType.hasBonus == true):
  - bonusPool = [bonusMin..bonusMax] - bonusExcludeNumbers
  - bonusIncludeNumber != null 이면 → 고정 사용
  - bonusIncludeNumber == null 이면 → bonusPool에서 랜덤 1개
  - 세트마다 독립 랜덤 (각 세트 보너스 볼이 달라도 됨)

보너스 볼이 없는 게임 (hasBonus == false):
  - bonusIncludeNumber, bonusExcludeNumbers 무시
  - GeneratedNumbers.bonusBalls = []
```

**검증 규칙 (`validateParameters` 확장)**

```
메인 볼:
  - nSets: 1~100
  - includeNumbers: 0~mainCount개, mainMin~mainMax 범위
  - excludeNumbers: 0~(mainMax-mainMin+1-mainCount)개, mainMin~mainMax 범위
  - include ∩ exclude = ∅

보너스 볼 (hasBonus == true인 경우만):
  - bonusIncludeNumber: null 또는 bonusMin~bonusMax 이내
  - bonusIncludeNumber가 bonusExcludeNumbers 안에 있으면 오류
  - bonusExcludeNumbers 후 가용 보너스 풀 >= 1개
```

#### 구현 체크리스트

- [ ] 함수 시그니처에 `GameType gameType`, `bonusIncludeNumber`, `bonusExcludeNumbers` 파라미터 추가
- [ ] 기존 로또645 로직을 `gameType` 기반으로 변환 (min/max/count 하드코딩 제거)
- [ ] 보너스 볼 생성 로직 추가 (`_generateBonusBall()` 내부 함수)
- [ ] `generateMonteCarloTop6` 함수명을 `generateMonteCarloTop`으로 변경 (6이 하드코딩 의미 제거)
- [ ] `validateParameters` 확장 — 보너스 볼 관련 검증 추가
- [ ] 반환 타입을 `List<List<int>>` → `GeneratedNumbers`로 변경
- [ ] `OfflineGenerateNotifier.generate()` 의 호출부를 새 시그니처에 맞게 수정
- [ ] `OfflineGenerateNotifier.generate()` 에서 `bonusBalls` 값을 `GeneratedNumbers` 에 설정

#### 시험 항목 및 기대 결과

**파워볼 (5+1, mainMax=69, bonusMax=26)**

| # | 시험 항목 | 입력 | 기대 결과 |
|---|-----------|------|-----------|
| C-T01 | QuickPick 메인 볼 범위 | powerball, nSets=10 | 모든 메인 번호 1~69 |
| C-T02 | QuickPick 메인 볼 개수 | powerball, nSets=5 | 각 세트 정확히 5개 |
| C-T03 | QuickPick 보너스 볼 범위 | powerball, nSets=20 | 모든 bonusBalls 원소 1~26 |
| C-T04 | QuickPick bonusBalls 길이 | powerball, nSets=7 | bonusBalls.length=7 |
| C-T05 | QuickPick 보너스 볼 고정 | bonusIncludeNumber=15 | 모든 세트 bonusBalls[i]=15 |
| C-T06 | QuickPick 보너스 볼 제외 | bonusExcludeNumbers=[1..25] | 모든 bonusBalls[i]=26 |
| C-T07 | QuickPick 보너스 풀 부족 오류 | bonusExcludeNumbers=[1..26] | 예외 발생 |
| C-T08 | MonteCarlo 메인 볼 범위 | powerball, nSets=5 | 모든 메인 번호 1~69 |
| C-T09 | MonteCarlo 보너스 볼 범위 | powerball, nSets=5 | 모든 bonusBalls 1~26 |

**메가밀리언 (5+1, mainMax=70, bonusMax=25)**

| # | 시험 항목 | 입력 | 기대 결과 |
|---|-----------|------|-----------|
| C-T10 | QuickPick 메인 볼 범위 | megaMillions, nSets=10 | 모든 메인 번호 1~70 |
| C-T11 | QuickPick 보너스 볼 범위 | megaMillions, nSets=10 | 모든 bonusBalls 1~25 |

**Win for Life (5+1, mainMax=48, bonusMax=18)**

| # | 시험 항목 | 입력 | 기대 결과 |
|---|-----------|------|-----------|
| C-T12 | QuickPick 메인 볼 범위 | winForLife, nSets=10 | 모든 메인 번호 1~48 |
| C-T13 | QuickPick 보너스 볼 범위 | winForLife, nSets=10 | 모든 bonusBalls 1~18 |

**로또645 보너스 없음 보장**

| # | 시험 항목 | 입력 | 기대 결과 |
|---|-----------|------|-----------|
| C-T14 | lotto645 bonusBalls 빈 리스트 | lotto645, nSets=5 | bonusBalls=[] |
| C-T15 | lotto645 메인 볼 개수 유지 | lotto645, nSets=5 | 각 세트 6개 |

**자동 시험 파일**: `test/unit/local_lotto_service_test.dart` (gameType 그룹 추가)

---

## Phase D — UI 구현

> **시험 방법 분류**  
> `자동`: `flutter test` 에서 실행하는 위젯 테스트  
> `수동`: 실기기/에뮬레이터에서 직접 확인

### D1. 홈 화면 — 게임 선택 드롭다운

#### 구현 체크리스트

- [ ] 기존 언어 선택 카드 위에 새 카드 or 언어 선택 카드를 합쳐 "게임·언어 선택 카드" 로 재구성
- [ ] `DropdownButton<GameType>` 위젯 추가 (게임 선택)
- [ ] 드롭다운 항목: `GameTypes.all` 목록 순서대로 (lotto645, powerball, megaMillions, winForLife)
- [ ] 항목 레이블: 국기 이모지 + 현재 언어 기준 게임 이름 (`l10n.gameLotto645` 등)
- [ ] 선택 시 `offlineSelectedGameTypeProvider` 업데이트
- [ ] 선택 시 포함/제외 번호 초기화 + 스낵바 표시 (D6와 연동)

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 기대 결과 | 방법 |
|---|-----------|-----------|------|
| D1-T01 | 홈 화면에 게임 드롭다운 표시 | `DropdownButton` 위젯 존재 | 자동 |
| D1-T02 | 기본 선택값 | "로또 6/45" 표시 | 자동 |
| D1-T03 | 드롭다운 열면 4개 항목 표시 | 항목 4개 찾힘 | 자동 |
| D1-T04 | 파워볼 선택 시 Provider 업데이트 | `offlineSelectedGameTypeProvider` = powerball | 자동 |
| D1-T05 | 게임 변경 시 스낵바 표시 | 스낵바에 초기화 메시지 존재 | 자동 |
| D1-T06 | 게임 변경 시 포함/제외 번호 초기화 | include=[], exclude=[] | 자동 |

### D2. 홈 화면 — 언어 선택 드롭다운

#### 구현 체크리스트

- [ ] 기존 ChoiceChip 목록 (`_buildLanguageSelector()`) 을 `DropdownButton<Locale>` 로 교체
- [ ] 항목 레이블: `SupportedLocales.getLanguageFlag()` + `getLanguageName()`
- [ ] 선택 시 `localeProvider` + `saveLocale()` 기존 로직 유지

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 기대 결과 | 방법 |
|---|-----------|-----------|------|
| D2-T01 | 언어 드롭다운 위젯 존재 | `DropdownButton` 2개 중 언어용 찾힘 | 자동 |
| D2-T02 | 기본 선택값 | 시스템 기본 언어 또는 저장값 | 수동 |
| D2-T03 | 언어 변경 시 화면 문자열 즉시 변경 | 앱 전체 텍스트 변경 | 수동 |

### D3. 게임 타입·언어 SharedPreferences 저장/복원

#### 구현 체크리스트

- [ ] `game_preferences.dart` 신규 파일 또는 `locale_preferences.dart` 확장
- [ ] `saveGameType(GameTypeId id)` 구현 — `prefs.setString('game_type', id.name)`
- [ ] `loadGameType()` 구현 — 저장값 없으면 `GameTypeId.lotto645` 반환
- [ ] 앱 시작 시 (`OfflineHomeScreen` initState 또는 provider 초기화) 저장값으로 provider 초기화
- [ ] 기존 `saveLocale()`, `loadLocale()` 패턴과 동일 방식으로 구현

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 기대 결과 | 방법 |
|---|-----------|-----------|------|
| D3-T01 | 게임 선택 후 앱 재시작 | 이전 선택값 유지 | 수동 |
| D3-T02 | 저장값 없을 때 기본값 | lotto645 표시 | 수동 |

### D4. 옵션 모달 — 메인 볼 범위 동적 표시

#### 구현 체크리스트

- [ ] `_parseNumberList()` 내 `max = 45` → `gameType.mainMax` 로 교체
- [ ] `includeNumbersHint` 텍스트에 `l10n.mainNumberRange(min: gt.mainMin, max: gt.mainMax)` 동적 삽입
- [ ] 포함 번호 최대 개수: `gt.mainCount`
- [ ] 제외 번호 최대 개수: `gt.mainMax - gt.mainMin + 1 - gt.mainCount`

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 기대 결과 | 방법 |
|---|-----------|-----------|------|
| D4-T01 | 파워볼 선택 후 모달 오픈 — 힌트 텍스트 | "1~69" 포함 텍스트 | 자동 |
| D4-T02 | 메가밀리언 선택 후 모달 오픈 — 힌트 텍스트 | "1~70" 포함 텍스트 | 자동 |
| D4-T03 | Win for Life 선택 후 — 포함 번호 최대 | 5개 초과 입력 시 6번째 무시 | 자동 |

### D5. 옵션 모달 — 보너스 볼 포함/제외 섹션

#### 구현 체크리스트

- [ ] 5+1 게임 타입 선택 시 모달 하단에 `── 보너스 볼 ──` 섹션 조건부 표시 (`gameType.hasBonus == true`)
- [ ] "포함할 {name} 번호" 텍스트 필드 (최대 1개, 범위 `bonusMin~bonusMax`)
- [ ] "제외할 {name} 번호" 텍스트 필드 (최대 `bonusMax-1`개, 범위 `bonusMin~bonusMax`)
- [ ] 포함 번호 입력 시 `offlineBonusIncludeNumberProvider` 업데이트
- [ ] 제외 번호 입력 시 `offlineBonusExcludeNumbersProvider` 업데이트
- [ ] 보너스 풀 부족 시 (제외 후 0개) 확인 버튼 비활성화

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 기대 결과 | 방법 |
|---|-----------|-----------|------|
| D5-T01 | lotto645 모달 — 보너스 섹션 숨김 | 보너스 섹션 없음 | 자동 |
| D5-T02 | 파워볼 모달 — 보너스 섹션 표시 | "파워볼" 라벨 포함 섹션 존재 | 자동 |
| D5-T03 | 보너스 번호 26 이상 입력 무시 (파워볼) | Provider 값 변경 없음 | 자동 |
| D5-T04 | 보너스 제외 전체 입력 후 확인 버튼 | 버튼 비활성화 | 자동 |
| D5-T05 | 보너스 포함 1개 + 제외 1개 겹침 | 검증 오류 표시 | 수동 |

### D6. 게임 타입 변경 시 포함/제외 초기화

#### 구현 체크리스트

- [ ] 드롭다운 `onChanged` 핸들러에서 이전 게임과 다른 게임으로 변경되는 경우에만 초기화
- [ ] `offlineIncludeNumbersProvider` → `[]` 로 reset
- [ ] `offlineExcludeNumbersProvider` → `[]` 로 reset
- [ ] `offlineBonusIncludeNumberProvider` → `null` 로 reset
- [ ] `offlineBonusExcludeNumbersProvider` → `[]` 로 reset
- [ ] `offlineSelectedGameTypeProvider` 업데이트
- [ ] 스낵바: `l10n.gameTypeChangedClearNumbers` 표시

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 기대 결과 | 방법 |
|---|-----------|-----------|------|
| D6-T01 | 같은 게임 재선택 | 초기화 없음, 스낵바 없음 | 자동 |
| D6-T02 | 다른 게임으로 변경 | include/exclude=[], 스낵바 표시 | 자동 |

### D7. `LottoBall` 위젯 업데이트

**파일**: `lib/presentation/widgets/lotto_ball.dart`

#### 구현 체크리스트

- [ ] 생성자에 `GameType? gameType` 파라미터 추가 (null 이면 lotto645 기본 동작)
- [ ] 생성자에 `bool isBonus = false` 파라미터 추가
- [ ] `isBonus == true` 이면 → `gameType.bonusBallColorArgb` 를 배경색으로 사용
- [ ] `isBonus == false` 이면 → `gameType.colorZoneFor(number)` 로 구간 결정, 기존 색상 테이블 적용
- [ ] 기존 `LottoConstants.isYellow()` 등의 호출을 `colorZoneFor()` 기반으로 교체
- [ ] 기존 호출부 (`offline_result_screen.dart`, `offline_my_numbers_screen.dart`)에서 `gameType` 파라미터 추가

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 기대 결과 | 방법 |
|---|-----------|-----------|------|
| D7-T01 | lotto645, 번호=10 → 노란색 | `colorZone=0` → 노란 배경색 | 자동 |
| D7-T02 | lotto645, 번호=11 → 파란색 | `colorZone=1` → 파란 배경색 | 자동 |
| D7-T03 | powerball, 번호=57 → 초록색 | `colorZone=4` → 초록 배경색 | 자동 |
| D7-T04 | powerball isBonus=true → 빨간 배경 | `bonusBallColorArgb` 적용 | 자동 |
| D7-T05 | winForLife isBonus=true → 노란 배경 | `bonusBallColorArgb` 적용 | 자동 |
| D7-T06 | 위젯 렌더링 오류 없음 (모든 조합) | 예외 없이 렌더링 | 자동 |

**자동 시험 파일**: `test/widget/lotto_ball_test.dart` (신규)

### D8. 결과 화면 — 5+1 분리 표시

**파일**: `lib/offline/screens/offline_result_screen.dart`

#### 구현 체크리스트

- [ ] `GeneratedNumbers.gameTypeId` 기반으로 보너스 볼 표시 여부 결정
- [ ] 메인 볼 5개 표시 후 `+` 텍스트 또는 `Icon` 삽입
- [ ] 보너스 볼 `LottoBall(isBonus: true, gameType: gt)` 로 표시
- [ ] `bonusBalls` 가 비어있으면 (lotto645) 기존과 동일하게 6개 메인 볼만 표시

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 기대 결과 | 방법 |
|---|-----------|-----------|------|
| D8-T01 | lotto645 결과 화면 — 볼 6개 | 6개 LottoBall, 보너스 없음 | 자동 |
| D8-T02 | powerball 결과 화면 — 볼 5+1 | 5개 메인 + `+` 구분자 + 1개 보너스 | 자동 |
| D8-T03 | 보너스 볼 색상 구분 | 보너스 LottoBall 배경색 = 빨간색 | 수동 |
| D8-T04 | 세트별 보너스 볼 다름 | 각 세트 보너스 볼 값 독립적 | 수동 |

**자동 시험 파일**: `test/widget/offline_result_screen_test.dart`

### D9–D10. 내 번호 화면 — 배지 + 필터

**파일**: `lib/offline/screens/offline_my_numbers_screen.dart`

#### 구현 체크리스트

- [ ] 번호 카드에 게임 타입 배지 추가 (`Chip` 또는 `Container` 라벨)
- [ ] 배지 텍스트: `l10n.gameLotto645` 등 현재 언어 기준 게임명
- [ ] 필터 드롭다운 추가 (항목: 전체 + 4개 게임)
- [ ] 필터 드롭다운 선택값: `_selectedFilter` 로컬 상태 (`StatefulWidget`)
- [ ] `offlineSavedNumbersProvider` 목록을 `_selectedFilter` 기준으로 필터링하여 표시
- [ ] 필터값 "전체" 이면 전체 표시, 특정 게임 이면 해당 `gameTypeId` 만 표시

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 기대 결과 | 방법 |
|---|-----------|-----------|------|
| D9-T01 | 저장된 번호에 게임 타입 배지 표시 | 각 카드에 게임명 라벨 존재 | 자동 |
| D10-T01 | 필터 드롭다운 위젯 존재 | DropdownButton 찾힘 | 자동 |
| D10-T02 | 필터 "파워볼" 선택 시 다른 게임 숨김 | lotto645 카드 사라짐 | 자동 |
| D10-T03 | 필터 "전체" 선택 시 전체 표시 | 모든 카드 표시 | 자동 |
| D10-T04 | 빈 필터 결과 시 안내 문구 | "저장된 번호가 없습니다" 또는 유사 | 수동 |

**자동 시험 파일**: `test/widget/offline_my_numbers_screen_test.dart`

### D11. `_canGenerate()` 보너스 볼 풀 부족 체크

#### 구현 체크리스트

- [ ] `_canGenerate()` 에 보너스 볼 풀 부족 체크 추가
- [ ] `gameType.hasBonus == true` 이고 `bonusPool.length < 1` 이면 `false` 반환

#### 시험 항목 및 기대 결과

| # | 시험 항목 | 기대 결과 | 방법 |
|---|-----------|-----------|------|
| D11-T01 | 보너스 제외 전부 — 생성 버튼 비활성화 | `ElevatedButton` 회색 | 자동 |
| D11-T02 | 보너스 제외 일부 — 생성 버튼 활성화 | `ElevatedButton` 활성색 | 자동 |

---

## Phase E — 다국어

### E1. ARB 파일 키 추가

#### 구현 체크리스트 (6개 파일 × 18개 키)

> 파일: `lib/core/localization/` 내 `app_ko.arb`, `app_en.arb`, `app_ja.arb`, `app_zh.arb`, `app_th.arb`, `app_vi.arb`

**한국어(`app_ko.arb`) 추가 키 목록**

- [ ] `"selectGame": "게임 선택"`
- [ ] `"gameLotto645": "로또 6/45"`
- [ ] `"gamePowerball": "파워볼"`
- [ ] `"gameMegaMillions": "메가밀리언"`
- [ ] `"gameWinForLife": "Win for Life"`
- [ ] `"bonusBallLabel": "보너스 볼"`
- [ ] `"bonusBallNamePowerball": "파워볼 (빨간 공)"`
- [ ] `"bonusBallNameMegaBall": "메가볼 (금색 공)"`
- [ ] `"bonusBallNameLuckyBall": "럭키볼 (노란 공)"`
- [ ] `"mainNumbers": "메인 번호"`
- [ ] `"bonusBallSection": "보너스 볼 ({name})"` (플레이스홀더 `name` 포함)
- [ ] `"includeBonusNumbersLabel": "포함할 {name} 번호"`
- [ ] `"excludeBonusNumbersLabel": "제외할 {name} 번호"`
- [ ] `"includeBonusHint": "1~{max}, 최대 1개"`
- [ ] `"excludeBonusHint": "1~{max}, 최대 {limit}개"`
- [ ] `"mainNumberRange": "메인 번호 범위: {min}~{max}"`
- [ ] `"bonusNumberRange": "보너스 번호 범위: 1~{max}"`
- [ ] `"filterAll": "전체"`
- [ ] `"gameTypeChangedClearNumbers": "게임 변경으로 포함/제외 번호가 초기화되었습니다"`

**영어(`app_en.arb`) — 동일 키 영문 번역**

- [ ] 위 19개 키 영문으로 추가

**일본어·중국어·태국어·베트남어** — 각각:

- [ ] `app_ja.arb`: 위 19개 키 일본어 번역 추가
- [ ] `app_zh.arb`: 위 19개 키 중국어(간체) 번역 추가
- [ ] `app_th.arb`: 위 19개 키 태국어 번역 추가
- [ ] `app_vi.arb`: 위 19개 키 베트남어 번역 추가

> 번역은 DeepL/ChatGPT 활용 후 검수. 기계 번역 표시(미검수) 주석 달아둘 것.

### E2. 코드 생성 재실행

- [ ] `flutter gen-l10n` 실행
- [ ] `lib/core/localization/generated/app_localizations*.dart` 파일 생성 확인
- [ ] 새 키가 `AppLocalizations` 클래스에 생성됐는지 확인
- [ ] 플레이스홀더 키 (`{name}`, `{max}`, `{limit}`, `{min}`) 파라미터 메서드로 생성됐는지 확인

### E3. 기존 ARB 불필요 키 정리 (선택)

- [ ] 기존 ARB에 남은 `powerball`, `megaBall`, `luckyBall` 단독 키(중복 위험) 제거 여부 검토
- [ ] `flutter gen-l10n` 재실행 후 빌드 오류 없음 확인

### E 시험 항목

| # | 시험 항목 | 기대 결과 | 방법 |
|---|-----------|-----------|------|
| E-T01 | `flutter gen-l10n` 성공 | 오류 없이 완료 | 자동(빌드) |
| E-T02 | `flutter analyze` 오류 없음 | 0 오류 | 자동 |
| E-T03 | 한국어 — 게임 드롭다운 표시 | "로또 6/45", "파워볼" 등 한글 표시 | 수동 |
| E-T04 | 영어 — 게임 드롭다운 표시 | "Lotto 6/45", "Powerball" 등 영문 표시 | 수동 |
| E-T05 | 파워볼 보너스 섹션 레이블 | "보너스 볼 (파워볼 (빨간 공))" 형태 | 수동 |
| E-T06 | ARB 플레이스홀더 메서드 — 파라미터 올바름 | `l10n.mainNumberRange(min: 1, max: 69)` 호출 가능 | 자동(컴파일) |

---

## 6. 자동 시험 파일 맵 및 실행 방법

### 6.1 자동 시험 파일 전체 목록

| 파일 | 커버 범위 | 예상 테스트 수 |
|------|-----------|--------------|
| `test/unit/game_type_test.dart` | A1 (GameType 모델) | 15개 |
| `test/unit/generated_numbers_test.dart` | A3, A5~A6 (모델·Provider) | 10개 |
| `test/unit/hive_adapter_test.dart` | A4 (어댑터 직렬화) | 6개 |
| `test/unit/local_lotto_service_test.dart` | B1, C1~C3 (로직) | 35개 |
| `test/widget/lotto_ball_test.dart` | D7 (볼 위젯) | 6개 |
| `test/widget/offline_home_screen_test.dart` | B2, D1~D2, D4~D6, D11 | 20개 |
| `test/widget/offline_result_screen_test.dart` | D8 (결과 화면) | 4개 |
| `test/widget/offline_my_numbers_screen_test.dart` | D9~D10 (내 번호) | 5개 |

**합계 예상**: 약 101개 자동 테스트

### 6.2 시험 실행 명령

```powershell
# 전체 테스트 실행
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter test

# 특정 파일만 실행
flutter test test/unit/local_lotto_service_test.dart

# 특정 그룹만 실행 (group 이름 기준)
flutter test --name "GameType"

# 커버리지 포함
flutter test --coverage
# 결과: coverage/lcov.info 생성
```

### 6.3 자동 시험 설계 — 핵심 파일 스켈레톤

#### `test/unit/game_type_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_wizard/core/models/game_type.dart';

void main() {
  group('GameType 모델', () {
    test('lotto645 mainMax == 45', () {
      expect(GameTypes.lotto645.mainMax, 45);
    });
    test('lotto645 hasBonus == false', () {
      expect(GameTypes.lotto645.hasBonus, isFalse);
    });
    test('powerball hasBonus == true', () {
      expect(GameTypes.powerball.hasBonus, isTrue);
    });
    test('colorZoneBounds 길이 == 5 (모든 타입)', () {
      for (final gt in GameTypes.all) {
        expect(gt.colorZoneBounds.length, 5,
            reason: '${gt.id} colorZoneBounds 길이');
      }
    });
    test('colorZoneBounds 마지막 값 == mainMax (모든 타입)', () {
      for (final gt in GameTypes.all) {
        expect(gt.colorZoneBounds.last, gt.mainMax,
            reason: '${gt.id} colorZoneBounds 마지막');
      }
    });
    test('lotto645 colorZoneFor — 경계 값', () {
      final gt = GameTypes.lotto645;
      expect(gt.colorZoneFor(1), 0);   // 노랑
      expect(gt.colorZoneFor(10), 0);
      expect(gt.colorZoneFor(11), 1);  // 파랑
      expect(gt.colorZoneFor(45), 4);  // 초록
    });
    test('powerball colorZoneFor(57) == 4 (초록)', () {
      expect(GameTypes.powerball.colorZoneFor(57), 4);
    });
    test('fromId 전체 순회', () {
      for (final id in GameTypeId.values) {
        expect(GameTypes.fromId(id).id, id);
      }
    });
  });
}
```

#### `test/unit/local_lotto_service_test.dart` (핵심 케이스)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/offline/services/local_lotto_service.dart';

void main() {
  group('로또645 회귀', () {
    test('QuickPick 세트 수', () {
      final result = generateQuickPick(gameType: GameTypes.lotto645, nSets: 5);
      expect(result.results.length, 5);
    });
    test('QuickPick 번호 범위 1~45', () {
      final result = generateQuickPick(gameType: GameTypes.lotto645, nSets: 20);
      for (final r in result.results) {
        for (final n in r.numbers) {
          expect(n, inInclusiveRange(1, 45));
        }
      }
    });
    test('QuickPick 세트 내 중복 없음', () {
      final result = generateQuickPick(gameType: GameTypes.lotto645, nSets: 50);
      for (final r in result.results) {
        expect(r.numbers.toSet().length, 6);
      }
    });
    test('QuickPick bonusBalls 비어있음', () {
      final result = generateQuickPick(gameType: GameTypes.lotto645, nSets: 5);
      expect(result.bonusBalls, isEmpty);
    });
    // ... 추가 케이스
  });

  group('파워볼 5+1 로직', () {
    test('메인 볼 5개 범위 1~69', () {
      final result = generateQuickPick(gameType: GameTypes.powerball, nSets: 10);
      for (final r in result.results) {
        expect(r.numbers.length, 5);
        for (final n in r.numbers) {
          expect(n, inInclusiveRange(1, 69));
        }
      }
    });
    test('보너스 볼 범위 1~26', () {
      final result = generateQuickPick(gameType: GameTypes.powerball, nSets: 10);
      expect(result.bonusBalls.length, 10);
      for (final b in result.bonusBalls) {
        expect(b, inInclusiveRange(1, 26));
      }
    });
    test('보너스 볼 고정', () {
      final result = generateQuickPick(
        gameType: GameTypes.powerball, nSets: 5,
        bonusIncludeNumber: 15,
      );
      expect(result.bonusBalls, everyElement(15));
    });
  });
}
```

#### `test/unit/hive_adapter_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:pick_wizard/data/data_sources/local/adapters/generated_numbers_adapter.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
    Hive.registerAdapter(GeneratedNumbersAdapter());
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  group('Hive 어댑터 라운드트립', () {
    test('lotto645 write → read', () async {
      final box = await Hive.openBox<GeneratedNumbers>('test_box');
      final original = GeneratedNumbers(
        gameTypeId: GameTypeId.lotto645,
        algorithmId: 1,
        algorithmName: '자동선택',
        results: [NumberSetResult(setNo: 1, numbers: [1,2,3,4,5,6])],
        bonusBalls: [],
        timestamp: DateTime(2026, 5, 6),
        cost: 0,
        isSaved: true,
        id: 'test-id',
      );
      await box.put('k', original);
      final loaded = box.get('k')!;
      expect(loaded.gameTypeId, GameTypeId.lotto645);
      expect(loaded.bonusBalls, isEmpty);
      expect(loaded.results[0].numbers, [1,2,3,4,5,6]);
    });

    test('powerball write → read (bonusBalls 보존)', () async {
      final box = await Hive.openBox<GeneratedNumbers>('test_box2');
      final original = GeneratedNumbers(
        gameTypeId: GameTypeId.powerball,
        algorithmId: 1,
        algorithmName: '자동선택',
        results: [NumberSetResult(setNo: 1, numbers: [7,15,32,50,68])],
        bonusBalls: [18],
        timestamp: DateTime(2026, 5, 6),
        cost: 0, isSaved: true, id: 'test-id-2',
      );
      await box.put('k', original);
      final loaded = box.get('k')!;
      expect(loaded.gameTypeId, GameTypeId.powerball);
      expect(loaded.bonusBalls, [18]);
    });
  });
}
```

### 6.4 수동 시험 시나리오 목록

> 에뮬레이터 또는 실기기에서 수행. 체크리스트 형식으로 관리.

**홈 화면**

- [ ] 게임 드롭다운 열면 4개 항목 국기+이름 표시
- [ ] 파워볼 선택 → 스낵바 "포함/제외 번호 초기화" 표시
- [ ] Win for Life 선택 → 알고리즘 선택 후 모달에 "럭키볼" 섹션 표시
- [ ] 언어 드롭다운 변경 → 즉시 게임 이름도 해당 언어로 변경
- [ ] 앱 종료 후 재시작 → 이전 게임 타입·언어 복원

**번호 생성 (파워볼)**

- [ ] 파워볼 QuickPick 생성 → 결과 화면에 메인 5개 + `+` + 빨간 공 1개
- [ ] 파워볼 보너스 볼 고정(번호=10) 후 5세트 생성 → 모든 세트 보너스=10
- [ ] 보너스 볼 전부 제외 → 생성 버튼 비활성화

**결과 화면**

- [ ] 메가밀리언 결과 — 메인 볼 색상이 범위별 구간 색상, 메가볼은 금색
- [ ] "내 번호로 저장" → 내 번호 화면에서 "[메가밀리언]" 배지 표시

**내 번호 화면**

- [ ] 필터 "파워볼" → 파워볼 저장 번호만 표시
- [ ] 필터 "전체" → 모든 번호 표시
- [ ] 파워볼 번호 카드에 메인 5개 + 보너스 볼 올바르게 표시

**DB 초기화 시나리오 (업데이트 모사)**

- [ ] SharedPreferences에서 `db_schema_version` 삭제 후 앱 재시작 → 경고 다이얼로그 표시, 내 번호 전체 삭제됨
- [ ] 버전=2 유지 상태 재시작 → 경고 다이얼로그 없음

---

## 부록. Phase별 작업 완료 기준 (Definition of Done)

| Phase | 완료 기준 |
|-------|-----------|
| A | 모든 자동 시험 통과 (`flutter test test/unit/`) + `flutter analyze` 0 오류 |
| B | `test/unit/local_lotto_service_test.dart` lotto645 그룹 전체 통과 + `test/widget/offline_home_screen_test.dart` regression 그룹 통과 |
| C | `test/unit/local_lotto_service_test.dart` gameType 그룹 전체 통과 |
| D | `flutter test test/widget/` 전체 통과 + 수동 시험 시나리오 전 항목 체크 |
| E | `flutter gen-l10n` 성공 + `flutter analyze` 0 오류 + 한·영 수동 시험 통과 |
| 전체 | `flutter test` 101개+ 통과 + 수동 시험 전 항목 체크 |
