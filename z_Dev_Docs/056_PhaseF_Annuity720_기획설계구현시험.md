# 056. PickWizard Phase F — 연금복권720+ (`annuity720`)  
## 기획서 · 상세설계 · 구현계획 · 시험명세 · 실행프롬프트

**문서 번호**: 056  
**작성일**: 2026-05-09  
**대상**: PickWizard 오프라인 앱  
**선행 완료 요건**: 053 STEP 0~15 전체 완료 (90개 테스트 PASS, `flutter analyze` 오류 0)  
**참고 문서**: 051 (Phase A~E 기획), 052 (구현 체크리스트), 053 (A~E 실행 프롬프트), 055 (코드베이스 검토)

---

## 📋 목차

1. [기획서 — Phase F 개요](#1-기획서)
2. [연금복권720+ 게임 규칙 상세](#2-게임-규칙)
3. [아키텍처 상세설계](#3-아키텍처-상세설계)
4. [구현 단계 계획 (STEP F-0 ~ F-9)](#4-구현-단계-계획)
5. [시험항목 상세 정의](#5-시험항목-상세-정의)
6. [통과/실패 기준](#6-통과실패-기준)
7. [자동시험 설정 및 계획](#7-자동시험-설정-및-계획)
8. [STEP별 모델 선택 가이드](#8-step별-모델-선택-가이드)
9. [STEP별 실행 지시 프롬프트](#9-step별-실행-지시-프롬프트)

---

## 1. 기획서

### 1.1 배경

Phase A~E에서 볼 픽 방식 4종(로또6/45, 파워볼, 메가밀리언, Win for Life)과  
그에 필요한 `GameType` 추상화·생성 로직·UI·다국어를 모두 구현 완료했다.

연금복권720+는 **시리얼 번호 방식**이라 볼 픽 방식과 구조가 근본적으로 다르다.

| 구분 | 볼 픽 방식 | 시리얼 방식 (연금복권720+) |
|------|-----------|--------------------------|
| 숫자 선택 방식 | 풀에서 N개 중복 없이 선택 | 6자리 각각 독립적 0~9 |
| 조 개념 | 없음 | 조(Group) 1~5 별도 선택 |
| 정렬 표시 | 오름차순 정렬 | 자리 순서 유지 |
| UI 표현 | LottoBall 구간 색상 | 자릿수 박스(DigitBox) |

### 1.2 Phase F 목표

1. `GameType` 레이어에 **"시리얼 카테고리" 개념** 추가 (`GameCategory` enum)  
2. `annuity720` 게임 타입 상수 정의 (조=보너스 슬롯 재활용)  
3. 시리얼 전용 **번호 생성 함수** `generateSerial` 구현  
4. 옵션 모달에 **조 고정/제외** UI 추가 (볼 포함/제외와 분기)  
5. **DigitBox** / **SerialNumberRow** 새 위젯 구현  
6. 결과 화면 · 내 번호 화면에서 시리얼 타입 **분기 처리**  
7. 신규 다국어 키 9개 추가  
8. 기존 90개 테스트 **회귀 보호** 유지

### 1.3 범위 외 (v1 보류)

- 자리별 고정 (위치 0~5에 특정 숫자 고정) — 구조는 설계하되 v1 미구현  
- 연금복권 당첨 번호 조회 / 통계 알고리즘 — 방향 2 범위

---

## 2. 게임 규칙

### 2.1 연금복권720+ 규칙

| 항목 | 값 |
|------|-----|
| 게임 이름 | 연금복권720+ |
| 조(Group) | 1 ~ 5 중 1개 선택 |
| 번호 자리 수 | 6자리 |
| 각 자리 범위 | 0 ~ 9 (독립, 반복 허용) |
| 표시 예시 | `3조  4 7 2 8 1 5` |
| 추첨 요일 | 매주 월요일 (한국) |
| 복권 가격 | 1,000원 |

### 2.2 데이터 모델 매핑 (기존 필드 재활용)

`GeneratedNumbers` 모델 변경 없이 기존 필드를 재활용한다.

| 기존 필드 | 볼 픽 의미 | 시리얼(annuity720) 의미 |
|-----------|-----------|------------------------|
| `results[i].numbers` | 메인 볼 번호 리스트 | 6자리 숫자 [d0,d1,d2,d3,d4,d5] |
| `bonusBalls[i]` | 보너스 볼 번호 | 조(Group) 1~5 |
| `gameTypeId` | 게임 식별자 | `GameTypeId.annuity720` |

### 2.3 GameType 파라미터 매핑

```
annuity720 GameType 상수:
  mainMin = 0,  mainMax = 9,  mainCount = 6   // 자리: 0~9, 6개
  bonusMin = 1, bonusMax = 5, bonusCount = 1  // 조: 1~5, 1개
  bonusBallColorArgb = 0xFF7B1FA2             // 보라색 (조 배지)
  colorZoneBounds = [1, 3, 5, 7, 9]          // 시리얼에서는 사용 안 함 (placeholder)
  category = GameCategory.serial
```

> **중요 설계 결정**: 시리얼 타입에서 `hasBonus == true` (bonusCount=1)이므로  
> 기존 Hive 어댑터가 `bonusBalls`를 읽고 쓰는 흐름이 그대로 작동한다.  
> Hive 스키마 변경 없음 → `dbSchemaVersion` 변경 불필요.

---

## 3. 아키텍처 상세설계

### 3.1 `game_type.dart` 변경

#### 3.1.1 `GameCategory` enum 신규 추가

```dart
enum GameCategory {
  ballPick,   // 볼 풀에서 N개 중복 없이 선택 (기존 4종)
  serial,     // 자리별 독립 선택 (연금복권720+)
}
```

#### 3.1.2 `GameTypeId` enum 확장

```dart
enum GameTypeId {
  lotto645,
  powerball,
  megaMillions,
  winForLife,
  annuity720,   // 추가 — 반드시 마지막에 추가 (Hive index 4)
}
```

> **Hive 호환**: 기존 어댑터가 `GameTypeId.values[index]`로 역직렬화하므로  
> 끝에 추가하면 기존 0~3 인덱스는 깨지지 않는다.

#### 3.1.3 `GameType` 클래스 변경

```dart
class GameType {
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
    this.category = GameCategory.ballPick,   // 신규 (기본값 볼픽)
  });

  // ... 기존 필드 동일 ...
  final GameCategory category;               // 신규

  bool get hasBonus => bonusCount > 0;
  bool get isSerial => category == GameCategory.serial;    // 신규 getter
  bool get isBallPick => category == GameCategory.ballPick; // 신규 getter
  // ... 기존 getter 동일 ...
}
```

#### 3.1.4 `GameTypes` 확장

```dart
class GameTypes {
  // ... 기존 4개 상수 동일 (category 필드 없으면 기본값 ballPick 적용) ...

  static const annuity720 = GameType(
    id: GameTypeId.annuity720,
    mainMin: 0,
    mainMax: 9,
    mainCount: 6,
    bonusMin: 1,
    bonusMax: 5,
    bonusCount: 1,
    bonusBallColorArgb: 0xFF7B1FA2,         // 보라색 조 배지
    colorZoneBounds: [1, 3, 5, 7, 9],       // 시리얼에서 미사용 (placeholder)
    category: GameCategory.serial,
  );

  static const all = [
    lotto645,
    powerball,
    megaMillions,
    winForLife,
    annuity720,   // 추가
  ];

  static GameType fromId(GameTypeId id) =>
      all.firstWhere((g) => g.id == id);
}
```

### 3.2 `local_lotto_service.dart` 변경

#### 3.2.1 시리얼 검증 함수 추가

```dart
/// annuity720 전용 파라미터 검증
(bool, String?) validateSerialParameters({
  required int nSets,
  int? fixedGroup,
  List<int>? excludeGroups,
}) {
  // nSets: 1~100
  // fixedGroup: null 또는 1~5
  // excludeGroups: 비어있거나, 1~5 범위, 중복 없음, 최대 4개
  // fixedGroup != null && excludeGroups.contains(fixedGroup) → 에러
  // 사용 가능한 조 수 = 5 - excludeGroups.length >= 1
}
```

#### 3.2.2 시리얼 생성 함수 추가

```dart
/// 알고리즘 1 (시리얼 타입 전용): 연금복권720+ 번호 생성
GeneratedNumbers generateSerial({
  required GameType gameType,   // gameType.isSerial == true 전제
  required int nSets,
  int? fixedGroup,              // null = 무작위 (1~5), 정수 = 고정
  List<int>? excludeGroups,     // 제외할 조 목록 (최대 4개)
}) {
  // 1. validateSerialParameters 호출
  // 2. 그룹 풀 생성: [1..5] - excludeGroups
  // 3. 각 세트:
  //    - group = fixedGroup ?? groupPool.random()
  //    - digits = List.generate(6, (_) => Random().nextInt(10))
  // 4. _buildGenerated 호출 (bonusBalls = 조 목록)
}
```

#### 3.2.3 `OfflineGenerateNotifier.generate()` 분기 수정

```dart
if (gameType.isSerial) {
  generated = generateSerial(
    gameType: gameType,
    nSets: nSets,
    fixedGroup: ref.read(offlineSerialFixedGroupProvider),
    excludeGroups: ref.read(offlineSerialExcludeGroupsProvider),
  );
} else if (algo.id == 1) {
  generated = generateQuickPick(...);   // 기존
} else if (algo.id == 9) {
  generated = generateMonteCarloTop(...); // 기존
}
```

### 3.3 `offline_providers.dart` 변경

```dart
/// 조 고정값 (annuity720 전용, null = 무작위)
final offlineSerialFixedGroupProvider = StateProvider<int?>((ref) => null);

/// 조 제외 목록 (annuity720 전용)
final offlineSerialExcludeGroupsProvider =
    StateProvider<List<int>>((ref) => []);
```

**`offlineAlgorithmsProvider` 변경**: 시리얼 타입에서는 알고리즘 9 숨김

```dart
final offlineAlgorithmsProvider = Provider<List<OfflineAlgorithmInfo>>((ref) {
  final gt = ref.watch(offlineSelectedGameTypeProvider);
  if (gt.isSerial) {
    return const [OfflineAlgorithmInfo(id: 1)];   // 자동선택만
  }
  return _kAlgorithms;   // 기존 1, 9
});
```

**게임 타입 변경 시 시리얼 Provider 초기화**:  
`offline_home_screen.dart`의 게임 드롭다운 `onChanged`에서 시리얼 Provider도 초기화:
```dart
ref.read(offlineSerialFixedGroupProvider.notifier).state = null;
ref.read(offlineSerialExcludeGroupsProvider.notifier).state = [];
```

### 3.4 새 위젯 설계

#### 3.4.1 `DigitBox` 위젯

```
lib/presentation/widgets/digit_box.dart
```

```
┌──────┐
│  7   │
└──────┘
```

- `digit`: int (0~9)  
- 고정 크기 36×36 dp, 둥근 모서리 4dp  
- 배경: 밝은 회색(#F5F5F5), 텍스트: 굵은 검은 숫자  
- `isHighlighted`: bool (옵션) — true면 보라색 배경  

#### 3.4.2 `SerialNumberRow` 위젯

```
lib/presentation/widgets/serial_number_row.dart
```

```
[ 3조 ]  [ 4 ][ 7 ][ 2 ][ 8 ][ 1 ][ 5 ]
(보라 뱃지)       (DigitBox 6개)
```

- `group`: int (1~5) — 보라색 배지로 표시 (`{group}조`)  
- `digits`: List<int> (길이 6, 각 0~9) — DigitBox 6개  
- 조 배지와 자릿수 박스 사이 8dp 여백  

### 3.5 화면 분기 처리

#### 3.5.1 홈 화면 옵션 모달 분기

```
gameType.isSerial  →  "조 고정" 입력 + "조 제외" 입력 표시
                      볼 포함/제외 섹션 숨김
                      보너스 볼 섹션 숨김

!isSerial, !hasBonus →  메인 볼 포함/제외 섹션만
!isSerial, hasBonus  →  메인 볼 + 보너스 볼 섹션
```

#### 3.5.2 결과 화면 분기

```
gameType.isSerial → SerialNumberRow(group: bonusBalls[i], digits: numbers[i])
!isSerial         → 기존 LottoBall 표시
```

#### 3.5.3 내 번호 화면 분기

```
gameType.isSerial → 배지: "연금복권720+"
                    번호: "{group}조 {d0}{d1}{d2}{d3}{d4}{d5}" 텍스트 형식
!isSerial         → 기존 LottoBall 표시
```

내 번호 필터 드롭다운에 `annuity720` 항목 추가.

### 3.6 Hive/DB 호환성 분석

| 항목 | 결론 |
|------|------|
| `dbSchemaVersion` | **변경 없음 (2 유지)** |
| `GeneratedNumbersAdapter` | **변경 없음** |
| `GameTypeId.annuity720` | enum 끝에 추가 → index=4, 기존 0~3 불변 |
| 기존 저장 데이터 | 호환 유지 (역직렬화 정상) |

### 3.7 `_canGenerate()` 시리얼 타입 로직

```dart
if (gameType.isSerial) {
  final excludeGroups = ref.read(offlineSerialExcludeGroupsProvider);
  final fixedGroup = ref.read(offlineSerialFixedGroupProvider);
  final availableGroups = 5 - excludeGroups.length;
  // fixedGroup이 excludeGroups에 있으면 false
  if (fixedGroup != null && excludeGroups.contains(fixedGroup)) return false;
  return availableGroups >= 1;
}
// else: 기존 볼 픽 로직
```

### 3.8 다국어 신규 키 (9개)

| 키 | 한국어 | 영어 |
|----|--------|------|
| `gameAnnuity720` | 연금복권720+ | Annuity 720+ |
| `annuity720GroupBadge` | {group}조 | Group {group} |
| `annuity720FullFormat` | {group}조 {digits} | Group {group}: {digits} |
| `serialFixedGroupLabel` | 조 고정 | Fix Group |
| `serialFixedGroupHint` | 1~5 중 1개 (빈칸=무작위) | 1–5, blank = random |
| `serialExcludeGroupsLabel` | 조 제외 | Exclude Groups |
| `serialExcludeGroupsHint` | 1~5, 최대 4개 | 1–5, up to 4 |
| `serialGroupRange` | 조 범위: 1~5 | Group range: 1–5 |
| `serialDigitRange` | 각 자리: 0~9 | Each digit: 0–9 |

---

## 4. 구현 단계 계획

| STEP | Phase | 핵심 작업 | 모델 | 검증 명령 |
|------|-------|-----------|------|-----------|
| F-0 | 사전 | 기존 테스트 90개 PASS 확인 | Auto | `flutter test` |
| F-1 | 아키텍처 | GameCategory + annuity720 GameType | **Think** | `flutter test test/unit/game_type_test.dart` |
| F-2 | Provider | 시리얼 Provider 2개 + 알고리즘 분기 | Auto | `flutter test test/unit/generated_numbers_test.dart` |
| F-3 | 생성 로직 | validateSerial + generateSerial | **Think** | `flutter test test/unit/local_lotto_service_test.dart` |
| F-4 | 홈 화면 | 드롭다운 annuity720 + 옵션 모달 분기 | Auto | `flutter test test/widget/offline_home_screen_test.dart` |
| F-5 | 위젯 | DigitBox + SerialNumberRow | Auto | `flutter test test/widget/digit_box_test.dart` |
| F-6 | 결과 화면 | 시리얼 타입 분기 표시 | Auto | `flutter test test/widget/offline_result_screen_test.dart` |
| F-7 | 내 번호 | 시리얼 배지 + 필터 | Auto | `flutter test test/widget/offline_my_numbers_screen_test.dart` |
| F-8 | 다국어 | ARB 9개 키 + gen-l10n | Auto | `flutter gen-l10n && flutter analyze` |
| F-9 | 통합 검증 | 전체 자동+수동 검증 | Auto | `flutter test && flutter analyze` |

---

## 5. 시험항목 상세 정의

### 5.1 F1 — GameCategory + GameType 확장 (15개)

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| F1-T01 | `GameCategory` enum에 `ballPick`, `serial` 두 값 존재 | unit |
| F1-T02 | `GameTypeId` enum에 `annuity720` 존재 (5번째 값) | unit |
| F1-T03 | `GameTypes.annuity720.category == GameCategory.serial` | unit |
| F1-T04 | `GameTypes.lotto645.category == GameCategory.ballPick` | unit |
| F1-T05 | `GameTypes.powerball.category == GameCategory.ballPick` | unit |
| F1-T06 | `GameTypes.annuity720.isSerial == true` | unit |
| F1-T07 | `GameTypes.lotto645.isSerial == false` | unit |
| F1-T08 | `GameTypes.annuity720.isBallPick == false` | unit |
| F1-T09 | `GameTypes.annuity720.mainMin==0, mainMax==9, mainCount==6` | unit |
| F1-T10 | `GameTypes.annuity720.bonusMin==1, bonusMax==5, bonusCount==1` | unit |
| F1-T11 | `GameTypes.annuity720.hasBonus == true` (bonusCount=1) | unit |
| F1-T12 | `GameTypes.annuity720.bonusBallColorArgb == 0xFF7B1FA2` | unit |
| F1-T13 | `GameTypes.all.length == 5` | unit |
| F1-T14 | `GameTypes.fromId(GameTypeId.annuity720) == GameTypes.annuity720` | unit |
| F1-T15 | 기존 `GameTypes.lotto645.colorZoneFor(10) == 0` 회귀 확인 | unit |

### 5.2 F2 — Provider 확장 (5개)

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| F2-T01 | `offlineSerialFixedGroupProvider` 초기값 == null | unit |
| F2-T02 | `offlineSerialExcludeGroupsProvider` 초기값 == [] | unit |
| F2-T03 | ballPick 게임 선택 시 `offlineAlgorithmsProvider` 반환 길이 == 2 (id:1, id:9) | unit |
| F2-T04 | `annuity720` 선택 시 `offlineAlgorithmsProvider` 반환 길이 == 1 (id:1만) | unit |
| F2-T05 | `annuity720` → ballPick으로 전환 시 `offlineAlgorithmsProvider` 다시 길이 2 | unit |

### 5.3 F3 — 시리얼 생성 로직 (14개)

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| F3-T01 | `generateSerial` 1세트: `results.length == 1` | unit |
| F3-T02 | `generateSerial` 1세트: `results[0].numbers.length == 6` | unit |
| F3-T03 | `generateSerial` 1세트: 각 자리 0~9 범위 | unit |
| F3-T04 | `generateSerial` 1세트: 자리끼리 중복 허용 (반복 선택 가능) | unit |
| F3-T05 | `generateSerial` 1세트: `bonusBalls.length == 1`, 값 1~5 | unit |
| F3-T06 | `generateSerial` 5세트: `results.length == 5`, `bonusBalls.length == 5` | unit |
| F3-T07 | `fixedGroup=3`: 모든 세트 `bonusBalls[i] == 3` | unit |
| F3-T08 | `excludeGroups=[1,2]`: 모든 세트 조가 {3,4,5} 중 하나 | unit |
| F3-T09 | `excludeGroups=[1,2,3,4,5]` → `ArgumentError` | unit |
| F3-T10 | `fixedGroup=3, excludeGroups=[3]` → 검증 실패 | unit |
| F3-T11 | `validateSerialParameters(nSets:0)` → `(false, ...)` | unit |
| F3-T12 | `validateSerialParameters(nSets:101)` → `(false, ...)` | unit |
| F3-T13 | 결과 `gameTypeId == GameTypeId.annuity720` | unit |
| F3-T14 | `fixedGroup=2` 범위 초과 없음, `fixedGroup=6` → 검증 실패 | unit |

### 5.4 F4 — 홈 화면 UI (8개)

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| F4-T01 | 게임 드롭다운에 5번째 항목 "연금복권720+" (또는 l10n.gameAnnuity720) 표시 | widget |
| F4-T02 | annuity720 선택 → `offlineSelectedGameTypeProvider.isSerial == true` | widget |
| F4-T03 | annuity720 선택 → 포함/제외/보너스 Provider 초기화 확인 | widget |
| F4-T04 | annuity720 선택 → 스낵바 초기화 메시지 표시 | widget |
| F4-T05 | annuity720 선택 → 알고리즘 목록에 "알고리즘 9" 항목 없음 | widget |
| F4-T06 | annuity720 선택 후 옵션 모달 열기 → "조 고정" 필드 표시 | widget |
| F4-T07 | annuity720 선택 후 옵션 모달 → 볼 포함/제외 섹션 없음 | widget |
| F4-T08 | annuity720 → 조 5개 모두 제외 설정 → 생성 버튼 비활성 | widget |

### 5.5 F5 — DigitBox + SerialNumberRow 위젯 (7개)

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| F5-T01 | `DigitBox(digit:5)` → "5" 텍스트 렌더링 | widget |
| F5-T02 | `DigitBox(digit:0)` → "0" 텍스트 렌더링 | widget |
| F5-T03 | `DigitBox(digit:9)` 렌더링 오류 없음 | widget |
| F5-T04 | `SerialNumberRow(group:3, digits:[4,7,2,8,1,5])` → "3조" 텍스트 포함 | widget |
| F5-T05 | `SerialNumberRow` → DigitBox 6개 렌더링 확인 | widget |
| F5-T06 | `SerialNumberRow` 조 배지 색상 0xFF7B1FA2 확인 | widget |
| F5-T07 | `SerialNumberRow` 렌더링 overflow 오류 없음 | widget |

### 5.6 F6 — 결과 화면 시리얼 분기 (3개)

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| F6-T01 | annuity720 GeneratedNumbers → `SerialNumberRow` 렌더링 | widget |
| F6-T02 | lotto645 GeneratedNumbers → `LottoBall` 6개 렌더링 (회귀) | widget |
| F6-T03 | powerball GeneratedNumbers → 기존 5+1 표시 (회귀) | widget |

### 5.7 F7 — 내 번호 화면 시리얼 처리 (4개)

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| F7-T01 | annuity720 저장 번호 → "연금복권720+" 배지 표시 | widget |
| F7-T02 | annuity720 저장 번호 → "3조 472815" 형식 텍스트 표시 | widget |
| F7-T03 | 필터 드롭다운에 "연금복권720+" 항목 존재 | widget |
| F7-T04 | 필터 "연금복권720+" 선택 → lotto645 카드 숨김 | widget |

### 5.8 F8 — 다국어 (2개 자동 + 3개 수동)

| ID | 시험 항목 | 유형 |
|----|-----------|------|
| F8-T01 | `flutter gen-l10n` 오류 없이 성공 | auto |
| F8-T02 | `flutter analyze` 오류 0 | auto |
| F8-T03 | 영어 앱에서 "Annuity 720+" 게임명 표시 | 수동 |
| F8-T04 | 조 배지 한국어 "3조" 표시 | 수동 |
| F8-T05 | 조 배지 영어 "Group 3" 표시 | 수동 |

### 5.9 F9 — 통합 (10개 자동 + 8개 수동)

**자동**:

| ID | 시험 항목 |
|----|-----------|
| F9-T01 | `flutter test` 전체 통과 (기존 90 + Phase F 신규 ~50) |
| F9-T02 | `flutter analyze` 오류 0 |
| F9-T03 | F1-T15: 기존 lotto645 colorZone 회귀 |
| F9-T04 | F6-T02: lotto645 결과 화면 LottoBall 6개 회귀 |
| F9-T05 | F6-T03: powerball 5+1 표시 회귀 |
| F9-T06 | F7-T04: lotto645 필터 annuity720 숨김 |
| F9-T07 | B-T01~T17 (기존 로또645 회귀 시험) 전체 PASS |
| F9-T08 | C-T01~T15 (기존 게임 타입 생성 로직 회귀 시험) 전체 PASS |
| F9-T09 | D7-T01~T06 (기존 LottoBall 위젯 회귀 시험) 전체 PASS |
| F9-T10 | D8-T01~T02 (기존 결과 화면 회귀 시험) 전체 PASS |

**수동 체크리스트**:

| 체크 | 항목 |
|------|------|
| [ ] | 게임 드롭다운에서 "연금복권720+" 선택 가능 |
| [ ] | 선택 시 스낵바 초기화 메시지 표시 |
| [ ] | 옵션 모달 → "조 고정" 입력 필드, "조 제외" 입력 필드 표시 |
| [ ] | 자동선택으로 5세트 생성 → 결과 화면에 `SerialNumberRow` 5개 표시 |
| [ ] | 조 고정=3 설정 후 생성 → 모든 세트 "3조" 표시 |
| [ ] | 저장 후 내 번호 화면 → "연금복권720+" 배지 + 숫자 표시 |
| [ ] | 필터 "연금복권720+" → 다른 게임 번호 숨김 |
| [ ] | 앱 재시작 후 annuity720 선택 유지 확인 |

---

## 6. 통과/실패 기준

### 6.1 PASS 기준 (모두 충족해야 함)

| 항목 | 기준 |
|------|------|
| 자동 테스트 | `flutter test` 전체 PASS, 기존 90개 포함 모두 통과 |
| 정적 분석 | `flutter analyze` — error 0, warning 0 |
| l10n 생성 | `flutter gen-l10n` 오류 없음 |
| 회귀 | 기존 B-T01~T17, C-T01~T15, D7~D10 시험 모두 통과 |
| 수동 UI | F9 수동 체크리스트 8개 항목 전부 체크 |

### 6.2 FAIL 기준 (하나라도 해당하면 해당 STEP 재작업)

| 항목 | 기준 |
|------|------|
| 기존 테스트 실패 | 기존 90개 중 1개라도 새로 실패 |
| 신규 테스트 실패 | F1~F8 시험 중 1개라도 실패 |
| analyze 오류 | error 1개 이상 |
| 생성 로직 오류 | 조 범위 벗어난 숫자 생성 (1~5 외) |
| 자리 오류 | digit 0~9 외 숫자 생성 |
| 기존 게임 영향 | lotto645/powerball 결과 화면 표시 이상 |

### 6.3 경고 수준 (Fix 권장, 즉시 블로킹 아님)

- MT(기계번역) 마킹된 일본어·중국어·태국어·베트남어 번역 품질 미검수  
- `colorZoneBounds` placeholder 값 문서화 필요  

---

## 7. 자동시험 설정 및 계획

### 7.1 테스트 파일 배치

```
test/
  unit/
    game_type_test.dart            ← F1 시험 추가 (기존 파일)
    generated_numbers_test.dart    ← F2 Provider 시험 추가 (기존 파일)
    local_lotto_service_test.dart  ← F3 시험 추가 (기존 파일)
  widget/
    offline_home_screen_test.dart  ← F4 시험 추가 (기존 파일)
    digit_box_test.dart            ← F5 시험 (신규 파일)
    offline_result_screen_test.dart← F6 시험 추가 (기존 파일)
    offline_my_numbers_screen_test.dart ← F7 시험 추가 (기존 파일)
```

### 7.2 CI 실행 순서

```powershell
# 워크스페이스 루트: h:\_Lotto_picker_app\pick_wizard\mobile_app
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"

# 1단계: 의존성
flutter pub get

# 2단계: 코드 생성 (build_runner)
dart run build_runner build --delete-conflicting-outputs

# 3단계: l10n 생성
flutter gen-l10n

# 4단계: 정적 분석
flutter analyze

# 5단계: 전체 단위 테스트
flutter test test/unit/

# 6단계: 전체 위젯 테스트
flutter test test/widget/

# 7단계: 전체 통합 실행
flutter test
```

### 7.3 STEP별 부분 실행 명령

| STEP | 명령 |
|------|------|
| F-1 | `flutter test test/unit/game_type_test.dart` |
| F-2 | `flutter test test/unit/generated_numbers_test.dart` |
| F-3 | `flutter test test/unit/local_lotto_service_test.dart` |
| F-4 | `flutter test test/widget/offline_home_screen_test.dart` |
| F-5 | `flutter test test/widget/digit_box_test.dart` |
| F-6 | `flutter test test/widget/offline_result_screen_test.dart` |
| F-7 | `flutter test test/widget/offline_my_numbers_screen_test.dart` |
| F-8 | `flutter gen-l10n && flutter analyze` |
| F-9 | `flutter test && flutter analyze` |

### 7.4 테스트 개수 예측

| 구분 | 기존 | Phase F 신규 | 합계 |
|------|------|-------------|------|
| unit/game_type | 15 | +15 | 30 |
| unit/generated_numbers | 7 | +5 | 12 |
| unit/local_lotto_service | 32 | +14 | 46 |
| unit/hive_adapter | 4 | 0 | 4 |
| widget/offline_home_screen | 15 | +8 | 23 |
| widget/digit_box | 0 | +7 | 7 |
| widget/offline_result_screen | 3 | +3 | 6 |
| widget/offline_my_numbers_screen | 4 | +4 | 8 |
| widget/lotto_ball | 6 | 0 | 6 |
| **합계** | **90** | **+56** | **≈142** |

---

## 8. STEP별 모델 선택 가이드

### Think 모델 사용 권장 (깊은 판단 필요)

| STEP | 이유 |
|------|------|
| **F-1** (GameCategory + GameType) | 기존 코드와의 호환성 결정, `GameCategory` 레이어 설계 트레이드오프, `annuity720`의 `hasBonus=true` 의미 확정, 기존 `colorZoneFor` 호환 경계 판단 |
| **F-3** (시리얼 생성 로직) | `validateSerialParameters` 엣지케이스 설계, 독립 자리 생성 vs 풀 선택의 개념적 분리, 기존 `validateParameters`와 분리 여부 판단, `_buildGenerated` 재활용 가부 |

### Auto 모델 사용 권장 (패턴 적용, 구현 중심)

| STEP | 이유 |
|------|------|
| **F-0** | 단순 테스트 실행 확인 |
| **F-2** | Provider 2개 추가 — 기존 패턴 그대로 복사 수준 |
| **F-4** | 기존 드롭다운 구현 패턴 반복, 분기 조건만 추가 |
| **F-5** | 새 위젯이지만 단순 StatelessWidget — DigitBox는 Text+Container 수준 |
| **F-6** | 기존 결과 화면 `hasBonus` 분기 패턴 반복 |
| **F-7** | 기존 내 번호 화면 분기 패턴 반복 |
| **F-8** | ARB 파일 키 추가 — 기계적 작업 |
| **F-9** | 명령 실행 + 체크리스트 확인 |

---

## 9. STEP별 실행 지시 프롬프트

> **사용법**: 각 STEP을 하나씩 순서대로 Cursor 에이전트에 붙여넣기.  
> 이전 STEP의 완료 기준을 확인한 후 다음 STEP 진행.  
> **(Think)** 표시된 STEP은 Think 모델로, 나머지는 Auto 모델로 실행.

---

### STEP F-0 — 사전 확인 (Auto)

```
현재 상태를 확인하라:

1. pick_wizard/mobile_app/ 디렉터리에서 flutter test 를 실행하라.
2. flutter analyze 를 실행하라.
3. 결과를 보고하라:
   - 총 테스트 수, PASS/FAIL 수
   - analyze 오류/경고 수
   - 현재 pubspec.yaml 의 version 값

완료 기준: flutter test 전체 PASS (90개), flutter analyze 오류 0.
이 기준을 만족하지 못하면 원인을 보고하고 멈춰라.
멈추지 않고 다음을 진행하면 안 된다.
```

---

### STEP F-1 — GameCategory + annuity720 GameType (Think)

```
z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md 의 섹션 3.1 을 참고하라.

[구현] lib/core/models/game_type.dart 수정:

1. 파일 최상단에 enum GameCategory { ballPick, serial } 추가.

2. GameTypeId enum 끝에 annuity720 추가:
   enum GameTypeId {
     lotto645, powerball, megaMillions, winForLife,
     annuity720,   // 반드시 마지막 (Hive index 4 보장)
   }

3. GameType 클래스에 필드·getter 추가:
   - final GameCategory category; (생성자 파라미터, 기본값: GameCategory.ballPick)
   - bool get isSerial => category == GameCategory.serial;
   - bool get isBallPick => category == GameCategory.ballPick;
   기존 모든 GameType 생성자 호출은 category 파라미터 없이도 동작해야 한다.

4. GameTypes 클래스에 annuity720 상수 추가:
   static const annuity720 = GameType(
     id: GameTypeId.annuity720,
     mainMin: 0, mainMax: 9, mainCount: 6,
     bonusMin: 1, bonusMax: 5, bonusCount: 1,
     bonusBallColorArgb: 0xFF7B1FA2,
     colorZoneBounds: [1, 3, 5, 7, 9],
     category: GameCategory.serial,
   );

5. GameTypes.all 리스트에 annuity720 추가 (끝에).

[시험] test/unit/game_type_test.dart 에 F1-T01~T15 시험 추가:
- 파일 기존 시험(A1-T01~T15) 아래에 추가한다.
- 056 문서 섹션 5.1 의 항목 15개를 모두 구현한다.

[실행]
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter test test/unit/game_type_test.dart
flutter analyze

완료 기준: F1-T01~T15 전체 PASS + 기존 A1-T01~T15 회귀 PASS + flutter analyze 오류 0.
```

---

### STEP F-2 — Provider 확장 (Auto)

```
z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md 의 섹션 3.3 을 참고하라.
STEP F-1 결과물을 사용한다.

[구현] lib/offline/providers/offline_providers.dart 수정:

1. 파일 하단에 시리얼 전용 Provider 2개 추가:
   final offlineSerialFixedGroupProvider = StateProvider<int?>((ref) => null);
   final offlineSerialExcludeGroupsProvider = StateProvider<List<int>>((ref) => []);

2. offlineAlgorithmsProvider 를 다음과 같이 수정:
   - Provider<List<OfflineAlgorithmInfo>> 를 아래와 같이 교체:
     final offlineAlgorithmsProvider = Provider<List<OfflineAlgorithmInfo>>((ref) {
       final gt = ref.watch(offlineSelectedGameTypeProvider);
       if (gt.isSerial) return const [OfflineAlgorithmInfo(id: 1)];
       return _kAlgorithms;
     });

[시험] test/unit/generated_numbers_test.dart 에 F2-T01~T05 추가:
- 056 문서 섹션 5.2 의 항목 5개를 구현한다.
- F2-T03~T05 는 ProviderContainer + offlineSelectedGameTypeProvider 를
  annuity720 / lotto645 로 override 하여 offlineAlgorithmsProvider 값을 검사한다.

[실행]
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter test test/unit/generated_numbers_test.dart
flutter analyze

완료 기준: F2-T01~T05 PASS + 기존 generated_numbers 시험 회귀 PASS.
```

---

### STEP F-3 — 시리얼 생성 로직 (Think)

```
z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md 의 섹션 3.2 전체를 참고하라.

[구현] lib/offline/services/local_lotto_service.dart 수정:

1. 파일 하단에 validateSerialParameters 함수 추가:
   (bool, String?) validateSerialParameters({
     required int nSets,
     int? fixedGroup,
     List<int>? excludeGroups,
   })
   검증 항목:
   - nSets: 1 ~ 100
   - fixedGroup: null 또는 1~5
   - excludeGroups: 비어있거나, 각 원소 1~5, 중복 없음, 최대 4개
   - fixedGroup != null && (excludeGroups?.contains(fixedGroup) == true) → 오류
   - 사용 가능한 조 수 = 5 - (excludeGroups?.length ?? 0), 이 값이 1 미만이면 오류
     단, fixedGroup != null 이면 풀 크기 검사 생략 (고정값 사용이므로 항상 가능)

2. generateSerial 함수 추가:
   GeneratedNumbers generateSerial({
     required GameType gameType,
     required int nSets,
     int? fixedGroup,
     List<int>? excludeGroups,
   })
   구현 규칙:
   - validateSerialParameters 로 검증 후 실패 시 ArgumentError
   - 그룹 풀 = [1,2,3,4,5] - (excludeGroups ?? [])
   - 각 세트: group = fixedGroup ?? groupPool.random(), digits = List.generate(6, (_)=>Random().nextInt(10))
   - _buildGenerated 호출:
       sets = [[d0,d1,d2,d3,d4,d5], ...] (정렬하지 않는다)
       bonusBalls = [group, group, ...]
   - 반환 GeneratedNumbers.gameTypeId == GameTypeId.annuity720

3. OfflineGenerateNotifier.generate() 수정:
   algo == null 체크 전에, gameType.isSerial 이면 algo.id 무관하게
   generateSerial 로 바로 분기한다:
   if (gameType.isSerial) {
     generated = generateSerial(
       gameType: gameType,
       nSets: nSets,
       fixedGroup: ref.read(offlineSerialFixedGroupProvider),
       excludeGroups: ref.read(offlineSerialExcludeGroupsProvider).isEmpty
           ? null
           : List<int>.from(ref.read(offlineSerialExcludeGroupsProvider)),
     );
   } else if (algo.id == 1) {
     // 기존 generateQuickPick
   } else if (algo.id == 9) {
     // 기존 generateMonteCarloTop
   }
   시리얼 결과의 algorithmName = 'Serial Quick Pick' 으로 설정.

4. _canGenerate 관련 처리는 이 STEP에서 하지 않는다 (STEP F-4에서 처리).

[시험] test/unit/local_lotto_service_test.dart 에 F3-T01~T14 추가:
- 056 문서 섹션 5.3 의 항목 14개를 구현한다.
- 기존 B-T01~T17, C-T01~T15 시험은 변경하지 않고 그대로 통과해야 한다.

[실행]
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter test test/unit/local_lotto_service_test.dart
flutter analyze

완료 기준: F3-T01~T14 PASS + 기존 B-T01~T17, C-T01~T15 회귀 PASS.
```

---

### STEP F-4 — 홈 화면 annuity720 드롭다운 + 옵션 모달 분기 (Auto)

```
z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md 의 섹션 3.3, 3.5.1, 3.7 을 참고하라.

[구현] lib/offline/screens/offline_home_screen.dart 수정:

1. 게임 드롭다운에 annuity720 항목 추가:
   - GameTypes.all 이 이제 5개이므로 자동으로 포함됨 (별도 목록 하드코딩이 아니라면)
   - 표시 레이블: "🇰🇷 ${l10n.gameAnnuity720}" (annuity720은 한국 게임)
   - 기존 lotto645도 "🇰🇷" 이모지 유지

2. 게임 드롭다운 onChanged 에 시리얼 Provider 초기화 추가:
   ref.read(offlineSerialFixedGroupProvider.notifier).state = null;
   ref.read(offlineSerialExcludeGroupsProvider.notifier).state = [];

3. _canGenerate() 에 시리얼 분기 추가:
   if (gameType.isSerial) {
     final excludeGroups = ref.read(offlineSerialExcludeGroupsProvider);
     final fixedGroup = ref.read(offlineSerialFixedGroupProvider);
     if (fixedGroup != null && excludeGroups.contains(fixedGroup)) return false;
     final available = 5 - excludeGroups.length;
     return available >= 1;
   }
   // else: 기존 볼 픽 로직

4. _AlgorithmOptionsSheetContent (또는 옵션 모달 위젯) 수정:
   gameType.isSerial 이면 아래 두 섹션을 표시하고, 볼 관련 섹션은 숨긴다:
   a) "조 고정" TextField:
      - 힌트: l10n.serialFixedGroupHint (빈칸=무작위)
      - onChanged: 정수 1~5 파싱 후 offlineSerialFixedGroupProvider 업데이트
        파싱 실패 또는 빈 문자열이면 null로 설정
      - 초기값: offlineSerialFixedGroupProvider 현재값
   b) "조 제외" TextField:
      - 힌트: l10n.serialExcludeGroupsHint (1~5, 최대 4개)
      - 쉼표 구분 정수 파싱, 1~5 범위 내 중복 없는 최대 4개
      - onChanged: 파싱 결과로 offlineSerialExcludeGroupsProvider 업데이트
      - 초기값: offlineSerialExcludeGroupsProvider 현재값

   gameType.isSerial == false 이면 기존 볼 포함/제외 + 보너스 볼 섹션 표시 (변경 없음).

[시험] test/widget/offline_home_screen_test.dart 에 F4-T01~T08 추가.
기존 D1~D11 시험은 변경하지 않고 회귀 통과해야 한다.

[실행]
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter test test/widget/offline_home_screen_test.dart
flutter analyze

완료 기준: F4-T01~T08 PASS + 기존 D1, D2, D4~D6, D11 시험 회귀 PASS.
```

---

### STEP F-5 — DigitBox + SerialNumberRow 위젯 (Auto)

```
z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md 의 섹션 3.4 를 참고하라.

[구현 1] lib/presentation/widgets/digit_box.dart 신규 생성:
class DigitBox extends StatelessWidget {
  const DigitBox({super.key, required this.digit, this.isHighlighted = false});
  final int digit;     // 0~9
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    // SizedBox(width:36, height:36) 안에
    // DecoratedBox (borderRadius:4, color: isHighlighted?0xFF7B1FA2:0xFFF5F5F5)
    // 중앙 Text(digit.toString(), bold, 16sp,
    //           color: isHighlighted?Colors.white:Colors.black)
  }
}

[구현 2] lib/presentation/widgets/serial_number_row.dart 신규 생성:
class SerialNumberRow extends StatelessWidget {
  const SerialNumberRow({
    super.key,
    required this.group,    // 1~5
    required this.digits,   // 길이 6, 각 0~9
  });
  final int group;
  final List<int> digits;

  @override
  Widget build(BuildContext context) {
    // Row:
    //   Container(보라색 배지, padding 8x4):
    //     Text('${group}조', color:white, bold)    ← l10n 키: annuity720GroupBadge
    //   SizedBox(width:8)
    //   ...digits.map((d) => Padding(right:4, child: DigitBox(digit:d)))
    //   (마지막 DigitBox는 오른쪽 padding 불필요)
  }
}

[시험] test/widget/digit_box_test.dart 신규 생성:
056 문서 섹션 5.5 의 F5-T01~T07 시험 구현.

[실행]
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter test test/widget/digit_box_test.dart
flutter analyze

완료 기준: F5-T01~T07 PASS, flutter analyze 오류 0.
```

---

### STEP F-6 — 결과 화면 시리얼 분기 (Auto)

```
z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md 의 섹션 3.5.2 를 참고하라.

[구현] lib/offline/screens/offline_result_screen.dart 수정:

현재 각 세트 번호를 LottoBall 로 표시하는 부분을 다음과 같이 분기한다:

final gameType = GameTypes.fromId(widget.generated.gameTypeId);

// 세트 번호 표시 (기존 hasBonus 분기 앞에 isSerial 분기 추가)
if (gameType.isSerial) {
  // bonusBalls[setIndex]: 조(1~5)
  // numbers: [d0,d1,d2,d3,d4,d5]
  SerialNumberRow(
    group: widget.generated.bonusBalls[setIndex],
    digits: widget.generated.results[setIndex].numbers,
  )
} else {
  // 기존 hasBonus 분기 (변경 없음)
}

[시험] test/widget/offline_result_screen_test.dart 에 F6-T01~T03 추가:
- F6-T01: annuity720 GeneratedNumbers 생성 후 결과 화면 렌더링 → SerialNumberRow key/type finder로 존재 확인
- F6-T02: lotto645 GeneratedNumbers → LottoBall 6개 (기존 D8-T01 회귀)
- F6-T03: powerball GeneratedNumbers → 5+1 표시 (기존 D8-T02 회귀)

[실행]
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter test test/widget/offline_result_screen_test.dart
flutter analyze

완료 기준: F6-T01~T03 PASS + 기존 D8-T01~T02 회귀 PASS.
```

---

### STEP F-7 — 내 번호 화면 시리얼 처리 (Auto)

```
z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md 의 섹션 3.5.3 을 참고하라.

[구현] lib/offline/screens/offline_my_numbers_screen.dart 수정:

1. 각 번호 카드의 게임 타입 배지 처리에 annuity720 추가:
   GameTypeId.annuity720 → l10n.gameAnnuity720 텍스트, 보라색 배경 배지

2. annuity720 카드의 번호 표시 변경:
   gameType.isSerial 이면 LottoBall 대신 아래 표시:
   Text(
     // "3조  472815" 형식 — l10n 없이 직접 포맷팅 또는 l10n.annuity720FullFormat 사용
     '${bonusBalls[0]}조  ${numbers.join('')}',
     style: 굵은 글씨,
   )
   단, 저장 번호가 여러 세트인 경우 각 세트마다 한 줄씩 표시.

3. 필터 드롭다운에 annuity720 항목 추가:
   DropdownMenuItem(value: GameTypeId.annuity720, child: Text(l10n.gameAnnuity720))

[시험] test/widget/offline_my_numbers_screen_test.dart 에 F7-T01~T04 추가.
기존 D9-T01, D10-T01~T03 회귀 확인.

[실행]
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter test test/widget/offline_my_numbers_screen_test.dart
flutter analyze

완료 기준: F7-T01~T04 PASS + 기존 D9, D10 시험 회귀 PASS.
```

---

### STEP F-8 — 다국어 ARB 키 추가 (Auto)

```
z_Dev_Docs/056_PhaseF_Annuity720_기획설계구현시험.md 의 섹션 3.8 을 참고하라.

[구현] lib/l10n/ 디렉터리의 ARB 파일 6개 수정:
app_ko.arb, app_en.arb, app_ja.arb, app_zh.arb, app_th.arb, app_vi.arb

아래 9개 키를 각 ARB 파일에 추가하라.
플레이스홀더가 있는 키는 ARB placeholders 문법을 정확히 사용하라:

키 1) "gameAnnuity720"
  ko: "연금복권720+"
  en: "Annuity 720+"
  ja: "年金くじ720+" // MT(미검수)
  zh: "年金彩票720+" // MT(미검수)
  th: "ลอตเตอรี่บำนาญ720+" // MT(미검수)
  vi: "Xổ số hưu trí 720+" // MT(미검수)

키 2) "annuity720GroupBadge"  [placeholder: group, type: int]
  ko: "{group}조"
  en: "Group {group}"
  (나머지 언어 MT 적용)

키 3) "annuity720FullFormat"  [placeholders: group(int), digits(String)]
  ko: "{group}조 {digits}"
  en: "Group {group}: {digits}"
  (나머지 언어 MT 적용)

키 4) "serialFixedGroupLabel"
  ko: "조 고정"
  en: "Fix Group"
  (나머지 MT)

키 5) "serialFixedGroupHint"
  ko: "1~5 중 1개 (빈칸=무작위)"
  en: "1–5, blank = random"
  (나머지 MT)

키 6) "serialExcludeGroupsLabel"
  ko: "조 제외"
  en: "Exclude Groups"
  (나머지 MT)

키 7) "serialExcludeGroupsHint"
  ko: "1~5, 최대 4개"
  en: "1–5, up to 4"
  (나머지 MT)

키 8) "serialGroupRange"
  ko: "조 범위: 1~5"
  en: "Group range: 1–5"
  (나머지 MT)

키 9) "serialDigitRange"
  ko: "각 자리: 0~9"
  en: "Each digit: 0–9"
  (나머지 MT)

MT(미검수) 주석 형식: "@키이름" 객체에 "description": "MT(미검수) - 검토 필요" 추가.

[실행]
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter gen-l10n
flutter analyze

완료 기준: flutter gen-l10n 성공, flutter analyze 오류 0.
```

---

### STEP F-9 — 전체 통합 검증 (Auto)

```
지금까지 구현한 Phase F 전체 코드가 함께 정상 동작하는지 최종 검증하라.

[자동 시험 전체 실행]
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter test
flutter analyze

기대 결과:
- 전체 시험 PASS (약 140개 이상)
- 기존 90개 시험 전부 회귀 PASS
- flutter analyze 오류 0

[결과 보고 항목]
- 총 시험 수 및 PASS/FAIL 수
- FAIL이 있다면 실패 시험 ID + 오류 메시지
- analyze 오류/경고 수

[실패 시 행동 지침]
- 기존 시험 FAIL → 해당 STEP으로 돌아가 회귀 원인 수정 후 F-9 재실행
- 신규 시험 FAIL → 해당 STEP 수정 후 재실행
- analyze 오류 → 해당 파일 수정 후 재실행
- 모두 통과하면 아래 수동 체크리스트를 출력하고 사용자에게 확인 요청

[수동 체크리스트 출력]
아래 항목을 에뮬레이터 또는 실기기에서 확인 후 체크하라:

[ ] 게임 드롭다운에서 "연금복권720+" 선택 가능 (5번째 항목)
[ ] 선택 시 스낵바 포함/제외 초기화 메시지 표시
[ ] 옵션 모달 → "조 고정", "조 제외" 필드 표시, 볼 섹션 없음
[ ] 알고리즘 목록에 "알고리즘 9" 없고 "자동선택"만 표시
[ ] 자동선택으로 5세트 생성 → 결과 화면에 "{N}조 XXXXXX" 형식 5줄 표시
[ ] 조 고정=3 설정 후 생성 → 모든 결과 줄 "3조" 표시
[ ] 저장 버튼 탭 후 내 번호 화면 → "연금복권720+" 보라색 배지 표시
[ ] 내 번호 필터 "연금복권720+" → 다른 게임 번호 숨김
[ ] 앱 재시작 후 annuity720 선택 유지 (SharedPreferences)
[ ] lotto645 / powerball 기존 동작 이상 없음 (회귀)

완료 기준: 자동 시험 전체 PASS + 수동 체크리스트 10개 항목 전부 체크.

[버전 업]
모든 검증 통과 후:
pubspec.yaml 의 version 을 1.1.0+2 → 1.2.0+3 으로 올려라.
(연금복권720+ 신규 게임 타입 추가 = minor 버전 증가)
```

---

## 부록 A. 설계 결정 사항 (ADR)

| # | 결정 항목 | 선택 | 이유 |
|---|-----------|------|------|
| D1 | `annuity720`의 `hasBonus` | **true** | `bonusBalls` 필드를 조(group) 저장에 재활용, 모델 변경 없음 |
| D2 | `GameCategory` 위치 | **`game_type.dart` 내 enum** | 별도 파일 불필요, 스코프 명확 |
| D3 | Hive 스키마 버전 | **2 유지 (변경 없음)** | `annuity720`은 enum 끝 추가로 기존 인덱스 0~3 불변 |
| D4 | 자리별 고정 옵션 | **v1 미구현** | UX 복잡도 대비 사용 빈도 낮음, 구조만 설계 |
| D5 | `generateSerial` 위치 | **`local_lotto_service.dart` 내 최상위 함수** | 기존 패턴(`generateQuickPick` 등) 일관성 |
| D6 | 결과 숫자 정렬 | **정렬 없음** | 시리얼 번호는 자리 순서가 의미 있음 |
| D7 | `colorZoneBounds` placeholder | **[1,3,5,7,9]** | 5개 유효 경계 필요 (기존 코드 불변), 실제 사용 안 함 |

## 부록 B. 기존 테스트 회귀 체크리스트

Phase F 완료 후 아래 시험 파일이 모두 통과해야 한다:

| 파일 | 시험 수 | 내용 |
|------|---------|------|
| `game_type_test.dart` | A1-T01~T15 (기존) + F1-T01~T15 | GameType 모델 전체 |
| `generated_numbers_test.dart` | 기존 7개 + F2-T01~T05 | GeneratedNumbers + Provider |
| `hive_adapter_test.dart` | A4-T01~T04 | Hive 어댑터 (변경 없음) |
| `local_lotto_service_test.dart` | B-T01~T17, C-T01~T15 (기존) + F3-T01~T14 | 생성 로직 전체 |
| `offline_home_screen_test.dart` | D1~D11 (기존) + F4-T01~T08 | 홈 화면 전체 |
| `digit_box_test.dart` | F5-T01~T07 | 신규 위젯 |
| `offline_result_screen_test.dart` | D8-T01~T02 (기존) + F6-T01~T03 | 결과 화면 전체 |
| `offline_my_numbers_screen_test.dart` | D9~D10 (기존) + F7-T01~T04 | 내 번호 화면 전체 |
| `lotto_ball_test.dart` | D7-T01~T06 | LottoBall 위젯 (변경 없음) |
