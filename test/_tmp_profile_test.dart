import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nextstep_ai_app/features/training_center/ui/screens/center_profile_screen.dart';

void main() {
  testWidgets('company profile builds without layout errors', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => const MaterialApp(
          home: CenterProfileScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('شركة التدريب التقني'), findsOneWidget);
    expect(find.text('إدارة المنشأة'), findsOneWidget);
    expect(find.text('المالية والحساب'), findsOneWidget);
  });
}
