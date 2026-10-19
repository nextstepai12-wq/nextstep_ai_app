import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/major_detail_screen.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('nextstep_hive_test');
    Hive.init(dir.path);
  });
  const recommendation = <String, dynamic>{
    'id': 1,
    'name': 'هندسة الحاسوب',
    'description': 'تخصص يهتم بتصميم وتطوير أنظمة الحاسوب والبرمجيات',
    'type': 'بكالوريوس',
    'duration': 4,
    'university_name': 'الجامعة الإسلامية',
    'university_location': 'غزة، فلسطين',
    'compatibility': 92,
  };

  Future<void> pumpMajorDetail(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const MajorDetailScreen(majorData: recommendation),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'major detail reads compatibility and university from recommendations',
    (tester) async {
      await pumpMajorDetail(tester);

      expect(find.text('الجامعة الإسلامية'), findsWidgets);
      expect(find.text('بكالوريوس'), findsWidgets);
      expect(find.text('92%'), findsWidgets);
      expect(find.textContaining('4 سنوات'), findsWidgets);
    },
  );

  testWidgets(
    'apply button is honest about the unavailable application flow',
    (tester) async {
      await pumpMajorDetail(tester);

      final applyButton = find.text('تقديم طلب');
      await tester.ensureVisible(applyButton);
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      expect(find.text('التقديم الإلكتروني غير متاح'), findsOneWidget);
    },
  );
}
