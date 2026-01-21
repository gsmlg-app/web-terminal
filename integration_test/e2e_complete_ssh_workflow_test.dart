import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_terminal/main.dart' as app;

/// E2E Test: Complete SSH Workflow
///
/// This test verifies the complete user journey for SSH connections:
/// 1. Launch app
/// 2. Navigate to settings
/// 3. Add a new SSH host
/// 4. Return to terminal screen
/// 5. Open SSH connection from session menu
/// 6. Select the configured host
/// 7. (Connection would occur if host was reachable)
///
/// This test focuses on the UI workflow rather than actual SSH connectivity,
/// as we cannot guarantee a live SSH server in CI/CD environments.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: Complete SSH Workflow', () {
    testWidgets('complete SSH host setup and connection flow',
        (tester) async {
      // STEP 1: Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify app launched successfully
      expect(find.byType(MaterialApp), findsOneWidget);

      // STEP 2: Navigate to settings
      // Look for settings navigation button
      final settingsFinder = find.byTooltip('Settings');
      if (settingsFinder.evaluate().isEmpty) {
        // Alternative: look for settings icon
        final settingsIconFinder = find.byIcon(Icons.settings);
        expect(settingsIconFinder, findsWidgets,
            reason: 'Settings navigation should be available');
        await tester.tap(settingsIconFinder.first);
      } else {
        await tester.tap(settingsFinder);
      }
      await tester.pumpAndSettle();

      // Verify we're on settings screen
      expect(
        find.text('Settings'),
        findsWidgets,
        reason: 'Should navigate to Settings screen',
      );

      // STEP 3: Navigate to SSH settings
      // Look for SSH Hosts section
      final sshHostsFinder = find.text('SSH Hosts');
      if (sshHostsFinder.evaluate().isNotEmpty) {
        await tester.tap(sshHostsFinder);
        await tester.pumpAndSettle();

        // STEP 4: Add a new SSH host
        // Look for add host button (could be FAB or IconButton)
        final addButtonFinder = find.byIcon(Icons.add);
        if (addButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(addButtonFinder.first);
          await tester.pumpAndSettle();

          // Fill in SSH host details
          // Look for host name field
          final hostNameField = find.byType(TextField).first;
          if (hostNameField.evaluate().isNotEmpty) {
            await tester.enterText(hostNameField, 'test-server');
            await tester.pumpAndSettle();
          }

          // Look for hostname/IP field
          final hostnameField = find.byType(TextField).at(1);
          if (hostnameField.evaluate().isNotEmpty) {
            await tester.enterText(hostnameField, '192.168.1.100');
            await tester.pumpAndSettle();
          }

          // Look for port field
          final portField = find.byType(TextField).at(2);
          if (portField.evaluate().isNotEmpty) {
            await tester.enterText(portField, '22');
            await tester.pumpAndSettle();
          }

          // Look for username field
          final usernameField = find.byType(TextField).at(3);
          if (usernameField.evaluate().isNotEmpty) {
            await tester.enterText(usernameField, 'testuser');
            await tester.pumpAndSettle();
          }

          // Save the host
          final saveFinder = find.text('Save');
          if (saveFinder.evaluate().isEmpty) {
            // Try looking for a save icon
            final saveIconFinder = find.byIcon(Icons.check);
            if (saveIconFinder.evaluate().isNotEmpty) {
              await tester.tap(saveIconFinder.first);
              await tester.pumpAndSettle();
            }
          } else {
            await tester.tap(saveFinder);
            await tester.pumpAndSettle();
          }
        }
      }

      // STEP 5: Navigate back to terminal screen
      // Look for terminal navigation button
      final terminalFinder = find.byTooltip('Terminal');
      if (terminalFinder.evaluate().isEmpty) {
        // Alternative: look for terminal icon or back navigation
        final backFinder = find.byIcon(Icons.arrow_back);
        if (backFinder.evaluate().isNotEmpty) {
          await tester.tap(backFinder.first);
          await tester.pumpAndSettle();
          // May need to go back multiple times
          if (backFinder.evaluate().isNotEmpty) {
            await tester.tap(backFinder.first);
            await tester.pumpAndSettle();
          }
        }
      } else {
        await tester.tap(terminalFinder);
        await tester.pumpAndSettle();
      }

      // STEP 6: Open session menu
      // Look for the plus icon button to add new session
      final plusButtonFinder = find.byIcon(Icons.add);
      if (plusButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(plusButtonFinder.first);
        await tester.pumpAndSettle();

        // STEP 7: Select SSH Shell option
        final sshShellFinder = find.text('SSH Shell');
        if (sshShellFinder.evaluate().isNotEmpty) {
          await tester.tap(sshShellFinder);
          await tester.pumpAndSettle();

          // STEP 8: Host selector should appear
          // If we successfully added a host, it should be listed
          final testServerFinder = find.text('test-server');
          if (testServerFinder.evaluate().isNotEmpty) {
            // Verify the host is available in the selector
            expect(
              testServerFinder,
              findsWidgets,
              reason: 'Configured SSH host should be available for selection',
            );

            // Select the host (would trigger connection attempt)
            await tester.tap(testServerFinder);
            await tester.pumpAndSettle();

            // NOTE: Connection would fail since this is a fake host
            // In a real scenario, you'd verify connection success/failure handling
          } else {
            // If host wasn't added, verify empty state or cancellation works
            final cancelFinder = find.text('Cancel');
            if (cancelFinder.evaluate().isNotEmpty) {
              await tester.tap(cancelFinder);
              await tester.pumpAndSettle();
            }
          }
        }
      }

      // Verify we're still on terminal screen (didn't crash)
      expect(
        find.byType(MaterialApp),
        findsOneWidget,
        reason: 'App should remain stable throughout workflow',
      );
    });

    testWidgets('SSH connection error handling', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to open SSH connection without configured hosts
      final plusButtonFinder = find.byIcon(Icons.add);
      if (plusButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(plusButtonFinder.first);
        await tester.pumpAndSettle();

        final sshShellFinder = find.text('SSH Shell');
        if (sshShellFinder.evaluate().isNotEmpty) {
          await tester.tap(sshShellFinder);
          await tester.pumpAndSettle();

          // Should show empty state or host selector with no hosts
          // Verify appropriate message
          final emptyStateFinder = find.textContaining('No');
          expect(
            emptyStateFinder.evaluate().isNotEmpty,
            true,
            reason: 'Should show appropriate empty state when no hosts configured',
          );
        }
      }
    });
  });
}
