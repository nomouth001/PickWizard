import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/presentation/providers/lotto_provider.dart';
import 'package:pick_wizard/presentation/providers/auth_provider.dart';
import 'package:pick_wizard/services/ads/ad_service.dart';

/// 앱 초기화 상태
/// 
/// 2026-01-05 16:20:00 EST - 초기 생성
/// 2026-01-16 EST - Guest 로그인 추가
enum AppInitStatus {
  initializing,
  initialized,
  error,
}

/// 앱 초기화 Provider
final appInitializationProvider = FutureProvider<AppInitStatus>((ref) async {
  try {
    // 1. 설정 로드
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 2. Guest 로그인 (자동)
    await ref.read(autoGuestLoginProvider.future);
    
    // 3. 광고 SDK 초기화 (041 AdMob/AdRaven)
    await AdService.instance.initialize();
    
    // 4. 최신 회차 동기화
    ref.read(latestDrawProvider);
    
    return AppInitStatus.initialized;
  } catch (e) {
    print('앱 초기화 오류: $e');
    return AppInitStatus.error;
  }
});

