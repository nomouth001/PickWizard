import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_wizard/core/localization/generated/app_localizations.dart';
import 'package:pick_wizard/core/localization/supported_locales.dart';
import 'package:pick_wizard/core/models/game_type.dart';
import 'package:pick_wizard/offline/providers/offline_providers.dart';
import 'package:pick_wizard/offline/screens/offline_home_screen.dart'
    show
        offlineBonusPickFeasible,
        offlineMainPickFeasible,
        OfflineHomeScreen;
import 'package:pick_wizard/presentation/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> tapGame(
    WidgetTester tester,
    String gameMenuLabel,
  ) async {
    await tester.tap(find.byKey(const ValueKey('offline_game_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining(gameMenuLabel).last);
    await tester.pumpAndSettle();
  }

  Future<void> openQuickPickSheet(WidgetTester tester) async {
    await tester.tap(find.textContaining('자동선택').first);
    await tester.pumpAndSettle();
  }

  Future<void> pumpHomeWithDisclaimerDismissed(
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
          home: OfflineHomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();
  }

  testWidgets('D1-T01 게임 DropdownButton 존재', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    expect(find.byKey(const ValueKey('offline_game_dropdown')), findsOneWidget);
  });

  testWidgets('D1-T02 기본 표시 로또 6/45', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    expect(find.textContaining('로또 6/45'), findsWidgets);
  });

  testWidgets('D1-T03 게임 드롭다운 항목 5개', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    await tester.tap(find.byKey(const ValueKey('offline_game_dropdown')));
    await tester.pumpAndSettle();
    final gameIds = tester
        .widgetList<DropdownMenuItem<GameType>>(
          find.byWidgetPredicate((w) => w is DropdownMenuItem<GameType>),
        )
        .map((e) => e.value!.id)
        .toSet();
    expect(gameIds.length, 5);
  });

  testWidgets('D1-T04 파워볼 선택 시 Provider = powerball', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    await tester.tap(find.byKey(const ValueKey('offline_game_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('파워볼').last);
    await tester.pumpAndSettle();
    expect(
      container.read(offlineSelectedGameTypeProvider).id,
      GameTypeId.powerball,
    );
  });

  testWidgets('D1-T05 게임 변경 시 스낵바', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
        offlineIncludeNumbersProvider.overrideWith((ref) => [1, 2]),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    await tester.tap(find.byKey(const ValueKey('offline_game_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('파워볼').last);
    await tester.pumpAndSettle();
    final ctx = tester.element(find.byType(OfflineHomeScreen));
    expect(
      find.text(AppLocalizations.of(ctx).gameTypeChangedClearNumbers),
      findsOneWidget,
    );
  });

  testWidgets('D1-T06 게임 변경 시 포함/제외 초기화', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
        offlineIncludeNumbersProvider.overrideWith((ref) => [7, 8]),
        offlineExcludeNumbersProvider.overrideWith((ref) => [3]),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    await tester.tap(find.byKey(const ValueKey('offline_game_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('메가밀리언').last);
    await tester.pumpAndSettle();
    expect(container.read(offlineIncludeNumbersProvider), isEmpty);
    expect(container.read(offlineExcludeNumbersProvider), isEmpty);
  });

  testWidgets('D2-T01 언어 DropdownButton 존재', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    expect(find.byKey(const ValueKey('offline_language_dropdown')), findsOneWidget);
  });

  testWidgets('D6-T01 같은 게임 재선택 시 번호 유지·스낵바 없음', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
        offlineIncludeNumbersProvider.overrideWith((ref) => [1, 2, 3]),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    expect(container.read(offlineIncludeNumbersProvider), [1, 2, 3]);

    await tester.tap(find.byKey(const ValueKey('offline_game_dropdown')));
    await tester.pumpAndSettle();
    final lottoText = find.textContaining('로또 6/45').last;
    await tester.ensureVisible(lottoText);
    await tester.tap(lottoText);
    await tester.pumpAndSettle();

    expect(container.read(offlineIncludeNumbersProvider), [1, 2, 3]);
    final ctx = tester.element(find.byType(OfflineHomeScreen));
    expect(
      find.text(AppLocalizations.of(ctx).gameTypeChangedClearNumbers),
      findsNothing,
    );
  });

  testWidgets('D6-T02 다른 게임으로 변경 시 초기화·스낵바', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
        offlineIncludeNumbersProvider.overrideWith((ref) => [1, 2]),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);

    await tester.tap(find.byKey(const ValueKey('offline_game_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Win for Life').last);
    await tester.pumpAndSettle();

    expect(container.read(offlineIncludeNumbersProvider), isEmpty);
    final ctx = tester.element(find.byType(OfflineHomeScreen));
    expect(
      find.text(AppLocalizations.of(ctx).gameTypeChangedClearNumbers),
      findsOneWidget,
    );
  });

  testWidgets('D4-T01 파워볼 모달 메인 포함 힌트에 1~69', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    await tapGame(tester, '파워볼');
    await openQuickPickSheet(tester);
    final tf = tester.widget<TextField>(
      find.byKey(const ValueKey('offline_main_include_field')),
    );
    expect(tf.decoration?.hintText, contains('1~69'));
  });

  testWidgets('D4-T02 메가밀리언 모달 메인 포함 힌트에 1~70', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    await tapGame(tester, '메가밀리언');
    await openQuickPickSheet(tester);
    final tf = tester.widget<TextField>(
      find.byKey(const ValueKey('offline_main_include_field')),
    );
    expect(tf.decoration?.hintText, contains('1~70'));
  });

  testWidgets('D4-T03 Win for Life 포함 번호 최대 5개', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    await tapGame(tester, 'Win for Life');
    await openQuickPickSheet(tester);
    await tester.enterText(
      find.byKey(const ValueKey('offline_main_include_field')),
      '1, 2, 3, 4, 5, 6',
    );
    await tester.pump();
    expect(container.read(offlineIncludeNumbersProvider).length, 5);
  });

  testWidgets('D5-T01 lotto645 모달 보너스 섹션 없음', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    await openQuickPickSheet(tester);
    expect(find.byKey(const ValueKey('offline_bonus_section')), findsNothing);
  });

  testWidgets('D5-T02 파워볼 모달 보너스 섹션·파워볼 라벨', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    await tapGame(tester, '파워볼');
    await openQuickPickSheet(tester);
    expect(find.byKey(const ValueKey('offline_bonus_section')), findsOneWidget);
    expect(find.textContaining('파워볼'), findsWidgets);
  });

  testWidgets('D5-T03 파워볼 보너스 26 초과 입력 무시', (tester) async {
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    await tapGame(tester, '파워볼');
    await openQuickPickSheet(tester);
    expect(container.read(offlineBonusIncludeNumberProvider), isNull);
    await tester.enterText(
      find.byKey(const ValueKey('offline_bonus_include_field')),
      '27',
    );
    await tester.pump();
    expect(container.read(offlineBonusIncludeNumberProvider), isNull);
  });

  testWidgets('D5-T04 보너스 제외 전부 시 확인 버튼 비활성화', (tester) async {
    SharedPreferences.setMockInitialValues({
      'selected_game_type': GameTypeId.powerball.name,
    });
    final container = ProviderContainer(
      overrides: [
        localeProvider.overrideWith((ref) => const Locale('ko')),
        offlineSelectedGameTypeProvider.overrideWith((ref) => GameTypes.powerball),
        offlineBonusExcludeNumbersProvider.overrideWith(
          (ref) => List.generate(26, (i) => i + 1),
        ),
      ],
    );
    addTearDown(container.dispose);
    await pumpHomeWithDisclaimerDismissed(tester, container);
    await openQuickPickSheet(tester);
    final btn = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('offline_options_confirm_button')),
    );
    expect(btn.onPressed, isNull);
  });

  test('D11-T01 보너스 제외 전부 — 생성 조건 불충족', () {
    final gt = GameTypes.powerball;
    expect(
      offlineMainPickFeasible(gt, [], []) &&
          offlineBonusPickFeasible(
            gt,
            null,
            List.generate(26, (i) => i + 1),
          ),
      isFalse,
    );
  });

  test('D11-T02 보너스 제외 일부 — 생성 조건 충족', () {
    final gt = GameTypes.powerball;
    expect(
      offlineMainPickFeasible(gt, [], []) &&
          offlineBonusPickFeasible(gt, null, [1, 2, 3]),
      isTrue,
    );
  });

  group('Phase F4 — 연금복권720+ 홈 (F4-T01~F4-T08)', () {
    testWidgets('F4-T01 게임 드롭다운에 연금복권720+ 항목', (tester) async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => const Locale('ko')),
        ],
      );
      addTearDown(container.dispose);
      await pumpHomeWithDisclaimerDismissed(tester, container);
      await tester.tap(find.byKey(const ValueKey('offline_game_dropdown')));
      await tester.pumpAndSettle();
      final ctx = tester.element(find.byType(OfflineHomeScreen));
      expect(
        find.textContaining(AppLocalizations.of(ctx).gameAnnuity720),
        findsWidgets,
      );
    });

    testWidgets('F4-T02 annuity720 선택 시 isSerial', (tester) async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => const Locale('ko')),
        ],
      );
      addTearDown(container.dispose);
      await pumpHomeWithDisclaimerDismissed(tester, container);
      await tapGame(tester, '연금복권');
      expect(
        container.read(offlineSelectedGameTypeProvider).isSerial,
        isTrue,
      );
    });

    testWidgets('F4-T03 annuity720 선택 시 볼 관련 Provider 초기화', (tester) async {
      SharedPreferences.setMockInitialValues({
        'selected_game_type': GameTypeId.powerball.name,
      });
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => const Locale('ko')),
          offlineSelectedGameTypeProvider.overrideWith((ref) => GameTypes.powerball),
          offlineIncludeNumbersProvider.overrideWith((ref) => [1, 2]),
          offlineBonusIncludeNumberProvider.overrideWith((ref) => 7),
          offlineBonusExcludeNumbersProvider.overrideWith((ref) => [1]),
        ],
      );
      addTearDown(container.dispose);
      await pumpHomeWithDisclaimerDismissed(tester, container);
      await tapGame(tester, '연금복권');
      expect(container.read(offlineIncludeNumbersProvider), isEmpty);
      expect(container.read(offlineExcludeNumbersProvider), isEmpty);
      expect(container.read(offlineBonusIncludeNumberProvider), isNull);
      expect(container.read(offlineBonusExcludeNumbersProvider), isEmpty);
    });

    testWidgets('F4-T04 annuity720 선택 시 스낵바', (tester) async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => const Locale('ko')),
        ],
      );
      addTearDown(container.dispose);
      await pumpHomeWithDisclaimerDismissed(tester, container);
      await tapGame(tester, '연금복권');
      final ctx = tester.element(find.byType(OfflineHomeScreen));
      expect(
        find.text(AppLocalizations.of(ctx).gameTypeChangedClearNumbers),
        findsOneWidget,
      );
    });

    testWidgets('F4-T05 annuity720에서 알고리즘 9 항목 표시', (tester) async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => const Locale('ko')),
        ],
      );
      addTearDown(container.dispose);
      await pumpHomeWithDisclaimerDismissed(tester, container);
      await tapGame(tester, '연금복권');
      await tester.pumpAndSettle();
      final ctx = tester.element(find.byType(OfflineHomeScreen));
      expect(find.text(AppLocalizations.of(ctx).serialAlgorithm9Name), findsOneWidget);
    });

    testWidgets('F4-T06 annuity720 옵션 모달에 조 고정 필드', (tester) async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => const Locale('ko')),
        ],
      );
      addTearDown(container.dispose);
      await pumpHomeWithDisclaimerDismissed(tester, container);
      await tapGame(tester, '연금복권');
      await openQuickPickSheet(tester);
      expect(
        find.byKey(const ValueKey('offline_serial_fixed_group_field')),
        findsOneWidget,
      );
    });

    testWidgets('F4-T07 annuity720 옵션 모달에 메인 포함 필드 없음', (tester) async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => const Locale('ko')),
        ],
      );
      addTearDown(container.dispose);
      await pumpHomeWithDisclaimerDismissed(tester, container);
      await tapGame(tester, '연금복권');
      await openQuickPickSheet(tester);
      expect(
        find.byKey(const ValueKey('offline_main_include_field')),
        findsNothing,
      );
    });

    testWidgets('F4-T08 조 5개 모두 제외 시 번호 생성 비활성', (tester) async {
      SharedPreferences.setMockInitialValues({
        'selected_game_type': GameTypeId.annuity720.name,
      });
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => const Locale('ko')),
          offlineSelectedGameTypeProvider.overrideWith((ref) => GameTypes.annuity720),
          offlineSelectedAlgorithmProvider.overrideWith(
            (ref) => const OfflineAlgorithmInfo(id: 1),
          ),
          offlineSerialExcludeGroupsProvider.overrideWith(
            (ref) => [1, 2, 3, 4, 5],
          ),
        ],
      );
      addTearDown(container.dispose);
      await pumpHomeWithDisclaimerDismissed(tester, container);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('offline_generate_button')),
        600,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(
        find.byKey(const ValueKey('offline_generate_button')),
      );
      final bg = btn.style?.backgroundColor?.resolve(<WidgetState>{});
      expect(bg, Colors.grey);
    });
  });

  group('Phase G3 — 시리얼 알고리즘 9 홈 UI (G3-T01~G3-T04)', () {
    testWidgets('G3-T01: annuity720 + 알고리즘 9 항목 표시', (tester) async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => const Locale('ko')),
        ],
      );
      addTearDown(container.dispose);
      await pumpHomeWithDisclaimerDismissed(tester, container);
      await tapGame(tester, '연금복권');
      await tester.pumpAndSettle();
      final ctx = tester.element(find.byType(OfflineHomeScreen));
      expect(
        find.text(AppLocalizations.of(ctx).serialAlgorithm9Name),
        findsOneWidget,
      );
    });

    testWidgets('G3-T02: 시리얼 알고리즘 9 설명에 serialAlgorithm9Desc 포함', (tester) async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => const Locale('ko')),
        ],
      );
      addTearDown(container.dispose);
      await pumpHomeWithDisclaimerDismissed(tester, container);
      await tapGame(tester, '연금복권');
      await tester.pumpAndSettle();
      final ctx = tester.element(find.byType(OfflineHomeScreen));
      expect(
        find.text(AppLocalizations.of(ctx).serialAlgorithm9Desc),
        findsOneWidget,
      );
    });

    testWidgets('G3-T03: 알고리즘 미선택 시 생성 버튼 비활성 (ballPick 회귀)',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => const Locale('ko')),
        ],
      );
      addTearDown(container.dispose);
      await pumpHomeWithDisclaimerDismissed(tester, container);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('offline_generate_button')),
        600,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(
        find.byKey(const ValueKey('offline_generate_button')),
      );
      final bg = btn.style?.backgroundColor?.resolve(<WidgetState>{});
      expect(bg, Colors.grey);
    });

    testWidgets(
        'G3-T04: annuity720 + 알고리즘9 + excludeGroups 전체 → 생성 비활성',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'selected_game_type': GameTypeId.annuity720.name,
      });
      final container = ProviderContainer(
        overrides: [
          localeProvider.overrideWith((ref) => const Locale('ko')),
          offlineSelectedGameTypeProvider.overrideWith(
            (ref) => GameTypes.annuity720,
          ),
          offlineSelectedAlgorithmProvider.overrideWith(
            (ref) => const OfflineAlgorithmInfo(id: 9),
          ),
          offlineSerialExcludeGroupsProvider.overrideWith(
            (ref) => [1, 2, 3, 4, 5],
          ),
        ],
      );
      addTearDown(container.dispose);
      await pumpHomeWithDisclaimerDismissed(tester, container);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('offline_generate_button')),
        600,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(
        find.byKey(const ValueKey('offline_generate_button')),
      );
      final bg = btn.style?.backgroundColor?.resolve(<WidgetState>{});
      expect(bg, Colors.grey);
    });
  });
}
