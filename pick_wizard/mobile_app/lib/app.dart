import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pick_wizard/core/theme/app_theme.dart';
import 'package:pick_wizard/core/localization/supported_locales.dart';
import 'package:pick_wizard/core/localization/generated/app_localizations.dart';
import 'package:pick_wizard/presentation/providers/locale_provider.dart';
import 'package:pick_wizard/presentation/screens/splash/splash_screen.dart';

/// 앱 루트 위젯
/// 
/// 2026-01-05 16:05:00 EST - 초기 생성
/// 2026-01-16 EST - 다국어 지원 적용
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      // 다국어 설정
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: SupportedLocales.locales,
      
      // 앱 설정
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

