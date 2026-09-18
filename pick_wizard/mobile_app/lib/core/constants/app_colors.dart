import 'package:flutter/material.dart';

/// 앱 색상 상수
/// 
/// 2026-01-05 15:30:00 EST - 초기 생성
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

