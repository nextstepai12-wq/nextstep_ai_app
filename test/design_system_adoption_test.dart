import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_add_user_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/major_detail_screen.dart';
import 'package:nextstep_ai_app/features/training_center/data/repos/training_center_repository.dart';
import 'package:nextstep_ai_app/features/training_center/logic/training_application_bloc/training_application_bloc.dart';
import 'package:nextstep_ai_app/features/training_center/ui/screens/training_application_screen.dart';
import 'package:nextstep_ai_app/features/university/ui/widgets/university_bottom_nav.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('nextstep_ds_test');
    Hive.init(dir.path);
    await Hive.openBox<dynamic>('training_cache');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  const major = <String, dynamic>{
    'id': 1,
    'name': 'هندسة الحاسوب',
    'university': 'الجامعة الإسلامية',
    'match': 92,
    'duration': 4,
    'description': 'تخصص تجريبي',
  };

  testWidgets('major detail renders in dark mode without exceptions',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const MajorDetailScreen(majorData: major),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('هندسة الحاسوب'), findsOneWidget);
  });

  testWidgets('admin add user form renders in dark mode',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const AdminAddUserScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('إضافة مستخدم جديد'), findsWidgets);
  });

  testWidgets('training application notice renders in dark mode',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: BlocProvider<TrainingApplicationBloc>(
          create: (_) => TrainingApplicationBloc(
            repository: TrainingCenterRepository(
              cacheBox: Hive.box<dynamic>('training_cache'),
            ),
          ),
          child: const TrainingApplicationScreen(programId: 'p1'),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('التقديم غير متاح'), findsWidgets);
  });

  testWidgets('university bottom nav exposes its selected tab to semantics',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          bottomNavigationBar: UniversityBottomNav(
            currentIndex: 3,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final selectedItem = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'الطلاب',
    );
    expect(selectedItem, findsOneWidget);
    final semantics = tester.getSemantics(selectedItem);
    expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
    expect(tester.takeException(), isNull);
    handle.dispose();
  });
}
