import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_wizard/core/localization/generated/app_localizations.dart';
import 'package:pick_wizard/core/localization/supported_locales.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:pick_wizard/offline/screens/offline_result_screen.dart';
import 'package:pick_wizard/presentation/widgets/lotto_ball.dart';
import 'package:pick_wizard/presentation/widgets/serial_number_row.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: SupportedLocales.locales,
      home: child,
    ),
  );
}

void main() {
  testWidgets('D8-T01 lotto645 결과 → LottoBall 6개, 보너스 없음', (tester) async {
    final generated = GeneratedNumbers(
      gameTypeId: GameTypeId.lotto645,
      algorithmId: 1,
      algorithmName: 'test',
      results: [
        const NumberSetResult(
          setNo: 1,
          numbers: [7, 14, 21, 28, 35, 42],
        ),
      ],
      timestamp: DateTime.utc(2026, 5, 8),
      cost: 0,
    );

    await tester.pumpWidget(
      _wrap(OfflineResultScreen(generated: generated)),
    );
    await tester.pumpAndSettle();

    final balls = tester.widgetList<LottoBall>(find.byType(LottoBall)).toList();
    expect(balls, hasLength(6));
    expect(balls.every((b) => !b.isBonus), isTrue);
    expect(find.text('+'), findsNothing);
  });

  testWidgets(
    'D8-T02 powerball 결과 (5세트, bonusBalls=[18]*5) → 메인 5 + 구분 + 보너스 1',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 3200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final generated = GeneratedNumbers(
        gameTypeId: GameTypeId.powerball,
        bonusBalls: List<int>.filled(5, 18),
        algorithmId: 1,
        algorithmName: 'test',
        results: List<NumberSetResult>.generate(
          5,
          (i) => NumberSetResult(
            setNo: i + 1,
            numbers: [10, 20, 30, 40, 50],
          ),
        ),
        timestamp: DateTime.utc(2026, 5, 8),
        cost: 0,
      );

      await tester.pumpWidget(
        _wrap(OfflineResultScreen(generated: generated)),
      );
      await tester.pumpAndSettle();

      final balls = tester.widgetList<LottoBall>(find.byType(LottoBall)).toList();
      expect(balls.where((b) => !b.isBonus).length, 25);
      expect(balls.where((b) => b.isBonus).length, 5);
      expect(find.text('+'), findsNWidgets(5));

      for (final b in balls.where((x) => x.isBonus)) {
        expect(b.number, 18);
      }
    },
  );

  group('Phase F6 — 결과 화면 시리얼 분기 (F6-T01~T03)', () {
    testWidgets('F6-T01: annuity720 결과 → SerialNumberRow 표시', (tester) async {
      final generated = GeneratedNumbers(
        gameTypeId: GameTypeId.annuity720,
        bonusBalls: const [3],
        algorithmId: 1,
        algorithmName: 'Serial Quick Pick',
        results: const [
          NumberSetResult(
            setNo: 1,
            numbers: [4, 7, 2, 8, 1, 5],
          ),
        ],
        timestamp: DateTime.utc(2026, 5, 8),
        cost: 0,
      );

      await tester.pumpWidget(
        _wrap(OfflineResultScreen(generated: generated)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SerialNumberRow), findsOneWidget);
      expect(
        find.byKey(const ValueKey('offline_serial_result_set_0')),
        findsOneWidget,
      );
    });

    testWidgets('F6-T02: lotto645 → LottoBall 6개 (D8-T01 회귀)', (tester) async {
      final generated = GeneratedNumbers(
        gameTypeId: GameTypeId.lotto645,
        algorithmId: 1,
        algorithmName: 'test',
        results: const [
          NumberSetResult(
            setNo: 1,
            numbers: [7, 14, 21, 28, 35, 42],
          ),
        ],
        timestamp: DateTime.utc(2026, 5, 8),
        cost: 0,
      );

      await tester.pumpWidget(
        _wrap(OfflineResultScreen(generated: generated)),
      );
      await tester.pumpAndSettle();

      final balls = tester.widgetList<LottoBall>(find.byType(LottoBall)).toList();
      expect(balls, hasLength(6));
      expect(balls.every((b) => !b.isBonus), isTrue);
      expect(find.text('+'), findsNothing);
    });

    testWidgets(
      'F6-T03: powerball → 5+1 표시 (D8-T02 회귀)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(480, 3200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final generated = GeneratedNumbers(
          gameTypeId: GameTypeId.powerball,
          bonusBalls: List<int>.filled(5, 18),
          algorithmId: 1,
          algorithmName: 'test',
          results: List<NumberSetResult>.generate(
            5,
            (i) => NumberSetResult(
              setNo: i + 1,
              numbers: [10, 20, 30, 40, 50],
            ),
          ),
          timestamp: DateTime.utc(2026, 5, 8),
          cost: 0,
        );

        await tester.pumpWidget(
          _wrap(OfflineResultScreen(generated: generated)),
        );
        await tester.pumpAndSettle();

        final balls =
            tester.widgetList<LottoBall>(find.byType(LottoBall)).toList();
        expect(balls.where((b) => !b.isBonus).length, 25);
        expect(balls.where((b) => b.isBonus).length, 5);
        expect(find.text('+'), findsNWidgets(5));

        for (final b in balls.where((x) => x.isBonus)) {
          expect(b.number, 18);
        }
      },
    );
  });

  group('Phase G6 — 시리얼 알고리즘 9 결과 헤더 (G6-T01)', () {
    testWidgets(
      'G6-T01: annuity720 + algorithmId 9 → serialAlgorithm9Name 표시',
      (tester) async {
        final generated = GeneratedNumbers(
          gameTypeId: GameTypeId.annuity720,
          bonusBalls: const [3],
          algorithmId: 9,
          algorithmName: 'Serial Digit Monte Carlo',
          results: const [
            NumberSetResult(
              setNo: 1,
              numbers: [1, 2, 3, 4, 5, 6],
            ),
          ],
          timestamp: DateTime.utc(2026, 5, 8),
          cost: 0,
        );

        await tester.pumpWidget(
          _wrap(OfflineResultScreen(generated: generated)),
        );
        await tester.pumpAndSettle();

        final ctx = tester.element(find.byType(OfflineResultScreen));
        final l10n = AppLocalizations.of(ctx);
        expect(find.text(l10n.serialAlgorithm9Name), findsOneWidget);
        expect(find.text(l10n.algorithm9NameDisplay), findsNothing);
      },
    );
  });
}
