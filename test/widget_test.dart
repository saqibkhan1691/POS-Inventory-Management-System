import 'package:flutter_test/flutter_test.dart';
import 'package:pos_system/core/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const POSApp());
    expect(find.byType(POSApp), findsOneWidget);
  });
}