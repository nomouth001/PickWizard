# Phase 3: Flutter 앱 기본 구조
## 상세 개발 로드맵

---

**Phase**: 3 - Flutter Mobile App Foundation  
**예상 기간**: 4-5일 (32-40시간)  
**선행 조건**: Phase 2 완료 (백엔드 API 동작)  
**목표**: Flutter 모바일 앱 기본 구조 및 번호 생성 플로우 완성

---

## 📋 Phase 개요

### 주요 산출물
- [x] Freezed 데이터 모델 (LottoDraw, GeneratedNumbers, AlgorithmInfo)
- [x] Dio + Retrofit API 클라이언트
- [x] Hive 로컬 저장소
- [x] Repository Pattern 구현
- [x] Riverpod 상태 관리
- [x] UI 화면 (스플래시, 홈, 번호 생성, 결과)
- [x] 공통 위젯 (로또 공, 번호 카드)

### 시간 배분
| 작업 | 예상 시간 | 누적 시간 |
|------|-----------|-----------|
| 3.1 코드 생성 및 기본 설정 | 3-4시간 | 3-4h |
| 3.2 데이터 모델 정의 | 4시간 | 7-8h |
| 3.3 API 클라이언트 | 8시간 | 15-16h |
| 3.4 로컬 저장소 (Hive) | 4시간 | 19-20h |
| 3.5 Repository 구현 | 6시간 | 25-26h |
| 3.6 Riverpod Provider | 6시간 | 31-32h |
| 3.7 UI 화면 구현 | 8시간 | 39-40h |

---

## 작업 3.1: 코드 생성 및 기본 설정 (3-4시간)

### 목표
Flutter 프로젝트 의존성 설치 및 코드 생성, 기본 상수 파일 작성

### Step 3.1.1: 의존성 설치

```bash
cd mobile_app
flutter pub get

# 출력 확인
# Running "flutter pub get" in mobile_app...
# Resolving dependencies... (X.Xs)
# Got dependencies!
```

**에러 발생 시**:
```bash
# Flutter 버전 확인
flutter --version

# 캐시 클리어
flutter clean
flutter pub get
```

---

### Step 3.1.2: 코드 생성 실행

```bash
# 일회성 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 출력 예시:
# [INFO] Generating build script...
# [INFO] Generating build script completed, took 2.1s
# [INFO] Creating build script snapshot...
# [INFO] Creating build script snapshot completed, took 8.3s
# [INFO] Running build...
# [INFO] Running build completed, took 15.2s
```

**생성되는 파일들**:
- `*.g.dart` - JSON 직렬화 코드 (json_serializable)
- `*.freezed.dart` - 불변 모델 코드 (freezed)
- `*.gr.dart` - 라우팅 코드 (auto_route, 선택)

---

### Step 3.1.3: 디렉토리 구조 생성

```bash
# lib 디렉토리 구조 생성 (PowerShell)
cd mobile_app/lib

mkdir -p core/{constants,theme,utils,errors}
mkdir -p data/{models,data_sources/{remote,local},repositories,dto}
mkdir -p domain/{entities,repositories,usecases}
mkdir -p presentation/{providers,screens,widgets,navigation}
```

**검증**:
```bash
tree lib /F  # Windows
# 또는
ls -R lib    # PowerShell
```

---

### Step 3.1.4: 기본 상수 파일 작성

#### API Endpoints

**파일**: `lib/core/constants/api_endpoints.dart`

```dart
/// API 엔드포인트 상수
/// 
/// 2026-01-05 EST - 초기 생성
class ApiEndpoints {
  ApiEndpoints._();
  
  // === 환경별 기본 URL ===
  static const String _devBaseUrl = 'http://localhost:8000';
  static const String _prodBaseUrl = 'https://api.luckyai645.com';
  
  /// 현재 환경에 맞는 Base URL 반환
  static String get baseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? _prodBaseUrl : _devBaseUrl;
  }
  
  // === 인증 API ===
  static const String guestLogin = '/api/auth/guest';
  static const String socialLogin = '/api/auth/social';
  static const String logout = '/api/auth/logout';
  
  // === 로또 데이터 API ===
  static const String latestDraw = '/api/draws/latest';
  static const String drawByNumber = '/api/draws/{draw_no}';
  static const String drawRange = '/api/draws/range';
  
  // === 번호 생성 API ===
  static const String generate = '/api/generate';
  static const String algorithms = '/api/algorithms';
  static const String algorithmById = '/api/algorithms/{id}';
  
  // === 코인 API ===
  static const String coinBalance = '/api/coins/balance';
  static const String dailyLogin = '/api/coins/daily-login';
  static const String watchAd = '/api/coins/watch-ad';
  static const String coinHistory = '/api/coins/history';
  
  // === 내 번호 API ===
  static const String myNumbers = '/api/my-numbers';
  static const String saveNumber = '/api/my-numbers/save';
  static const String checkWinning = '/api/my-numbers/check';
  static const String myNumbersHistory = '/api/my-numbers/history';
  
  // === 결제 API ===
  static const String purchaseCoins = '/api/payment/purchase';
  static const String verifyPurchase = '/api/payment/verify';
  
  // === 통계 API ===
  static const String userStats = '/api/stats/user';
  static const String algorithmStats = '/api/stats/algorithms';
}
```

---

#### 앱 색상

**파일**: `lib/core/constants/app_colors.dart`

```dart
import 'package:flutter/material.dart';

/// 앱 색상 상수
/// 
/// 2026-01-05 EST - 초기 생성
class AppColors {
  AppColors._();
  
  // === 브랜드 색상 ===
  static const Color primary = Color(0xFF667EEA);
  static const Color primaryDark = Color(0xFF5568D3);
  static const Color primaryLight = Color(0xFF8896F0);
  
  static const Color secondary = Color(0xFF764BA2);
  static const Color secondaryDark = Color(0xFF5D3A82);
  static const Color secondaryLight = Color(0xFF926FC4);
  
  static const Color accent = Color(0xFFF093FB);
  static const Color accentDark = Color(0xFFD17CE8);
  static const Color accentLight = Color(0xFFF5B3FC);
  
  // === 그라데이션 ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // === 배경 색상 ===
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF1E1E1E);
  
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF2C2C2C);
  
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceVariantDark = Color(0xFF383838);
  
  // === 텍스트 색상 ===
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFF868E96);
  static const Color textHint = Color(0xFFADB5BD);
  static const Color textDisabled = Color(0xFFDEE2E6);
  
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;
  
  // === 상태 색상 ===
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  
  // === 로또 공 색상 (번호 범위별) ===
  static const Color ball1to10 = Color(0xFFFFC107);    // 노란색 (1~10)
  static const Color ball11to20 = Color(0xFF2196F3);   // 파란색 (11~20)
  static const Color ball21to30 = Color(0xFFEF5350);   // 빨간색 (21~30)
  static const Color ball31to40 = Color(0xFF757575);   // 회색 (31~40)
  static const Color ball41to45 = Color(0xFF66BB6A);   // 초록색 (41~45)
  static const Color ballBonus = Color(0xFF9C27B0);    // 보라색 (보너스)
  
  /// 번호에 따른 로또 공 색상 반환
  static Color getBallColor(int number, {bool isBonus = false}) {
    if (isBonus) return ballBonus;
    
    if (number <= 10) return ball1to10;
    if (number <= 20) return ball11to20;
    if (number <= 30) return ball21to30;
    if (number <= 40) return ball31to40;
    return ball41to45;
  }
  
  // === 회색조 ===
  static const Color grey100 = Color(0xFFF8F9FA);
  static const Color grey200 = Color(0xFFE9ECEF);
  static const Color grey300 = Color(0xFFDEE2E6);
  static const Color grey400 = Color(0xFFCED4DA);
  static const Color grey500 = Color(0xFFADB5BD);
  static const Color grey600 = Color(0xFF6C757D);
  static const Color grey700 = Color(0xFF495057);
  static const Color grey800 = Color(0xFF343A40);
  static const Color grey900 = Color(0xFF212529);
  
  // === 구분선 ===
  static const Color divider = grey300;
  static const Color dividerDark = grey700;
  
  // === 그림자 ===
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x4D000000);
}
```

---

#### 앱 문자열

**파일**: `lib/core/constants/app_strings.dart`

```dart
/// 앱 문자열 상수
/// 
/// 2026-01-05 EST - 초기 생성
class AppStrings {
  AppStrings._();
  
  // === 앱 정보 ===
  static const String appName = 'LuckyAI 645';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI 기반 로또 번호 생성 앱';
  
  // === 공통 버튼 ===
  static const String ok = '확인';
  static const String cancel = '취소';
  static const String save = '저장';
  static const String delete = '삭제';
  static const String edit = '수정';
  static const String close = '닫기';
  static const String retry = '재시도';
  static const String refresh = '새로고침';
  static const String share = '공유';
  
  // === 홈 화면 ===
  static const String homeTitle = '로또 번호 생성';
  static const String latestDrawTitle = '최신 당첨번호';
  static const String generateNumbersButton = '번호 생성하기';
  static const String myNumbersButton = '내 번호 확인';
  static const String statisticsButton = '통계 보기';
  
  // === 번호 생성 화면 ===
  static const String selectAlgorithm = '알고리즘 선택';
  static const String numberOfSets = '생성 개수';
  static const String excludeNumbers = '제외할 번호';
  static const String includeNumbers = '포함할 번호';
  static const String generateButton = '번호 생성';
  static const String generating = '번호 생성 중...';
  
  // === 알고리즘 이름 ===
  static const String algoRandom = '순수 랜덤';
  static const String algoLSTM = 'LSTM AI';
  static const String algoEnsemble = '앙상블';
  static const String algoPattern = '패턴 분석';
  static const String algoWeighted = '가중치 조합';
  static const String algoFrequency = '빈도 기반';
  static const String algoHotCold = '핫/콜드 넘버';
  
  // === 코인 ===
  static const String coinBalance = '보유 코인';
  static const String coins = '코인';
  static const String getCoinsFree = '무료 코인 받기';
  static const String purchaseCoins = '코인 구매';
  static const String dailyLoginReward = '일일 로그인 보상';
  static const String watchAdReward = '광고 시청 보상';
  static const String insufficientCoins = '코인이 부족합니다';
  
  // === 에러 메시지 ===
  static const String errorGeneral = '오류가 발생했습니다';
  static const String errorNetwork = '네트워크 연결을 확인해주세요';
  static const String errorServer = '서버 오류가 발생했습니다';
  static const String errorTimeout = '요청 시간이 초과되었습니다';
  static const String errorUnknown = '알 수 없는 오류가 발생했습니다';
  
  // === 성공 메시지 ===
  static const String successGenerated = '번호가 생성되었습니다';
  static const String successSaved = '저장되었습니다';
  static const String successDeleted = '삭제되었습니다';
  
  // === 확인 메시지 ===
  static const String confirmDelete = '정말 삭제하시겠습니까?';
  static const String confirmLogout = '로그아웃 하시겠습니까?';
}
```

---

#### 앱 테마

**파일**: `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:luckyai_645/core/constants/app_colors.dart';

/// 앱 테마 정의
/// 
/// 2026-01-05 EST - 초기 생성
class AppTheme {
  AppTheme._();
  
  /// 라이트 테마
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // === 색상 스키마 ===
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),
      
      // === 스캐폴드 ===
      scaffoldBackgroundColor: AppColors.background,
      
      // === 앱바 ===
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      
      // === 카드 ===
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // === 버튼 ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // === 입력 필드 ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // === 텍스트 테마 ===
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textTertiary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
        ),
      ),
      
      // === 구분선 ===
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      
      // === 아이콘 ===
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
    );
  }
  
  /// 다크 테마 (추후 구현)
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      // ... 다크 테마 상세 설정
    );
  }
}
```

### 완료 기준 체크리스트
- [ ] `flutter pub get` 성공
- [ ] `dart run build_runner build` 성공
- [ ] `lib/core/` 디렉토리 구조 생성
- [ ] `api_endpoints.dart`, `app_colors.dart`, `app_strings.dart`, `app_theme.dart` 작성
- [ ] 앱 실행 시 에러 없음

---

## 작업 3.2: 데이터 모델 정의 (4시간)

### 목표
Freezed를 사용한 불변 데이터 모델 정의 및 JSON 직렬화

### Step 3.2.1: LottoDraw 모델

**파일**: `lib/data/models/lotto_draw.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lotto_draw.freezed.dart';
part 'lotto_draw.g.dart';

/// 로또 회차 모델
/// 
/// 2026-01-05 EST - 초기 생성
@freezed
class LottoDraw with _$LottoDraw {
  const factory LottoDraw({
    @JsonKey(name: 'draw_no') required int drawNo,
    @JsonKey(name: 'draw_date') required DateTime drawDate,
    @JsonKey(name: 'numbers') required List<int> numbers,
    @JsonKey(name: 'bonus') required int bonus,
    @JsonKey(name: 'first_prize_amount') int? firstPrizeAmount,
    @JsonKey(name: 'first_winner_count') int? firstWinnerCount,
  }) = _LottoDraw;
  
  factory LottoDraw.fromJson(Map<String, dynamic> json) => 
      _$LottoDrawFromJson(json);
  
  /// 생성자 본문 (추가 메서드용)
  const LottoDraw._();
  
  /// 번호 문자열 반환 (예: "1, 7, 14, 21, 28, 35")
  String get numbersString => numbers.join(', ');
  
  /// 전체 번호 (번호 + 보너스)
  List<int> get allNumbers => [...numbers, bonus];
  
  /// 회차 표시 문자열 (예: "1169회")
  String get drawTitle => '$drawNo회';
  
  /// 추첨일 문자열 (예: "2024년 12월 30일")
  String get drawDateString {
    return '${drawDate.year}년 ${drawDate.month}월 ${drawDate.day}일';
  }
}
```

---

### Step 3.2.2: GeneratedNumbers 모델

**파일**: `lib/data/models/generated_numbers.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'generated_numbers.freezed.dart';
part 'generated_numbers.g.dart';

/// 생성된 번호 세트 모델
/// 
/// 2026-01-05 EST - 초기 생성
@freezed
@HiveType(typeId: 0)  // Hive 저장용
class GeneratedNumbers with _$GeneratedNumbers {
  const factory GeneratedNumbers({
    @HiveField(0) required String id,
    @HiveField(1) @JsonKey(name: 'algorithm_id') required int algorithmId,
    @HiveField(2) @JsonKey(name: 'algorithm_name') required String algorithmName,
    @HiveField(3) @JsonKey(name: 'numbers') required List<List<int>> numbers,
    @HiveField(4) @JsonKey(name: 'generated_at') required DateTime generatedAt,
    @HiveField(5) @JsonKey(name: 'cost') int? cost,
    @HiveField(6) @JsonKey(name: 'is_saved') @Default(false) bool isSaved,
  }) = _GeneratedNumbers;
  
  factory GeneratedNumbers.fromJson(Map<String, dynamic> json) => 
      _$GeneratedNumbersFromJson(json);
  
  const GeneratedNumbers._();
  
  /// 세트 개수
  int get setCount => numbers.length;
  
  /// 첫 번째 세트
  List<int> get firstSet => numbers.isNotEmpty ? numbers[0] : [];
}
```

---

### Step 3.2.3: AlgorithmInfo 모델

**파일**: `lib/data/models/algorithm_info.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'algorithm_info.freezed.dart';
part 'algorithm_info.g.dart';

/// 알고리즘 정보 모델
/// 
/// 2026-01-05 EST - 초기 생성
@freezed
class AlgorithmInfo with _$AlgorithmInfo {
  const factory AlgorithmInfo({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'description') required String description,
    @JsonKey(name: 'cost_per_set') required int costPerSet,
    @JsonKey(name: 'version') String? version,
    @JsonKey(name: 'parameters') Map<String, dynamic>? parameters,
  }) = _AlgorithmInfo;
  
  factory AlgorithmInfo.fromJson(Map<String, dynamic> json) => 
      _$AlgorithmInfoFromJson(json);
  
  const AlgorithmInfo._();
  
  /// 무료 알고리즘 여부
  bool get isFree => costPerSet == 0;
  
  /// 비용 표시 문자열 (예: "무료", "5코인")
  String get costString => isFree ? '무료' : '$costPerSet코인';
}
```

---

### Step 3.2.4: 코드 생성 실행

```bash
# 모델 파일 작성 후 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 생성되는 파일들 확인
# - lotto_draw.freezed.dart
# - lotto_draw.g.dart
# - generated_numbers.freezed.dart
# - generated_numbers.g.dart
# - algorithm_info.freezed.dart
# - algorithm_info.g.dart
```

**에러 발생 시**:
```bash
# 특정 파일만 재생성
dart run build_runner build --delete-conflicting-outputs --build-filter="lib/data/models/*.dart"

# 캐시 클리어 후 재생성
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### 완료 기준 체크리스트
- [ ] `LottoDraw`, `GeneratedNumbers`, `AlgorithmInfo` 모델 작성
- [ ] `*.freezed.dart`, `*.g.dart` 파일 생성 성공
- [ ] JSON 직렬화/역직렬화 테스트 통과

---

## 작업 3.3: API 클라이언트 (8시간)

### 목표
Dio + Retrofit을 사용한 HTTP 클라이언트 구현

### Step 3.3.1: Dio 클라이언트 설정

**파일**: `lib/data/data_sources/remote/api_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:luckyai_645/core/constants/api_endpoints.dart';

/// Dio 클라이언트 Provider
/// 
/// 2026-01-05 EST - 초기 생성
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  
  // === 인터셉터 추가 ===
  
  // 1. Pretty Logger (개발 모드만)
  if (!const bool.fromEnvironment('dart.vm.product')) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }
  
  // 2. 인증 인터셉터
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // TODO: 액세스 토큰 추가
        // final token = await ref.read(authTokenProvider.future);
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        
        handler.next(options);
      },
      onError: (error, handler) async {
        // 401 Unauthorized 처리
        if (error.response?.statusCode == 401) {
          // TODO: 토큰 갱신 로직
          // final refreshed = await ref.read(authServiceProvider).refreshToken();
          // if (refreshed) {
          //   return handler.resolve(await _retry(error.requestOptions));
          // }
        }
        
        handler.next(error);
      },
    ),
  );
  
  return dio;
});

/// 에러 처리 유틸리티
class DioErrorHandler {
  static String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '요청 시간이 초과되었습니다';
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return '잘못된 요청입니다';
          case 401:
            return '인증이 필요합니다';
          case 402:
            return '코인이 부족합니다';
          case 403:
            return '권한이 없습니다';
          case 404:
            return '요청한 데이터를 찾을 수 없습니다';
          case 500:
            return '서버 오류가 발생했습니다';
          default:
            return '오류가 발생했습니다 (${statusCode})';
        }
        
      case DioExceptionType.cancel:
        return '요청이 취소되었습니다';
        
      case DioExceptionType.connectionError:
        return '네트워크 연결을 확인해주세요';
        
      default:
        return '알 수 없는 오류가 발생했습니다';
    }
  }
}
```

---

### Step 3.3.2: Retrofit API 인터페이스

**파일**: `lib/data/data_sources/remote/lotto_api.dart`

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:luckyai_645/core/constants/api_endpoints.dart';
import 'package:luckyai_645/data/models/lotto_draw.dart';
import 'package:luckyai_645/data/models/generated_numbers.dart';
import 'package:luckyai_645/data/models/algorithm_info.dart';

part 'lotto_api.g.dart';

/// Lotto API 인터페이스
/// 
/// 2026-01-05 EST - 초기 생성
@RestApi(baseUrl: '')
abstract class LottoApi {
  factory LottoApi(Dio dio, {String baseUrl}) = _LottoApi;
  
  // === 로또 데이터 API ===
  
  /// 최신 회차 조회
  @GET(ApiEndpoints.latestDraw)
  Future<LottoDraw> getLatestDraw();
  
  /// 특정 회차 조회
  @GET(ApiEndpoints.drawByNumber)
  Future<LottoDraw> getDrawByNumber(@Path('draw_no') int drawNo);
  
  /// 범위 조회
  @GET(ApiEndpoints.drawRange)
  Future<List<LottoDraw>> getDrawRange(
    @Query('start') int start,
    @Query('end') int end,
  );
  
  // === 알고리즘 API ===
  
  /// 알고리즘 목록 조회
  @GET(ApiEndpoints.algorithms)
  Future<List<AlgorithmInfo>> getAlgorithms();
  
  /// 알고리즘 상세 조회
  @GET(ApiEndpoints.algorithmById)
  Future<AlgorithmInfo> getAlgorithmById(@Path('id') int id);
  
  // === 번호 생성 API ===
  
  /// 번호 생성
  @POST(ApiEndpoints.generate)
  Future<GenerateResponse> generateNumbers(
    @Body() GenerateRequest request,
  );
}

/// 번호 생성 요청 모델
class GenerateRequest {
  final int algorithmId;
  final int nSets;
  final List<int>? excludeNumbers;
  final List<int>? includeNumbers;
  final Map<String, dynamic>? extraParams;
  
  GenerateRequest({
    required this.algorithmId,
    required this.nSets,
    this.excludeNumbers,
    this.includeNumbers,
    this.extraParams,
  });
  
  Map<String, dynamic> toJson() => {
    'algorithm_id': algorithmId,
    'n_sets': nSets,
    if (excludeNumbers != null) 'exclude_numbers': excludeNumbers,
    if (includeNumbers != null) 'include_numbers': includeNumbers,
    if (extraParams != null) ...extraParams!,
  };
}

/// 번호 생성 응답 모델
class GenerateResponse {
  final int algorithmId;
  final String algorithmName;
  final List<NumberSet> results;
  final DateTime timestamp;
  final int totalCost;
  
  GenerateResponse({
    required this.algorithmId,
    required this.algorithmName,
    required this.results,
    required this.timestamp,
    required this.totalCost,
  });
  
  factory GenerateResponse.fromJson(Map<String, dynamic> json) {
    return GenerateResponse(
      algorithmId: json['algorithm_id'],
      algorithmName: json['algorithm_name'],
      results: (json['results'] as List)
          .map((e) => NumberSet.fromJson(e))
          .toList(),
      timestamp: DateTime.parse(json['timestamp']),
      totalCost: json['total_cost'],
    );
  }
}

/// 번호 세트 모델
class NumberSet {
  final List<int> numbers;
  final int setNo;
  
  NumberSet({
    required this.numbers,
    required this.setNo,
  });
  
  factory NumberSet.fromJson(Map<String, dynamic> json) {
    return NumberSet(
      numbers: List<int>.from(json['numbers']),
      setNo: json['set_no'],
    );
  }
}
```

---

### Step 3.3.3: Retrofit 코드 생성

```bash
# Retrofit API 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 생성되는 파일: lotto_api.g.dart
```

---

### Step 3.3.4: API Provider 정의

**파일**: `lib/data/data_sources/remote/api_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luckyai_645/data/data_sources/remote/api_client.dart';
import 'package:luckyai_645/data/data_sources/remote/lotto_api.dart';

/// Lotto API Provider
final lottoApiProvider = Provider<LottoApi>((ref) {
  final dio = ref.watch(dioProvider);
  return LottoApi(dio);
});
```

### 완료 기준 체크리스트
- [ ] `api_client.dart` (Dio 설정) 작성
- [ ] `lotto_api.dart` (Retrofit 인터페이스) 작성
- [ ] `lotto_api.g.dart` 생성 성공
- [ ] 백엔드 API 호출 테스트 성공

---

---

**Phase 3 Part 1 문서 종료**

다음: [Phase 3 Part 2 - Hive, Repository, Provider, UI](012_Phase_3_Flutter_App_Part2.md)

