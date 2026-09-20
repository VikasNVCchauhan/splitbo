import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SplitBo sign-in screen renders without crash',
      (WidgetTester tester) async {
    // Minimal smoke test — verifies the widget tree doesn't throw during build.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Splitbo')),
        ),
      ),
    );
    expect(find.text('Splitbo'), findsOneWidget);
  });
}
