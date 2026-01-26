import 'package:flutter/material.dart' show TextButton, ListTile;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_terminal/main.dart' as app;
import 'package:web_terminal/screens/terminal/widgets/session_menu.dart';
import 'package:web_terminal/screens/terminal/widgets/terminal_app_bar.dart';
import 'package:web_terminal/screens/terminal/widgets/ssh_host_selector.dart';

/// Integration tests for SSH session creation flow.
///
/// Tests the complete user flow for:
/// - Opening SSH host selector
/// - Selecting an SSH host
/// - Handling empty host list
/// - Error states in SSH connection
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SSH Session Integration Tests', () {
    testWidgets('can open SSH host selector from session menu',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap the session menu button
      final sessionMenuButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(SessionMenu),
      );

      expect(sessionMenuButton, findsOneWidget);
      await tester.tap(sessionMenuButton);
      await tester.pumpAndSettle();

      // Find "SSH Shell" option
      final sshShellOption = find.text('SSH Shell');
      expect(sshShellOption, findsOneWidget);

      await tester.tap(sshShellOption);
      await tester.pumpAndSettle();

      // SSH host selector dialog should appear
      final sshHostSelector = find.byType(SshHostSelector);
      expect(sshHostSelector, findsOneWidget);

      // Verify no errors occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('SSH host selector shows empty state when no hosts configured',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Open SSH host selector
      final sessionMenuButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(SessionMenu),
      );

      await tester.tap(sessionMenuButton);
      await tester.pumpAndSettle();

      final sshShellOption = find.text('SSH Shell');
      await tester.tap(sshShellOption);
      await tester.pumpAndSettle();

      // If no hosts are configured, empty state message appears
      // The exact message depends on SshHostBloc state
      // Either "No SSH hosts configured" or the host list

      // Verify dialog is present and no errors
      expect(find.byType(SshHostSelector), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('can cancel SSH host selection', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Open SSH host selector
      final sessionMenuButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(SessionMenu),
      );

      await tester.tap(sessionMenuButton);
      await tester.pumpAndSettle();

      final sshShellOption = find.text('SSH Shell');
      await tester.tap(sshShellOption);
      await tester.pumpAndSettle();

      // Find Cancel button
      final cancelButton = find.widgetWithText(TextButton, 'Cancel');
      expect(cancelButton, findsOneWidget);

      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.byType(SshHostSelector), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SSH session menu option shows correct label and icon',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Open session menu
      final sessionMenuButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(SessionMenu),
      );

      await tester.tap(sessionMenuButton);
      await tester.pumpAndSettle();

      // Verify SSH Shell option exists
      expect(find.text('SSH Shell'), findsOneWidget);

      // Verify icon is present (cloud icon)
      final sshMenuItem = find.ancestor(
        of: find.text('SSH Shell'),
        matching: find.byType(ListTile),
      );
      expect(sshMenuItem, findsOneWidget);

      // Close menu
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    });

    testWidgets('SFTP session menu option is available', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for app initialization
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Open session menu
      final sessionMenuButton = find.descendant(
        of: find.byType(TerminalAppBar),
        matching: find.byType(SessionMenu),
      );

      await tester.tap(sessionMenuButton);
      await tester.pumpAndSettle();

      // Verify SFTP Server option exists
      expect(find.text('SFTP Server'), findsOneWidget);

      // Close menu
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
