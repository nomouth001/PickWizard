import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/data/models/lotto_draw.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:pick_wizard/data/models/algorithm_info.dart';
import 'package:pick_wizard/data/repositories/repository_providers.dart';
import 'package:pick_wizard/data/data_sources/remote/lotto_api.dart';

/// 최신 회차 Provider
/// 
/// 2026-01-05 16:20:00 EST - 초기 생성
final latestDrawProvider = FutureProvider<LottoDraw?>((ref) async {
  final repository = ref.watch(lottoRepositoryProvider);
  final result = await repository.getLatestDraw();
  
  return result.fold(
    (failure) {
      print('최신 회차 조회 실패: ${failure.message}');
      return null;
    },
    (draw) => draw,
  );
});

/// 알고리즘 목록 Provider
final algorithmsProvider = FutureProvider<List<AlgorithmInfo>>((ref) async {
  final repository = ref.watch(lottoRepositoryProvider);
  final result = await repository.getAlgorithms();
  
  return result.fold(
    (failure) {
      print('알고리즘 목록 조회 실패: ${failure.message}');
      return [];
    },
    (algorithms) {
      // 2026-01-17 20:00:00 EST - 알고리즘 표시 순서 변경
      // 2026-01-18 EST - 알고리즘 8 (AI Selection) 추가
      // 새 순서: 1(자동) → 6(빈도) → 7(핫콜드) → 2(고급빈도) → 5(가중치) → 4(패턴) → 3(딥러닝) → 8(AI)
      const displayOrder = [1, 6, 7, 2, 5, 4, 3, 8];
      final sortedAlgorithms = <AlgorithmInfo>[];
      
      for (final id in displayOrder) {
        final algo = algorithms.firstWhere(
          (a) => a.id == id,
          orElse: () => algorithms.first, // fallback (shouldn't happen)
        );
        sortedAlgorithms.add(algo);
      }
      
      // 정의되지 않은 알고리즘이 있으면 마지막에 추가
      for (final algo in algorithms) {
        if (!displayOrder.contains(algo.id)) {
          sortedAlgorithms.add(algo);
        }
      }
      
      return sortedAlgorithms;
    },
  );
});

/// 생성된 번호 목록 Provider
final generatedNumbersProvider = FutureProvider<List<GeneratedNumbers>>((ref) async {
  final repository = ref.watch(lottoRepositoryProvider);
  final result = await repository.getLocalGeneratedNumbers();
  
  return result.fold(
    (failure) => [],
    (numbers) => numbers,
  );
});

/// 번호 생성 State Provider
final generateStateProvider = StateNotifierProvider<GenerateNotifier, AsyncValue<GeneratedNumbers?>>((ref) {
  return GenerateNotifier(ref);
});

/// 번호 생성 State Notifier
class GenerateNotifier extends StateNotifier<AsyncValue<GeneratedNumbers?>> {
  final Ref ref;
  
  GenerateNotifier(this.ref) : super(const AsyncValue.data(null));
  
  /// 번호 생성
  Future<void> generate(GenerateRequest request) async {
    state = const AsyncValue.loading();
    
    final repository = ref.read(lottoRepositoryProvider);
    final result = await repository.generateNumbers(request);
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (generated) => AsyncValue.data(generated),
    );
    
    // 생성 성공 시 목록 갱신
    if (state.hasValue) {
      ref.invalidate(generatedNumbersProvider);
    }
  }
  
  /// 상태 초기화
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 선택된 알고리즘 Provider
/// 2026-01-16 EST - 기본값을 null에서 알고리즘 1번(순수 랜덤)으로 변경 예정 (초기화 후)
final selectedAlgorithmProvider = StateProvider<AlgorithmInfo?>((ref) => null);

/// 제외 번호 Provider
final excludeNumbersProvider = StateProvider<List<int>>((ref) => []);

/// 포함 번호 Provider
final includeNumbersProvider = StateProvider<List<int>>((ref) => []);

/// 생성 세트 수 Provider
/// 2026-01-16 EST - 기본값 5개 설정
final numberOfSetsProvider = StateProvider<int>((ref) => 5);

/// 알고리즘 파라미터 Provider
/// 2026-01-17 EST - Phase 2: 알고리즘별 파라미터 상태 관리
final algorithmParametersProvider = StateNotifierProvider<
  AlgorithmParametersNotifier,
  Map<int, Map<String, dynamic>>
>((ref) => AlgorithmParametersNotifier());

/// 알고리즘 파라미터 Notifier
/// 2026-01-17 EST - 알고리즘별로 파라미터를 저장하고 관리
class AlgorithmParametersNotifier extends StateNotifier<Map<int, Map<String, dynamic>>> {
  AlgorithmParametersNotifier() : super({});
  
  /// 파라미터 가져오기 (없으면 기본값 반환)
  Map<String, dynamic> getParameters(int algorithmId) {
    return state[algorithmId] ?? _getDefaultParameters(algorithmId);
  }
  
  /// 파라미터 업데이트
  void updateParameter(int algorithmId, String key, dynamic value) {
    final current = state[algorithmId] ?? _getDefaultParameters(algorithmId);
    state = {
      ...state,
      algorithmId: {...current, key: value},
    };
  }
  
  /// 전체 파라미터 업데이트
  void updateParameters(int algorithmId, Map<String, dynamic> parameters) {
    state = {
      ...state,
      algorithmId: parameters,
    };
  }
  
  /// 파라미터 초기화
  void resetParameters(int algorithmId) {
    final newState = Map<int, Map<String, dynamic>>.from(state);
    newState.remove(algorithmId);
    state = newState;
  }
  
  /// 알고리즘별 기본 파라미터
  Map<String, dynamic> _getDefaultParameters(int algorithmId) {
    switch (algorithmId) {
      case 1: // 자동선택 (Quick Pick)
        return {};
      
      case 2: // 고급 빈도 분석
        return {
          'window_type': 'all',
          'window_size': 50,
          'exclude_consecutive_2': false,
          'exclude_frequent': false,
          'frequent_lookback': 10,
          'frequent_threshold': 5,
          'apply_recent_penalty': false,
          'penalty_rate': 0.5,
          'probability_mode': 'normal',
          'temperature': 1.0,
        };
      
      case 3: // 딥러닝 선택
        return {
          'learning_mode': 'non-cumulative',
          'probability_mode': 'normal',
          'window_size': 100,
          'hidden_size': 128,
          'num_layers': 2,
          'dropout': 0.2,
          'num_epochs': 50,
          'learning_rate': 0.001,
          'batch_size': 32,
          'apply_recent_penalty': false,
          'penalty_rate': 0.5,
          'temperature': 1.0,
        };
      
      case 4: // 패턴 분석
        return {
          'pattern_type': 'range',
          'range_divisions': 5,
          'rank_combo_size': 3,
          'rank_mode': 'cumulative',
          'rank_window': 50,
          'analysis_window_type': 'all',
          'analysis_window_size': 100,
          'top_n_patterns': 10,
          'in_pattern_probability': 'frequency',
        };
      
      case 5: // 가중치 조합
        return {
          'frequency_weight': 0.3,
          'recency_weight': 0.3,
          'zone_weight': 0.2,
          'diversity_weight': 0.2,
          'recent_draws': 100,
        };
      
      case 6: // 빈도 기반
        return {
          'recent_draws': 100,
          'temperature': 1.0,
        };
      
      case 7: // 핫/콜드 넘버
        return {
          'hot_window': 20,
          'hot_count': 3,
          'cold_window': 50,
          'cold_count': 2,
        };
      
      default:
        return {};
    }
  }
}
