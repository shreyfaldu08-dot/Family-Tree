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

    // Verify bottom navigation destinations
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Family Tree'), findsOneWidget);
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
