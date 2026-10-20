import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/training_center/ui/screens/registration_requests_screen.dart';
import 'package:nextstep_ai_app/features/university/ui/screens/add_edit_program_screen.dart';

void main() {
  group('university program edit handoff', () {
    const programData = <String, dynamic>{
      'id': 7,
      'name': 'هندسة البرمجيات',
      'faculty': 'كلية الهندسة وتكنولوجيا المعلومات',
      'type': 'بكالوريوس',
      'description': 'وصف تجريبي',
      'minScore': '85',
      'fee': '120',
      'creditHours': '132',
      'isActive': true,
    };

    testWidgets('prefills the selected program and returns local changes',
        (tester) async {
      Map<String, dynamic>? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await Navigator.of(context).push<
                        Map<String, dynamic>>(
                      MaterialPageRoute<Map<String, dynamic>>(
                        builder: (_) => const AddEditProgramScreen(
                          isEditing: true,
                          programData: programData,
                        ),
                      ),
                    );
                  },
                  child: const Text('فتح'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('فتح'));
      await tester.pumpAndSettle();

      expect(find.text('هندسة البرمجيات'), findsWidgets);
      expect(find.text('كلية الهندسة وتكنولوجيا المعلومات'), findsWidgets);

      await tester.ensureVisible(find.text('حفظ التغييرات'));
      await tester.tap(find.text('حفظ التغييرات'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!['name'], 'هندسة البرمجيات');
      expect(result!['faculty'], 'كلية الهندسة وتكنولوجيا المعلومات');
      expect(result!['isActive'], isTrue);
    });
  });

  group('training registration request handoff', () {
    final request = RegistrationRequest(
      id: 'REQ-TEST-1',
      name: 'طالب اختبار',
      initials: 'ط ا',
      course: 'دورة اختبار',
      time: 'الآن',
      status: RequestStatus.pending,
      job: 'متقدم',
    );

    testWidgets('details screen renders the selected request only',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: RegistrationRequestDetailsScreen(request: request),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('REQ-TEST-1'), findsOneWidget);
      expect(find.text('طالب اختبار'), findsWidgets);
      expect(find.text('دورة اختبار'), findsWidgets);
    });

    testWidgets('confirming a decision pops with the selected status',
        (tester) async {
      RequestStatus? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await Navigator.of(context).push<RequestStatus>(
                      MaterialPageRoute<RequestStatus>(
                        builder: (_) =>
                            RegistrationRequestDetailsScreen(request: request),
                      ),
                    );
                  },
                  child: const Text('فتح'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('فتح'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.ensureVisible(find.text('قبول الطالب'));
      await tester.tap(find.text('قبول الطالب'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.text('تأكيد القبول'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(result, RequestStatus.accepted);
    });
  });
}
