import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:uuid/uuid.dart';

/// 테스트용 [ProviderContainer]. [overrides] 로 Provider 치환 가능.
ProviderContainer makeContainer({List<Override> overrides = const []}) {
  return ProviderContainer(overrides: overrides);
}

/// 더미 [GeneratedNumbers]. [gameType]이 null이면 lotto645 기본값 사용.
GeneratedNumbers makeGeneratedNumbers(
  GameType? gameType, {
  int nSets = 3,
}) {
  final gt = gameType ?? GameTypes.lotto645;
  final results = List<NumberSetResult>.generate(
    nSets,
    (i) => NumberSetResult(
      setNo: i + 1,
      numbers: List<int>.generate(gt.mainCount, (j) => j + 1),
    ),
  );
  return GeneratedNumbers(
    gameTypeId: gt.id,
    algorithmId: 1,
    algorithmName: 'test',
    results: results,
    timestamp: DateTime.utc(2026, 5, 6),
    cost: 0,
    isSaved: false,
    id: const Uuid().v4(),
  );
}
