import 'package:flutter_test/flutter_test.dart';
import 'package:nisarga_app/app.dart';

void main() {
  testWidgets('App loads login screen test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const NisargaApp());

    // Check if login screen is shown
    expect(find.text('Nisarga'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
