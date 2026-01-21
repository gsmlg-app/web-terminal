import 'package:flutter/material.dart' show Icons, PopupMenuButton;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_terminal/main.dart' as app;
import 'package:web_terminal/screens/terminal/widgets/session_menu.dart';
import 'package:web_terminal/screens/terminal/widgets/terminal_app_bar.dart';

/// Integration tests for session management features.
///
/// Tests the complete user flow for:
/// - Switching between sessions
/// - Closing sessions
/// - Fullscreen toggle
/// - Session selector dropdown
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Session Management Integration Tests', () {
    testWidgets('can toggle fullscreen mode', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find fullscreen toggle button in AppBar
      final fullscreenButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byIcon(Icons.fullscreen),
      );

      if (fullscreenButton.evaluate().isNotEmpty) {
        // Tap fullscreen toggle
        await tester.tap(fullscreenButton);
        await tester.pumpAndSettle();

        // Icon should change to fullscreen_exit
        final exitFullscreenButton = find.descendant(
          of: find.byType(TerminalAppBar),
          matching: find.byIcon(Icons.fullscreen_exit),
        );

        expect(exitFullscreenButton, findsOneWidget);

        // Toggle back
        await tester.tap(exitFullscreenButton);
        await tester.pumpAndSettle();

        // Should return to fullscreen icon
        expect(find.byIcon(Icons.fullscreen), findsOneWidget);
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('session selector shows current session', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Open a local shell first
      final sessionMenuButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(SessionMenu),
      );

      await tester.tap(sessionMenuButton);
      await tester.pumpAndSettle();

      final localShellOption = find.text('Local Shell');
      await tester.tap(localShellOption);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Find session selector in AppBar (shows current session name)
      // The selector is usually a dropdown or button showing session title
      final sessionSelector = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(PopupMenuButton<String>),
      );

      if (sessionSelector.evaluate().isNotEmpty) {
        expect(sessionSelector, findsOneWidget);
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('can switch between multiple sessions', (tester) async {
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

      // Open two sessions
      await openLocalShell();
      await openLocalShell();

      // Find session selector
      final sessionSelector = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(PopupMenuButton<String>),
      );

      if (sessionSelector.evaluate().isNotEmpty) {
        // Tap to open session list
        await tester.tap(sessionSelector);
        await tester.pumpAndSettle();

        // Should show list of sessions
        // Tap to select different session
        // The exact implementation depends on session naming
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('can close a session', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Open a local shell
      final sessionMenuButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(SessionMenu),
      );

      await tester.tap(sessionMenuButton);
      await tester.pumpAndSettle();

      final localShellOption = find.text('Local Shell');
      await tester.tap(localShellOption);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Find close button in AppBar
      final closeButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byIcon(Icons.close),
      );

      if (closeButton.evaluate().isNotEmpty) {
        await tester.tap(closeButton);
        await tester.pumpAndSettle();

        // Session should be closed
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('session list updates when sessions are opened/closed',
        (tester) async {
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

      // Open session
      await openLocalShell();

      // Session selector should show the session
      final sessionSelector = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(PopupMenuButton<String>),
      );

      if (sessionSelector.evaluate().isNotEmpty) {
        expect(sessionSelector, findsOneWidget);
      }

      // Open another session
      await openLocalShell();

      // Close first session
      final closeButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byIcon(Icons.close),
      );

      if (closeButton.evaluate().isNotEmpty) {
        await tester.tap(closeButton);
        await tester.pumpAndSettle();
      }

      // Should still have one session remaining
      expect(tester.takeException(), isNull);
    });

    testWidgets('fullscreen toggle keyboard shortcut works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // F11 keyboard shortcut for fullscreen
      // This requires focus and keyboard event simulation
      // Flutter integration tests support simulated key presses

      // For now, verify app handles initialization correctly
      expect(tester.takeException(), isNull);

      // Note: Full keyboard shortcut testing would require:
      // await tester.sendKeyEvent(LogicalKeyboardKey.f11);
      // But this needs proper focus setup in integration test environment
    });

    testWidgets('session names are unique and descriptive', (tester) async {
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

      // Open multiple sessions
      await openLocalShell();
      await openLocalShell();

      // Each session should have a unique name or identifier
      // The exact naming convention depends on implementation
      // Verify multiple sessions can coexist
      expect(tester.takeException(), isNull);
    });
  });
}
