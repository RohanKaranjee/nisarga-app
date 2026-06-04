import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nisarga_app/presentation/widgets/gradient_header.dart';

void main() {
  testWidgets('GradientHeader renders correctly with title and subtitle',
      (WidgetTester tester) async {
    // Define test values
    const testTitle = 'My Test Title';
    const testSubtitle = 'My Test Subtitle';
    const testIcon = Icons.star;

    // Build the widget in a testable environment
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GradientHeader(
            title: testTitle,
            subtitle: testSubtitle,
            icon: testIcon,
          ),
        ),
      ),
    );

    // Verify the title is found
    expect(find.text(testTitle), findsOneWidget);

    // Verify the subtitle is found
    expect(find.text(testSubtitle), findsOneWidget);

    // Verify the icon is found
    expect(find.byIcon(testIcon), findsOneWidget);

    // Verify the background is a container (GradientHeader is built with a Container)
    expect(
      find.byWidgetPredicate((widget) =>
          widget is Container && widget.decoration is BoxDecoration),
      findsWidgets,
    );
  });
}
