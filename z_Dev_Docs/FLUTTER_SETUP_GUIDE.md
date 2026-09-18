# Flutter 프로젝트 설정 가이드

## 📋 개요
Flutter SDK 설치 후 다음 단계를 따라 모바일 앱 프로젝트를 생성하세요.

## 🚀 Flutter 프로젝트 생성

### 1. Flutter SDK 설치 확인
```bash
flutter --version
flutter doctor
```

### 2. 프로젝트 생성
```bash
cd H:\_Lotto_picker_app\pick_wizard
flutter create mobile_app --org com.pickwizard --project-name pick_wizard
```

### 3. 의존성 추가

**파일**: `mobile_app/pubspec.yaml`

```yaml
name: pick_wizard
description: PickWizard — 복권 번호 추천 보조 앱
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # === 상태 관리 ===
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # === 네트워킹 ===
  dio: ^5.4.0
  retrofit: ^4.0.3
  pretty_dio_logger: ^1.3.1
  connectivity_plus: ^5.0.2
  
  # === 로컬 저장소 ===
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  
  # === JSON 직렬화 ===
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  
  # === UI/차트 ===
  fl_chart: ^0.66.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.9
  lottie: ^3.0.0
  
  # === 유틸리티 ===
  intl: ^0.19.0
  qr_flutter: ^4.1.0
  share_plus: ^7.2.1
  url_launcher: ^6.2.2
  path_provider: ^2.1.2
  
  # === Firebase ===
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  firebase_analytics: ^10.8.0
  
  # === 인앱 결제 ===
  in_app_purchase: ^3.1.13
  
  # === 광고 ===
  google_mobile_ads: ^4.0.0
  
  # === 기타 ===
  logger: ^2.0.2
  equatable: ^2.0.5
  dartz: ^0.10.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  
  # === 코드 생성 ===
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  freezed: ^2.4.6
  riverpod_generator: ^2.3.9
  retrofit_generator: ^8.0.6
  hive_generator: ^2.0.1
  
  # === 테스트 ===
  mockito: ^5.4.4
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/lottie/
  
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.ttf
        - asset: assets/fonts/Pretendard-Bold.ttf
          weight: 700
```

### 4. Lint 규칙 설정

**파일**: `mobile_app/analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  
  errors:
    invalid_annotation_target: ignore
    
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    # 스타일
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - prefer_final_locals
    
    # 가독성
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - avoid_print
    - avoid_unnecessary_containers
    
    # 에러 방지
    - avoid_empty_else
    - avoid_returning_null_for_void
    - no_duplicate_case_values
    - prefer_is_empty
    - prefer_is_not_empty
```

### 5. 상수 파일 생성

**파일**: `mobile_app/lib/core/constants/api_endpoints.dart`

```dart
/// API 엔드포인트 상수
/// 2026-01-04 EST - 초기 생성
class ApiEndpoints {
  ApiEndpoints._();
  
  // === 기본 URL ===
  static const String _devBaseUrl = 'http://localhost:8000';
  static const String _prodBaseUrl = 'https://api.luckyai645.com';
  
  static String get baseUrl {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? _prodBaseUrl : _devBaseUrl;
  }
  
  // === 인증 ===
  static const String guestLogin = '/api/auth/guest';
  static const String socialLogin = '/api/auth/social';
  
  // === 로또 데이터 ===
  static const String latestDraw = '/api/draws/latest';
  static const String drawByNumber = '/api/draws/{draw_no}';
  static const String drawRange = '/api/draws/range';
  
  // === 번호 생성 ===
  static const String generate = '/api/generate';
  static const String algorithms = '/api/algorithms';
  
  // === 코인 ===
  static const String coinBalance = '/api/coins/balance';
  static const String dailyLogin = '/api/coins/daily-login';
  static const String watchAd = '/api/coins/watch-ad';
  
  // === 내 번호 ===
  static const String myNumbers = '/api/my-numbers';
  static const String saveNumber = '/api/my-numbers/save';
  static const String checkWinning = '/api/my-numbers/check';
}
```

**파일**: `mobile_app/lib/core/constants/app_colors.dart`

```dart
import 'package:flutter/material.dart';

/// 앱 색상 상수
class AppColors {
  AppColors._();
  
  // === 주요 색상 ===
  static const Color primary = Color(0xFF667EEA);
  static const Color secondary = Color(0xFF764BA2);
  static const Color accent = Color(0xFFF093FB);
  
  // === 배경 ===
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // === 텍스트 ===
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFADB5BD);
  
  // === 상태 ===
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // === 로또 공 색상 (번호 범위별) ===
  static const Color ball1to10 = Color(0xFFFFC107);    // 노란색
  static const Color ball11to20 = Color(0xFF2196F3);   // 파란색
  static const Color ball21to30 = Color(0xFFEF5350);   // 빨간색
  static const Color ball31to40 = Color(0xFF757575);   // 회색
  static const Color ball41to45 = Color(0xFF66BB6A);   // 초록색
  static const Color ballBonus = Color(0xFF9C27B0);    // 보라색
  
  /// 번호에 따른 로또 공 색상 반환
  static Color getLottoBallColor(int number) {
    if (number <= 10) return ball1to10;
    if (number <= 20) return ball11to20;
    if (number <= 30) return ball21to30;
    if (number <= 40) return ball31to40;
    return ball41to45;
  }
}
```

### 6. .gitignore 설정

**파일**: `mobile_app/.gitignore`

```gitignore
# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
*.g.dart
*.freezed.dart

# IntelliJ
*.iml
.idea/

# VS Code
.vscode/

# Android
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java
**/android/key.properties
*.jks

# iOS
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/.last_build_id
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# 환경 변수
.env
.env.local

# Firebase
**/google-services.json
**/GoogleService-Info.plist
firebase_app_id_file.json

# 로그
*.log

# Coverage
coverage/
```

### 7. 의존성 설치 및 코드 생성

```bash
cd mobile_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 8. 앱 실행 테스트

```bash
# Windows
flutter run -d windows

# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios
```

## ✅ 완료 기준
- [ ] `flutter doctor` 모든 항목 통과
- [ ] `flutter pub get` 성공
- [ ] 코드 생성 성공 (*.g.dart, *.freezed.dart)
- [ ] 샘플 앱 실행 확인

## 📝 참고
- Flutter SDK 3.16 이상 권장
- Android Studio 또는 VS Code 사용
- Dart 3.2 이상 필요

---

**작성일**: 2026-01-04 EST  
**상태**: Flutter SDK 설치 대기 중

