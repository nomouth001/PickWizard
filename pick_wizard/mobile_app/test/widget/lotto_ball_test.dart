import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_wizard/core/constants/app_colors.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/presentation/widgets/lotto_ball.dart';

Color _circleFillColor(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(LottoBall),
      matching: find.byType(Container),
    ),
  );
  final deco = container.decoration;
  expect(deco, isA<BoxDecoration>());
  final color = (deco as BoxDecoration).color;
  expect(color, isNotNull);
  return color!;
}

void main() {
  testWidgets('D7-T01 lotto645 번호 10 → 노란색', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: LottoBall(number: 10, gameType: GameTypes.lotto645),
        ),
      ),
    );
    expect(_circleFillColor(tester), AppColors.ball1to10);
  });

  testWidgets('D7-T02 lotto645 번호 11 → 파란색', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: LottoBall(number: 11, gameType: GameTypes.lotto645),
        ),
      ),
    );
    expect(_circleFillColor(tester), AppColors.ball11to20);
  });

  testWidgets('D7-T03 powerball 번호 57 → 초록색', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: LottoBall(number: 57, gameType: GameTypes.powerball),
        ),
      ),
    );
    expect(_circleFillColor(tester), AppColors.ball41to45);
  });

  testWidgets('D7-T04 powerball 보너스 ARGB 0xFFE53935', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: LottoBall(
            number: 7,
            gameType: GameTypes.powerball,
            isBonus: true,
          ),
        ),
      ),
    );
    expect(_circleFillColor(tester), const Color(0xFFE53935));
  });

  testWidgets('D7-T05 Win for Life 보너스 ARGB 0xFFFDD835', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: LottoBall(
            number: 3,
            gameType: GameTypes.winForLife,
            isBonus: true,
          ),
        ),
      ),
    );
    expect(_circleFillColor(tester), const Color(0xFFFDD835));
  });

  testWidgets('D7-T06 모든 게임·번호 조합 렌더링', (tester) async {
    for (final gt in GameTypes.all) {
      for (var n = gt.mainMin; n <= gt.mainMax; n++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: LottoBall(number: n, gameType: gt),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(LottoBall), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      if (gt.hasBonus) {
        final bMin = gt.bonusMin!;
        final bMax = gt.bonusMax!;
        for (var b = bMin; b <= bMax; b++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Center(
                child: LottoBall(
                  number: b,
                  gameType: gt,
                  isBonus: true,
                ),
              ),
            ),
          );
          await tester.pump();
          expect(find.byType(LottoBall), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    }
  });
}
