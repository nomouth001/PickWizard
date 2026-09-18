import 'dart:math';

import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';

/// 오프라인 로또 번호 생성 서비스 (045 설계)
///
/// 볼픽: 알고리즘 1(자동선택), 9(만 번 뽑기 상위 6개).
/// 시리얼(annuity720): 알고리즘 1(시리얼 퀵픽), 9(자리별 3천회 최빈).

const int _minSets = 1;
const int _maxSets = 100;
const int _monteCarloTrials = 10000;
const int _kSerialDigitTrialsPerPosition = 3000;

/// 검증 결과 (유효, 메시지)
(bool, String?) validateParameters({
  required GameType gameType,
  required int nSets,
  List<int>? excludeNumbers,
  List<int>? includeNumbers,
  int? bonusIncludeNumber,
  List<int>? bonusExcludeNumbers,
}) {
  final maxExclude = gameType.mainPoolSize - gameType.mainCount;
  final maxInclude = gameType.mainCount;

  if (nSets < _minSets || nSets > _maxSets) {
    return (false, '세트 수는 $_minSets~$_maxSets 사이여야 합니다');
  }
  if (excludeNumbers != null) {
    if (excludeNumbers.length > maxExclude) {
      return (false, '제외 번호는 최대 $maxExclude개까지 가능합니다');
    }
    if (_hasInvalidOrDuplicate(
      excludeNumbers,
      gameType.mainMin,
      gameType.mainMax,
    )) {
      return (false,
          '제외 번호는 ${gameType.mainMin}~${gameType.mainMax} 사이 정수이며 중복이 없어야 합니다');
    }
  }
  if (includeNumbers != null) {
    if (includeNumbers.length > maxInclude) {
      return (false, '포함 번호는 최대 $maxInclude개까지 가능합니다');
    }
    if (_hasInvalidOrDuplicate(
      includeNumbers,
      gameType.mainMin,
      gameType.mainMax,
    )) {
      return (false,
          '포함 번호는 ${gameType.mainMin}~${gameType.mainMax} 사이 정수이며 중복이 없어야 합니다');
    }
  }
  if (excludeNumbers != null && includeNumbers != null) {
    final overlap = excludeNumbers.toSet().intersection(includeNumbers.toSet());
    if (overlap.isNotEmpty) {
      return (false, '제외/포함 번호가 겹칩니다');
    }
  }
  final excludeCount = excludeNumbers?.length ?? 0;
  final includeCount = includeNumbers?.length ?? 0;
  final availableCount = gameType.mainPoolSize - excludeCount;
  final requiredCount = gameType.mainCount - includeCount;
  if (availableCount < requiredCount) {
    return (false, '사용 가능한 번호가 부족합니다');
  }

  if (gameType.hasBonus) {
    final bonusMin = gameType.bonusMin!;
    final bonusMax = gameType.bonusMax!;
    if (bonusIncludeNumber != null &&
        (bonusIncludeNumber < bonusMin || bonusIncludeNumber > bonusMax)) {
      return (false, '보너스 포함 번호는 $bonusMin~$bonusMax 범위여야 합니다');
    }
    if (bonusExcludeNumbers != null) {
      if (_hasInvalidOrDuplicate(bonusExcludeNumbers, bonusMin, bonusMax)) {
        return (false, '보너스 제외 번호는 $bonusMin~$bonusMax 사이 정수이며 중복이 없어야 합니다');
      }
      if (bonusIncludeNumber != null &&
          bonusExcludeNumbers.contains(bonusIncludeNumber)) {
        return (false, '보너스 포함/제외 번호가 겹칩니다');
      }
      final bonusPoolSize = bonusMax - bonusMin + 1;
      final availableBonusPoolSize = bonusPoolSize - bonusExcludeNumbers.length;
      if (availableBonusPoolSize < 1) {
        return (false, '사용 가능한 보너스 번호가 부족합니다');
      }
    }
  }

  return (true, null);
}

bool _hasInvalidOrDuplicate(List<int> numbers, int min, int max) {
  final set = <int>{};
  for (final n in numbers) {
    if (n < min || n > max) return true;
    if (!set.add(n)) return true;
  }
  return false;
}

/// 사용 가능한 번호 풀 (mainMin~mainMax에서 제외·포함 제거)
List<int> getAvailableNumbers({
  required GameType gameType,
  List<int>? excludeNumbers,
  List<int>? includeNumbers,
}) {
  final set = <int>{};
  for (int i = gameType.mainMin; i <= gameType.mainMax; i++) {
    set.add(i);
  }
  if (excludeNumbers != null) set.removeAll(excludeNumbers);
  if (includeNumbers != null) set.removeAll(includeNumbers);
  return set.toList()..sort();
}

int _generateBonusBall(
  GameType gameType, {
  int? include,
  List<int>? exclude,
}) {
  final bonusMin = gameType.bonusMin!;
  final bonusMax = gameType.bonusMax!;
  final pool = <int>{};
  for (var n = bonusMin; n <= bonusMax; n++) {
    pool.add(n);
  }
  if (exclude != null) {
    pool.removeAll(exclude);
  }
  if (include != null) {
    return include;
  }
  if (pool.isEmpty) {
    throw ArgumentError('사용 가능한 보너스 번호가 부족합니다');
  }
  final list = pool.toList()..sort();
  list.shuffle();
  return list.first;
}

GeneratedNumbers _buildGenerated({
  required GameType gameType,
  required List<List<int>> sets,
  required List<int> bonusBalls,
}) {
  final results = sets
      .asMap()
      .entries
      .map((e) => NumberSetResult(setNo: e.key + 1, numbers: e.value))
      .toList();
  return GeneratedNumbers(
    gameTypeId: gameType.id,
    bonusBalls: bonusBalls,
    algorithmId: 0,
    algorithmName: '',
    results: results,
    timestamp: DateTime.now(),
    cost: 0,
    isSaved: false,
    id: null,
  );
}

/// 알고리즘 1: 자동선택 (Quick Pick)
GeneratedNumbers generateQuickPick({
  required GameType gameType,
  required int nSets,
  List<int>? excludeNumbers,
  List<int>? includeNumbers,
  int? bonusIncludeNumber,
  List<int>? bonusExcludeNumbers,
}) {
  final ok = validateParameters(
    gameType: gameType,
    nSets: nSets,
    excludeNumbers: excludeNumbers,
    includeNumbers: includeNumbers,
    bonusIncludeNumber: bonusIncludeNumber,
    bonusExcludeNumbers: bonusExcludeNumbers,
  );
  if (!ok.$1) throw ArgumentError(ok.$2);

  final available = getAvailableNumbers(
    gameType: gameType,
    excludeNumbers: excludeNumbers,
    includeNumbers: includeNumbers,
  );
  final include = includeNumbers ?? [];
  final remaining = gameType.mainCount - include.length;
  final bonusBalls = <int>[];
  if (remaining <= 0) {
    final fixedSets = List<List<int>>.generate(
      nSets,
      (_) => List<int>.from(include)..sort(),
    );
    if (gameType.hasBonus) {
      for (var i = 0; i < nSets; i++) {
        bonusBalls.add(
          _generateBonusBall(
            gameType,
            include: bonusIncludeNumber,
            exclude: bonusExcludeNumbers,
          ),
        );
      }
    }
    return _buildGenerated(
      gameType: gameType,
      sets: fixedSets,
      bonusBalls: bonusBalls,
    );
  }
  if (available.length < remaining) throw ArgumentError('사용 가능한 번호 부족');

  final resultSets = <List<int>>[];
  for (int s = 0; s < nSets; s++) {
    available.shuffle();
    final selected = available.take(remaining).toList()..sort();
    final set = List<int>.from(include)..addAll(selected);
    set.sort();
    resultSets.add(set);
    if (gameType.hasBonus) {
      bonusBalls.add(
        _generateBonusBall(
          gameType,
          include: bonusIncludeNumber,
          exclude: bonusExcludeNumbers,
        ),
      );
    }
  }
  return _buildGenerated(
    gameType: gameType,
    sets: resultSets,
    bonusBalls: bonusBalls,
  );
}

/// 알고리즘 9: 만 번 뽑기 6개
GeneratedNumbers generateMonteCarloTop({
  required GameType gameType,
  required int nSets,
  List<int>? excludeNumbers,
  List<int>? includeNumbers,
  int? bonusIncludeNumber,
  List<int>? bonusExcludeNumbers,
}) {
  final ok = validateParameters(
    gameType: gameType,
    nSets: nSets,
    excludeNumbers: excludeNumbers,
    includeNumbers: includeNumbers,
    bonusIncludeNumber: bonusIncludeNumber,
    bonusExcludeNumbers: bonusExcludeNumbers,
  );
  if (!ok.$1) throw ArgumentError(ok.$2);

  final pool = getAvailableNumbers(
    gameType: gameType,
    excludeNumbers: excludeNumbers,
    includeNumbers: includeNumbers,
  );
  final include = includeNumbers ?? [];
  final needPerSet = gameType.mainCount - include.length;
  if (pool.length < needPerSet) throw ArgumentError('사용 가능한 번호 부족');

  final resultSets = <List<int>>[];
  final bonusBalls = <int>[];
  final random = Random();

  for (int s = 0; s < nSets; s++) {
    final counts = <int, int>{};
    for (int i = 0; i < _monteCarloTrials; i++) {
      final num = pool[random.nextInt(pool.length)];
      counts[num] = (counts[num] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) {
        final c = b.value.compareTo(a.value);
        return c != 0 ? c : a.key.compareTo(b.key);
      });
    final selected = <int>[];
    for (final e in sorted) {
      if (selected.length >= needPerSet) break;
      selected.add(e.key);
    }
    final set = List<int>.from(include)..addAll(selected);
    set.sort();
    resultSets.add(set);
    if (gameType.hasBonus) {
      bonusBalls.add(
        _generateBonusBall(
          gameType,
          include: bonusIncludeNumber,
          exclude: bonusExcludeNumbers,
        ),
      );
    }
  }
  return _buildGenerated(
    gameType: gameType,
    sets: resultSets,
    bonusBalls: bonusBalls,
  );
}

/// 시리얼(연금복권720+) 전용 파라미터 검증.
(bool, String?) validateSerialParameters({
  required int nSets,
  int? fixedGroup,
  List<int>? excludeGroups,
}) {
  if (nSets < _minSets || nSets > _maxSets) {
    return (false, '세트 수는 $_minSets~$_maxSets 사이여야 합니다');
  }

  if (fixedGroup != null && (fixedGroup < 1 || fixedGroup > 5)) {
    return (false, '고정 조는 1~5 범위여야 합니다');
  }

  final excludes = excludeGroups ?? const <int>[];
  if (excludes.length > 4) {
    return (false, '제외 조는 최대 4개까지 가능합니다');
  }
  if (_hasInvalidOrDuplicate(excludes, 1, 5)) {
    return (false, '제외 조는 1~5 사이 정수이며 중복이 없어야 합니다');
  }

  if (fixedGroup != null && excludes.contains(fixedGroup)) {
    return (false, '고정 조와 제외 조가 겹칩니다');
  }

  if (fixedGroup == null) {
    final availableGroupCount = 5 - excludes.length;
    if (availableGroupCount < 1) {
      return (false, '사용 가능한 조가 부족합니다');
    }
  }

  return (true, null);
}

/// 연금복권720+ 시리얼 번호 생성.
GeneratedNumbers generateSerial({
  required GameType gameType,
  required int nSets,
  int? fixedGroup,
  List<int>? excludeGroups,
}) {
  final ok = validateSerialParameters(
    nSets: nSets,
    fixedGroup: fixedGroup,
    excludeGroups: excludeGroups,
  );
  if (!ok.$1) throw ArgumentError(ok.$2);
  if (!gameType.isSerial) {
    throw ArgumentError('시리얼 생성은 serial 게임 타입에서만 지원합니다.');
  }

  final random = Random();
  final groupPool = [1, 2, 3, 4, 5]
    ..removeWhere((g) => (excludeGroups ?? const <int>[]).contains(g));

  final sets = <List<int>>[];
  final bonusBalls = <int>[];
  for (var i = 0; i < nSets; i++) {
    final group = _pickSerialGroup(
      random: random,
      fixedGroup: fixedGroup,
      groupPool: groupPool,
    );
    final digits = List<int>.generate(6, (_) => random.nextInt(10));
    sets.add(digits);
    bonusBalls.add(group);
  }

  return _buildGenerated(
    gameType: gameType,
    sets: sets,
    bonusBalls: bonusBalls,
  );
}

int _pickSerialGroup({
  required Random random,
  required int? fixedGroup,
  required List<int> groupPool,
}) {
  if (fixedGroup != null) return fixedGroup;
  return groupPool[random.nextInt(groupPool.length)];
}

/// 알고리즘 9 (시리얼): 각 자리 0~9를 [_kSerialDigitTrialsPerPosition]회 뽑아
/// 최빈값을 선택한다. 동률이면 더 작은 숫자를 선택한다.
GeneratedNumbers generateSerialDigitMonteCarlo({
  required GameType gameType,
  required int nSets,
  int? fixedGroup,
  List<int>? excludeGroups,
  Random? random,
}) {
  final ok = validateSerialParameters(
    nSets: nSets,
    fixedGroup: fixedGroup,
    excludeGroups: excludeGroups,
  );
  if (!ok.$1) throw ArgumentError(ok.$2);
  if (!gameType.isSerial) {
    throw ArgumentError('시리얼 생성은 serial 게임 타입에서만 지원합니다.');
  }

  final rng = random ?? Random();
  final groupPool = [1, 2, 3, 4, 5]
    ..removeWhere((g) => (excludeGroups ?? const <int>[]).contains(g));
  final sets = <List<int>>[];
  final bonusBalls = <int>[];

  for (var i = 0; i < nSets; i++) {
    final group = _pickSerialGroup(
      random: rng,
      fixedGroup: fixedGroup,
      groupPool: groupPool,
    );
    final digits = <int>[];
    for (var position = 0; position < 6; position++) {
      final counts = List<int>.filled(10, 0);
      for (var trial = 0; trial < _kSerialDigitTrialsPerPosition; trial++) {
        final value = rng.nextInt(10);
        counts[value]++;
      }

      var bestDigit = 0;
      var bestCount = counts[0];
      for (var digit = 1; digit < counts.length; digit++) {
        if (counts[digit] > bestCount) {
          bestCount = counts[digit];
          bestDigit = digit;
        }
      }
      digits.add(bestDigit);
    }

    sets.add(digits);
    bonusBalls.add(group);
  }

  return _buildGenerated(
    gameType: gameType,
    sets: sets,
    bonusBalls: bonusBalls,
  );
}

