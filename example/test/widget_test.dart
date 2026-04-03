import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('example app renders title', (tester) async {
    await tester.pumpWidget(const StateWidgetExampleApp());
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('flutter_state_widget example'), findsOneWidget);
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('First item'), findsOneWidget);
  });
}
