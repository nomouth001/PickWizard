import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/presentation/providers/locale_provider.dart';
import 'package:pick_wizard/core/localization/supported_locales.dart';
import 'package:pick_wizard/data/data_sources/local/hive_database.dart';
import 'package:pick_wizard/services/ads/ad_service.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/offline/app_offline.dart';
import 'package:pick_wizard/offline/providers/offline_providers.dart';
import 'package:pick_wizard/offline/utils/game_preferences.dart';
import 'package:pick_wizard/offline/utils/locale_preferences.dart';

/// 오프라인 전용 앱 진입점 (045)
///
/// 실행: flutter run -t lib/offline/main_offline.dart
/// Chrome(웹)에서는 AdMob 미지원이므로 광고 초기화 생략.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.initialize();
  if (!kIsWeb) {
    await AdService.instance.initialize();
  }

  // 저장된 언어 로드 (없으면 시스템 언어 → 우리 팩 또는 영어)
  final savedLocale = await loadSavedLocale();
  final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
  final initialLocale = savedLocale ?? SupportedLocales.localeFromSystem(systemLocale);
  final initialGameTypeId = await loadGameType();
  final initialGameType = GameTypes.fromId(initialGameTypeId);

  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith((ref) => initialLocale),
        offlineSelectedGameTypeProvider.overrideWith((ref) => initialGameType),
      ],
      child: const OfflineApp(),
    ),
  );
}
