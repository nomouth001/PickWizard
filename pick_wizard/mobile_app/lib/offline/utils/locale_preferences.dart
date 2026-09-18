import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pick_wizard/core/localization/supported_locales.dart';

/// 오프라인 앱 언어 선택 유지 (SharedPreferences)
const String _kLocaleKey = 'locale';

/// 저장된 언어 코드 로드. 없으면 null.
Future<Locale?> loadSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(_kLocaleKey);
  if (code == null || code.isEmpty) return null;
  return SupportedLocales.findLocale(code);
}

/// 선택한 로케일 저장
Future<void> saveLocale(Locale locale) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kLocaleKey, locale.languageCode);
}
