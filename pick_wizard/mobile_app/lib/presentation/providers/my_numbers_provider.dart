import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/data/data_sources/remote/lotto_api.dart';
import 'package:pick_wizard/data/data_sources/remote/api_providers.dart';
import 'package:pick_wizard/presentation/providers/auth_provider.dart';

/// 내 번호 관리 Provider
/// 
/// 2026-01-16 EST - 초기 생성 (Phase 5 통합)

/// 내 번호 목록 Provider
final myNumbersProvider = FutureProvider<List<MyNumberResponse>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) {
    return [];
  }
  
  final api = ref.watch(lottoApiProvider);
  
  try {
    final response = await api.getMyNumbers(userId, 0, 100);
    return response.numbers;
  } catch (e) {
    print('내 번호 목록 조회 실패: $e');
    return [];
  }
});

/// 내 번호 저장 Notifier
class SaveMyNumbersNotifier extends StateNotifier<AsyncValue<MyNumberResponse?>> {
  final Ref ref;
  
  SaveMyNumbersNotifier(this.ref) : super(const AsyncValue.data(null));
  
  Future<void> save({
    required List<int> numbers,
    int? algorithmId,
    String? algorithmName,
    String? memo,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) {
      state = AsyncValue.error('사용자 ID가 없습니다', StackTrace.current);
      return;
    }
    
    state = const AsyncValue.loading();
    
    try {
      final api = ref.read(lottoApiProvider);
      final request = SaveMyNumbersRequest(
        userId: userId,
        numbers: numbers,
        algorithmId: algorithmId,
        algorithmName: algorithmName,
        memo: memo,
      );
      
      final response = await api.saveMyNumbers(request);
      
      state = AsyncValue.data(response);
      
      // 내 번호 목록 갱신
      ref.invalidate(myNumbersProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final saveMyNumbersProvider = StateNotifierProvider<SaveMyNumbersNotifier, AsyncValue<MyNumberResponse?>>((ref) {
  return SaveMyNumbersNotifier(ref);
});

/// 당첨 확인 Notifier
class CheckWinningNotifier extends StateNotifier<AsyncValue<CheckWinningResponse?>> {
  final Ref ref;
  
  CheckWinningNotifier(this.ref) : super(const AsyncValue.data(null));
  
  Future<void> check({
    required List<int> userNumberIds,
    int? drawNo,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) {
      state = AsyncValue.error('사용자 ID가 없습니다', StackTrace.current);
      return;
    }
    
    state = const AsyncValue.loading();
    
    try {
      final api = ref.read(lottoApiProvider);
      final request = CheckWinningRequest(
        userId: userId,
        userNumberIds: userNumberIds,
        drawNo: drawNo,
      );
      
      final response = await api.checkWinning(request);
      
      state = AsyncValue.data(response);
      
      // 내 번호 목록 갱신 (당첨 여부 업데이트)
      ref.invalidate(myNumbersProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final checkWinningProvider = StateNotifierProvider<CheckWinningNotifier, AsyncValue<CheckWinningResponse?>>((ref) {
  return CheckWinningNotifier(ref);
});

/// 내 번호 삭제 Notifier
class DeleteMyNumberNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  
  DeleteMyNumberNotifier(this.ref) : super(const AsyncValue.data(null));
  
  Future<void> delete(int numberId) async {
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) {
      state = AsyncValue.error('사용자 ID가 없습니다', StackTrace.current);
      return;
    }
    
    state = const AsyncValue.loading();
    
    try {
      final api = ref.read(lottoApiProvider);
      await api.deleteMyNumber(numberId, userId);
      
      state = const AsyncValue.data(null);
      
      // 내 번호 목록 갱신
      ref.invalidate(myNumbersProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final deleteMyNumberProvider = StateNotifierProvider<DeleteMyNumberNotifier, AsyncValue<void>>((ref) {
  return DeleteMyNumberNotifier(ref);
});
