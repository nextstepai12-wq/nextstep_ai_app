import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/widgets/app_bottom_nav.dart';
import 'package:nextstep_ai_app/core/widgets/app_responsive.dart';

void main() {
  test('light and dark themes expose complete semantic tokens', () {
    final ThemeData light = AppTheme.light;
    final ThemeData dark = AppTheme.dark;

    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);

    final AppColors? lightTokens = light.extension<AppColors>();
    final AppColors? darkTokens = dark.extension<AppColors>();

    expect(lightTokens, isNotNull);
    expect(darkTokens, isNotNull);
    expect(lightTokens!.isDark, isFalse);
    expect(darkTokens!.isDark, isTrue);
    expect(light.scaffoldBackgroundColor, lightTokens.background);
    expect(dark.scaffoldBackgroundColor, darkTokens.background);
    expect(light.colorScheme.primary, lightTokens.primary);
    expect(dark.colorScheme.primary, darkTokens.primary);
  });

  testWidgets('AppBottomNav renders labels and reports selection',
      (WidgetTester tester) async {
    int? tappedIndex;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            bottomNavigationBar: AppBottomNav(
              items: const <AppNavItem>[
                AppNavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
                AppNavItem(icon: Icons.person_rounded, label: 'حسابي'),
              ],
              currentIndex: 0,
              onChanged: (int index) => tappedIndex = index,
            ),
          ),
        ),
      ),
    );

    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('حسابي'), findsOneWidget);

    await tester.tap(find.text('حسابي'));
    expect(tappedIndex, 1);
  });

  testWidgets('SampleDataBadge labels prototype data clearly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Center(child: SampleDataBadge())),
      ),
    );

    expect(find.text('بيانات تجريبية'), findsOneWidget);
  });
}
