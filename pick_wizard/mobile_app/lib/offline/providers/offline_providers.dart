import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:pick_wizard/data/data_sources/local/local_data_source.dart';
import '../services/local_lotto_service.dart';

/// 오프라인 전용 알고리즘 식별자.
/// 표시 이름·설명은 화면에서 l10n으로 직접 생성한다.
class OfflineAlgorithmInfo {
  final int id;

  const OfflineAlgorithmInfo({required this.id});
}

/// 볼픽: 알고리즘 1(자동선택), 9(만 번 뽑기).
/// 시리얼: 알고리즘 1(시리얼 퀵픽), 9(자리별 3천회 최빈).
const List<OfflineAlgorithmInfo> _kAlgorithms = [
  OfflineAlgorithmInfo(id: 1),
  OfflineAlgorithmInfo(id: 9),
];

final offlineAlgorithmsProvider =
    Provider<List<OfflineAlgorithmInfo>>((ref) {
  final gt = ref.watch(offlineSelectedGameTypeProvider);
  if (gt.isSerial) {
    return const [
      OfflineAlgorithmInfo(id: 1),
      OfflineAlgorithmInfo(id: 9),
    ];
  }
  return _kAlgorithms;
});

/// 선택된 알고리즘 (1 또는 9). 기본값 없음 — 사용자가 알고리즘 탭 후 모달에서 옵션 확인 시 선택됨.
final offlineSelectedAlgorithmProvider =
    StateProvider<OfflineAlgorithmInfo?>((ref) => null);

/// 포함할 번호 (최대 6개)
final offlineIncludeNumbersProvider = StateProvider<List<int>>((ref) => []);

/// 제외할 번호 (최대 39개)
final offlineExcludeNumbersProvider = StateProvider<List<int>>((ref) => []);

/// 생성 세트 수 (1~100, 기본 5)
final offlineNumberOfSetsProvider = StateProvider<int>((ref) => 5);

/// 선택된 복권 게임 타입 (STEP 5~)
final offlineSelectedGameTypeProvider =
    StateProvider<GameType>((ref) => GameTypes.lotto645);

/// 보너스 볼 고정값 (5+1 게임, STEP 7~)
final offlineBonusIncludeNumberProvider = StateProvider<int?>((ref) => null);

/// 보너스 볼 제외 목록 (5+1 게임, STEP 7~)
final offlineBonusExcludeNumbersProvider =
    StateProvider<List<int>>((ref) => []);

/// 로컬 데이터 소스 (오프라인용)
final offlineLocalDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource();
});

/// 저장된 내 번호 목록 (내 번호 화면에서 watch, 저장 시 invalidate)
final offlineSavedNumbersProvider = Provider<List<GeneratedNumbers>>((ref) {
  final ds = ref.watch(offlineLocalDataSourceProvider);
  return ds.getAllGeneratedNumbers();
});

/// 번호 생성 실행 (오프라인 로컬만)
final offlineGenerateProvider =
    StateNotifierProvider<OfflineGenerateNotifier, AsyncValue<GeneratedNumbers?>>(
        (ref) {
  return OfflineGenerateNotifier(ref);
});

class OfflineGenerateNotifier
    extends StateNotifier<AsyncValue<GeneratedNumbers?>> {
  final Ref ref;

  OfflineGenerateNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> generate() async {
    final algo = ref.read(offlineSelectedAlgorithmProvider);
    final gameType = ref.read(offlineSelectedGameTypeProvider);
    final include = ref.read(offlineIncludeNumbersProvider);
    final exclude = ref.read(offlineExcludeNumbersProvider);
    final bonusInclude = ref.read(offlineBonusIncludeNumberProvider);
    final bonusExclude = ref.read(offlineBonusExcludeNumbersProvider);
    final nSets = ref.read(offlineNumberOfSetsProvider);

    state = const AsyncValue.loading();

    try {
      final includeList = include.isEmpty ? null : List<int>.from(include);
      final excludeList = exclude.isEmpty ? null : List<int>.from(exclude);

      if (algo == null) {
        throw ArgumentError('알고리즘을 선택해 주세요.');
      }

      GeneratedNumbers generated;
      if (gameType.isSerial) {
        final serialExclude = ref.read(offlineSerialExcludeGroupsProvider);
        final excludeGroups =
            serialExclude.isEmpty ? null : List<int>.from(serialExclude);
        final fixedGroup = ref.read(offlineSerialFixedGroupProvider);
        if (algo.id == 1) {
          generated = generateSerial(
            gameType: gameType,
            nSets: nSets,
            fixedGroup: fixedGroup,
            excludeGroups: excludeGroups,
          );
        } else if (algo.id == 9) {
          generated = generateSerialDigitMonteCarlo(
            gameType: gameType,
            nSets: nSets,
            fixedGroup: fixedGroup,
            excludeGroups: excludeGroups,
          );
        } else {
          throw ArgumentError('지원하지 않는 알고리즘입니다.');
        }
      } else {
        if (algo.id == 1) {
        generated = generateQuickPick(
          gameType: gameType,
          nSets: nSets,
          excludeNumbers: excludeList,
          includeNumbers: includeList,
          bonusIncludeNumber: bonusInclude,
          bonusExcludeNumbers: bonusExclude,
        );
        } else if (algo.id == 9) {
        generated = generateMonteCarloTop(
          gameType: gameType,
          nSets: nSets,
          excludeNumbers: excludeList,
          includeNumbers: includeList,
          bonusIncludeNumber: bonusInclude,
          bonusExcludeNumbers: bonusExclude,
        );
        } else {
          throw ArgumentError('지원하지 않는 알고리즘입니다.');
        }
      }

      final algorithmName = gameType.isSerial
          ? (algo.id == 1
              ? 'Serial Quick Pick'
              : 'Serial Digit Monte Carlo')
          : (algo.id == 1 ? 'Quick Pick' : 'Monte Carlo Top');
      final finalized = generated.copyWith(
        algorithmId: algo.id,
        algorithmName: algorithmName,
        timestamp: DateTime.now(),
        id: const Uuid().v4(),
      );

      // 저장은 결과 화면에서 "내 번호로 저장" 탭 시에만 수행
      state = AsyncValue.data(finalized);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 조 고정값 (annuity720 전용, null = 무작위)
final offlineSerialFixedGroupProvider = StateProvider<int?>((ref) => null);

/// 조 제외 목록 (annuity720 전용)
final offlineSerialExcludeGroupsProvider =
    StateProvider<List<int>>((ref) => []);
