import 'package:flutter_test/flutter_test.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:pick_wizard/offline/providers/offline_providers.dart';

import '../helpers/test_helpers.dart';

void main() {
  GeneratedNumbers makeBase({
    GameTypeId? gameTypeId,
    List<int>? bonusBalls,
  }) {
    return GeneratedNumbers(
      gameTypeId: gameTypeId ?? GameTypeId.lotto645,
      bonusBalls: bonusBalls ?? const [],
      algorithmId: 1,
      algorithmName: '테스트 알고리즘',
      results: const [
        NumberSetResult(setNo: 1, numbers: [1, 2, 3, 4, 5, 6]),
      ],
      timestamp: DateTime.utc(2026, 5, 6),
      cost: 0,
      isSaved: false,
      id: 'test-id',
    );
  }

  test('기본값: gameTypeId는 lotto645', () {
    final g = makeGeneratedNumbers(null, nSets: 3);
    expect(g.gameTypeId, GameTypeId.lotto645);
  });

  test('기본값: bonusBalls는 빈 리스트', () {
    final g = makeGeneratedNumbers(null, nSets: 3);
    expect(g.bonusBalls, isEmpty);
  });

  test('powerball 설정: gameTypeId와 bonusBalls 값이 유지된다', () {
    final g = makeBase(
      gameTypeId: GameTypeId.powerball,
      bonusBalls: const [18],
    );
    expect(g.gameTypeId, GameTypeId.powerball);
    expect(g.bonusBalls, const [18]);
  });

  test('copyWith: bonusBalls를 [5, 10]으로 변경할 수 있다', () {
    final g = makeBase();
    final copied = g.copyWith(bonusBalls: const [5, 10]);
    expect(copied.bonusBalls, const [5, 10]);
  });

  group('오프라인 Provider (A5~A6)', () {
    test('offlineSelectedGameTypeProvider 초기값은 lotto645', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(
        container.read(offlineSelectedGameTypeProvider),
        GameTypes.lotto645,
      );
    });

    test('offlineBonusIncludeNumberProvider 초기값은 null', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(offlineBonusIncludeNumberProvider), isNull);
    });

    test('offlineBonusExcludeNumbersProvider 초기값은 빈 리스트', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(offlineBonusExcludeNumbersProvider), isEmpty);
    });

    test('offlineSelectedGameTypeProvider를 powerball로 변경할 수 있다', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      container.read(offlineSelectedGameTypeProvider.notifier).state =
          GameTypes.powerball;
      expect(
        container.read(offlineSelectedGameTypeProvider),
        GameTypes.powerball,
      );
    });
  });

  group('오프라인 시리얼 Provider + 알고리즘 (F2)', () {
    test('F2-T01: offlineSerialFixedGroupProvider 초기값은 null', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(offlineSerialFixedGroupProvider), isNull);
    });

    test('F2-T02: offlineSerialExcludeGroupsProvider 초기값은 빈 리스트', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(offlineSerialExcludeGroupsProvider), isEmpty);
    });

    test('F2-T03: ballPick(lotto645) 선택 시 offlineAlgorithmsProvider 길이 2', () {
      final container = makeContainer(
        overrides: [
          offlineSelectedGameTypeProvider
              .overrideWith((ref) => GameTypes.lotto645),
        ],
      );
      addTearDown(container.dispose);
      final algos = container.read(offlineAlgorithmsProvider);
      expect(algos.length, 2);
      expect(algos.map((a) => a.id).toList(), [1, 9]);
    });

    test('F2-T04: annuity720 선택 시 offlineAlgorithmsProvider 길이 2(id:1·9)', () {
      final container = makeContainer(
        overrides: [
          offlineSelectedGameTypeProvider
              .overrideWith((ref) => GameTypes.annuity720),
        ],
      );
      addTearDown(container.dispose);
      final algos = container.read(offlineAlgorithmsProvider);
      expect(algos.length, 2);
      expect(algos.map((a) => a.id).toList(), [1, 9]);
    });

    test('F2-T05: annuity720 → ballPick 전환 시 offlineAlgorithmsProvider 다시 길이 2',
        () {
      final container = makeContainer();
      addTearDown(container.dispose);
      container.read(offlineSelectedGameTypeProvider.notifier).state =
          GameTypes.annuity720;
      expect(container.read(offlineAlgorithmsProvider).length, 2);
      container.read(offlineSelectedGameTypeProvider.notifier).state =
          GameTypes.lotto645;
      final algos = container.read(offlineAlgorithmsProvider);
      expect(algos.length, 2);
      expect(algos.map((a) => a.id).toList(), [1, 9]);
    });
  });

  group('Phase G2 — 시리얼 알고리즘 Provider·생성 (G2-T01~G2-T05)', () {
    test('G2-T01: annuity720 선택 시 offlineAlgorithmsProvider 길이 2, id 1·9',
        () {
      final container = makeContainer(
        overrides: [
          offlineSelectedGameTypeProvider
              .overrideWith((ref) => GameTypes.annuity720),
        ],
      );
      addTearDown(container.dispose);
      final algos = container.read(offlineAlgorithmsProvider);
      expect(algos.length, 2);
      expect(algos.map((a) => a.id).toList(), [1, 9]);
    });

    test('G2-T02: lotto645 선택 시 offlineAlgorithmsProvider 길이 2 (회귀)', () {
      final container = makeContainer(
        overrides: [
          offlineSelectedGameTypeProvider
              .overrideWith((ref) => GameTypes.lotto645),
        ],
      );
      addTearDown(container.dispose);
      final algos = container.read(offlineAlgorithmsProvider);
      expect(algos.length, 2);
      expect(algos.map((a) => a.id).toList(), [1, 9]);
    });

    test('G2-T03: annuity720 → lotto645 → annuity720 알고리즘 목록 정상', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      container.read(offlineSelectedGameTypeProvider.notifier).state =
          GameTypes.annuity720;
      expect(
        container.read(offlineAlgorithmsProvider).map((a) => a.id).toList(),
        [1, 9],
      );
      container.read(offlineSelectedGameTypeProvider.notifier).state =
          GameTypes.lotto645;
      expect(
        container.read(offlineAlgorithmsProvider).map((a) => a.id).toList(),
        [1, 9],
      );
      container.read(offlineSelectedGameTypeProvider.notifier).state =
          GameTypes.annuity720;
      expect(
        container.read(offlineAlgorithmsProvider).map((a) => a.id).toList(),
        [1, 9],
      );
    });

    test('G2-T04: isSerial + algo.id=9 로 generate → algorithmId==9', () async {
      final container = makeContainer(
        overrides: [
          offlineSelectedGameTypeProvider
              .overrideWith((ref) => GameTypes.annuity720),
          offlineSelectedAlgorithmProvider
              .overrideWith((ref) => const OfflineAlgorithmInfo(id: 9)),
          offlineNumberOfSetsProvider.overrideWith((ref) => 1),
        ],
      );
      addTearDown(container.dispose);
      await container.read(offlineGenerateProvider.notifier).generate();
      final async = container.read(offlineGenerateProvider);
      expect(async.hasValue, isTrue);
      expect(async.value!.algorithmId, 9);
    });

    test(
        'G2-T05: isSerial + algo.id=9 로 generate → '
        'algorithmName==Serial Digit Monte Carlo',
        () async {
      final container = makeContainer(
        overrides: [
          offlineSelectedGameTypeProvider
              .overrideWith((ref) => GameTypes.annuity720),
          offlineSelectedAlgorithmProvider
              .overrideWith((ref) => const OfflineAlgorithmInfo(id: 9)),
          offlineNumberOfSetsProvider.overrideWith((ref) => 1),
        ],
      );
      addTearDown(container.dispose);
      await container.read(offlineGenerateProvider.notifier).generate();
      final async = container.read(offlineGenerateProvider);
      expect(async.hasValue, isTrue);
      expect(async.value!.algorithmName, 'Serial Digit Monte Carlo');
    });
  });
}
