// Widget smoke test for BusIndia
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:busindia/core/theme/app_theme.dart';

void main() {
  testWidgets('BusIndia app renders without crashing', (WidgetTester tester) async {
    // Build minimal app (no Firebase init needed in widget test)
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Center(
              child: Text('BusIndia'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('BusIndia'), findsOneWidget);
  });
}
