import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:modurwall/main.dart';

void main() {
  testWidgets('ModUrWall smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ModUrWallApp());

    // Verify that the app title is present
    expect(find.text('MODURUWALL'), findsOneWidget);
  });
}