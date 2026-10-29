import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_legacy/app/app.dart';

void main() {
  testWidgets('FamilyLegacyApp smoke test renders navigation shell and dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FamilyLegacyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify user greeting renders
    expect(find.text('Sara Wilson'), findsWidgets);

    // Verify bottom navigation icon destinations render cleanly
    expect(find.byIcon(Icons.cottage_rounded), findsOneWidget);
    expect(find.byIcon(Icons.account_tree_outlined), findsWidgets);
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    expect(find.byIcon(Icons.people_outline_rounded), findsWidgets);
    expect(find.byIcon(Icons.person_outline_rounded), findsWidgets);
  });
}
