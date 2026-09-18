import 'package:flutter_test/flutter_test.dart';
import 'package:pick_wizard/core/models/game_type.dart';

void main() {
  group('GameType 모델', () {
    test('A1-T01: lotto645 mainMax는 45', () {
      expect(GameTypes.lotto645.mainMax, 45);
    });

    test('A1-T02: powerball mainCount는 5', () {
      expect(GameTypes.powerball.mainCount, 5);
    });

    test('A1-T03: powerball은 보너스 볼이 있다', () {
      expect(GameTypes.powerball.hasBonus, isTrue);
    });

    test('A1-T04: lotto645는 보너스 볼이 없다', () {
      expect(GameTypes.lotto645.hasBonus, isFalse);
    });

    test('A1-T05: megaMillions bonusMax는 25', () {
      expect(GameTypes.megaMillions.bonusMax, 25);
    });

    test('A1-T06: winForLife bonusMax는 18', () {
      expect(GameTypes.winForLife.bonusMax, 18);
    });

    test('A1-T07: lotto645 colorZoneFor(1)는 0', () {
      expect(GameTypes.lotto645.colorZoneFor(1), 0);
    });

    test('A1-T08: lotto645 colorZoneFor(10)는 0', () {
      expect(GameTypes.lotto645.colorZoneFor(10), 0);
    });

    test('A1-T09: lotto645 colorZoneFor(11)는 1', () {
      expect(GameTypes.lotto645.colorZoneFor(11), 1);
    });

    test('A1-T10: lotto645 colorZoneFor(45)는 4', () {
      expect(GameTypes.lotto645.colorZoneFor(45), 4);
    });

    test('A1-T11: powerball colorZoneFor(57)는 4', () {
      expect(GameTypes.powerball.colorZoneFor(57), 4);
    });

    test('A1-T12: fromId는 megaMillions를 조회한다', () {
      expect(
        GameTypes.fromId(GameTypeId.megaMillions),
        same(GameTypes.megaMillions),
      );
    });

    test('A1-T13: fromId는 모든 id를 올바르게 조회한다', () {
      for (final id in GameTypeId.values) {
        expect(GameTypes.fromId(id).id, id);
      }
    });

    test('A1-T14: 모든 GameType의 colorZoneBounds 길이는 5', () {
      for (final gameType in GameTypes.all) {
        expect(
          gameType.colorZoneBounds.length,
          5,
          reason: '${gameType.id} colorZoneBounds length',
        );
      }
    });

    test('A1-T15: 모든 GameType의 colorZoneBounds 마지막 값은 mainMax', () {
      for (final gameType in GameTypes.all) {
        expect(
          gameType.colorZoneBounds.last,
          gameType.mainMax,
          reason: '${gameType.id} last colorZoneBound',
        );
      }
    });

    test('F1-T01: GameCategory enum에 ballPick, serial이 존재한다', () {
      expect(GameCategory.values, [GameCategory.ballPick, GameCategory.serial]);
    });

    test('F1-T02: GameTypeId enum에 annuity720이 5번째 값으로 존재한다', () {
      expect(GameTypeId.values.length, 5);
      expect(GameTypeId.values[4], GameTypeId.annuity720);
    });

    test('F1-T03: annuity720 category는 serial이다', () {
      expect(GameTypes.annuity720.category, GameCategory.serial);
    });

    test('F1-T04: lotto645 category는 ballPick이다', () {
      expect(GameTypes.lotto645.category, GameCategory.ballPick);
    });

    test('F1-T05: powerball category는 ballPick이다', () {
      expect(GameTypes.powerball.category, GameCategory.ballPick);
    });

    test('F1-T06: annuity720 isSerial은 true다', () {
      expect(GameTypes.annuity720.isSerial, isTrue);
    });

    test('F1-T07: lotto645 isSerial은 false다', () {
      expect(GameTypes.lotto645.isSerial, isFalse);
    });

    test('F1-T08: annuity720 isBallPick은 false다', () {
      expect(GameTypes.annuity720.isBallPick, isFalse);
    });

    test('F1-T09: annuity720 main 설정은 0~9, 6개다', () {
      expect(GameTypes.annuity720.mainMin, 0);
      expect(GameTypes.annuity720.mainMax, 9);
      expect(GameTypes.annuity720.mainCount, 6);
    });

    test('F1-T10: annuity720 bonus 설정은 1~5, 1개다', () {
      expect(GameTypes.annuity720.bonusMin, 1);
      expect(GameTypes.annuity720.bonusMax, 5);
      expect(GameTypes.annuity720.bonusCount, 1);
    });

    test('F1-T11: annuity720 hasBonus는 true다', () {
      expect(GameTypes.annuity720.hasBonus, isTrue);
    });

    test('F1-T12: annuity720 bonusBallColorArgb는 0xFF7B1FA2다', () {
      expect(GameTypes.annuity720.bonusBallColorArgb, 0xFF7B1FA2);
    });

    test('F1-T13: GameTypes.all 길이는 5다', () {
      expect(GameTypes.all.length, 5);
    });

    test('F1-T14: fromId로 annuity720 조회가 가능하다', () {
      expect(
        GameTypes.fromId(GameTypeId.annuity720),
        same(GameTypes.annuity720),
      );
    });

    test('F1-T15: lotto645 colorZoneFor(10)은 0으로 회귀 유지된다', () {
      expect(GameTypes.lotto645.colorZoneFor(10), 0);
    });
  });
}
