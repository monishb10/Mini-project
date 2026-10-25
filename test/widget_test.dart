import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_pattern_mining/main.dart';

void main() {
  testWidgets(
    'App smoke test - mounts successfully and displays dashboard or login',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify that the app mounts and displays navigation or main brand text
      expect(find.textContaining('SAPM System'), findsWidgets);
    },
  );
}
