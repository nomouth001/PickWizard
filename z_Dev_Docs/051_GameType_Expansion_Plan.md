# 051. PickWizard 게임 타입 확장 기획서

**문서 번호**: 051  
**작성일**: 2026-05-06  
**최종 수정**: 2026-05-06 (결정사항 확정 반영)  
**대상**: PickWizard 오프라인 앱  
**목적**: 현재 로또6/45 단일 게임에서 파워볼, 메가밀리언, Win for Life를 추가 지원하는 방향의 아키텍처 설계 및 구현 계획 (연금복권720+는 Phase F로 분리)

---

## 📋 목차

1. [배경 및 목적](#1-배경-및-목적)
2. [지원 게임 타입 정의](#2-지원-게임-타입-정의)
3. [아키텍처 변경 계획](#3-아키텍처-변경-계획)
4. [화면 및 UX 변경](#4-화면-및-ux-변경)
5. [다국어 처리](#5-다국어-처리)
6. [구현 단계 계획](#6-구현-단계-계획)
7. [확정 결정 사항](#7-확정-결정-사항)
8. [관련 문서](#8-관련-문서)

---

## 1. 배경 및 목적

현재 PickWizard는 **한국 로또6/45** 한 종만 지원한다. 번호 범위(1~45)와 선택 개수(6개)가 전체 코드에 하드코딩되어 있어 다른 게임을 추가하려면 로직·상수·UI 전반을 수정해야 하는 구조다.

이 문서는 게임 타입을 추상화하여 **볼 픽(ball pick) 방식 3종을 추가**하는 설계와 구현 계획을 정의한다.  
이 확장이 완료되면 방향 2(과거 당첨번호 다운로드 + 통계 알고리즘)를 게임 타입별로 올바르게 붙일 수 있는 기반이 된다.

연금복권720+는 시리얼 번호 형식으로 볼 픽 방식과 구조가 다르므로 **Phase F(별도 단계)** 로 분리한다.

---

## 2. 지원 게임 타입 정의

### 2.1 게임 목록

| ID | 이름 | 주 시장 | 형식 | 이번 단계 |
|----|------|---------|------|-----------|
| `lotto645` | 로또 6/45 | 한국 🇰🇷 | 1~45 중 6개 | 현재 구현 |
| `powerball` | 파워볼 (Powerball) | 미국 🇺🇸 | 1~69 중 5개 + 파워볼 1~26 중 1개 | Phase A~E |
| `megaMillions` | 메가밀리언 (Mega Millions) | 미국 🇺🇸 | 1~70 중 5개 + 메가볼 1~25 중 1개 | Phase A~E |
| `winForLife` | Win for Life (Lucky for Life) | 미국 🇺🇸 | 1~48 중 5개 + 럭키볼 1~18 중 1개 | Phase A~E |
| `annuity720` | 연금복권720+ | 한국 🇰🇷 | 조(1~5) + 6자리(각 0~9) | **Phase F (별도)** |

### 2.2 게임별 상세 규칙

#### 로또6/45 (현행)

| 항목 | 값 |
|------|-----|
| 메인 풀 | 1 ~ 45 |
| 메인 선택 개수 | 6 |
| 보너스 풀 | 없음 |
| 보너스 선택 개수 | 0 |
| 추첨 요일 | 토 (한국) |

#### 파워볼 (Powerball)

| 항목 | 값 |
|------|-----|
| 메인 풀 | 1 ~ 69 (흰색 공) |
| 메인 선택 개수 | 5 |
| 보너스 풀 | 1 ~ 26 (파워볼, 빨간 공) |
| 보너스 선택 개수 | 1 |
| 추첨 요일 | 월·수·토 (미국 동부 기준) |

#### 메가밀리언 (Mega Millions)

| 항목 | 값 |
|------|-----|
| 메인 풀 | 1 ~ 70 (흰색 공) |
| 메인 선택 개수 | 5 |
| 보너스 풀 | 1 ~ 25 (메가볼, 금색 공) |
| 보너스 선택 개수 | 1 |
| 추첨 요일 | 화·금 (미국 동부 기준) |

#### Win for Life (Lucky for Life 기준, 전국권)

| 항목 | 값 |
|------|-----|
| 메인 풀 | 1 ~ 48 |
| 메인 선택 개수 | 5 |
| 보너스 풀 | 1 ~ 18 (럭키볼, 노란 공) |
| 보너스 선택 개수 | 1 |
| 추첨 요일 | 매일 (미국 동부 기준) |

> **확정**: PickWizard의 "Win for Life" 타입은 **Lucky for Life (1~48/5+1 + 1~18/1)** 기준으로 구현한다.

### 2.3 연금복권720+ (Phase F, 별도 단계)

연금복권720+는 6자리 시리얼 번호 형식(조 1~5, 각 자리 0~9)으로 나머지 볼 픽 방식과 구조가 완전히 다르다.  
볼 픽 4종(Phase A~E) 완성 후 **Phase F**에서 별도로 기획·구현한다.

| 항목 | 값 |
|------|-----|
| 조(Group) | 1 ~ 5 중 1개 |
| 번호 | 6자리 (각 자리 0~9 독립 선택) |
| 형식 예시 | 3조 472815 |

### 2.4 메인 볼 색상 구간 (게임 타입별)

기존의 구간별 색상 체계(노랑·파랑·빨강·회색·초록)를 **5구간 비례 분할** 방식으로 각 게임에 적용한다.  
`LottoBall` 위젯은 게임 타입을 받아 해당 테이블 기준으로 색상을 결정한다.

| 게임 타입 | 메인 범위 | 1구간 노랑 | 2구간 파랑 | 3구간 빨강 | 4구간 회색 | 5구간 초록 |
|-----------|-----------|-----------|-----------|-----------|-----------|-----------|
| 로또6/45 | 1~45 | 1~10 | 11~20 | 21~30 | 31~40 | 41~45 |
| 파워볼 | 1~69 | 1~14 | 15~28 | 29~42 | 43~56 | 57~69 |
| 메가밀리언 | 1~70 | 1~14 | 15~28 | 29~42 | 43~56 | 57~70 |
| Win for Life | 1~48 | 1~10 | 11~20 | 21~30 | 31~40 | 41~48 |

보너스 볼(파워볼 빨간 공, 메가볼 금색 공, 럭키볼 노란 공)은 색상 구간을 적용하지 않고 **고유 배경색**으로 단일 표시한다.

---

## 3. 아키텍처 변경 계획

### 3.1 현재 구조의 문제점

```
LottoConstants (하드코딩)
  - minNumber = 1
  - maxNumber = 45
  - numbersPerDraw = 6

local_lotto_service.dart (하드코딩)
  - _minNumber = 1
  - _maxNumber = 45
  - _numbersPerDraw = 6

offline_home_screen.dart (하드코딩)
  - poolSize = 45 - exclude.length ...
  - _parseNumberList: min=1, max=45
```

### 3.2 목표 구조

#### 3.2.1 `GameType` 모델 (신규)

```dart
// lib/core/models/game_type.dart

enum GameTypeId { lotto645, powerball, megaMillions, winForLife }

class GameType {
  final GameTypeId id;

  // 메인 풀
  final int mainMin;
  final int mainMax;
  final int mainCount;         // 메인 볼 선택 수

  // 보너스 풀 (bonusCount == 0 이면 해당 없음)
  final int? bonusMin;
  final int? bonusMax;
  final int bonusCount;        // 0 또는 1

  // 볼 색상 (보너스 전용 고유색, bonusCount == 0 이면 무시)
  // Flutter Color 값은 구현 시 AppColors 또는 직접 ARGB 정수로 관리
  final int bonusBallColorArgb;

  // 색상 구간 경계 (메인 볼용, 구간 수 = 5)
  // [0]: 1구간 끝, [1]: 2구간 끝, [2]: 3구간 끝, [3]: 4구간 끝, [4]: 5구간 끝(= mainMax)
  final List<int> colorZoneBounds;

  const GameType({
    required this.id,
    required this.mainMin,
    required this.mainMax,
    required this.mainCount,
    this.bonusMin,
    this.bonusMax,
    this.bonusCount = 0,
    this.bonusBallColorArgb = 0,
    required this.colorZoneBounds,
  });

  bool get hasBonus => bonusCount > 0;
}

class GameTypes {
  static const lotto645 = GameType(
    id: GameTypeId.lotto645,
    mainMin: 1, mainMax: 45, mainCount: 6,
    colorZoneBounds: [10, 20, 30, 40, 45],
  );
  static const powerball = GameType(
    id: GameTypeId.powerball,
    mainMin: 1, mainMax: 69, mainCount: 5,
    bonusMin: 1, bonusMax: 26, bonusCount: 1,
    bonusBallColorArgb: 0xFFE53935, // 빨간색
    colorZoneBounds: [14, 28, 42, 56, 69],
  );
  static const megaMillions = GameType(
    id: GameTypeId.megaMillions,
    mainMin: 1, mainMax: 70, mainCount: 5,
    bonusMin: 1, bonusMax: 25, bonusCount: 1,
    bonusBallColorArgb: 0xFFFFB300, // 금색
    colorZoneBounds: [14, 28, 42, 56, 70],
  );
  static const winForLife = GameType(
    id: GameTypeId.winForLife,
    mainMin: 1, mainMax: 48, mainCount: 5,
    bonusMin: 1, bonusMax: 18, bonusCount: 1,
    bonusBallColorArgb: 0xFFFDD835, // 노란색
    colorZoneBounds: [10, 20, 30, 40, 48],
  );

  static const all = [lotto645, powerball, megaMillions, winForLife];

  static GameType fromId(GameTypeId id) =>
      all.firstWhere((g) => g.id == id);
}
```

#### 3.2.2 `local_lotto_service.dart` 변경

하드코딩 상수를 제거하고 `GameType` 파라미터를 받는다.  
보너스 볼이 있는 게임 타입은 메인 풀과 보너스 풀을 분리하여 각각 독립 선택한다.  
보너스 볼도 포함/제외 옵션을 지원한다.

```dart
// 변경 후 시그니처 예시
GeneratedNumbers generateQuickPick({
  required GameType gameType,
  required int nSets,
  List<int>? excludeNumbers,       // 메인 볼 제외 (0~mainMax-mainCount 개)
  List<int>? includeNumbers,       // 메인 볼 포함 (0~mainCount 개)
  int? bonusIncludeNumber,         // 보너스 볼 고정 (0 또는 1개)
  List<int>? bonusExcludeNumbers,  // 보너스 볼 제외 (0~bonusMax-1 개)
});

GeneratedNumbers generateMonteCarloTop6({
  required GameType gameType,
  required int nSets,
  List<int>? excludeNumbers,
  List<int>? includeNumbers,
  int? bonusIncludeNumber,
  List<int>? bonusExcludeNumbers,
});
```

검증 함수(`validateParameters`)도 `GameType` 파라미터 기반으로 범위 검사.

#### 3.2.3 `GeneratedNumbers` 모델 변경

```dart
// 기존
class GeneratedNumbers {
  final List<List<int>> sets;    // 세트별 번호 목록
  final DateTime createdAt;
  ...
}

// 변경 후
class GeneratedNumbers {
  final GameTypeId gameTypeId;        // 추가: 게임 타입 식별자
  final List<List<int>> mainSets;     // 변경: sets → mainSets (메인 볼)
  final List<int> bonusBalls;         // 추가: 보너스 볼 목록 (길이 = nSets, 보너스 없으면 빈 리스트)
  final DateTime createdAt;
  ...
}
```

> ⚠️ **Hive 마이그레이션 필요**  
> 필드명이 `sets` → `mainSets`로 바뀌고 `gameTypeId`, `bonusBalls` 필드가 추가된다.  
> 기존 저장 데이터와 Hive typeId 충돌이 발생한다.  
> 구현 시 다음 중 하나를 선택해야 한다:  
> - **옵션 A**: Hive typeId 변경 + 마이그레이션 로직 작성 (기존 데이터 유지)  
> - **옵션 B**: 앱 업데이트 시 내 번호 DB 초기화 (경고 다이얼로그 표시)  
> 사용자 저장 데이터가 적은 초기 단계이므로 **옵션 B가 단순하고 현실적**이다.

#### 3.2.4 `LottoConstants` 처리

- `LottoConstants`는 로또6/45 전용 레거시 상수로 유지 (하위 호환)
- 색상 판정 메서드(`isYellow` 등)는 `GameType.colorZoneBounds`를 사용하는 범용 함수로 대체
- `LottoBall` 위젯은 `number`와 `gameType`을 함께 받아 색상 결정

### 3.3 Provider 변경

```
offlineSelectedAlgorithmProvider       → 유지
offlineNumberOfSetsProvider            → 유지
offlineIncludeNumbersProvider          → 유지 (범위 검증만 GameType 기반으로)
offlineExcludeNumbersProvider          → 유지 (범위 검증만 GameType 기반으로)

[신규]
offlineSelectedGameTypeProvider        → StateProvider<GameType>  기본값: GameTypes.lotto645
offlineBonusIncludeNumberProvider      → StateProvider<int?>       기본값: null
offlineBonusExcludeNumbersProvider     → StateProvider<List<int>>  기본값: []
```

> ⚠️ **게임 타입 전환 시 포함/제외 번호 초기화 정책**  
> 게임 타입이 변경되면 현재 설정된 포함/제외 번호가 새 게임의 범위를 벗어날 수 있다.  
> (예: 파워볼에서 번호 65를 포함 설정 후 로또6/45로 전환 → 65는 유효하지 않음)  
> **정책**: 게임 타입 변경 시 포함/제외 번호(메인+보너스) 전체를 자동 초기화한다.  
> 전환 전 간단한 스낵바로 사용자에게 알린다.

---

## 4. 화면 및 UX 변경

### 4.1 게임·언어 선택 UI (드롭다운)

현재 언어 선택은 `ChoiceChip` 목록 형태다. 이번에 **게임 선택과 언어 선택 모두 `DropdownButton`으로 변경**한다.  
두 항목을 하나의 카드 안에 두 행으로 배치한다.

```
┌──────────────────────────────────────────────────┐
│  게임   [ 로또 6/45 (🇰🇷)              ▼ ]       │
│  언어   [ 한국어 🇰🇷                   ▼ ]       │
└──────────────────────────────────────────────────┘
```

- `게임` 드롭다운 항목: 로또 6/45 🇰🇷 / 파워볼 🇺🇸 / 메가밀리언 🇺🇸 / Win for Life 🇺🇸
- `언어` 드롭다운 항목: 기존 지원 언어 목록 동일 (6개 언어)
- 선택값은 모두 SharedPreferences에 저장 (앱 재시작 후 유지)
- 게임 타입 변경 시 → 포함/제외 번호 초기화 (스낵바 알림)

### 4.2 번호 생성 옵션 모달 변경

#### 4.2.1 메인 볼 포함/제외

포함/제외 번호 범위 힌트를 선택된 게임 타입에 맞게 동적 표시.

| 게임 타입 | 메인 포함/제외 범위 | 최대 포함 | 최대 제외 |
|-----------|-------------------|-----------|-----------|
| 로또6/45 | 1 ~ 45 | 6개 | 39개 |
| 파워볼 | 1 ~ 69 | 5개 | 64개 |
| 메가밀리언 | 1 ~ 70 | 5개 | 65개 |
| Win for Life | 1 ~ 48 | 5개 | 43개 |

#### 4.2.2 보너스 볼 포함/제외 (5+1 게임 전용 섹션)

파워볼·메가밀리언·Win for Life 선택 시 옵션 모달 하단에 **보너스 볼 섹션**을 추가 표시.

| 게임 타입 | 보너스 볼 이름 | 보너스 범위 | 최대 포함 | 최대 제외 |
|-----------|--------------|-----------|-----------|-----------|
| 파워볼 | 파워볼 (빨간) | 1 ~ 26 | 1개 | 25개 |
| 메가밀리언 | 메가볼 (금색) | 1 ~ 25 | 1개 | 24개 |
| Win for Life | 럭키볼 (노랑) | 1 ~ 18 | 1개 | 17개 |

```
── 보너스 볼 (파워볼) ──────────────────────
포함할 파워볼 번호:  [ 텍스트 입력, 1~26, 최대 1개 ]
                    현재 선택: 없음
제외할 파워볼 번호:  [ 텍스트 입력, 1~26, 최대 25개 ]
                    현재 선택: 0개
────────────────────────────────────────────
```

- 포함 1개가 입력되면 해당 번호로 보너스 볼이 고정
- 제외 목록에서 풀이 1개 미만으로 줄어드는 경우 생성 버튼 비활성화

### 4.3 결과 화면 변경

5+1 형식의 게임 타입에서는 메인 볼 5개 + 보너스 볼 1개를 분리 표시.

```
파워볼 예시:
[ 12 ][ 25 ][ 38 ][ 55 ][ 67 ]  +  [ 🔴 18 ]
  노랑  파랑  빨강  회색  초록      (파워볼 빨간 공)

메가밀리언 예시:
[  7 ][ 19 ][ 33 ][ 48 ][ 62 ]  +  [ 🟡  9 ]
  노랑  파랑  빨강  회색  초록      (메가볼 금색 공)
```

- 구분선(`+`) 또는 아이콘으로 메인/보너스 경계 표시
- `LottoBall` 위젯: `gameType` 파라미터 및 `isBonus` 플래그 추가
- 로또6/45는 기존 결과 화면과 동일

### 4.4 내 번호 화면 변경

#### 4.4.1 게임 타입 배지 표시

저장된 번호 카드마다 게임 타입 배지(뱃지) 표시.

```
[🇰🇷 로또6/45  ] 2026-05-01  14  22  33  41  43  45
[🇺🇸 파워볼    ] 2026-05-03   7  19  28  55  62  + 🔴15
[🇺🇸 메가밀리언] 2026-05-04   2  18  31  47  68  + 🟡11
```

#### 4.4.2 게임 타입 필터

내 번호 화면 상단에 필터 드롭다운을 추가.

```
┌──────────────────────────────────────────┐
│ 내 번호     필터: [ 전체              ▼ ]│
└──────────────────────────────────────────┘
```

- 필터 항목: 전체 / 로또 6/45 / 파워볼 / 메가밀리언 / Win for Life
- 필터 선택값은 앱 세션 내에서만 유지 (앱 재시작 시 "전체" 로 초기화)

---

## 5. 다국어 처리

### 5.1 추가 필요 문자열

| 키 | 한국어 | 영어 |
|----|--------|------|
| `selectGame` | 게임 선택 | Select Game |
| `gameLotto645` | 로또 6/45 | Lotto 6/45 |
| `gamePowerball` | 파워볼 | Powerball |
| `gameMegaMillions` | 메가밀리언 | Mega Millions |
| `gameWinForLife` | Win for Life | Win for Life |
| `bonusBallLabel` | 보너스 볼 | Bonus Ball |
| `bonusBallNamePowerball` | 파워볼 (빨간 공) | Powerball (Red) |
| `bonusBallNameMegaBall` | 메가볼 (금색 공) | Mega Ball (Gold) |
| `bonusBallNameLuckyBall` | 럭키볼 (노란 공) | Lucky Ball (Yellow) |
| `mainNumbers` | 메인 번호 | Main Numbers |
| `bonusBallSection` | 보너스 볼 ({name}) | Bonus Ball ({name}) |
| `includeBonusNumbersLabel` | 포함할 {name} 번호 | Include {name} Number |
| `excludeBonusNumbersLabel` | 제외할 {name} 번호 | Exclude {name} Numbers |
| `includeBonusHint` | 1~{max}, 최대 1개 | 1~{max}, up to 1 |
| `excludeBonusHint` | 1~{max}, 최대 {limit}개 | 1~{max}, up to {limit} |
| `mainNumberRange` | 메인 번호 범위: {min}~{max} | Main: {min}~{max} |
| `bonusNumberRange` | 보너스 번호 범위: 1~{max} | Bonus: 1~{max} |
| `filterAll` | 전체 | All |
| `gameTypeChangedClearNumbers` | 게임 변경으로 포함/제외 번호가 초기화되었습니다 | Game changed. Include/exclude numbers reset. |

> **중복 키 제거**: 이전 초안의 `powerball`, `megaBall`, `luckyBall` 키는 위 `bonusBallNamePowerball` 등으로 통합하여 게임명 키(`gamePowerball`)와 충돌 방지.

### 5.2 ARB 파일 수정 대상

- `app_en.arb`, `app_ko.arb`, `app_ja.arb`, `app_zh.arb`, `app_th.arb`, `app_vi.arb`
- 총 6개 언어 파일에 위 키 추가

---

## 6. 구현 단계 계획

### Phase A — 아키텍처 기반 작업 (선행)

| # | 작업 | 영향 파일 |
|---|------|-----------|
| A1 | `GameType` 모델 신규 생성 | `lib/core/models/game_type.dart` (신규) |
| A2 | `LottoConstants` 의존 코드를 `GameType` 기반으로 리팩토링 | `local_lotto_service.dart`, `offline_home_screen.dart` |
| A3 | `GeneratedNumbers` 모델 변경 (`gameTypeId`, `mainSets`, `bonusBalls`) | `data/models/generated_numbers.dart` |
| A4 | Hive 어댑터 재생성 + DB 초기화 마이그레이션 처리 | `adapters/generated_numbers_adapter.dart`, `hive_database.dart` |
| A5 | `offlineSelectedGameTypeProvider` 신규 추가 | `offline/providers/offline_providers.dart` |
| A6 | `offlineBonusIncludeNumberProvider`, `offlineBonusExcludeNumbersProvider` 신규 추가 | `offline/providers/offline_providers.dart` |

### Phase B — 로또6/45 회귀 검증

| # | 작업 |
|---|------|
| B1 | A 작업 완료 후 기존 로또6/45 동작이 동일한지 전체 테스트 |
| B2 | `widget_test.dart` 기존 케이스 통과 확인 |

### Phase C — 게임 타입별 생성 로직 구현

| # | 작업 | 영향 파일 |
|---|------|-----------|
| C1 | `generateQuickPick` / `generateMonteCarloTop6` 를 `GameType` 파라미터 기반으로 수정 | `local_lotto_service.dart` |
| C2 | 5+1 보너스 볼 생성 로직 추가 (메인 풀과 보너스 풀 독립 선택) | `local_lotto_service.dart` |
| C3 | `validateParameters` 를 `GameType` 기반으로 수정 (보너스 볼 포함/제외 검증 포함) | `local_lotto_service.dart` |

### Phase D — UI 구현

| # | 작업 | 영향 파일 |
|---|------|-----------|
| D1 | 홈 화면: 게임 선택 드롭다운 추가 | `offline_home_screen.dart` |
| D2 | 홈 화면: 언어 선택을 ChoiceChip에서 드롭다운으로 변경 | `offline_home_screen.dart` |
| D3 | 게임 타입·언어 선택값 SharedPreferences 저장/복원 | `offline/utils/locale_preferences.dart` 또는 신규 `game_preferences.dart` |
| D4 | 번호 생성 옵션 모달: 메인 볼 범위 힌트를 GameType 기반으로 동적 표시 | `offline_home_screen.dart` |
| D5 | 번호 생성 옵션 모달: 5+1 게임 전용 보너스 볼 포함/제외 섹션 추가 | `offline_home_screen.dart` |
| D6 | 게임 타입 변경 시 포함/제외 번호 초기화 + 스낵바 알림 | `offline_home_screen.dart` |
| D7 | `LottoBall` 위젯: `gameType` 파라미터 및 `isBonus` 플래그 추가, 색상 구간 로직 대체 | `presentation/widgets/lotto_ball.dart` |
| D8 | 결과 화면: 5+1 형식 분리 표시 (메인+보너스 구분선) | `offline_result_screen.dart` |
| D9 | 내 번호 화면: 게임 타입 배지 표시 | `offline_my_numbers_screen.dart` |
| D10 | 내 번호 화면: 게임 타입 필터 드롭다운 추가 | `offline_my_numbers_screen.dart` |
| D11 | `_canGenerate()` 로직을 GameType 기반으로 수정 (보너스 볼 포함/제외 풀 부족 체크) | `offline_home_screen.dart` |

### Phase E — 다국어

| # | 작업 |
|---|------|
| E1 | 6개 ARB 파일에 섹션 5.1의 문자열 키 추가 |
| E2 | `flutter gen-l10n` 재실행 후 생성된 localizations 파일 확인 |
| E3 | 기존 ARB에서 더 이상 사용하지 않는 키 정리 (선택) |

### Phase F — 연금복권720+ (별도 단계)

볼 픽 4종(Phase A~E) 완성 및 검증 후 별도 기획서로 진행.

- 시리얼 번호 생성 로직 별도 구현
- 조(1~5) 선택 UI 추가
- 6자리 각 자리(0~9) 개별 생성 로직
- 결과 표시 형식 별도 설계
- `GameType` 추상화 레이어에 "시리얼 타입" 레이어 추가 필요

---

## 7. 확정 결정 사항

| # | 항목 | 결정 |
|---|------|------|
| Q1 | Win for Life 기준 | **Lucky for Life (1~48/5 + 1~18/1)** 기준으로 확정 |
| Q2 | 연금복권720+ 포함 여부 | **Phase F(별도 단계)** 로 분리 확정 |
| Q3 | 게임 타입별 볼 색상 | **기존 5구간 색상 체계 유지**, 각 게임 범위에 비례 분할 적용 (섹션 2.4 참조) |
| Q4 | 보너스 볼 포함/제외 옵션 | **지원** — 5+1 게임 옵션 모달에 보너스 볼 섹션 추가 |
| Q5 | 내 번호 화면 게임 타입 필터 | **1단계(Phase D)에서 포함** — 드롭다운 필터 추가 |
| Q6 | 게임·언어 선택 UI 형태 | **드롭다운(DropdownButton)** 으로 통일 |
| Q7 | 게임 타입 전환 시 포함/제외 처리 | **전체 자동 초기화** + 스낵바 알림 |
| Q8 | Hive 마이그레이션 전략 | **앱 업데이트 시 DB 초기화 (옵션 B)** + 사용자 경고 다이얼로그 |

---

## 8. 관련 문서

- [044] 오프라인 앱 알고리즘 선정 보고서
- [045] 오프라인 앱 계획안 및 UI 디자인
- [049] Android/iOS 애셋 요건
- [052] 방향 2 기획서 — 과거 당첨번호 다운로드 + 통계 알고리즘 (본 문서 완성 후 작성 예정)
