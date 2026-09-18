# 053. PickWizard 게임 타입 확장 — 에이전트 실행 프롬프트 목록

**문서 번호**: 053  
**작성일**: 2026-05-06  
**용도**: 051·052 문서 기반으로 Cursor auto 에이전트에게 단계별로 지시할 프롬프트 모음  
**사용법**: 각 STEP을 순서대로 하나씩 에이전트에 붙여넣기. 이전 STEP 완료(테스트 통과) 확인 후 다음 STEP 진행.

---

## 사전 확인 (에이전트 지시 전 직접 수행)

```powershell
cd "h:\_Lotto_picker_app\pick_wizard\mobile_app"
flutter test   # 기존 placeholder 테스트 통과 확인
```

---

## STEP 0 — 시험 인프라 세팅

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "0. 시험 인프라 사전 설정" 섹션을 실행하라.

구체적으로:
1. pick_wizard/mobile_app/pubspec.yaml 의 dev_dependencies에 다음 두 패키지를 추가하라.
   - mocktail: ^1.0.4
   - hive_test: ^1.0.1
   최신 버전을 pub.dev에서 확인하여 적용하라.

2. 아래 디렉터리와 파일을 생성하라 (내용은 빈 파일로):
   - test/unit/game_type_test.dart
   - test/unit/generated_numbers_test.dart
   - test/unit/hive_adapter_test.dart
   - test/unit/local_lotto_service_test.dart
   - test/widget/offline_home_screen_test.dart
   - test/widget/offline_result_screen_test.dart
   - test/widget/offline_my_numbers_screen_test.dart
   - test/helpers/test_helpers.dart

3. test/helpers/test_helpers.dart 에 아래 두 함수를 구현하라:
   - makeContainer({List<Override> overrides}): ProviderContainer 반환
   - makeGeneratedNumbers(GameType gt, {int nSets = 3}): 더미 GeneratedNumbers 반환
   (GameType 모델은 아직 없으므로 dynamic 타입으로 stub 처리하고, STEP 1 완료 후 타입 교체한다.)

4. pick_wizard/mobile_app/ 에서 flutter pub get 을 실행하라.

완료 기준: flutter pub get 성공, 위 파일 모두 존재.
```

---

## STEP 1 — Phase A1: GameType 모델 생성

```
z_Dev_Docs/051_GameType_Expansion_Plan.md 섹션 3.2.1 과
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "A1. GameType 모델 신규 생성" 섹션을 참고하라.

[구현] lib/core/models/game_type.dart 를 새로 만들어라.

요구사항:
- enum GameTypeId { lotto645, powerball, megaMillions, winForLife }
- class GameType (const constructor):
    필드: id, mainMin, mainMax, mainCount,
          bonusMin(int?), bonusMax(int?), bonusCount(기본0),
          bonusBallColorArgb(기본0), colorZoneBounds(List<int> 길이=5)
    getter: hasBonus (bonusCount > 0), mainPoolSize, bonusPoolSize(int?), colorZoneFor(int n) → int 0~4
- class GameTypes (정적 상수 4개 + all + fromId):
    lotto645:    mainMin=1, mainMax=45, mainCount=6,  bonus없음, colorZoneBounds=[10,20,30,40,45]
    powerball:   mainMin=1, mainMax=69, mainCount=5,  bonusMin=1,bonusMax=26,bonusCount=1, colorArgb=0xFFE53935, colorZoneBounds=[14,28,42,56,69]
    megaMillions:mainMin=1, mainMax=70, mainCount=5,  bonusMin=1,bonusMax=25,bonusCount=1, colorArgb=0xFFFFB300, colorZoneBounds=[14,28,42,56,70]
    winForLife:  mainMin=1, mainMax=48, mainCount=5,  bonusMin=1,bonusMax=18,bonusCount=1, colorArgb=0xFFFDD835, colorZoneBounds=[10,20,30,40,48]

colorZoneFor(n) 구현 규칙:
  colorZoneBounds = [b0, b1, b2, b3, b4]
  n <= b0 이면 0, n <= b1 이면 1, ..., n <= b4 이면 4

[시험] test/unit/game_type_test.dart 에 052 문서의 A1-T01~T15 시험 항목을 모두 구현하라.
052 문서의 "test/unit/game_type_test.dart 스켈레톤" 코드를 시작점으로 사용하라.

[실행]
cd pick_wizard/mobile_app
flutter test test/unit/game_type_test.dart

완료 기준: A1-T01~T15 전체 PASS, flutter analyze 오류 0.
```

---

## STEP 2 — Phase A2: 하드코딩 상수 제거 (리팩토링)

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "A2. LottoConstants 의존 코드 리팩토링" 섹션을 참고하라.
STEP 1에서 만든 lib/core/models/game_type.dart 를 활용한다.

[구현 1] lib/offline/services/local_lotto_service.dart 수정:
- 파일 상단 _minNumber=1, _maxNumber=45, _numbersPerDraw=6, _maxExclude=39, _maxInclude=6 상수를 제거한다.
  (_monteCarloTrials=10000 은 유지)
- _hasInvalidOrDuplicate(List<int> numbers) 함수에 min, max 파라미터를 추가한다.
- getAvailableNumbers() 함수에 GameType gameType 파라미터를 추가하고, 범위를 gameType.mainMin~mainMax 로 교체한다.
- 이 시점에서는 generateQuickPick, generateMonteCarloTop6 의 시그니처는 아직 변경하지 않는다.
  (STEP 5에서 변경)
- 단, 내부에서 _minNumber, _maxNumber, _numbersPerDraw 를 직접 참조하는 부분을
  임시로 1, 45, 6 리터럴로 유지하거나, LottoConstants 상수로 교체해도 된다.

[구현 2] lib/offline/screens/offline_home_screen.dart 수정:
- _canGenerate() 내부: poolSize 계산을 45 고정값 대신 ref.read(offlineSelectedGameTypeProvider) 기반으로 교체한다.
  (offlineSelectedGameTypeProvider 는 아직 없으므로 일단 45 유지하고 TODO 주석 달아두기)
- _parseNumberList() 내부: max=45 를 gameType.mainMax 로 교체할 준비만 해두고, TODO 주석으로 표시한다.
  실제 교체는 STEP 8에서 수행한다.
- LottoConstants import 는 유지한다.

[실행]
cd pick_wizard/mobile_app
flutter analyze
flutter test test/unit/game_type_test.dart

완료 기준: flutter analyze 오류 0, game_type_test.dart PASS 유지.
```

---

## STEP 3 — Phase A3: GeneratedNumbers 모델 변경

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "A3. GeneratedNumbers 모델 변경" 섹션을 참고하라.
lib/core/models/game_type.dart (STEP 1 결과물)를 import 한다.

[구현] lib/data/models/generated_numbers.dart 수정:
- GeneratedNumbers freezed factory에 필드 2개 추가:
    @Default(GameTypeId.lotto645) GameTypeId gameTypeId,
    @Default([]) List<int> bonusBalls,
- import 에 game_type.dart 추가.
- freezed 재생성 명령 실행:
    dart run build_runner build --delete-conflicting-outputs
- 생성된 generated_numbers.freezed.dart, generated_numbers.g.dart 확인 (오류 없을 것).

[시험] test/unit/generated_numbers_test.dart 에 아래 시험 4개 추가:
- 기본값: GeneratedNumbers(...).gameTypeId == GameTypeId.lotto645
- 기본값: GeneratedNumbers(...).bonusBalls == []
- powerball 세팅: gameTypeId=powerball, bonusBalls=[18] 로 생성 후 값 확인
- copyWith: bonusBalls=[5,10] 으로 copyWith 후 값 확인

[실행]
cd pick_wizard/mobile_app
dart run build_runner build --delete-conflicting-outputs
flutter test test/unit/generated_numbers_test.dart

완료 기준: build_runner 성공, 시험 4개 PASS, flutter analyze 오류 0.
```

---

## STEP 4 — Phase A4: Hive 어댑터 수정 + DB 마이그레이션

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "A4. Hive 어댑터 재생성 + DB 초기화 마이그레이션" 섹션을 참고하라.

[구현 1] lib/data/data_sources/local/adapters/generated_numbers_adapter.dart 수정:
- write() 메서드 끝에 두 필드 추가:
    writer.writeInt(obj.gameTypeId.index);          // GameTypeId를 index(int)로 저장
    writer.writeList(obj.bonusBalls);
- read() 메서드 끝에 두 필드 읽기 추가:
    final gameTypeIndex = reader.readInt();
    final gameTypeId = GameTypeId.values[gameTypeIndex];
    final bonusBalls = (reader.readList() as List).cast<int>();
- GeneratedNumbers 생성 시 gameTypeId, bonusBalls 파라미터 추가.

[구현 2] lib/data/data_sources/local/hive_database.dart 수정:
- 상수 추가: static const int dbSchemaVersion = 2;
- static const String _schemaVersionKey = 'db_schema_version';
- initialize() 메서드에 아래 로직 추가 (Hive.openBox 이전 시점):
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt(_schemaVersionKey) ?? 0;
    if (savedVersion < dbSchemaVersion) {
      // 기존 박스 데이터 삭제 후 버전 업데이트
      // (박스가 아직 열리지 않은 상태이므로 Hive.deleteBoxFromDisk 사용)
      await Hive.deleteBoxFromDisk(generatedNumbersBox);
      await prefs.setInt(_schemaVersionKey, dbSchemaVersion);
      // 마이그레이션 플래그 저장 (앱에서 다이얼로그 표시용)
      await prefs.setBool('show_db_reset_dialog', true);
    }

[구현 3] lib/offline/screens/offline_splash_screen.dart (또는 앱 첫 화면) 수정:
- 앱 시작 후 SharedPreferences에서 'show_db_reset_dialog' == true 이면
  AlertDialog("앱 업데이트로 저장된 번호가 초기화되었습니다.") 표시 후 false로 재설정.

[시험] test/unit/hive_adapter_test.dart 에 052 문서의 A4-T01~T04 구현:
- hive_test 패키지의 setUp(setUpTestHive), tearDown(tearDownTestHive) 사용.
- 052 문서의 "hive_adapter_test.dart 스켈레톤" 코드를 시작점으로 사용.

[실행]
cd pick_wizard/mobile_app
flutter test test/unit/hive_adapter_test.dart

완료 기준: A4-T01~T04 PASS, flutter analyze 오류 0.
```

---

## STEP 5 — Phase A5·A6: Provider 추가

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "A5~A6. Provider 신규 추가" 섹션을 참고하라.

[구현] lib/offline/providers/offline_providers.dart 수정:
1. import 에 game_type.dart 추가.
2. 파일 하단(또는 적절한 위치)에 3개 Provider 추가:
   final offlineSelectedGameTypeProvider =
       StateProvider<GameType>((ref) => GameTypes.lotto645);

   final offlineBonusIncludeNumberProvider =
       StateProvider<int?>((ref) => null);

   final offlineBonusExcludeNumbersProvider =
       StateProvider<List<int>>((ref) => []);

3. offlineAlgorithmsProvider 내 하드코딩 description 문자열
   ("1~45 중 6개를 완전 무작위로 선택합니다." 등)은
   이 시점에서 game_type 기반으로 바꾸지 않는다. TODO 주석만 달아둔다.
   (STEP 8에서 처리)

4. OfflineGenerateNotifier.generate() 내부에서
   offlineSelectedGameTypeProvider 를 읽는 라인 추가:
   final gameType = ref.read(offlineSelectedGameTypeProvider);
   (아직 generateQuickPick에 전달하지는 않음 — STEP 6에서 연결)

[시험] test/unit/generated_numbers_test.dart 에 Provider 초기값 시험 3개 추가:
(ProviderContainer + test_helpers.makeContainer 사용)
- offlineSelectedGameTypeProvider 초기값 == GameTypes.lotto645
- offlineBonusIncludeNumberProvider 초기값 == null
- offlineBonusExcludeNumbersProvider 초기값 == []
그리고 gameType 변경 시험 1개:
- offlineSelectedGameTypeProvider 를 powerball로 update 후 값 확인

[실행]
cd pick_wizard/mobile_app
flutter test test/unit/generated_numbers_test.dart
flutter analyze

완료 기준: 시험 전체 PASS, flutter analyze 오류 0.
```

---

## STEP 6 — Phase B: 로또645 회귀 검증 (시험 작성 + 실행)

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "Phase B — 로또645 회귀 검증" 섹션 전체를 참고하라.
현재 local_lotto_service.dart 는 아직 GameType 파라미터를 받지 않는다.
이 STEP에서는 기존 시그니처(파라미터 없는 버전)를 그대로 두고 회귀 시험만 작성한다.

[시험] test/unit/local_lotto_service_test.dart 에
052 문서 B-T01~T17 시험 항목 전체를 구현하라.
- generateQuickPick, generateMonteCarloTop6 는 현재 시그니처(GameType 없는 버전)로 호출.
- 번호 범위 1~45, 개수 6개, 중복 없음, 정렬, 포함/제외, 오류 케이스를 모두 커버.

[실행]
cd pick_wizard/mobile_app
flutter test test/unit/local_lotto_service_test.dart

완료 기준: B-T01~T17 전체 PASS.
(이 시험들은 STEP 7 이후에도 계속 통과해야 하는 회귀 기준선이다.)
```

---

## STEP 7 — Phase C: 게임 타입별 생성 로직

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "Phase C — 게임 타입별 생성 로직" 섹션을 참고하라.

[구현] lib/offline/services/local_lotto_service.dart 대폭 수정:

1. 함수 시그니처 변경:
   - generateQuickPick 에 required GameType gameType, int? bonusIncludeNumber, List<int>? bonusExcludeNumbers 추가
   - generateMonteCarloTop6 → generateMonteCarloTop 으로 이름 변경하고 동일 파라미터 추가
   - 두 함수 모두 반환 타입을 List<List<int>> → GeneratedNumbers 로 변경

2. 내부 로직 변경:
   - _minNumber, _maxNumber, _numbersPerDraw 하드코딩을 gameType.mainMin, mainMax, mainCount 로 교체
   - 보너스 볼 생성 내부 함수 _generateBonusBall(GameType gt, int? include, List<int>? exclude) 추가:
       bonusPool = [gt.bonusMin!..gt.bonusMax!] - (exclude ?? [])
       include != null 이면 include 반환
       아니면 bonusPool 에서 랜덤 1개 반환
   - 각 함수에서 gt.hasBonus 이면 세트마다 _generateBonusBall 호출하여 bonusBalls 리스트 생성
   - GeneratedNumbers 생성 시 gameTypeId=gameType.id, bonusBalls=bonusBalls 설정

3. validateParameters 확장:
   - 기존 검증 로직을 gameType 기반으로 교체 (min/max/count 하드코딩 제거)
   - 보너스 볼 검증 추가:
       gt.hasBonus == true 이고 bonusIncludeNumber != null 이면 범위 체크
       bonusExcludeNumbers 후 가용 보너스 풀 >= 1개 체크

4. OfflineGenerateNotifier.generate() 연결:
   - STEP 5에서 읽어둔 gameType, bonusIncludeNumber, bonusExcludeNumbers 를 실제로 함수에 전달

[시험] test/unit/local_lotto_service_test.dart 에
- 기존 B-T01~T17 시험을 새 시그니처(gameType=GameTypes.lotto645 추가)에 맞게 수정
- 052 문서의 C-T01~T15 시험 항목 추가 (powerball, megaMillions, winForLife, 보너스 볼 포함/제외)

[실행]
cd pick_wizard/mobile_app
flutter test test/unit/local_lotto_service_test.dart

완료 기준: B-T01~T17 (수정된 버전) + C-T01~T15 전체 PASS, flutter analyze 오류 0.
```

---

## STEP 8 — Phase D1·D2: 게임·언어 선택 드롭다운

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "D1. 홈 화면 — 게임 선택 드롭다운" 및 "D2. 홈 화면 — 언어 선택 드롭다운" 섹션을 참고하라.

[구현] lib/offline/screens/offline_home_screen.dart 수정:

1. _buildLanguageSelector() 메서드를 _buildGameAndLanguageCard() 로 리팩토링:
   - 기존 ChoiceChip 언어 선택을 DropdownButton<Locale> 로 교체
   - 게임 선택 DropdownButton<GameType> 추가 (GameTypes.all 목록)
   - 두 드롭다운을 하나의 Card 안에 세로로 배치:
       Row: "게임" 라벨 + DropdownButton<GameType>
       Row: "언어" 라벨 + DropdownButton<Locale>
   - 게임 드롭다운 항목 레이블: 국기 이모지 + l10n 게임명
       lotto645 → "🇰🇷 로또 6/45"
       powerball → "🇺🇸 파워볼"
       megaMillions → "🇺🇸 메가밀리언"
       winForLife → "🇺🇸 Win for Life"

2. 게임 드롭다운 onChanged:
   - 이전 gameType 과 다르면 포함/제외 번호 전체 초기화 (D6 로직 함께 구현):
       ref.read(offlineIncludeNumbersProvider.notifier).state = []
       ref.read(offlineExcludeNumbersProvider.notifier).state = []
       ref.read(offlineBonusIncludeNumberProvider.notifier).state = null
       ref.read(offlineBonusExcludeNumbersProvider.notifier).state = []
   - offlineSelectedGameTypeProvider 업데이트
   - ScaffoldMessenger 스낵바 표시 (l10n.gameTypeChangedClearNumbers)

3. _canGenerate() 내 45 하드코딩 → gameType 기반 교체:
   final gameType = ref.read(offlineSelectedGameTypeProvider);
   final poolSize = gameType.mainMax - gameType.mainMin + 1 - exclude.length - ...

4. offlineAlgorithmsProvider description 문자열 TODO 주석 제거 후 gameType 기반으로 동적 변경 (선택, 여의치 않으면 생략)

[시험] test/widget/offline_home_screen_test.dart 에 052 문서 D1-T01~T06, D2-T01, D6-T01~T02 구현:
- ProviderScope + OfflineHomeScreen 렌더링
- 게임 드롭다운 존재 확인
- 기본값 "로또 6/45" 확인
- 드롭다운 4개 항목 확인
- 파워볼 선택 시 Provider 값 변경 + 스낵바 확인
- 포함/제외 번호 초기화 확인

[실행]
cd pick_wizard/mobile_app
flutter test test/widget/offline_home_screen_test.dart

완료 기준: D1-T01~T06, D6-T01~T02 PASS, flutter analyze 오류 0.
```

---

## STEP 9 — Phase D3: 게임 타입 SharedPreferences 저장/복원

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "D3. 게임 타입·언어 SharedPreferences 저장/복원" 섹션을 참고하라.

[구현] lib/offline/utils/locale_preferences.dart (또는 신규 game_preferences.dart) 수정/생성:
- saveGameType(GameTypeId id) → prefs.setString('selected_game_type', id.name)
- Future<GameTypeId> loadGameType():
    final name = prefs.getString('selected_game_type');
    return GameTypeId.values.firstWhere((e) => e.name == name,
        orElse: () => GameTypeId.lotto645);

[구현] offline_home_screen.dart 의 _OfflineHomeScreenState.initState() (또는 OfflineHomeScreen build 직후) 수정:
- loadGameType() 결과로 offlineSelectedGameTypeProvider 초기화
- 게임 드롭다운 onChanged 에서 saveGameType(newGameType.id) 호출

[수동 시험] (자동화 어려움 — 직접 확인):
- [ ] 파워볼 선택 후 앱 완전 종료(핫 리스타트 아닌 실제 재시작) → 파워볼 유지 확인
- [ ] 저장값 없는 최초 실행 → 로또6/45 표시 확인

완료 기준: flutter analyze 오류 0, 수동 시험 2항목 체크.
```

---

## STEP 10 — Phase D4·D5: 옵션 모달 — 메인 볼 + 보너스 볼 섹션

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "D4. 옵션 모달 — 메인 볼 범위 동적 표시" 및 "D5. 옵션 모달 — 보너스 볼 포함/제외 섹션" 섹션을 참고하라.

[구현] lib/offline/screens/offline_home_screen.dart 의 _AlgorithmOptionsSheetContent 수정:

1. D4 — 메인 볼 범위:
   - initState 또는 build 에서 ref.read(offlineSelectedGameTypeProvider) 로 gameType 읽기
   - _parseNumberList() 의 max=45 → gameType.mainMax 로 교체, min=1 → gameType.mainMin
   - 포함 번호 힌트: l10n.mainNumberRange(min: gt.mainMin, max: gt.mainMax) 로 동적 교체
   - 포함 번호 maxCount: gt.mainCount
   - 제외 번호 maxCount: gt.mainMax - gt.mainMin + 1 - gt.mainCount

2. D5 — 보너스 볼 섹션 (gameType.hasBonus == true 일 때만 표시):
   - 섹션 헤더: l10n.bonusBallSection(name: 게임별 보너스명)
   - "포함할 {name} 번호" TextField (최대 1개):
       onChanged: 값 파싱 후 offlineBonusIncludeNumberProvider 업데이트
   - "제외할 {name} 번호" TextField (최대 bonusMax-1개):
       onChanged: 값 파싱 후 offlineBonusExcludeNumbersProvider 업데이트
   - 보너스 볼 포함/제외 입력 초기값은 현재 Provider 값으로 설정 (initState)

3. D11 — _canGenerate() 보너스 볼 풀 부족 체크 추가:
   - gameType.hasBonus == true 이면:
       bonusExclude = ref.read(offlineBonusExcludeNumbersProvider)
       bonusInclude = ref.read(offlineBonusIncludeNumberProvider)
       bonusPool = [gt.bonusMin!..gt.bonusMax!].toSet() - bonusExclude.toSet()
       bonusInclude != null 이면 bonusPool에 bonusInclude 추가 (고정 사용이므로 항상 가능)
       bonusPool.isEmpty 이면 false 반환

[시험] test/widget/offline_home_screen_test.dart 에 D4-T01~T03, D5-T01~T04, D11-T01~T02 추가.

[실행]
cd pick_wizard/mobile_app
flutter test test/widget/offline_home_screen_test.dart

완료 기준: 누적 위젯 시험 전체 PASS, flutter analyze 오류 0.
```

---

## STEP 11 — Phase D7: LottoBall 위젯 업데이트

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "D7. LottoBall 위젯 업데이트" 섹션을 참고하라.

[구현] lib/presentation/widgets/lotto_ball.dart 수정:
1. 생성자에 파라미터 추가:
   - GameType? gameType   (null 이면 GameTypes.lotto645 기본값으로 처리)
   - bool isBonus = false

2. 색상 결정 로직 변경:
   - isBonus == true 이면:
       Color.fromARGB 로 gameType!.bonusBallColorArgb 사용
   - isBonus == false 이면:
       final zone = (gameType ?? GameTypes.lotto645).colorZoneFor(number)
       zone 0→노랑, 1→파랑, 2→빨강, 3→회색, 4→초록 (기존 색상값 유지)

3. 기존 LottoConstants.isYellow() 등 호출부를 위 로직으로 교체.
4. 기존 LottoBall 호출부 (offline_result_screen, offline_my_numbers_screen 등) 에서
   gameType 파라미터 추가 (null 전달로 기본값 처리 — 이후 STEP에서 실제 값으로 교체).

[시험] test/widget/lotto_ball_test.dart 신규 생성:
052 문서 D7-T01~T06 구현.
- lotto645 번호=10 → 노란 배경색 확인
- lotto645 번호=11 → 파란 배경색 확인
- powerball 번호=57 → 초록 배경색 확인
- powerball isBonus=true → 0xFFE53935 색상 확인
- winForLife isBonus=true → 0xFFFDD835 색상 확인
- 모든 게임·번호 조합 렌더링 오류 없음

[실행]
cd pick_wizard/mobile_app
flutter test test/widget/lotto_ball_test.dart

완료 기준: D7-T01~T06 PASS, flutter analyze 오류 0.
```

---

## STEP 12 — Phase D8: 결과 화면 5+1 분리 표시

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "D8. 결과 화면 — 5+1 분리 표시" 섹션을 참고하라.

[구현] lib/offline/screens/offline_result_screen.dart 수정:
1. 화면에 GeneratedNumbers 를 받아 gameType 을 결정:
   final gameType = GameTypes.fromId(widget.generated.gameTypeId)

2. 각 세트 번호 표시 부분:
   - gameType.hasBonus == false (lotto645):
       기존과 동일하게 6개 LottoBall(number: n, gameType: gameType) 표시
   - gameType.hasBonus == true (5+1 게임):
       메인 볼 5개 LottoBall(number: n, gameType: gameType, isBonus: false) 표시
       Text('+', style: ...) 또는 Icon 구분자
       보너스 볼 1개: LottoBall(number: bonusBalls[setIndex], gameType: gameType, isBonus: true) 표시
       bonusBalls 가 비거나 setIndex 초과이면 조용히 생략 (방어 처리)

[시험] test/widget/offline_result_screen_test.dart:
052 문서 D8-T01~T02 구현:
- lotto645 결과 → LottoBall 6개, isBonus 없음
- powerball 결과 (5세트, bonusBalls=[18]*5) → 메인 5개 + '+' + isBonus LottoBall 1개

[실행]
cd pick_wizard/mobile_app
flutter test test/widget/offline_result_screen_test.dart

완료 기준: D8-T01~T02 PASS, flutter analyze 오류 0.
```

---

## STEP 13 — Phase D9·D10: 내 번호 화면 배지 + 필터

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "D9~D10. 내 번호 화면 — 배지 + 필터" 섹션을 참고하라.

[구현] lib/offline/screens/offline_my_numbers_screen.dart 수정:

1. D9 — 게임 타입 배지:
   - 각 번호 카드에 Chip 또는 Container 배지 추가
   - 배지 텍스트: 게임 타입별 l10n 문자열 (gameLotto645, gamePowerball 등)
   - 게임 타입 아이콘/이모지 포함 (선택)
   - 5+1 게임 카드: 메인 번호 5개 + '+' + 보너스 볼 1개 표시
     (LottoBall 위젯 STEP 11 결과물 사용, isBonus: true 적용)

2. D10 — 게임 타입 필터:
   - StatefulWidget 의 로컬 상태: GameTypeId? _filterGameType (null = 전체)
   - AppBar 또는 화면 상단에 DropdownButton 추가:
       항목: "전체" (null), lotto645, powerball, megaMillions, winForLife
   - offlineSavedNumbersProvider 목록을 _filterGameType 기준으로 필터:
       _filterGameType == null 이면 전체
       아니면 .where((g) => g.gameTypeId == _filterGameType).toList()
   - 결과가 비어있으면 "저장된 번호가 없습니다" 또는 기존 빈 상태 UI 표시

[시험] test/widget/offline_my_numbers_screen_test.dart:
052 문서 D9-T01, D10-T01~T03 구현.
- 배지 위젯 존재 확인
- 필터 드롭다운 존재 확인
- 필터 "파워볼" 선택 시 lotto645 카드 사라짐 확인
- 필터 "전체" 선택 시 전체 카드 표시 확인

[실행]
cd pick_wizard/mobile_app
flutter test test/widget/offline_my_numbers_screen_test.dart

완료 기준: D9-T01, D10-T01~T03 PASS, flutter analyze 오류 0.
```

---

## STEP 14 — Phase E: 다국어 ARB 키 추가

```
z_Dev_Docs/052_GameType_Expansion_Implementation_Checklist.md 의 "Phase E — 다국어" 섹션 전체를 참고하라.
추가해야 할 키 목록: 052 문서 "E1. ARB 파일 키 추가" 의 체크리스트 항목 19개.

[구현]
1. lib/core/localization/ 디렉터리의 ARB 파일 6개를 모두 수정하라:
   app_ko.arb, app_en.arb, app_ja.arb, app_zh.arb, app_th.arb, app_vi.arb

2. 각 파일에 아래 19개 키를 추가하라. 플레이스홀더(중괄호 포함) 키는 ARB placeholders 문법을 사용하라:

   "selectGame": "게임 선택" (ko) / "Select Game" (en) / 각 언어로
   "gameLotto645": "로또 6/45" / "Lotto 6/45"
   "gamePowerball": "파워볼" / "Powerball"
   "gameMegaMillions": "메가밀리언" / "Mega Millions"
   "gameWinForLife": "Win for Life" / "Win for Life"
   "bonusBallLabel": "보너스 볼" / "Bonus Ball"
   "bonusBallNamePowerball": "파워볼 (빨간 공)" / "Powerball (Red)"
   "bonusBallNameMegaBall": "메가볼 (금색 공)" / "Mega Ball (Gold)"
   "bonusBallNameLuckyBall": "럭키볼 (노란 공)" / "Lucky Ball (Yellow)"
   "mainNumbers": "메인 번호" / "Main Numbers"
   "bonusBallSection": "보너스 볼 ({name})" / "Bonus Ball ({name})"  [placeholder: name]
   "includeBonusNumbersLabel": "포함할 {name} 번호" / "Include {name} Number"  [placeholder: name]
   "excludeBonusNumbersLabel": "제외할 {name} 번호" / "Exclude {name} Numbers"  [placeholder: name]
   "includeBonusHint": "1~{max}, 최대 1개" / "1~{max}, up to 1"  [placeholder: max]
   "excludeBonusHint": "1~{max}, 최대 {limit}개" / "1~{max}, up to {limit}"  [placeholder: max, limit]
   "mainNumberRange": "메인 번호 범위: {min}~{max}" / "Main: {min}~{max}"  [placeholder: min, max]
   "bonusNumberRange": "보너스 번호 범위: 1~{max}" / "Bonus: 1~{max}"  [placeholder: max]
   "filterAll": "전체" / "All"
   "gameTypeChangedClearNumbers": "게임 변경으로 포함/제외 번호가 초기화되었습니다" / "Game changed. Include/exclude numbers reset."

   일본어·중국어·태국어·베트남어는 기계 번역 적용 후 주석 // MT(미검수) 달아둘 것.

3. flutter gen-l10n 실행.

[실행]
cd pick_wizard/mobile_app
flutter gen-l10n
flutter analyze

완료 기준: flutter gen-l10n 성공, flutter analyze 오류 0.
```

---

## STEP 15 — 전체 통합 검증

```
지금까지 구현한 모든 코드가 함께 정상 동작하는지 최종 검증하라.

[자동 시험 전체 실행]
cd pick_wizard/mobile_app
flutter test
flutter analyze

기대 결과:
- 전체 시험 PASS (약 100개 이상)
- flutter analyze 오류 0

[수동 시험 — 에뮬레이터 또는 실기기에서 확인]
아래 항목을 순서대로 수동으로 확인하고 결과를 기록하라:

홈 화면:
- [ ] 게임 드롭다운 열면 4개 항목 표시 (로또6/45, 파워볼, 메가밀리언, Win for Life)
- [ ] 언어 드롭다운으로 영어 변경 시 게임 이름도 영어로 변경
- [ ] 파워볼 선택 → 스낵바 초기화 메시지 표시
- [ ] 앱 종료 후 재시작 → 이전 게임 타입 복원

파워볼 번호 생성:
- [ ] 알고리즘 선택 → 옵션 모달에 "파워볼" 보너스 볼 섹션 표시
- [ ] 보너스 볼 고정(예: 15) 후 5세트 생성 → 모든 세트 보너스=15
- [ ] 결과 화면: 메인 5개(흰색 구간 색상) + '+' + 빨간 공 1개

내 번호 화면:
- [ ] 저장된 파워볼 번호에 "[파워볼]" 배지 + 메인5+보너스1 표시
- [ ] 필터 "파워볼" → 다른 게임 번호 숨김
- [ ] 필터 "전체" → 전체 표시

DB 초기화:
- [ ] SharedPreferences db_schema_version 삭제 후 앱 재시작 → 경고 다이얼로그 표시
- [ ] 재시작 후 내 번호 화면 비어있음

완료 기준: 자동 시험 전체 PASS + 수동 시험 전 항목 체크.
```

---

## 빠른 참조 — STEP 순서 요약

| STEP | Phase | 핵심 작업 | 검증 명령 |
|------|-------|-----------|-----------|
| 0 | 준비 | 패키지 추가, 디렉터리 생성 | `flutter pub get` |
| 1 | A1 | GameType 모델 | `flutter test test/unit/game_type_test.dart` |
| 2 | A2 | 하드코딩 상수 제거 | `flutter analyze` |
| 3 | A3 | GeneratedNumbers 모델 | `flutter test test/unit/generated_numbers_test.dart` |
| 4 | A4 | Hive 어댑터 + DB 마이그레이션 | `flutter test test/unit/hive_adapter_test.dart` |
| 5 | A5·A6 | Provider 추가 | `flutter test test/unit/generated_numbers_test.dart` |
| 6 | B | 로또645 회귀 시험 작성 | `flutter test test/unit/local_lotto_service_test.dart` |
| 7 | C | 게임 타입별 생성 로직 | `flutter test test/unit/local_lotto_service_test.dart` |
| 8 | D1·D2·D6 | 게임·언어 드롭다운 + 초기화 | `flutter test test/widget/offline_home_screen_test.dart` |
| 9 | D3 | SharedPreferences 저장/복원 | 수동 확인 |
| 10 | D4·D5·D11 | 옵션 모달 + 보너스 볼 섹션 | `flutter test test/widget/offline_home_screen_test.dart` |
| 11 | D7 | LottoBall 위젯 | `flutter test test/widget/lotto_ball_test.dart` |
| 12 | D8 | 결과 화면 5+1 | `flutter test test/widget/offline_result_screen_test.dart` |
| 13 | D9·D10 | 내 번호 배지 + 필터 | `flutter test test/widget/offline_my_numbers_screen_test.dart` |
| 14 | E | ARB 키 추가 + gen-l10n | `flutter gen-l10n && flutter analyze` |
| 15 | 전체 | 통합 검증 | `flutter test` + 수동 |
