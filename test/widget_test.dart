import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyscoop/main.dart';

void main() {
  testWidgets('Joyscoop app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JoyScoopApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Welcome back is present
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
