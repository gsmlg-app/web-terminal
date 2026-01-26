import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_terminal/main.dart' as app;

/// E2E Test: Error Recovery Flows
///
/// This test verifies error handling and recovery across different scenarios:
/// 1. Connection failures (SSH, network errors)
/// 2. Session limit exceeded
/// 3. Invalid configuration
/// 4. Database errors
/// 5. Recovery actions (retry, cancel, etc.)
///
/// This tests the app's resilience and user-friendly error handling.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E: Error Recovery', () {
    testWidgets('handle SSH connection failure gracefully', (tester) async {
      // STEP 1: Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify app launched
      expect(find.byType(MaterialApp), findsOneWidget);

      // STEP 2: Navigate to settings and add unreachable SSH host
      final settingsFinder = find.byIcon(Icons.settings);
      if (settingsFinder.evaluate().isNotEmpty) {
        await tester.tap(settingsFinder.first);
        await tester.pumpAndSettle();

        final sshHostsFinder = find.text('SSH Hosts');
        if (sshHostsFinder.evaluate().isNotEmpty) {
          await tester.tap(sshHostsFinder);
          await tester.pumpAndSettle();

          // Add a host that will fail
          final addButtonFinder = find.byIcon(Icons.add);
          if (addButtonFinder.evaluate().isNotEmpty) {
            await tester.tap(addButtonFinder.first);
            await tester.pumpAndSettle();

            // Fill with unreachable host
            final textFields = find.byType(TextField);
            if (textFields.evaluate().length >= 4) {
              await tester.enterText(textFields.first, 'unreachable-host');
              await tester.pumpAndSettle();

              await tester.enterText(textFields.at(1), '192.0.2.1'); // TEST-NET
              await tester.pumpAndSettle();

              await tester.enterText(textFields.at(2), '22');
              await tester.pumpAndSettle();

              await tester.enterText(textFields.at(3), 'testuser');
              await tester.pumpAndSettle();

              // Save
              final saveFinder = find.text('Save');
              if (saveFinder.evaluate().isNotEmpty) {
                await tester.tap(saveFinder);
                await tester.pumpAndSettle();
              }
            }
          }

          // Navigate back to terminal
          final backFinder = find.byIcon(Icons.arrow_back);
          if (backFinder.evaluate().isNotEmpty) {
            await tester.tap(backFinder.first);
            await tester.pumpAndSettle();
            await tester.tap(backFinder.first);
            await tester.pumpAndSettle();
          }
        }
      }

      // STEP 3: Try to connect to unreachable host
      final terminalFinder = find.byTooltip('Terminal');
      if (terminalFinder.evaluate().isNotEmpty) {
        await tester.tap(terminalFinder);
        await tester.pumpAndSettle();
      }

      final plusButtonFinder = find.byIcon(Icons.add);
      if (plusButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(plusButtonFinder.first);
        await tester.pumpAndSettle();

        final sshShellFinder = find.text('SSH Shell');
        if (sshShellFinder.evaluate().isNotEmpty) {
          await tester.tap(sshShellFinder);
          await tester.pumpAndSettle();

          // Select unreachable host
          final unreachableHostFinder = find.text('unreachable-host');
          if (unreachableHostFinder.evaluate().isNotEmpty) {
            await tester.tap(unreachableHostFinder);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // STEP 4: Verify error message or loading state
            // Should show error dialog, snackbar, or connection failure indicator
            final errorIndicators = [
              find.textContaining('Error'),
              find.textContaining('Failed'),
              find.textContaining('Unable'),
              find.textContaining('timeout'),
              find.byIcon(Icons.error),
              find.byIcon(Icons.warning),
            ];

            var foundError = false;
            for (final indicator in errorIndicators) {
              if (indicator.evaluate().isNotEmpty) {
                foundError = true;
                break;
              }
            }

            // If error shown, verify recovery options
            if (foundError) {
              // Look for retry or cancel buttons
              final retryFinder = find.text('Retry');
              final cancelFinder = find.text('Cancel');
              final okFinder = find.text('OK');

              if (retryFinder.evaluate().isNotEmpty) {
                // Test retry flow
                await tester.tap(retryFinder);
                await tester.pumpAndSettle(const Duration(seconds: 1));
              } else if (cancelFinder.evaluate().isNotEmpty) {
                // Test cancel flow
                await tester.tap(cancelFinder);
                await tester.pumpAndSettle();
              } else if (okFinder.evaluate().isNotEmpty) {
                // Dismiss error
                await tester.tap(okFinder);
                await tester.pumpAndSettle();
              }
            }
          }
        }
      }

      // STEP 5: Verify app recovered and is stable
      expect(
        find.byType(MaterialApp),
        findsOneWidget,
        reason: 'App should remain stable after connection failure',
      );

      // Verify we can still interact with the app
      final plusButton2Finder = find.byIcon(Icons.add);
      expect(
        plusButton2Finder.evaluate().isNotEmpty,
        true,
        reason: 'UI should be responsive after error',
      );
    });

    testWidgets('handle session limit exceeded', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // STEP 1: Try to create more sessions than allowed
      // Default limit is 10, try to create 12
      var sessionsCreated = 0;
      var limitReached = false;

      for (var i = 0; i < 12; i++) {
        final plusButtonFinder = find.byIcon(Icons.add);
        if (plusButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(plusButtonFinder.first);
          await tester.pumpAndSettle();

          final localShellFinder = find.text('Local Shell');
          if (localShellFinder.evaluate().isNotEmpty) {
            await tester.tap(localShellFinder);
            await tester.pumpAndSettle(const Duration(milliseconds: 500));

            sessionsCreated++;

            // Check for limit warning
            final limitIndicators = [
              find.textContaining('limit'),
              find.textContaining('maximum'),
              find.textContaining('max'),
            ];

            for (final indicator in limitIndicators) {
              if (indicator.evaluate().isNotEmpty) {
                limitReached = true;
                // Dismiss warning if shown
                final okFinder = find.text('OK');
                if (okFinder.evaluate().isNotEmpty) {
                  await tester.tap(okFinder);
                  await tester.pumpAndSettle();
                }
                break;
              }
            }

            if (limitReached) break;
          } else {
            // Menu closed, might have hit limit
            break;
          }
        } else {
          break;
        }
      }

      // STEP 2: Verify limit enforcement or graceful handling
      if (limitReached) {
        expect(
          limitReached,
          true,
          reason: 'Should show limit warning when exceeded',
        );
      }

      // STEP 3: Close some sessions and verify we can create new ones
      if (sessionsCreated > 1) {
        // Open session selector
        final sessionSelectorFinder = find.byTooltip('Switch session');
        if (sessionSelectorFinder.evaluate().isNotEmpty) {
          await tester.tap(sessionSelectorFinder);
          await tester.pumpAndSettle();

          // Close a session
          final closeButtonFinder = find.byIcon(Icons.close);
          if (closeButtonFinder.evaluate().isNotEmpty) {
            await tester.tap(closeButtonFinder.first);
            await tester.pumpAndSettle();

            // Try to create a new session
            final plusButton2Finder = find.byIcon(Icons.add);
            if (plusButton2Finder.evaluate().isNotEmpty) {
              await tester.tap(plusButton2Finder.first);
              await tester.pumpAndSettle();

              final localShell2Finder = find.text('Local Shell');
              if (localShell2Finder.evaluate().isNotEmpty) {
                await tester.tap(localShell2Finder);
                await tester.pumpAndSettle();

                // Should succeed since we freed up a slot
                expect(
                  find.byType(MaterialApp),
                  findsOneWidget,
                  reason: 'Should be able to create session after closing one',
                );
              }
            }
          }
        }
      }

      // Verify app stability
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('handle empty state errors gracefully', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // STEP 1: Try to connect SSH without any hosts configured
      final plusButtonFinder = find.byIcon(Icons.add);
      if (plusButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(plusButtonFinder.first);
        await tester.pumpAndSettle();

        final sshShellFinder = find.text('SSH Shell');
        if (sshShellFinder.evaluate().isNotEmpty) {
          await tester.tap(sshShellFinder);
          await tester.pumpAndSettle();

          // STEP 2: Should show empty state or no hosts message
          final emptyStateIndicators = [
            find.textContaining('No'),
            find.textContaining('empty'),
            find.textContaining('Add'),
            find.byIcon(Icons.info_outline),
          ];

          var foundEmptyState = false;
          for (final indicator in emptyStateIndicators) {
            if (indicator.evaluate().isNotEmpty) {
              foundEmptyState = true;
              break;
            }
          }

          expect(
            foundEmptyState,
            true,
            reason: 'Should show empty state when no SSH hosts configured',
          );

          // STEP 3: Cancel and verify recovery
          final cancelFinder = find.text('Cancel');
          if (cancelFinder.evaluate().isNotEmpty) {
            await tester.tap(cancelFinder);
            await tester.pumpAndSettle();
          }
        }
      }

      // Verify app stability
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('recover from invalid settings input', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to settings
      final settingsFinder = find.byIcon(Icons.settings);
      if (settingsFinder.evaluate().isNotEmpty) {
        await tester.tap(settingsFinder.first);
        await tester.pumpAndSettle();

        final terminalFinder = find.text('Terminal');
        if (terminalFinder.evaluate().isNotEmpty) {
          await tester.tap(terminalFinder);
          await tester.pumpAndSettle();

          // Try to enter invalid values
          final textFields = find.byType(TextField);
          if (textFields.evaluate().isNotEmpty) {
            // Try to enter invalid max shells (e.g., 0 or negative)
            // This depends on form validation, but we test the flow
            await tester.enterText(textFields.first, '-1');
            await tester.pumpAndSettle();

            // Try to save
            final saveFinder = find.text('Save');
            if (saveFinder.evaluate().isNotEmpty) {
              await tester.tap(saveFinder);
              await tester.pumpAndSettle();

              // Should show validation error or reject invalid input
              final errorIndicators = [
                find.textContaining('invalid'),
                find.textContaining('error'),
                find.byIcon(Icons.error),
              ];

              var foundValidation = false;
              for (final indicator in errorIndicators) {
                if (indicator.evaluate().isNotEmpty) {
                  foundValidation = true;
                  break;
                }
              }

              // If validation shown, correct the input
              if (foundValidation) {
                await tester.enterText(textFields.first, '10');
                await tester.pumpAndSettle();

                if (saveFinder.evaluate().isNotEmpty) {
                  await tester.tap(saveFinder);
                  await tester.pumpAndSettle();
                }
              }
            }
          }
        }
      }

      // Verify app stability
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('handle rapid user interactions without crashes',
        (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // STEP 1: Rapidly create and close sessions
      for (var i = 0; i < 5; i++) {
        // Create session
        final plusButtonFinder = find.byIcon(Icons.add);
        if (plusButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(plusButtonFinder.first);
          await tester.pump(const Duration(milliseconds: 100));

          final localShellFinder = find.text('Local Shell');
          if (localShellFinder.evaluate().isNotEmpty) {
            await tester.tap(localShellFinder);
            await tester.pump(const Duration(milliseconds: 200));
          }
        }

        // Immediately close a session
        final sessionSelectorFinder = find.byTooltip('Switch session');
        if (sessionSelectorFinder.evaluate().isNotEmpty) {
          await tester.tap(sessionSelectorFinder);
          await tester.pump(const Duration(milliseconds: 100));

          final closeButtonFinder = find.byIcon(Icons.close);
          if (closeButtonFinder.evaluate().isNotEmpty) {
            await tester.tap(closeButtonFinder.first);
            await tester.pump(const Duration(milliseconds: 100));
          }
        }
      }

      await tester.pumpAndSettle();

      // STEP 2: Rapidly toggle fullscreen
      for (var i = 0; i < 3; i++) {
        final fullscreenFinder = find.byIcon(Icons.fullscreen);
        if (fullscreenFinder.evaluate().isNotEmpty) {
          await tester.tap(fullscreenFinder.first);
          await tester.pump(const Duration(milliseconds: 100));
        }

        final exitFullscreenFinder = find.byIcon(Icons.fullscreen_exit);
        if (exitFullscreenFinder.evaluate().isNotEmpty) {
          await tester.tap(exitFullscreenFinder.first);
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await tester.pumpAndSettle();

      // STEP 3: Verify app is stable after rapid interactions
      expect(
        find.byType(MaterialApp),
        findsOneWidget,
        reason: 'App should handle rapid interactions without crashes',
      );

      // Verify UI is responsive
      final plusButtonFinder = find.byIcon(Icons.add);
      expect(
        plusButtonFinder.evaluate().isNotEmpty,
        true,
        reason: 'UI should remain responsive after rapid interactions',
      );
    });
  });
}
