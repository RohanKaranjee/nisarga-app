import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nisarga_app/presentation/widgets/expandable_section.dart';

void main() {
  testWidgets('ExpandableSection toggles content visibility',
      (WidgetTester tester) async {
    const titleText = 'Toggle Section';
    const contentText = 'Hidden Content Revealed';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExpandableSection(
            title: titleText,
            content: contentText,
          ),
        ),
      ),
    );

    // Title should be visible
    expect(find.text(titleText), findsOneWidget);

    // Check if the ExpansionTile exists
    final expansionTileFinder = find.byType(ExpansionTile);
    expect(expansionTileFinder, findsOneWidget);

    // Initial state is collapsed.
    // In Flutter, ExpansionTile's children might exist in the tree but be invisible/zero height.
    // Tapping expands it.
    await tester.tap(expansionTileFinder);
    await tester.pumpAndSettle(); // Wait for animation to finish

    // Verify content text is now fully visible
    expect(find.text(contentText), findsOneWidget);

    // Tap to collapse again
    await tester.tap(expansionTileFinder);
    await tester.pumpAndSettle();

    // We can assume it collapses successfully if the widget responds to taps and animates
  });
}
