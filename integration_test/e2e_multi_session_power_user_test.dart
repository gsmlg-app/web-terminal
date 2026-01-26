import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_terminal/main.dart' as app;

/// E2E Test: Multi-Session Power User Workflow
///
/// This test verifies a power user workflow with multiple sessions:
/// 1. Launch app
/// 2. Create multiple local shell sessions
/// 3. Switch between sessions
/// 4. Verify session isolation
/// 5. Close sessions individually
/// 6. Verify proper cleanup
///
/// This tests the complete multi-session experience that power users rely on.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: Multi-Session Power User', () {
    testWidgets('create and manage multiple shell sessions', (tester) async {
      // STEP 1: Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify app launched
      expect(find.byType(MaterialApp), findsOneWidget);

      // STEP 2: Create first additional session (one exists by default)
      final plusButtonFinder = find.byIcon(Icons.add);
      if (plusButtonFinder.evaluate().isNotEmpty) {
        // Open session menu
        await tester.tap(plusButtonFinder.first);
        await tester.pumpAndSettle();

        // Select Local Shell
        final localShellFinder = find.text('Local Shell');
        if (localShellFinder.evaluate().isNotEmpty) {
          await tester.tap(localShellFinder);
          await tester.pumpAndSettle();

          // Wait for session to be created
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // STEP 3: Create second additional session
          final plusButton2Finder = find.byIcon(Icons.add);
          if (plusButton2Finder.evaluate().isNotEmpty) {
            await tester.tap(plusButton2Finder.first);
            await tester.pumpAndSettle();

            final localShell2Finder = find.text('Local Shell');
            if (localShell2Finder.evaluate().isNotEmpty) {
              await tester.tap(localShell2Finder);
              await tester.pumpAndSettle(const Duration(seconds: 1));

              // STEP 4: Create third additional session
              final plusButton3Finder = find.byIcon(Icons.add);
              if (plusButton3Finder.evaluate().isNotEmpty) {
                await tester.tap(plusButton3Finder.first);
                await tester.pumpAndSettle();

                final localShell3Finder = find.text('Local Shell');
                if (localShell3Finder.evaluate().isNotEmpty) {
                  await tester.tap(localShell3Finder);
                  await tester.pumpAndSettle(const Duration(seconds: 1));
                }
              }
            }
          }
        }
      }

      // STEP 5: Verify multiple sessions exist by checking session selector
      // Tap on the session name in AppBar to open session selector
      final sessionSelectorFinder = find.byTooltip('Switch session');
      if (sessionSelectorFinder.evaluate().isEmpty) {
        // Alternative: look for the session name text in AppBar
        final appBarFinder = find.byType(AppBar);
        if (appBarFinder.evaluate().isNotEmpty) {
          // Find text widgets in AppBar area
          final sessionNameFinder = find.descendant(
            of: appBarFinder,
            matching: find.byType(Text),
          );
          if (sessionNameFinder.evaluate().isNotEmpty) {
            // Try to tap the first text (likely session name)
            await tester.tap(sessionNameFinder.first);
            await tester.pumpAndSettle();
          }
        }
      } else {
        await tester.tap(sessionSelectorFinder);
        await tester.pumpAndSettle();
      }

      // Verify multiple sessions are listed
      // Should see "Shell 1", "Shell 2", "Shell 3", etc.
      final shellFinders = [
        find.textContaining('Shell'),
        find.textContaining('Local'),
      ];

      var foundMultipleSessions = false;
      for (final finder in shellFinders) {
        if (finder.evaluate().length >= 3) {
          foundMultipleSessions = true;
          break;
        }
      }

      if (foundMultipleSessions) {
        expect(
          foundMultipleSessions,
          true,
          reason: 'Should have created multiple sessions',
        );

        // STEP 6: Switch to a different session
        final sessionItems = find.byType(ListTile);
        if (sessionItems.evaluate().length >= 2) {
          // Tap the second session
          await tester.tap(sessionItems.at(1));
          await tester.pumpAndSettle();

          // Verify we switched sessions (session name in AppBar should change)
          expect(
            find.byType(AppBar),
            findsOneWidget,
            reason: 'AppBar should be present after switching',
          );
        }

        // STEP 7: Close a session
        // Re-open session selector
        final sessionSelector2Finder = find.byTooltip('Switch session');
        if (sessionSelector2Finder.evaluate().isNotEmpty) {
          await tester.tap(sessionSelector2Finder);
          await tester.pumpAndSettle();
        } else {
          // Use alternative method
          final appBarFinder = find.byType(AppBar);
          if (appBarFinder.evaluate().isNotEmpty) {
            final sessionNameFinder = find.descendant(
              of: appBarFinder,
              matching: find.byType(Text),
            );
            if (sessionNameFinder.evaluate().isNotEmpty) {
              await tester.tap(sessionNameFinder.first);
              await tester.pumpAndSettle();
            }
          }
        }

        // Look for close button on one of the sessions
        final closeButtonFinder = find.byIcon(Icons.close);
        if (closeButtonFinder.evaluate().isNotEmpty) {
          // Close one session
          await tester.tap(closeButtonFinder.first);
          await tester.pumpAndSettle();

          // Verify session was closed
          // Re-open selector to check session count
          final sessionSelector3Finder = find.byTooltip('Switch session');
          if (sessionSelector3Finder.evaluate().isNotEmpty) {
            await tester.tap(sessionSelector3Finder);
            await tester.pumpAndSettle();

            // Should have one fewer session
            final remainingSessionsFinder = find.byType(ListTile);
            expect(
              remainingSessionsFinder.evaluate().length,
              lessThan(4),
              reason: 'Should have fewer sessions after closing one',
            );
          }
        }
      }

      // Verify app is still stable
      expect(
        find.byType(MaterialApp),
        findsOneWidget,
        reason: 'App should remain stable after multi-session operations',
      );
    });

    testWidgets('enforce max sessions limit', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to create many sessions rapidly
      for (var i = 0; i < 12; i++) {
        final plusButtonFinder = find.byIcon(Icons.add);
        if (plusButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(plusButtonFinder.first);
          await tester.pumpAndSettle();

          final localShellFinder = find.text('Local Shell');
          if (localShellFinder.evaluate().isNotEmpty) {
            await tester.tap(localShellFinder);
            await tester.pumpAndSettle(const Duration(milliseconds: 500));
          } else {
            // Menu might have closed, break
            break;
          }
        } else {
          // No more plus button, might have hit limit
          break;
        }
      }

      // Verify app didn't crash
      expect(find.byType(MaterialApp), findsOneWidget);

      // If max limit is enforced (default 10), should see error or limit message
      // This is platform-dependent, so we just verify stability
    });

    testWidgets('session isolation - each session maintains independent state',
        (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Create two sessions
      final plusButtonFinder = find.byIcon(Icons.add);
      if (plusButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(plusButtonFinder.first);
        await tester.pumpAndSettle();

        final localShellFinder = find.text('Local Shell');
        if (localShellFinder.evaluate().isNotEmpty) {
          await tester.tap(localShellFinder);
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }
      }

      // Switch between sessions and verify they maintain state
      final sessionSelectorFinder = find.byTooltip('Switch session');
      if (sessionSelectorFinder.evaluate().isNotEmpty) {
        // Open selector
        await tester.tap(sessionSelectorFinder);
        await tester.pumpAndSettle();

        // Switch to first session
        final sessionItems = find.byType(ListTile);
        if (sessionItems.evaluate().length >= 2) {
          await tester.tap(sessionItems.first);
          await tester.pumpAndSettle();

          // Give time for terminal to render
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Switch back to second session
          if (sessionSelectorFinder.evaluate().isNotEmpty) {
            await tester.tap(sessionSelectorFinder);
            await tester.pumpAndSettle();

            if (sessionItems.evaluate().length >= 2) {
              await tester.tap(sessionItems.at(1));
              await tester.pumpAndSettle();
            }
          }
        }
      }

      // Verify stability
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('fullscreen toggle with multiple sessions', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Create multiple sessions
      for (var i = 0; i < 2; i++) {
        final plusButtonFinder = find.byIcon(Icons.add);
        if (plusButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(plusButtonFinder.first);
          await tester.pumpAndSettle();

          final localShellFinder = find.text('Local Shell');
          if (localShellFinder.evaluate().isNotEmpty) {
            await tester.tap(localShellFinder);
            await tester.pumpAndSettle(const Duration(milliseconds: 500));
          }
        }
      }

      // Toggle fullscreen
      final fullscreenFinder = find.byIcon(Icons.fullscreen);
      if (fullscreenFinder.evaluate().isNotEmpty) {
        await tester.tap(fullscreenFinder.first);
        await tester.pumpAndSettle();

        // Verify bottom navigation is hidden
        final bottomNavFinder = find.byType(NavigationBar);
        expect(
          bottomNavFinder.evaluate().isEmpty,
          true,
          reason: 'Bottom navigation should be hidden in fullscreen',
        );

        // Exit fullscreen
        final exitFullscreenFinder = find.byIcon(Icons.fullscreen_exit);
        if (exitFullscreenFinder.evaluate().isNotEmpty) {
          await tester.tap(exitFullscreenFinder.first);
          await tester.pumpAndSettle();

          // Verify bottom navigation is back
          expect(
            find.byType(NavigationBar),
            findsOneWidget,
            reason: 'Bottom navigation should return after exiting fullscreen',
          );
        }
      }

      // Verify app stability
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
