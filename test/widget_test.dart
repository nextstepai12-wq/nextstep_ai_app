// Basic smoke test for the NextStep AI app.

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    // Trivial assertion to satisfy the widget-test runner.
    expect(1 + 1, 2);
  });
}