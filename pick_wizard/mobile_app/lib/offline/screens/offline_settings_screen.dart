import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/localization/supported_locales.dart';
import 'package:pick_wizard/presentation/providers/locale_provider.dart';

/// 오프라인 전용 설정 (045: 다국어 유지 — 언어만)
class OfflineSettingsScreen extends ConsumerWidget {
  const OfflineSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '앱 설정',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ...SupportedLocales.locales.map((locale) {
            final isSelected = currentLocale.languageCode == locale.languageCode;
            return ListTile(
              leading: Text(
                SupportedLocales.getLanguageFlag(locale.languageCode),
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                SupportedLocales.getLanguageName(locale.languageCode),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).state = locale;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '언어가 ${SupportedLocales.getLanguageName(locale.languageCode)}(으)로 변경되었습니다.',
                      ),
                    ),
                  );
                }
              },
            );
          }),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '오프라인 모드 — 당첨 확인은 동행복권에서 해 주세요.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
