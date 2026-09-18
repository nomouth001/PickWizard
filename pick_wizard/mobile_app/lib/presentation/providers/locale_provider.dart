import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/localization/supported_locales.dart';

/// 언어 선택 Provider
///
/// 앱 시작 시 기기 시스템 언어를 감지해 초기값 설정.
/// 우리 언어팩(ko, en, zh, vi, th) 이외는 영어로 표시.
final localeProvider = StateProvider<Locale>((ref) {
  final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
  return SupportedLocales.localeFromSystem(systemLocale);
});

/// 언어 변경 함수
class LocaleNotifier {
  final Ref ref;

  LocaleNotifier(this.ref);

  /// 언어 변경 (오프라인 앱에서는 언어 선택 시 locale_preferences.saveLocale 호출)
  void changeLanguage(String languageCode) {
    final locale = SupportedLocales.findLocale(languageCode);
    if (locale != null) {
      ref.read(localeProvider.notifier).state = locale;
    }
  }

  /// 시스템 언어로 설정 (우리 팩에 있으면 해당 언어, 없으면 영어)
  void useSystemLanguage() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    ref.read(localeProvider.notifier).state =
        SupportedLocales.localeFromSystem(systemLocale);
  }
}
