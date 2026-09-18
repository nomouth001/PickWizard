# 029. 다국어 지원 시스템 설계 및 구현

**작성일**: 2026-01-16  
**버전**: 1.0  
**상태**: 구현 완료 (한국어 + 영어)

---

## 목차

1. [개요](#1-개요)
2. [설계 철학](#2-설계-철학)
3. [시스템 아키텍처](#3-시스템-아키텍처)
4. [구현 상세](#4-구현-상세)
5. [사용 가이드](#5-사용-가이드)
6. [확장 로드맵](#6-확장-로드맵)
7. [참고 자료](#7-참고-자료)

---

## 1. 개요

### 1.1 목적

LuckyAI 645 앱에 확장 가능한 다국어 지원 시스템을 구축하여:
- 한국, 미국, 중국, 베트남, 태국 등 글로벌 시장 진출 기반 마련
- 새로운 언어 추가 시 최소한의 작업으로 확장 가능
- 타입 안전하고 유지보수 용이한 문자열 관리

### 1.2 지원 언어

| 언어 | 코드 | 상태 | 우선순위 |
|------|------|------|----------|
| 한국어 | `ko` | ✅ 완성 | P0 (기본) |
| 영어 | `en` | ✅ 완성 | P0 |
| 중국어 | `zh` | ⏳ 템플릿 | P1 |
| 베트남어 | `vi` | ⏳ 템플릿 | P1 |
| 태국어 | `th` | ⏳ 템플릿 | P1 |

### 1.3 핵심 요구사항

1. **플러그인 방식**: ARB 파일만 추가하면 언어 추가 완료
2. **타입 안전**: 컴파일 타임에 문자열 키 검증
3. **중앙 관리**: 모든 문자열을 한 곳에서 관리
4. **파라미터 지원**: 동적 값 삽입 가능
5. **번역 용이**: 번역가가 쉽게 작업할 수 있는 포맷

---

## 2. 설계 철학

### 2.1 플러그인 아키텍처

**핵심 개념**: "언어 추가 = 파일 1개 추가"

```
새로운 언어 추가 프로세스:
1. app_XX.arb 파일 생성 (5분)
2. 기존 한국어 ARB 복사하여 번역 (1시간)
3. supported_locales.dart에 Locale 추가 (1분)
4. flutter pub get → 자동 완료!

총 소요 시간: 약 1시간 10분
코드 변경: 단 2줄!
```

### 2.2 레이어 분리

```
┌─────────────────────────────────────┐
│  UI Layer (Widgets)                 │
│  - context.l10n.keyName 사용        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Localization Layer                 │
│  - AppLocalizations (자동 생성)     │
│  - 언어별 구현 클래스                │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  Data Layer (ARB 파일)              │
│  - app_ko.arb (한국어 데이터)        │
│  - app_en.arb (영어 데이터)          │
└─────────────────────────────────────┘
```

### 2.3 Flutter 표준 따르기

- **flutter_localizations**: 공식 패키지 사용
- **intl**: 국제화 표준 (날짜, 숫자, 통화)
- **ARB 포맷**: Application Resource Bundle (구글 표준)
- **코드 생성**: `flutter gen-l10n` 활용

---

## 3. 시스템 아키텍처

### 3.1 파일 구조

```
mobile_app/
├── l10n.yaml                        # 다국어 설정 파일
├── lib/
│   ├── l10n/                        # ARB 언어팩 디렉토리
│   │   ├── app_ko.arb              # 한국어 (77개 문자열)
│   │   ├── app_en.arb              # 영어 (77개 문자열)
│   │   ├── app_zh.arb              # 중국어 템플릿
│   │   ├── app_vi.arb              # 베트남어 템플릿
│   │   └── app_th.arb              # 태국어 템플릿
│   ├── core/
│   │   └── localization/
│   │       ├── generated/           # 자동 생성 (Git 무시)
│   │       │   ├── app_localizations.dart
│   │       │   ├── app_localizations_ko.dart
│   │       │   └── app_localizations_en.dart
│   │       └── supported_locales.dart   # 지원 언어 목록
│   └── presentation/
│       └── providers/
│           └── locale_provider.dart     # 언어 선택 상태 관리
└── pubspec.yaml                     # 다국어 패키지 의존성
```

### 3.2 데이터 흐름

```
사용자 언어 선택
       ↓
LocaleProvider 상태 변경
       ↓
MaterialApp locale 업데이트
       ↓
AppLocalizations 재생성
       ↓
context.l10n.keyName 호출
       ↓
해당 언어의 문자열 반환
```

### 3.3 주요 컴포넌트

#### 3.3.1 l10n.yaml (설정 파일)

```yaml
arb-dir: lib/l10n                    # ARB 파일 디렉토리
template-arb-file: app_ko.arb        # 기준 언어 (한국어)
output-localization-file: app_localizations.dart
output-class: AppLocalizations       # 생성될 클래스 이름
nullable-getter: false               # non-nullable
synthetic-package: false             # 실제 파일 생성
output-dir: lib/core/localization/generated
```

#### 3.3.2 ARB 파일 (JSON 기반)

```json
{
  "@@locale": "ko",
  "@@context": "LuckyAI 645 - 한국어 언어팩",
  
  "appTitle": "LuckyAI 645",
  "@appTitle": {
    "description": "앱 타이틀"
  },
  
  "drawNumber": "제 {number}회",
  "@drawNumber": {
    "description": "회차 번호",
    "placeholders": {
      "number": {
        "type": "int"
      }
    }
  }
}
```

**특징**:
- `@@locale`: 언어 코드
- `키`: 실제 문자열
- `@키`: 메타데이터 (설명, 파라미터)
- `{변수}`: 동적 값 삽입

#### 3.3.3 SupportedLocales (지원 언어 목록)

```dart
class SupportedLocales {
  static const List<Locale> locales = [
    Locale('ko', ''), // 한국어 (기본)
    Locale('en', ''), // 영어
  ];
  
  static const Locale fallbackLocale = Locale('ko', '');
  
  static String getLanguageName(String code) { ... }
  static String getLanguageFlag(String code) { ... }
}
```

**역할**:
- 지원 언어 중앙 관리
- 언어 이름, 국기 이모지 제공
- Locale 객체 생성

#### 3.3.4 LocaleProvider (상태 관리)

```dart
final localeProvider = StateProvider<Locale>((ref) {
  return SupportedLocales.fallbackLocale;
});

class LocaleNotifier {
  void changeLanguage(String languageCode) {
    final locale = SupportedLocales.findLocale(languageCode);
    ref.read(localeProvider.notifier).state = locale;
  }
}
```

**역할**:
- 현재 선택 언어 저장
- 언어 변경 트리거
- (나중에) SharedPreferences 연동

---

## 4. 구현 상세

### 4.1 pubspec.yaml 설정

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 다국어 지원
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  uses-material-design: true
  generate: true  # 코드 자동 생성 활성화
```

### 4.2 MaterialApp 설정

```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      // 다국어 설정
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,           // 앱 문자열
        GlobalMaterialLocalizations.delegate, // Material 위젯
        GlobalWidgetsLocalizations.delegate,  // Flutter 위젯
        GlobalCupertinoLocalizations.delegate, // Cupertino 위젯
      ],
      supportedLocales: SupportedLocales.locales,
      
      // 타이틀을 다국어로
      onGenerateTitle: (context) => 
        AppLocalizations.of(context)!.appTitle,
      
      home: const SplashScreen(),
    );
  }
}
```

### 4.3 코드에서 사용법

#### 4.3.1 간단한 문자열

```dart
// 하드코딩 (Before)
Text("알고리즘 선택")

// 다국어 (After)
Text(context.l10n.selectAlgorithm)
```

**확장 메서드**:
```dart
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
```

#### 4.3.2 파라미터가 있는 문자열

```dart
// ARB 파일
"drawNumber": "제 {number}회"
"generatedCount": "총 {count}개 생성됨"

// 사용
Text(context.l10n.drawNumber(1205))        // "제 1205회"
Text(context.l10n.generatedCount(5))       // "총 5개 생성됨"
```

#### 4.3.3 언어 전환

```dart
// 한국어로 변경
ref.read(localeProvider.notifier).state = Locale('ko');

// 영어로 변경
ref.read(localeProvider.notifier).state = Locale('en');

// 설정 화면 예시
DropdownButton<String>(
  value: ref.watch(localeProvider).languageCode,
  items: SupportedLocales.locales.map((locale) {
    return DropdownMenuItem(
      value: locale.languageCode,
      child: Row(
        children: [
          Text(SupportedLocales.getLanguageFlag(locale.languageCode)),
          SizedBox(width: 8),
          Text(SupportedLocales.getLanguageName(locale.languageCode)),
        ],
      ),
    );
  }).toList(),
  onChanged: (code) {
    ref.read(localeProvider.notifier).state = Locale(code!);
  },
)
```

### 4.4 ARB 파일 구조 (카테고리별)

#### 전체 문자열 목록 (77개)

```
1. 앱 전역 (1개)
   - appTitle

2. 공통 (10개)
   - confirm, cancel, close, save, delete, edit
   - loading, error, success, warning, info

3. 네비게이션 (5개)
   - home, generate, history, myNumbers, settings

4. 홈 화면 (4개)
   - latestDraw, drawNumber, bonusNumber, drawDate

5. 번호 생성 화면 (11개)
   - selectAlgorithm, numberOfSets, quickButton5/10
   - directInput, enterNumberOfSets, generateButton 등

6. 알고리즘 (21개)
   - algorithm1~7Name (각 7개)
   - algorithm1~7Desc (각 7개)
   - free, coinsPerSet

7. 결과 화면 (8개)
   - generatedNumbers, generatedCount, setNumber
   - saveToMyNumbers, share, generateAgain 등

8. 검증 메시지 (5개)
   - maxLimitTitle/Message
   - requirementTitle, requirementSelectAlgorithm 등

9. 에러 메시지 (5개)
   - errorLoadAlgorithms, errorGenerateFailed
   - errorNetwork, errorServer, errorUnknown

10. 언어 설정 (7개)
    - language, selectLanguage
    - languageKorean/English/Chinese/Vietnamese/Thai
```

### 4.5 코드 생성 프로세스

```bash
# 1. ARB 파일 작성/수정
vim lib/l10n/app_ko.arb

# 2. 코드 생성
flutter pub get
flutter gen-l10n

# 3. 생성된 파일 확인
lib/core/localization/generated/
├── app_localizations.dart          # 추상 베이스 클래스
├── app_localizations_ko.dart       # 한국어 구현
└── app_localizations_en.dart       # 영어 구현
```

**생성된 코드 예시**:

```dart
// app_localizations.dart (자동 생성)
abstract class AppLocalizations {
  String get appTitle;
  String drawNumber(int number);
  String generatedCount(int count);
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
}

// app_localizations_ko.dart (자동 생성)
class AppLocalizationsKo extends AppLocalizations {
  @override
  String get appTitle => 'LuckyAI 645';
  
  @override
  String drawNumber(int number) => '제 $number회';
  
  @override
  String generatedCount(int count) => '총 ${count}개 생성됨';
}
```

---

## 5. 사용 가이드

### 5.1 개발자 워크플로우

#### 5.1.1 새로운 문자열 추가

```
1. app_ko.arb에 추가
   "newKey": "새로운 문자열",
   "@newKey": {
     "description": "설명"
   }

2. app_en.arb에도 추가 (영어 번역)
   "newKey": "New String"

3. 코드 생성
   flutter gen-l10n

4. 사용
   Text(context.l10n.newKey)
```

#### 5.1.2 파라미터가 있는 문자열 추가

```json
// ARB 파일
"welcome": "환영합니다, {name}님!",
"@welcome": {
  "description": "환영 메시지",
  "placeholders": {
    "name": {
      "type": "String",
      "example": "홍길동"
    }
  }
}

// 사용
Text(context.l10n.welcome("홍길동"))  // "환영합니다, 홍길동님!"
```

#### 5.1.3 복수형 지원

```json
"itemCount": "{count, plural, =0{항목 없음} =1{항목 1개} other{{count}개 항목}}",
"@itemCount": {
  "placeholders": {
    "count": {
      "type": "int"
    }
  }
}
```

### 5.2 번역가 워크플로우

```
1. app_ko.arb 파일 수령
2. app_XX.arb로 복사
3. @@locale 변경
4. 각 키의 값만 번역 (키 이름은 그대로)
5. 완성된 파일 전달
```

**주의사항**:
- `@키` 메타데이터는 번역하지 않음
- `{변수}` 형식은 그대로 유지
- 주석(`_comment`)은 선택적으로 번역

### 5.3 새로운 언어 추가 (예: 일본어)

```dart
// 1. app_ja.arb 파일 생성
{
  "@@locale": "ja",
  "appTitle": "LuckyAI 645",
  "selectAlgorithm": "アルゴリズムを選択",
  ...
}

// 2. supported_locales.dart 수정
static const List<Locale> locales = [
  Locale('ko', ''),
  Locale('en', ''),
  Locale('ja', ''), // 추가!
];

static String getLanguageName(String code) {
  switch (code) {
    case 'ko': return '한국어';
    case 'en': return 'English';
    case 'ja': return '日本語'; // 추가!
    ...
  }
}

static String getLanguageFlag(String code) {
  switch (code) {
    case 'ko': return '🇰🇷';
    case 'en': return '🇺🇸';
    case 'ja': return '🇯🇵'; // 추가!
    ...
  }
}

// 3. 코드 생성
flutter pub get
flutter gen-l10n

// 완료! app_localizations_ja.dart 자동 생성됨
```

---

## 6. 확장 로드맵

### 6.1 Phase 1: 기반 구축 (✅ 완료)

**목표**: 한국어 + 영어 다국어 인프라 구축

**완료 항목**:
- ✅ l10n.yaml 설정
- ✅ ARB 파일 구조 설계 (77개 문자열)
- ✅ app_ko.arb 한국어 완성
- ✅ app_en.arb 영어 완성
- ✅ SupportedLocales 클래스
- ✅ LocaleProvider 상태 관리
- ✅ MaterialApp 다국어 설정

### 6.2 Phase 2: UI 통합 (다음 단계)

**목표**: 기존 하드코딩 문자열을 다국어로 전환

**작업 목록**:
- [ ] generate_screen.dart - `context.l10n` 사용
- [ ] home_screen.dart - 하드코딩 제거
- [ ] result_screen.dart - 다국어 적용
- [ ] splash_screen.dart - 다국어 적용
- [ ] 에러 메시지 통일

**예상 시간**: 2시간

### 6.3 Phase 3: 언어 선택 UI (그 다음)

**목표**: 사용자가 언어를 선택할 수 있는 UI 제공

**작업 목록**:
- [ ] 설정 화면 생성
- [ ] 언어 선택 위젯 (국기 아이콘)
- [ ] SharedPreferences 연동 (선택 저장)
- [ ] 앱 재시작 시 언어 복원

**UI 디자인**:
```
┌────────────────────────────┐
│  설정                       │
├────────────────────────────┤
│  언어 / Language            │
│  🇰🇷 한국어             [v] │
│  🇺🇸 English             [ ] │
│  🇨🇳 中文                [ ] │
│  🇻🇳 Tiếng Việt         [ ] │
│  🇹🇭 ภาษาไทย            [ ] │
└────────────────────────────┘
```

**예상 시간**: 3시간

### 6.4 Phase 4: 알고리즘 파라미터 다국어 (나중에)

**목표**: 알고리즘 상세 설정 화면의 모든 문자열 다국어 지원

**작업 목록**:
- [ ] 알고리즘 2 (고급 빈도): 파라미터 라벨 ARB 추가
- [ ] 알고리즘 3 (LSTM): 파라미터 라벨 ARB 추가
- [ ] 알고리즘 4 (패턴): 파라미터 라벨 ARB 추가
- [ ] 도움말 텍스트 다국어화

**예상 추가 문자열**: 약 50개

### 6.5 Phase 5: 나머지 언어 번역 (외주 또는 자동)

**목표**: 중국어, 베트남어, 태국어 번역 완료

**작업 방법**:
1. **전문 번역가 고용** (권장)
   - 비용: 약 $50/언어
   - 품질: 높음
   - 시간: 1주일

2. **ChatGPT 활용**
   - 비용: 무료
   - 품질: 중간
   - 시간: 1시간
   - 주의: 원어민 검수 필요

3. **크라우드소싱**
   - Crowdin, Lokalise 플랫폼 활용
   - 커뮤니티 기여

### 6.6 Phase 6: 백엔드 다국어 (선택)

**목표**: 알고리즘 name/description을 API에서 다국어로 제공

**설계**:
```python
# backend/app/algorithms/i18n.py
ALGORITHM_NAMES = {
    1: {
        'ko': '자동선택 (Quick Pick)',
        'en': 'Quick Pick',
        'zh': '快速选择',
    },
    2: {
        'ko': '고급 빈도 분석',
        'en': 'Advanced Frequency',
        'zh': '高级频率分析',
    },
}

# API에서 사용
@router.get("/api/algorithms")
async def get_algorithms(lang: str = 'ko'):
    algorithms = []
    for algo in algorithm_classes:
        algorithms.append({
            'id': algo.algorithm_id,
            'name': ALGORITHM_NAMES[algo.algorithm_id][lang],
            ...
        })
    return algorithms
```

**장점**:
- 번역 업데이트 시 앱 재배포 불필요
- 서버에서 일괄 관리

**단점**:
- API 응답 크기 증가 (미미함)
- 네트워크 의존성

---

## 7. 참고 자료

### 7.1 Flutter 공식 문서

- [Internationalizing Flutter apps](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [gen-l10n tool](https://docs.flutter.dev/development/accessibility-and-localization/internationalization#configuring-the-l10n-yaml-file)
- [ARB file format](https://github.com/google/app-resource-bundle)

### 7.2 Best Practices

#### 7.2.1 ARB 파일 관리

```json
// ✅ Good: 카테고리별 주석
{
  "_comment_app": "=== 앱 전역 ===",
  "appTitle": "LuckyAI 645",
  
  "_comment_common": "=== 공통 ===",
  "confirm": "확인"
}

// ❌ Bad: 주석 없이 나열
{
  "appTitle": "LuckyAI 645",
  "confirm": "확인",
  "selectAlgorithm": "알고리즘 선택"
}
```

#### 7.2.2 키 네이밍 컨벤션

```
- camelCase 사용
- 카테고리 접두사 추가 (선택)
- 동사는 명령형

✅ Good:
- selectAlgorithm (동사 + 명사)
- errorLoadAlgorithms (명사 + 동사)
- numberOfSets (명사구)

❌ Bad:
- SELECT_ALGORITHM (대문자)
- algorithm-select (케밥 케이스)
- selectingAlgorithm (진행형)
```

#### 7.2.3 파라미터 네이밍

```json
// ✅ Good: 의미 있는 이름
"welcome": "환영합니다, {userName}님!"

// ❌ Bad: 약어
"welcome": "환영합니다, {u}님!"
```

### 7.3 성능 최적화

#### 7.3.1 지연 로딩 (Lazy Loading)

```dart
// 모든 언어를 한 번에 로드하지 않음
// 선택된 언어만 메모리에 로드
MaterialApp(
  locale: currentLocale,
  localizationsDelegates: [
    AppLocalizations.delegate, // 필요한 언어만 로드
  ],
)
```

#### 7.3.2 빌드 시 최적화

```dart
// 빌드 시 모든 ARB 파일을 다트 코드로 컴파일
// 런타임 파싱 없음 → 빠른 성능
```

### 7.4 테스트

#### 7.4.1 단위 테스트

```dart
testWidgets('한국어 문자열 테스트', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('ko'),
      localizationsDelegates: [
        AppLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          expect(context.l10n.appTitle, 'LuckyAI 645');
          expect(context.l10n.drawNumber(1205), '제 1205회');
          return Container();
        },
      ),
    ),
  );
});
```

#### 7.4.2 언어 전환 테스트

```dart
testWidgets('언어 전환 테스트', (tester) async {
  final container = ProviderContainer();
  
  // 한국어
  expect(container.read(localeProvider).languageCode, 'ko');
  
  // 영어로 전환
  container.read(localeProvider.notifier).state = Locale('en');
  expect(container.read(localeProvider).languageCode, 'en');
});
```

### 7.5 문제 해결 (Troubleshooting)

#### 문제 1: "AppLocalizations.of(context) returned null"

**원인**: MaterialApp에 localizationsDelegates 누락

**해결**:
```dart
MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate, // 추가!
    GlobalMaterialLocalizations.delegate,
  ],
)
```

#### 문제 2: "No file found at lib/core/localization/generated"

**원인**: 코드 생성 안 됨

**해결**:
```bash
flutter pub get
flutter gen-l10n  # 이것을 실행해야 함!
```

#### 문제 3: "Type 'int' is not a subtype of type 'String'"

**원인**: ARB 파일에서 placeholders 타입 불일치

**해결**:
```json
// ❌ Bad
"drawNumber": "제 {number}회"
// @drawNumber에 placeholders 누락

// ✅ Good
"drawNumber": "제 {number}회",
"@drawNumber": {
  "placeholders": {
    "number": {
      "type": "int"  // 타입 명시!
    }
  }
}
```

---

## 부록 A: 전체 ARB 파일 구조

### A.1 한국어 (app_ko.arb) - 77개 문자열

```json
{
  "@@locale": "ko",
  "@@context": "LuckyAI 645 - 한국어 언어팩",
  
  "_comment_app": "=== 앱 전역 (1개) ===",
  "appTitle": "LuckyAI 645",
  
  "_comment_common": "=== 공통 (10개) ===",
  "confirm": "확인",
  "cancel": "취소",
  "close": "닫기",
  "save": "저장",
  "delete": "삭제",
  "edit": "수정",
  "loading": "로딩 중...",
  "error": "오류",
  "success": "성공",
  "warning": "경고",
  "info": "정보",
  
  "_comment_navigation": "=== 네비게이션 (5개) ===",
  "home": "홈",
  "generate": "번호 생성",
  "history": "히스토리",
  "myNumbers": "내 번호",
  "settings": "설정",
  
  "_comment_home": "=== 홈 화면 (4개) ===",
  "latestDraw": "최신 회차",
  "drawNumber": "제 {number}회",
  "bonusNumber": "보너스",
  "drawDate": "추첨일",
  
  "_comment_generate": "=== 번호 생성 화면 (11개) ===",
  "selectAlgorithm": "알고리즘 선택",
  "algorithmSelection": "알고리즘 선택",
  "numberOfSets": "생성 개수",
  "numberOfSetsCount": "{count}개",
  "quickButton5": "5개",
  "quickButton10": "10개",
  "directInput": "직접 입력",
  "enterNumberOfSets": "생성 개수를 입력하세요",
  "rangeHint": "1~100",
  "setsUnit": "개",
  "generateButton": "번호 생성",
  "generating": "생성 중...",
  
  "_comment_algorithm": "=== 알고리즘 (21개) ===",
  "algorithm1Name": "자동선택 (Quick Pick)",
  "algorithm1Desc": "1~45 중 6개를 완전 무작위로 선택합니다...",
  "algorithm2Name": "고급 빈도 분석",
  "algorithm2Desc": "과거 출현 빈도를 분석하여...",
  ... (알고리즘 3~7 생략)
  "free": "무료",
  "coinsPerSet": "{coins}코인",
  
  "_comment_result": "=== 결과 화면 (8개) ===",
  "generatedNumbers": "생성된 번호",
  "generatedCount": "총 {count}개 생성됨",
  "setNumber": "세트 {number}",
  "saveToMyNumbers": "내 번호에 저장",
  "share": "공유",
  "generateAgain": "다시 생성",
  "backToHome": "홈으로",
  
  "_comment_validation": "=== 검증 메시지 (5개) ===",
  "maxLimitTitle": "생성 개수 제한",
  "maxLimitMessage": "최대 100개까지만 생성 가능합니다.",
  "requirementTitle": "입력 확인",
  "requirementSelectAlgorithm": "알고리즘을 선택해주세요.",
  "requirementSelectCount": "생성 개수를 선택하거나 입력해주세요...",
  "requirementSelectBoth": "알고리즘을 선택하고...",
  
  "_comment_error": "=== 에러 메시지 (5개) ===",
  "errorLoadAlgorithms": "알고리즘을 불러올 수 없습니다",
  "errorGenerateFailed": "번호 생성 실패: {message}",
  "errorNetwork": "네트워크 연결을 확인해주세요",
  "errorServer": "서버 오류가 발생했습니다",
  "errorUnknown": "알 수 없는 오류가 발생했습니다",
  
  "_comment_language": "=== 언어 설정 (7개) ===",
  "language": "언어",
  "selectLanguage": "언어 선택",
  "languageKorean": "한국어",
  "languageEnglish": "English",
  "languageChinese": "中文",
  "languageVietnamese": "Tiếng Việt",
  "languageThai": "ภาษาไทย"
}
```

---

## 부록 B: 코드 생성 스크립트

### B.1 일괄 코드 생성 (Windows PowerShell)

```powershell
# generate_l10n.ps1
cd luckyai_645/mobile_app

Write-Host "📦 패키지 설치 중..." -ForegroundColor Cyan
flutter pub get

Write-Host "🔨 다국어 코드 생성 중..." -ForegroundColor Cyan
flutter gen-l10n

Write-Host "✅ 완료!" -ForegroundColor Green
Write-Host "생성된 파일:" -ForegroundColor Yellow
Get-ChildItem lib/core/localization/generated/*.dart
```

### B.2 ARB 파일 검증 스크립트

```python
# validate_arb.py
import json
import sys

def validate_arb(ko_file, en_file):
    with open(ko_file) as f:
        ko_data = json.load(f)
    with open(en_file) as f:
        en_data = json.load(f)
    
    ko_keys = {k for k in ko_data.keys() if not k.startswith('_') and not k.startswith('@')}
    en_keys = {k for k in en_data.keys() if not k.startswith('_') and not k.startswith('@')}
    
    missing_in_en = ko_keys - en_keys
    extra_in_en = en_keys - ko_keys
    
    if missing_in_en:
        print(f"❌ 영어 번역 누락: {missing_in_en}")
        return False
    
    if extra_in_en:
        print(f"⚠️ 영어에만 있는 키: {extra_in_en}")
    
    print(f"✅ 검증 완료: {len(ko_keys)}개 키 일치")
    return True

if __name__ == '__main__':
    result = validate_arb('lib/l10n/app_ko.arb', 'lib/l10n/app_en.arb')
    sys.exit(0 if result else 1)
```

---

## 부록 C: 언어별 특수 고려사항

### C.1 중국어 (간체 vs 번체)

```dart
// 간체 중국어 (중국 본토)
Locale('zh', 'CN')

// 번체 중국어 (대만, 홍콩)
Locale('zh', 'TW')
Locale('zh', 'HK')
```

### C.2 베트남어 성조 기호

```
베트남어는 성조 기호(diacritics)가 중요:
- Tiếng Việt (올바름)
- Tieng Viet (잘못됨)

ARB 파일은 UTF-8 인코딩 필수!
```

### C.3 태국어 띄어쓰기

```
태국어는 단어 사이에 공백이 없음:
"ภาษาไทย" (Thai Language)

긴 문장도 공백 없이 작성:
"กรุณาเลือกอัลกอริทึม" (Please select algorithm)
```

---

## 결론

LuckyAI 645의 다국어 지원 시스템은 **플러그인 아키텍처**를 기반으로 설계되어:
- 새로운 언어 추가가 단순함 (ARB 파일 1개)
- 타입 안전하고 유지보수 용이
- Flutter 표준 도구 활용 (flutter_localizations, intl)
- 글로벌 시장 진출 준비 완료

현재 한국어와 영어 인프라가 완성되었으며, 중국어/베트남어/태국어는 템플릿만 준비된 상태입니다. 번역 완료 후 즉시 서비스 가능합니다.

**다음 단계**: Phase 2 (UI 통합) 진행 예정

---

**작성자**: AI Assistant  
**최종 검토**: 2026-01-16  
**문서 버전**: 1.0
