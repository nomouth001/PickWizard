import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/extensions/localization_extension.dart';
import 'package:pick_wizard/offline/screens/offline_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 오프라인 앱 런칭(스플래시) 화면
/// 약 2초 표시 후 홈으로 전환
class OfflineSplashScreen extends ConsumerStatefulWidget {
  const OfflineSplashScreen({super.key});

  @override
  ConsumerState<OfflineSplashScreen> createState() => _OfflineSplashScreenState();
}

class _OfflineSplashScreenState extends ConsumerState<OfflineSplashScreen> {
  static const String _dbResetDialogFlagKey = 'show_db_reset_dialog';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleStartupFlow();
    });
  }

  Future<void> _handleStartupFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final shouldShowDialog = prefs.getBool(_dbResetDialogFlagKey) ?? false;
    if (shouldShowDialog && mounted) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.dbResetDialogTitle),
          content: Text(context.l10n.dbResetDialogMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(context.l10n.confirm),
            ),
          ],
        ),
      );
      await prefs.setBool(_dbResetDialogFlagKey, false);
    }

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const OfflineHomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.casino_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.appNameOffline,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.appSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              const Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
