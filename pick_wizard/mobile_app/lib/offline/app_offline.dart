import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pick_wizard/core/theme/app_theme.dart';
import 'package:pick_wizard/core/localization/supported_locales.dart';
import 'package:pick_wizard/core/localization/generated/app_localizations.dart';
import 'package:pick_wizard/presentation/providers/locale_provider.dart';
import 'package:pick_wizard/offline/screens/offline_splash_screen.dart';

/// 오프라인 전용 앱 (045 설계 — 2화면: 홈/번호생성 → 결과)
/// 기존 디자인을 유지한 채 필요한 코드만 다른 포장으로 제공
class OfflineApp extends ConsumerWidget {
  const OfflineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: SupportedLocales.locales,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const OfflineSplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
