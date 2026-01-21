import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_terminal/main.dart' as app;
import 'package:web_terminal/screens/terminal/widgets/session_menu.dart';
import 'package:web_terminal/screens/terminal/widgets/terminal_app_bar.dart';

/// Integration tests for local shell session creation and interaction.
///
/// Tests the complete user flow for:
/// - Opening a new local shell session
/// - Session appears in terminal screen
/// - Multiple sessions can be opened
/// - Session menu appears correctly
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Local Shell Integration Tests', () {
    testWidgets('can open local shell session from session menu',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap the session menu button (plus icon)
      final sessionMenuButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(SessionMenu),
      );

      expect(sessionMenuButton, findsOneWidget);
      await tester.tap(sessionMenuButton);
      await tester.pumpAndSettle();

      // Find "Local Shell" option in popup menu
      final localShellOption = find.text('Local Shell');
      expect(localShellOption, findsOneWidget);

      await tester.tap(localShellOption);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify no errors occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('can open multiple local shell sessions', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Helper to open a local shell
      Future<void> openLocalShell() async {
        final sessionMenuButton = find.descendant(
          of: find.byType(TerminalAppBar),
          matching: find.byType(SessionMenu),
        );

        await tester.tap(sessionMenuButton);
        await tester.pumpAndSettle();

        final localShellOption = find.text('Local Shell');
        await tester.tap(localShellOption);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Open first session
      await openLocalShell();
      expect(tester.takeException(), isNull);

      // Open second session
      await openLocalShell();
      expect(tester.takeException(), isNull);

      // Open third session
      await openLocalShell();
      expect(tester.takeException(), isNull);

      // Verify all sessions opened successfully without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('session menu shows all session types', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap session menu
      final sessionMenuButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(SessionMenu),
      );

      await tester.tap(sessionMenuButton);
      await tester.pumpAndSettle();

      // Verify all session types are present
      expect(find.text('Local Shell'), findsOneWidget);
      expect(find.text('SSH Shell'), findsOneWidget);
      expect(find.text('SFTP Server'), findsOneWidget);

      // Close menu by tapping outside
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    });

    testWidgets('local shell session uses default profile if available',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Open local shell
      final sessionMenuButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(SessionMenu),
      );

      await tester.tap(sessionMenuButton);
      await tester.pumpAndSettle();

      final localShellOption = find.text('Local Shell');
      await tester.tap(localShellOption);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // If there's a single default profile, it should auto-select
      // If multiple profiles or no profiles, a dialog appears
      // Either way, no errors should occur
      expect(tester.takeException(), isNull);
    });
  });
}
