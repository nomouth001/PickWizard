import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';
import 'package:pick_wizard/core/extensions/localization_extension.dart';
import 'package:pick_wizard/presentation/providers/app_initialization_provider.dart';
import 'package:pick_wizard/presentation/screens/home/home_screen.dart';

/// 스플래시 화면
/// 
/// 2026-01-05 16:30:00 EST - 초기 생성
/// 2026-01-16 EST - 다국어 문자열 적용 (context.l10n 사용)
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(appInitializationProvider);
    
    // 초기화 완료 시 홈으로 이동
    initState.whenData((status) {
      if (status == AppInitStatus.initialized) {
        Future.microtask(() {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        });
      }
    });
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고
              const Icon(
                Icons.stars,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              
              // 앱 이름
              Text(
                context.l10n.appTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                context.l10n.appSubtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              
              // 로딩 인디케이터
              initState.when(
                data: (status) {
                  if (status == AppInitStatus.error) {
                    return Text(
                      context.l10n.initializationError,
                      style: const TextStyle(color: Colors.white),
                    );
                  }
                  return const CircularProgressIndicator(
                    color: Colors.white,
                  );
                },
                loading: () => const CircularProgressIndicator(
                  color: Colors.white,
                ),
                error: (_, __) => Text(
                  context.l10n.errorOccurred,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

