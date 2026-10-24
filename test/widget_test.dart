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

    // Verify main brand heading renders
    expect(find.text('Vansora'), findsWidgets);

    // Verify bottom navigation icon destinations render cleanly
    expect(find.byIcon(Icons.cottage_rounded), findsOneWidget);
    expect(find.byIcon(Icons.park_outlined), findsOneWidget);
    expect(find.byIcon(Icons.diversity_3_outlined), findsOneWidget);
    expect(find.byIcon(Icons.auto_stories_outlined), findsWidgets);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
  });
}
