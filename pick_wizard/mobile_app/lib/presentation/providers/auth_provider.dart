import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pick_wizard/data/auth_service.dart';
import 'package:pick_wizard/data/data_sources/remote/lotto_api.dart';
import 'package:pick_wizard/data/data_sources/remote/api_providers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// 인증 Provider
/// 
/// 2026-01-16 EST - 초기 생성 (Phase 4 통합)
/// 034 EST - OAuth 로그인/로그아웃

/// Device ID Provider
final deviceIdProvider = FutureProvider<String>((ref) async {
  final deviceInfo = DeviceInfoPlugin();
  
  if (kIsWeb) {
    // 웹 환경
    final webInfo = await deviceInfo.webBrowserInfo;
    return 'web-${webInfo.userAgent?.hashCode ?? DateTime.now().millisecondsSinceEpoch}';
  }
  
  try {
    // Android
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  } catch (e) {
    // iOS 또는 다른 플랫폼
    try {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown-ios';
    } catch (e) {
      // 기타 (Windows, Linux, macOS)
      return 'desktop-${DateTime.now().millisecondsSinceEpoch}';
    }
  }
});

/// 현재 사용자 ID Provider
final currentUserIdProvider = StateProvider<String?>((ref) => null);

/// Guest 로그인 Provider
final guestLoginProvider = FutureProvider.family<GuestLoginResponse, String>((ref, deviceId) async {
  final api = ref.watch(lottoApiProvider);
  
  try {
    final request = GuestLoginRequest(
      deviceId: deviceId,
      fcmToken: null, // TODO: FCM 토큰 추가
    );
    
    final response = await api.guestLogin(request);
    
    // 사용자 ID 저장
    ref.read(currentUserIdProvider.notifier).state = response.userId;
    
    return response;
  } catch (e) {
    print('Guest 로그인 실패: $e');
    rethrow;
  }
});

/// 자동 Guest 로그인 Provider
final autoGuestLoginProvider = FutureProvider<String?>((ref) async {
  try {
    // 1. Device ID 가져오기
    final deviceId = await ref.watch(deviceIdProvider.future);
    
    // 2. Guest 로그인
    final response = await ref.watch(guestLoginProvider(deviceId).future);
    
    return response.userId;
  } catch (e) {
    print('자동 Guest 로그인 실패: $e');
    return null;
  }
});

/// 034 OAuth 로그인/로그아웃 Notifier
class OAuthLoginNotifier extends StateNotifier<AsyncValue<LoginResponse?>> {
  OAuthLoginNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> login(LoginRequest request) async {
    state = const AsyncValue.loading();
    try {
      final api = _ref.read(lottoApiProvider);
      final auth = _ref.read(authServiceProvider);
      final response = await api.login(request);
      await auth.setToken(response.accessToken);
      _ref.read(currentUserIdProvider.notifier).state = response.userId;
      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    final auth = _ref.read(authServiceProvider);
    await auth.logout();
    _ref.read(currentUserIdProvider.notifier).state = null;
    state = const AsyncValue.data(null);
  }
}

final oauthLoginProvider = StateNotifierProvider<OAuthLoginNotifier, AsyncValue<LoginResponse?>>((ref) {
  return OAuthLoginNotifier(ref);
});
