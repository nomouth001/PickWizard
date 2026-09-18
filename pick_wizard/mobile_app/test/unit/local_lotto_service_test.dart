import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/offline/services/local_lotto_service.dart';

class _CyclingRandom implements Random {
  int _i = 0;

  @override
  int nextInt(int max) => (_i++) % max;

  @override
  double nextDouble() => throw UnimplementedError();

  @override
  bool nextBool() => throw UnimplementedError();
}

class _ConstantRandom implements Random {
  final int value;
  _ConstantRandom(this.value);

  @override
  int nextInt(int max) => value % max;

  @override
  double nextDouble() => throw UnimplementedError();

  @override
  bool nextBool() => throw UnimplementedError();
}

void main() {
  group('Phase B — 로또645 회귀 (B-T01~B-T17)', () {
    test('B-T01: QuickPick 출력 개수', () {
      final r = generateQuickPick(gameType: GameTypes.lotto645, nSets: 5);
      expect(r.results.length, 5);
    });

    test('B-T02: QuickPick 번호 범위 1~45', () {
      final r = generateQuickPick(gameType: GameTypes.lotto645, nSets: 10);
      for (final set in r.results.map((e) => e.numbers)) {
        for (final n in set) {
          expect(n, inInclusiveRange(1, 45));
        }
      }
    });

    test('B-T03: QuickPick 세트 내 중복 없음', () {
      final r = generateQuickPick(gameType: GameTypes.lotto645, nSets: 50);
      for (final set in r.results.map((e) => e.numbers)) {
        expect(set.length, 6);
        expect(set.toSet().length, 6);
      }
    });

    test('B-T04: QuickPick 각 세트 오름차순 정렬', () {
      final r = generateQuickPick(gameType: GameTypes.lotto645, nSets: 5);
      for (final set in r.results.map((e) => e.numbers)) {
        expect(List<int>.from(set)..sort(), set);
      }
    });

    test('B-T05: QuickPick 포함 번호 보장', () {
      const include = [7, 13, 22];
      final r = generateQuickPick(
        gameType: GameTypes.lotto645,
        nSets: 5,
        includeNumbers: include,
      );
      for (final set in r.results.map((e) => e.numbers)) {
        expect(set.contains(7), isTrue);
        expect(set.contains(13), isTrue);
        expect(set.contains(22), isTrue);
      }
    });

    test('B-T06: QuickPick 제외 번호 배제', () {
      final exclude = List<int>.generate(5, (i) => i + 1);
      final r = generateQuickPick(
        gameType: GameTypes.lotto645,
        nSets: 10,
        excludeNumbers: exclude,
      );
      for (final set in r.results.map((e) => e.numbers)) {
        for (final n in set) {
          expect(n, greaterThan(5));
        }
      }
    });

    test('B-T07: QuickPick 포함+제외 동시 (5 포함, 10~44 제외)', () {
      final exclude = List<int>.generate(35, (i) => 10 + i);
      final r = generateQuickPick(
        gameType: GameTypes.lotto645,
        nSets: 8,
        includeNumbers: const [5],
        excludeNumbers: exclude,
      );
      const allowedFill = {1, 2, 3, 4, 6, 7, 8, 9, 45};
      for (final set in r.results.map((e) => e.numbers)) {
        expect(set.contains(5), isTrue);
        for (final n in set) {
          if (n != 5) {
            expect(allowedFill.contains(n), isTrue,
                reason: '나머지 5개는 1~9·45 중에서만 선택');
          }
        }
      }
    });

    test('B-T08: nSets 범위 초과 시 ArgumentError', () {
      expect(
        () => generateQuickPick(
          gameType: GameTypes.lotto645,
          nSets: 101,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('B-T09: 포함 번호 7개 시 ArgumentError', () {
      final include = List<int>.generate(7, (i) => i + 1);
      expect(
        () => generateQuickPick(
          gameType: GameTypes.lotto645,
          nSets: 1,
          includeNumbers: include,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('B-T10: 제외 번호 40개 시 ArgumentError', () {
      final exclude = List<int>.generate(40, (i) => i + 1);
      expect(
        () => generateQuickPick(
          gameType: GameTypes.lotto645,
          nSets: 1,
          excludeNumbers: exclude,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('B-T11: 포함/제외 겹침 시 ArgumentError', () {
      expect(
        () => generateQuickPick(
          gameType: GameTypes.lotto645,
          nSets: 1,
          includeNumbers: const [5],
          excludeNumbers: const [5],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('B-T12: 제외 39개(1~39), 포함 없음 — 유효', () {
      final exclude = List<int>.generate(39, (i) => i + 1);
      final ok = validateParameters(
        gameType: GameTypes.lotto645,
        nSets: 1,
        excludeNumbers: exclude,
        includeNumbers: null,
      );
      expect(ok.$1, isTrue);

      final r = generateQuickPick(
        gameType: GameTypes.lotto645,
        nSets: 3,
        excludeNumbers: exclude,
      );
      expect(r.results.length, 3);
      for (final set in r.results.map((e) => e.numbers)) {
        expect(set.toSet(), {40, 41, 42, 43, 44, 45});
      }
    });

    test('B-T13: 제외 39개 + 포함이 나머지 6개 전부 — 유효', () {
      final exclude = List<int>.generate(39, (i) => i + 1);
      final include = List<int>.generate(6, (i) => 40 + i);
      final ok = validateParameters(
        gameType: GameTypes.lotto645,
        nSets: 1,
        excludeNumbers: exclude,
        includeNumbers: include,
      );
      expect(ok.$1, isTrue);

      final r = generateQuickPick(
        gameType: GameTypes.lotto645,
        nSets: 4,
        excludeNumbers: exclude,
        includeNumbers: include,
      );
      expect(r.results.length, 4);
      for (final set in r.results.map((e) => e.numbers)) {
        expect(set, include);
      }
    });

    test('B-T14: MonteCarlo 출력 개수', () {
      final r = generateMonteCarloTop(gameType: GameTypes.lotto645, nSets: 3);
      expect(r.results.length, 3);
    });

    test('B-T15: MonteCarlo 번호 범위 1~45', () {
      final r = generateMonteCarloTop(gameType: GameTypes.lotto645, nSets: 10);
      for (final set in r.results.map((e) => e.numbers)) {
        for (final n in set) {
          expect(n, inInclusiveRange(1, 45));
        }
      }
    });

    test('B-T16: MonteCarlo 세트 내 중복 없음', () {
      final r = generateMonteCarloTop(gameType: GameTypes.lotto645, nSets: 10);
      for (final set in r.results.map((e) => e.numbers)) {
        expect(set.length, 6);
        expect(set.toSet().length, 6);
      }
    });

    test('B-T17: MonteCarlo 포함 번호 보장', () {
      const include = [3, 7];
      final r = generateMonteCarloTop(
        gameType: GameTypes.lotto645,
        nSets: 6,
        includeNumbers: include,
      );
      for (final set in r.results.map((e) => e.numbers)) {
        expect(set.contains(3), isTrue);
        expect(set.contains(7), isTrue);
      }
    });
  });

  group('Phase C — 게임 타입별 생성 로직 (C-T01~C-T15)', () {
    test('C-T01: powerball QuickPick 메인 번호 범위 1~69', () {
      final r = generateQuickPick(gameType: GameTypes.powerball, nSets: 10);
      for (final set in r.results.map((e) => e.numbers)) {
        for (final n in set) {
          expect(n, inInclusiveRange(1, 69));
        }
      }
    });

    test('C-T02: powerball QuickPick 세트당 메인 번호 5개', () {
      final r = generateQuickPick(gameType: GameTypes.powerball, nSets: 5);
      for (final set in r.results.map((e) => e.numbers)) {
        expect(set.length, 5);
      }
    });

    test('C-T03: powerball QuickPick 보너스 볼 범위 1~26', () {
      final r = generateQuickPick(gameType: GameTypes.powerball, nSets: 20);
      for (final b in r.bonusBalls) {
        expect(b, inInclusiveRange(1, 26));
      }
    });

    test('C-T04: powerball QuickPick bonusBalls 길이 = nSets', () {
      final r = generateQuickPick(gameType: GameTypes.powerball, nSets: 7);
      expect(r.bonusBalls.length, 7);
    });

    test('C-T05: powerball QuickPick 보너스 포함 고정', () {
      final r = generateQuickPick(
        gameType: GameTypes.powerball,
        nSets: 5,
        bonusIncludeNumber: 15,
      );
      expect(r.bonusBalls, everyElement(15));
    });

    test('C-T06: powerball QuickPick 보너스 제외 [1..25]면 모두 26', () {
      final r = generateQuickPick(
        gameType: GameTypes.powerball,
        nSets: 6,
        bonusExcludeNumbers: List<int>.generate(25, (i) => i + 1),
      );
      expect(r.bonusBalls, everyElement(26));
    });

    test('C-T07: powerball QuickPick 보너스 제외 [1..26]면 오류', () {
      expect(
        () => generateQuickPick(
          gameType: GameTypes.powerball,
          nSets: 1,
          bonusExcludeNumbers: List<int>.generate(26, (i) => i + 1),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('C-T08: powerball MonteCarlo 메인 번호 범위 1~69', () {
      final r = generateMonteCarloTop(gameType: GameTypes.powerball, nSets: 5);
      for (final set in r.results.map((e) => e.numbers)) {
        for (final n in set) {
          expect(n, inInclusiveRange(1, 69));
        }
      }
    });

    test('C-T09: powerball MonteCarlo 보너스 볼 범위 1~26', () {
      final r = generateMonteCarloTop(gameType: GameTypes.powerball, nSets: 5);
      for (final b in r.bonusBalls) {
        expect(b, inInclusiveRange(1, 26));
      }
    });

    test('C-T10: megaMillions QuickPick 메인 번호 범위 1~70', () {
      final r = generateQuickPick(gameType: GameTypes.megaMillions, nSets: 10);
      for (final set in r.results.map((e) => e.numbers)) {
        for (final n in set) {
          expect(n, inInclusiveRange(1, 70));
        }
      }
    });

    test('C-T11: megaMillions QuickPick 보너스 볼 범위 1~25', () {
      final r = generateQuickPick(gameType: GameTypes.megaMillions, nSets: 10);
      for (final b in r.bonusBalls) {
        expect(b, inInclusiveRange(1, 25));
      }
    });

    test('C-T12: winForLife QuickPick 메인 번호 범위 1~48', () {
      final r = generateQuickPick(gameType: GameTypes.winForLife, nSets: 10);
      for (final set in r.results.map((e) => e.numbers)) {
        for (final n in set) {
          expect(n, inInclusiveRange(1, 48));
        }
      }
    });

    test('C-T13: winForLife QuickPick 보너스 볼 범위 1~18', () {
      final r = generateQuickPick(gameType: GameTypes.winForLife, nSets: 10);
      for (final b in r.bonusBalls) {
        expect(b, inInclusiveRange(1, 18));
      }
    });

    test('C-T14: lotto645 bonusBalls는 빈 리스트', () {
      final r = generateQuickPick(gameType: GameTypes.lotto645, nSets: 5);
      expect(r.bonusBalls, isEmpty);
    });

    test('C-T15: lotto645 메인 번호 개수는 세트당 6개', () {
      final r = generateQuickPick(gameType: GameTypes.lotto645, nSets: 5);
      for (final set in r.results.map((e) => e.numbers)) {
        expect(set.length, 6);
      }
    });
  });

  group('Phase F3 — 시리얼 생성 로직 (F3-T01~F3-T14)', () {
    test('F3-T01: generateSerial 1세트 결과 길이 == 1', () {
      final r = generateSerial(gameType: GameTypes.annuity720, nSets: 1);
      expect(r.results.length, 1);
    });

    test('F3-T02: generateSerial 1세트 각 numbers 길이 == 6', () {
      final r = generateSerial(gameType: GameTypes.annuity720, nSets: 1);
      expect(r.results.single.numbers.length, 6);
    });

    test('F3-T03: 각 자리 숫자는 0~9 범위', () {
      final r = generateSerial(gameType: GameTypes.annuity720, nSets: 20);
      for (final set in r.results.map((e) => e.numbers)) {
        for (final d in set) {
          expect(d, inInclusiveRange(0, 9));
        }
      }
    });

    test('F3-T04: 자리 중복 허용(다중 세트 중 최소 1세트는 중복 가능)', () {
      final r = generateSerial(gameType: GameTypes.annuity720, nSets: 50);
      final hasDuplicateSet = r.results
          .map((e) => e.numbers)
          .any((digits) => digits.toSet().length < digits.length);
      expect(hasDuplicateSet, isTrue);
    });

    test('F3-T05: bonusBalls 길이 1, 값 1~5', () {
      final r = generateSerial(gameType: GameTypes.annuity720, nSets: 1);
      expect(r.bonusBalls.length, 1);
      expect(r.bonusBalls.single, inInclusiveRange(1, 5));
    });

    test('F3-T06: 5세트 생성 시 results/bonusBalls 길이 모두 5', () {
      final r = generateSerial(gameType: GameTypes.annuity720, nSets: 5);
      expect(r.results.length, 5);
      expect(r.bonusBalls.length, 5);
    });

    test('F3-T07: fixedGroup=3이면 모든 bonusBalls가 3', () {
      final r = generateSerial(
        gameType: GameTypes.annuity720,
        nSets: 10,
        fixedGroup: 3,
      );
      expect(r.bonusBalls, everyElement(3));
    });

    test('F3-T08: excludeGroups=[1,2]이면 조는 3,4,5 중 하나', () {
      final r = generateSerial(
        gameType: GameTypes.annuity720,
        nSets: 20,
        excludeGroups: const [1, 2],
      );
      for (final g in r.bonusBalls) {
        expect({3, 4, 5}.contains(g), isTrue);
      }
    });

    test('F3-T09: excludeGroups=[1,2,3,4,5]는 ArgumentError', () {
      expect(
        () => generateSerial(
          gameType: GameTypes.annuity720,
          nSets: 1,
          excludeGroups: const [1, 2, 3, 4, 5],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('F3-T10: fixedGroup=3 + excludeGroups=[3]은 validate 실패', () {
      final ok = validateSerialParameters(
        nSets: 1,
        fixedGroup: 3,
        excludeGroups: const [3],
      );
      expect(ok.$1, isFalse);
    });

    test('F3-T11: validateSerialParameters(nSets:0) 실패', () {
      final ok = validateSerialParameters(nSets: 0);
      expect(ok.$1, isFalse);
    });

    test('F3-T12: validateSerialParameters(nSets:101) 실패', () {
      final ok = validateSerialParameters(nSets: 101);
      expect(ok.$1, isFalse);
    });

    test('F3-T13: generateSerial 결과 gameTypeId는 annuity720', () {
      final r = generateSerial(gameType: GameTypes.annuity720, nSets: 3);
      expect(r.gameTypeId, GameTypeId.annuity720);
    });

    test('F3-T14: fixedGroup=2 유효, fixedGroup=6은 validate 실패', () {
      final okValid = validateSerialParameters(nSets: 1, fixedGroup: 2);
      final okInvalid = validateSerialParameters(nSets: 1, fixedGroup: 6);
      expect(okValid.$1, isTrue);
      expect(okInvalid.$1, isFalse);
    });
  });

  group('Phase G1 — 시리얼 자리별 MonteCarlo (G1-T01~G1-T11)', () {
    test('G1-T01: nSets=1 -> results.length==1, numbers.length==6', () {
      final r =
          generateSerialDigitMonteCarlo(gameType: GameTypes.annuity720, nSets: 1);
      expect(r.results.length, 1);
      expect(r.results.single.numbers.length, 6);
    });

    test('G1-T02: 모든 자리 값은 0~9 범위', () {
      final r =
          generateSerialDigitMonteCarlo(gameType: GameTypes.annuity720, nSets: 20);
      for (final set in r.results.map((e) => e.numbers)) {
        for (final d in set) {
          expect(d, inInclusiveRange(0, 9));
        }
      }
    });

    test('G1-T03: bonusBalls.length==1, 값은 1~5', () {
      final r =
          generateSerialDigitMonteCarlo(gameType: GameTypes.annuity720, nSets: 1);
      expect(r.bonusBalls.length, 1);
      expect(r.bonusBalls.single, inInclusiveRange(1, 5));
    });

    test('G1-T04: nSets=10 -> results.length==10', () {
      final r =
          generateSerialDigitMonteCarlo(gameType: GameTypes.annuity720, nSets: 10);
      expect(r.results.length, 10);
    });

    test('G1-T05: fixedGroup=4면 모든 세트 조가 4', () {
      final r = generateSerialDigitMonteCarlo(
        gameType: GameTypes.annuity720,
        nSets: 10,
        fixedGroup: 4,
      );
      expect(r.bonusBalls, everyElement(4));
    });

    test('G1-T06: excludeGroups=[5]면 조는 1,2,3,4 중 하나', () {
      final r = generateSerialDigitMonteCarlo(
        gameType: GameTypes.annuity720,
        nSets: 20,
        excludeGroups: const [5],
      );
      for (final g in r.bonusBalls) {
        expect({1, 2, 3, 4}.contains(g), isTrue);
      }
    });

    test('G1-T07: validateSerialParameters 실패 케이스는 ArgumentError', () {
      expect(
        () => generateSerialDigitMonteCarlo(
          gameType: GameTypes.annuity720,
          nSets: 1,
          excludeGroups: const [1, 2, 3, 4, 5],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('G1-T08: serial이 아닌 gameType(lotto645) 호출 시 ArgumentError', () {
      expect(
        () => generateSerialDigitMonteCarlo(
          gameType: GameTypes.lotto645,
          nSets: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('G1-T09: 순환 RNG는 동률 타이브레이크로 6자리 모두 0', () {
      final r = generateSerialDigitMonteCarlo(
        gameType: GameTypes.annuity720,
        nSets: 1,
        random: _CyclingRandom(),
      );
      expect(r.results.single.numbers, [0, 0, 0, 0, 0, 0]);
    });

    test('G1-T10: 상수 RNG(3)는 모든 자리가 3', () {
      final r = generateSerialDigitMonteCarlo(
        gameType: GameTypes.annuity720,
        nSets: 1,
        random: _ConstantRandom(3),
      );
      expect(r.results.single.numbers, [3, 3, 3, 3, 3, 3]);
    });

    test('G1-T11: gameTypeId == annuity720', () {
      final r =
          generateSerialDigitMonteCarlo(gameType: GameTypes.annuity720, nSets: 2);
      expect(r.gameTypeId, GameTypeId.annuity720);
    });
  });
}
