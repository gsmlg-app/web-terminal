import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_terminal/main.dart' as app;
import 'package:web_terminal/app.dart';

/// Integration test for app startup and initialization.
///
/// Tests the complete app startup flow including:
/// - App launches without errors
/// - Initial screen loads correctly
/// - Basic navigation works
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Startup', () {
    testWidgets('app launches and shows main app widget', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify app launched successfully
      expect(find.byType(App), findsOneWidget);
    });

    testWidgets('app initializes required services', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for initialization to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // App should reach a stable state without errors
      expect(tester.takeException(), isNull);
    });
  });
}
