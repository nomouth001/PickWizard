import 'package:flutter/material.dart';

/// 지원 언어 목록
/// 
/// 2026-01-16 EST - 플러그인 방식 다국어 인프라
/// 새로운 언어 추가 시 이 파일만 수정하면 됨
class SupportedLocales {
  /// 지원 언어 목록
  static const List<Locale> locales = [
    Locale('ko', ''), // 한국어 (기본)
    Locale('en', ''), // 영어
    Locale('zh', ''), // 중국어
    Locale('vi', ''), // 베트남어
    Locale('th', ''), // 태국어
    Locale('ja', ''), // 일본어
  ];
  
  /// 기본 언어
  static const Locale fallbackLocale = Locale('ko', '');

  /// 시스템(기기) 로케일을 감지해 앱 로케일로 변환. 우리 언어팩에 없으면 영어.
  static Locale localeFromSystem(Locale systemLocale) {
    final found = findLocale(systemLocale.languageCode);
    return found ?? const Locale('en');
  }
  
  /// 언어 코드로 Locale 찾기
  static Locale? findLocale(String languageCode) {
    try {
      return locales.firstWhere(
        (locale) => locale.languageCode == languageCode,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// 언어 이름 (Native)
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      case 'vi':
        return 'Tiếng Việt';
      case 'th':
        return 'ภาษาไทย';
      case 'ja':
        return '日本語';
      default:
        return languageCode;
    }
  }
  
  /// 언어 국기 이모지
  static String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return '🇰🇷';
      case 'en':
        return '🇺🇸';
      case 'zh':
        return '🇨🇳';
      case 'vi':
        return '🇻🇳';
      case 'th':
        return '🇹🇭';
      case 'ja':
        return '🇯🇵';
      default:
        return '🌐';
    }
  }
}
