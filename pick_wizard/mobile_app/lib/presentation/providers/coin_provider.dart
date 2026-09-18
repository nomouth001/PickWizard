import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/constants/feature_flags.dart';
import 'package:pick_wizard/data/data_sources/remote/lotto_api.dart';
import 'package:pick_wizard/data/data_sources/remote/api_providers.dart';
import 'package:pick_wizard/presentation/providers/auth_provider.dart';

/// 코인 시스템 Provider
/// 
/// 2026-01-16 EST - 초기 생성 (Phase 4 통합)
/// 2026-02-20 - 043: useCoinAndWallet false 시 API 스킵

/// 코인 잔액 Provider
final coinBalanceProvider = FutureProvider<CoinBalanceResponse?>((ref) async {
  if (!FeatureFlags.useCoinAndWallet) return null;

  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final api = ref.watch(lottoApiProvider);
  try {
    return await api.getCoinBalance(userId);
  } catch (e) {
    print('코인 잔액 조회 실패: $e');
    return null;
  }
});

/// 코인 거래 내역 Provider
final coinHistoryProvider = FutureProvider<CoinHistoryResponse?>((ref) async {
  if (!FeatureFlags.useCoinAndWallet) return null;

  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final api = ref.watch(lottoApiProvider);
  try {
    return await api.getCoinHistory(userId, 100);
  } catch (e) {
    print('코인 거래 내역 조회 실패: $e');
    return null;
  }
});

/// 일일 로그인 보상 Notifier
class DailyLoginNotifier extends StateNotifier<AsyncValue<CoinBalanceResponse?>> {
  final Ref ref;
  
  DailyLoginNotifier(this.ref) : super(const AsyncValue.data(null));
  
  Future<void> claim() async {
    if (!FeatureFlags.useCoinAndWallet) {
      state = const AsyncValue.data(null);
      return;
    }
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncValue.error('사용자 ID가 없습니다', StackTrace.current);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final api = ref.read(lottoApiProvider);
      final response = await api.claimDailyLogin({'user_id': userId});
      state = AsyncValue.data(response);
      ref.invalidate(coinBalanceProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final dailyLoginProvider = StateNotifierProvider<DailyLoginNotifier, AsyncValue<CoinBalanceResponse?>>((ref) {
  return DailyLoginNotifier(ref);
});

/// 광고 시청 보상 Notifier
class AdRewardNotifier extends StateNotifier<AsyncValue<CoinBalanceResponse?>> {
  final Ref ref;
  
  AdRewardNotifier(this.ref) : super(const AsyncValue.data(null));
  
  Future<void> claim() async {
    if (!FeatureFlags.useCoinAndWallet) {
      state = const AsyncValue.data(null);
      return;
    }
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncValue.error('사용자 ID가 없습니다', StackTrace.current);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final api = ref.read(lottoApiProvider);
      final response = await api.claimAdReward({'user_id': userId});
      state = AsyncValue.data(response);
      ref.invalidate(coinBalanceProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adRewardProvider = StateNotifierProvider<AdRewardNotifier, AsyncValue<CoinBalanceResponse?>>((ref) {
  return AdRewardNotifier(ref);
});
