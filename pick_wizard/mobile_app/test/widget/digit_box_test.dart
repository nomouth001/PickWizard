import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pick_wizard/core/localization/generated/app_localizations.dart';
import 'package:pick_wizard/core/localization/supported_locales.dart';
import 'package:pick_wizard/presentation/widgets/digit_box.dart';
import 'package:pick_wizard/presentation/widgets/serial_number_row.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('ko'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: SupportedLocales.locales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('F5-T01: DigitBox(digit:5) → "5" 텍스트', (tester) async {
    await tester.pumpWidget(_wrap(const DigitBox(digit: 5)));
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('F5-T02: DigitBox(digit:0) → "0" 텍스트', (tester) async {
    await tester.pumpWidget(_wrap(const DigitBox(digit: 0)));
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('F5-T03: DigitBox(digit:9) 렌더링 오류 없음', (tester) async {
    await tester.pumpWidget(_wrap(const DigitBox(digit: 9)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('9'), findsOneWidget);
  });

  testWidgets('F5-T04: SerialNumberRow group:3 → "3조" 포함', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SerialNumberRow(
          group: 3,
          digits: [4, 7, 2, 8, 1, 5],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('3조'), findsOneWidget);
  });

  testWidgets('F5-T05: SerialNumberRow → DigitBox 6개', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SerialNumberRow(
          group: 1,
          digits: [0, 1, 2, 3, 4, 5],
        ),
      ),
    );
    expect(find.byType(DigitBox), findsNWidgets(6));
  });

  testWidgets('F5-T06: SerialNumberRow 조 배지 색상 0xFF7B1FA2', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SerialNumberRow(
          group: 2,
          digits: [1, 1, 1, 1, 1, 1],
        ),
      ),
    );
    final badge = find.descendant(
      of: find.byType(SerialNumberRow),
      matching: find.byWidgetPredicate((w) {
        if (w is! Container) return false;
        final d = w.decoration;
        if (d is! BoxDecoration || d.color == null) return false;
        return d.color == const Color(0xFF7B1FA2);
      }),
    );
    expect(badge, findsOneWidget);
  });

  testWidgets('F5-T07: SerialNumberRow overflow 없음', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: SupportedLocales.locales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SerialNumberRow(
                  group: 5,
                  digits: const [9, 9, 9, 9, 9, 9],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
