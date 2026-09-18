import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/data/data_sources/local/adapters/generated_numbers_adapter.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(GeneratedNumbersAdapter());
    }
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  GeneratedNumbers makeSample({
    required GameTypeId gameTypeId,
    required List<int> bonusBalls,
  }) {
    return GeneratedNumbers(
      gameTypeId: gameTypeId,
      bonusBalls: bonusBalls,
      algorithmId: 1,
      algorithmName: '자동선택',
      results: const [
        NumberSetResult(setNo: 1, numbers: [1, 2, 3, 4, 5, 6]),
      ],
      timestamp: DateTime.utc(2026, 5, 6),
      cost: 0,
      isSaved: true,
      id: 'id-1',
    );
  }

  test('A4-T01: lotto645 라운드트립 시 gameTypeId/bonusBalls 보존', () async {
    final box = await Hive.openBox<GeneratedNumbers>('generated_numbers_a4_t01');
    final original = makeSample(
      gameTypeId: GameTypeId.lotto645,
      bonusBalls: const [],
    );

    await box.put('k', original);
    final loaded = box.get('k');

    expect(loaded, isNotNull);
    expect(loaded!.gameTypeId, GameTypeId.lotto645);
    expect(loaded.bonusBalls, isEmpty);
    expect(loaded.results.first.numbers, const [1, 2, 3, 4, 5, 6]);
  });

  test('A4-T02: powerball 라운드트립 시 보너스 볼 값 보존', () async {
    final box = await Hive.openBox<GeneratedNumbers>('generated_numbers_a4_t02');
    final original = makeSample(
      gameTypeId: GameTypeId.powerball,
      bonusBalls: const [18],
    );

    await box.put('k', original);
    final loaded = box.get('k');

    expect(loaded, isNotNull);
    expect(loaded!.gameTypeId, GameTypeId.powerball);
    expect(loaded.bonusBalls, const [18]);
  });

  test('A4-T03: 다중 세트의 bonusBalls 리스트 길이/값 보존', () async {
    final box = await Hive.openBox<GeneratedNumbers>('generated_numbers_a4_t03');
    final original = GeneratedNumbers(
      gameTypeId: GameTypeId.megaMillions,
      bonusBalls: const [3, 7, 11, 22, 24],
      algorithmId: 9,
      algorithmName: '만 번 뽑기',
      results: const [
        NumberSetResult(setNo: 1, numbers: [1, 2, 3, 4, 5]),
        NumberSetResult(setNo: 2, numbers: [6, 7, 8, 9, 10]),
        NumberSetResult(setNo: 3, numbers: [11, 12, 13, 14, 15]),
        NumberSetResult(setNo: 4, numbers: [16, 17, 18, 19, 20]),
        NumberSetResult(setNo: 5, numbers: [21, 22, 23, 24, 25]),
      ],
      timestamp: DateTime.utc(2026, 5, 6),
      cost: 0,
      isSaved: false,
      id: 'id-3',
    );

    await box.put('k', original);
    final loaded = box.get('k');

    expect(loaded, isNotNull);
    expect(loaded!.bonusBalls.length, 5);
    expect(loaded.bonusBalls, const [3, 7, 11, 22, 24]);
  });

  test('A4-T04: 모든 GameTypeId가 index 직렬화/역직렬화로 보존', () async {
    final box = await Hive.openBox<GeneratedNumbers>('generated_numbers_a4_t04');
    for (final id in GameTypeId.values) {
      final original = makeSample(gameTypeId: id, bonusBalls: const []);
      await box.put(id.index, original);
    }

    for (final id in GameTypeId.values) {
      final loaded = box.get(id.index);
      expect(loaded, isNotNull);
      expect(loaded!.gameTypeId, id);
    }
  });
}
