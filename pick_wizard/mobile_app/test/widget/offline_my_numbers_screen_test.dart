import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_wizard/core/localization/generated/app_localizations.dart';
import 'package:pick_wizard/core/localization/supported_locales.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/data/models/generated_numbers.dart';
import 'package:pick_wizard/offline/providers/offline_providers.dart';
import 'package:pick_wizard/offline/screens/offline_my_numbers_screen.dart';

Future<void> pumpMyNumbers(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        locale: Locale('ko'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: SupportedLocales.locales,
        home: OfflineMyNumbersScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('D9-T01 게임 타입 배지(Chip) 존재', (tester) async {
    final saved = <GeneratedNumbers>[
      GeneratedNumbers(
        id: 'lotto-a',
        gameTypeId: GameTypeId.lotto645,
        algorithmId: 1,
        algorithmName: 't',
        results: const [
          NumberSetResult(setNo: 1, numbers: [1, 2, 3, 4, 5, 6]),
        ],
        timestamp: DateTime.utc(2026, 5, 8),
        cost: 0,
      ),
    ];
    final container = ProviderContainer(
      overrides: [
        offlineSavedNumbersProvider.overrideWith((ref) => saved),
      ],
    );
    addTearDown(container.dispose);

    await pumpMyNumbers(tester, container);

    expect(find.byType(Chip), findsWidgets);
    expect(
      find.byKey(const ValueKey('offline_saved_game_badge_lotto-a')),
      findsOneWidget,
    );
  });

  testWidgets('D10-T01 게임 필터 드롭다운 존재', (tester) async {
    final saved = <GeneratedNumbers>[
      GeneratedNumbers(
        id: 'x',
        gameTypeId: GameTypeId.lotto645,
        algorithmId: 1,
        algorithmName: 't',
        results: const [
          NumberSetResult(setNo: 1, numbers: [1, 2, 3, 4, 5, 6]),
        ],
        timestamp: DateTime.utc(2026, 5, 8),
        cost: 0,
      ),
    ];
    final container = ProviderContainer(
      overrides: [
        offlineSavedNumbersProvider.overrideWith((ref) => saved),
      ],
    );
    addTearDown(container.dispose);

    await pumpMyNumbers(tester, container);

    expect(
      find.byKey(const ValueKey('offline_my_numbers_game_filter')),
      findsOneWidget,
    );
  });

  testWidgets('D10-T02 필터 파워볼 선택 시 로또 6/45 카드 없음', (tester) async {
    final saved = <GeneratedNumbers>[
      GeneratedNumbers(
        id: 'id-lotto',
        gameTypeId: GameTypeId.lotto645,
        algorithmId: 1,
        algorithmName: 'algo',
        results: const [
          NumberSetResult(setNo: 1, numbers: [1, 2, 3, 4, 5, 6]),
        ],
        timestamp: DateTime.utc(2026, 5, 8, 10),
        cost: 0,
      ),
      GeneratedNumbers(
        id: 'id-power',
        gameTypeId: GameTypeId.powerball,
        bonusBalls: const [18],
        algorithmId: 1,
        algorithmName: 'algo',
        results: const [
          NumberSetResult(setNo: 1, numbers: [10, 20, 30, 40, 50]),
        ],
        timestamp: DateTime.utc(2026, 5, 8, 11),
        cost: 0,
      ),
    ];
    final container = ProviderContainer(
      overrides: [
        offlineSavedNumbersProvider.overrideWith((ref) => saved),
      ],
    );
    addTearDown(container.dispose);

    await pumpMyNumbers(tester, container);

    expect(find.textContaining('로또 6/45'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('offline_my_numbers_game_filter')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('파워볼').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('로또 6/45'), findsNothing);
    expect(find.textContaining('파워볼'), findsWidgets);
  });

  testWidgets('D10-T03 필터 전체 선택 시 두 카드 모두 표시', (tester) async {
    final saved = <GeneratedNumbers>[
      GeneratedNumbers(
        id: 'id-lotto',
        gameTypeId: GameTypeId.lotto645,
        algorithmId: 1,
        algorithmName: 'algo',
        results: const [
          NumberSetResult(setNo: 1, numbers: [1, 2, 3, 4, 5, 6]),
        ],
        timestamp: DateTime.utc(2026, 5, 8, 10),
        cost: 0,
      ),
      GeneratedNumbers(
        id: 'id-power',
        gameTypeId: GameTypeId.powerball,
        bonusBalls: const [18],
        algorithmId: 1,
        algorithmName: 'algo',
        results: const [
          NumberSetResult(setNo: 1, numbers: [10, 20, 30, 40, 50]),
        ],
        timestamp: DateTime.utc(2026, 5, 8, 11),
        cost: 0,
      ),
    ];
    final container = ProviderContainer(
      overrides: [
        offlineSavedNumbersProvider.overrideWith((ref) => saved),
      ],
    );
    addTearDown(container.dispose);

    await pumpMyNumbers(tester, container);

    await tester.tap(
      find.byKey(const ValueKey('offline_my_numbers_game_filter')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('파워볼').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('로또 6/45'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('offline_my_numbers_game_filter')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('전체').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('로또 6/45'), findsWidgets);
    expect(find.byKey(const ValueKey('offline_saved_game_badge_id-power')), findsOneWidget);
    expect(find.byKey(const ValueKey('offline_saved_game_badge_id-lotto')), findsOneWidget);
  });

  group('Phase F7 — 내 번호 시리얼 (F7-T01~T04)', () {
    testWidgets('F7-T01: annuity720 배지에 연금복권720+ 및 보라 Chip', (tester) async {
      final saved = <GeneratedNumbers>[
        GeneratedNumbers(
          id: 'ann-a',
          gameTypeId: GameTypeId.annuity720,
          bonusBalls: const [3],
          algorithmId: 1,
          algorithmName: 'Serial Quick Pick',
          results: const [
            NumberSetResult(setNo: 1, numbers: [4, 7, 2, 8, 1, 5]),
          ],
          timestamp: DateTime.utc(2026, 5, 8),
          cost: 0,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          offlineSavedNumbersProvider.overrideWith((ref) => saved),
        ],
      );
      addTearDown(container.dispose);

      await pumpMyNumbers(tester, container);

      final ctx = tester.element(find.byType(OfflineMyNumbersScreen));
      final l10n = AppLocalizations.of(ctx);
      expect(find.textContaining(l10n.gameAnnuity720), findsWidgets);
      final chip = tester.widget<Chip>(
        find.byKey(const ValueKey('offline_saved_game_badge_ann-a')),
      );
      expect(chip.backgroundColor, const Color(0xFF7B1FA2));
    });

    testWidgets('F7-T02: annuity720 번호 "3조  472815" 형식', (tester) async {
      final saved = <GeneratedNumbers>[
        GeneratedNumbers(
          id: 'ann-b',
          gameTypeId: GameTypeId.annuity720,
          bonusBalls: const [3],
          algorithmId: 1,
          algorithmName: 'Serial Quick Pick',
          results: const [
            NumberSetResult(setNo: 1, numbers: [4, 7, 2, 8, 1, 5]),
          ],
          timestamp: DateTime.utc(2026, 5, 8),
          cost: 0,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          offlineSavedNumbersProvider.overrideWith((ref) => saved),
        ],
      );
      addTearDown(container.dispose);

      await pumpMyNumbers(tester, container);

      expect(find.text('3조  472815'), findsOneWidget);
    });

    testWidgets('F7-T03: 필터 드롭다운에 연금복권720+', (tester) async {
      final saved = <GeneratedNumbers>[
        GeneratedNumbers(
          id: 'ann-c',
          gameTypeId: GameTypeId.annuity720,
          bonusBalls: const [1],
          algorithmId: 1,
          algorithmName: 't',
          results: const [
            NumberSetResult(setNo: 1, numbers: [1, 2, 3, 4, 5, 6]),
          ],
          timestamp: DateTime.utc(2026, 5, 8),
          cost: 0,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          offlineSavedNumbersProvider.overrideWith((ref) => saved),
        ],
      );
      addTearDown(container.dispose);

      await pumpMyNumbers(tester, container);

      await tester.tap(
        find.byKey(const ValueKey('offline_my_numbers_game_filter')),
      );
      await tester.pumpAndSettle();

      final ctx = tester.element(find.byType(OfflineMyNumbersScreen));
      expect(
        find.textContaining(AppLocalizations.of(ctx).gameAnnuity720),
        findsWidgets,
      );
    });

    testWidgets('F7-T04: 필터 연금복권720+ 선택 시 로또 카드 숨김', (tester) async {
      final saved = <GeneratedNumbers>[
        GeneratedNumbers(
          id: 'id-lotto',
          gameTypeId: GameTypeId.lotto645,
          algorithmId: 1,
          algorithmName: 'algo',
          results: const [
            NumberSetResult(setNo: 1, numbers: [1, 2, 3, 4, 5, 6]),
          ],
          timestamp: DateTime.utc(2026, 5, 8, 10),
          cost: 0,
        ),
        GeneratedNumbers(
          id: 'id-annuity',
          gameTypeId: GameTypeId.annuity720,
          bonusBalls: const [2],
          algorithmId: 1,
          algorithmName: 'algo',
          results: const [
            NumberSetResult(setNo: 1, numbers: [1, 1, 1, 1, 1, 1]),
          ],
          timestamp: DateTime.utc(2026, 5, 8, 11),
          cost: 0,
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          offlineSavedNumbersProvider.overrideWith((ref) => saved),
        ],
      );
      addTearDown(container.dispose);

      await pumpMyNumbers(tester, container);

      expect(find.textContaining('로또 6/45'), findsWidgets);

      await tester.tap(
        find.byKey(const ValueKey('offline_my_numbers_game_filter')),
      );
      await tester.pumpAndSettle();

      final ctx = tester.element(find.byType(OfflineMyNumbersScreen));
      final annuityLabel = AppLocalizations.of(ctx).gameAnnuity720;
      await tester.tap(find.textContaining(annuityLabel).last);
      await tester.pumpAndSettle();

      expect(find.textContaining('로또 6/45'), findsNothing);
      expect(find.textContaining(annuityLabel), findsWidgets);
    });
  });

  group('Phase G6 — 시리얼 알고리즘 9 카드 라벨 (G6-T02)', () {
    testWidgets(
      'G6-T02: annuity720 + algorithmId 9 → 카드에 serialAlgorithm9Name',
      (tester) async {
        final saved = <GeneratedNumbers>[
          GeneratedNumbers(
            id: 'ann-serial9',
            gameTypeId: GameTypeId.annuity720,
            bonusBalls: const [3],
            algorithmId: 9,
            algorithmName: 'Serial Digit Monte Carlo',
            results: const [
              NumberSetResult(setNo: 1, numbers: [1, 2, 3, 4, 5, 6]),
            ],
            timestamp: DateTime.utc(2026, 5, 8),
            cost: 0,
          ),
        ];
        final container = ProviderContainer(
          overrides: [
            offlineSavedNumbersProvider.overrideWith((ref) => saved),
          ],
        );
        addTearDown(container.dispose);

        await pumpMyNumbers(tester, container);

        final ctx = tester.element(find.byType(OfflineMyNumbersScreen));
        final l10n = AppLocalizations.of(ctx);
        expect(find.text(l10n.serialAlgorithm9Name), findsOneWidget);
        expect(find.text(l10n.algorithm9NameDisplay), findsNothing);
      },
    );
  });
}
