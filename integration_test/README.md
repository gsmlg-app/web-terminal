# Integration Tests

Integration tests for the web terminal application. These tests verify end-to-end functionality across multiple components and services.

## Test Files

### Integration Tests (Component-Level)
- **app_startup_test.dart** - App initialization and startup flows
- **local_shell_test.dart** - Local shell session creation and management
- **ssh_session_test.dart** - SSH connection flow and host selection
- **terminal_settings_test.dart** - Terminal settings configuration
- **session_management_test.dart** - Session switching, fullscreen, and lifecycle

### End-to-End Tests (Complete User Journeys)
- **e2e_complete_ssh_workflow_test.dart** - Complete SSH workflow from setup to connection
- **e2e_multi_session_power_user_test.dart** - Multi-session power user scenarios
- **e2e_settings_persistence_test.dart** - Settings persistence across navigation
- **e2e_error_recovery_test.dart** - Error handling and recovery flows

## Running Integration Tests

Integration tests require a running device or emulator.

### Run all integration tests on macOS

```bash
flutter test integration_test/ -d macos
```

### Run a specific test file

```bash
flutter test integration_test/local_shell_test.dart -d macos
```

### Run on Android Emulator

```bash
# Start Android emulator first
emulator -avd <emulator_name>

# Run tests
flutter test integration_test/ -d android
```

### Run on iOS Simulator

```bash
# Start iOS simulator first
open -a Simulator

# Run tests
flutter test integration_test/ -d ios
```

### Run using flutter drive (for performance profiling)

```bash
flutter drive \
  --driver=integration_test_driver/integration_test.dart \
  --target=integration_test/app_startup_test.dart \
  -d macos
```

## Writing Integration Tests

Integration tests should:
1. Test complete user flows across multiple screens
2. Verify interactions between app components
3. Test with real backend services (or well-configured mocks)
4. Focus on critical user paths from the PRD

Example structure:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web_terminal/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Feature Name', () {
    testWidgets('user flow description', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test implementation
    });
  });
}
```

## CI/CD Integration

Integration tests can be added to GitHub Actions:

```yaml
- name: Run integration tests
  run: flutter test integration_test
```

For device-specific testing, consider using:
- Firebase Test Lab
- AWS Device Farm
- GitHub Actions with emulator setup

## Best Practices

1. **Keep tests independent** - Each test should be able to run in isolation
2. **Use realistic data** - Test with data that matches production scenarios
3. **Test error paths** - Verify error handling and recovery
4. **Minimize flakiness** - Use `pumpAndSettle()` and proper waits
5. **Document test scenarios** - Clear descriptions of what each test verifies

## Test Coverage

### Local Shell Tests (local_shell_test.dart)
- ✅ Open local shell session from session menu
- ✅ Open multiple local shell sessions
- ✅ Session menu shows all session types
- ✅ Default profile auto-selection

### SSH Session Tests (ssh_session_test.dart)
- ✅ Open SSH host selector from session menu
- ✅ Empty state when no hosts configured
- ✅ Cancel SSH host selection
- ✅ Session menu options and icons
- ✅ SFTP server option availability

### Terminal Settings Tests (terminal_settings_test.dart)
- ✅ Navigate to settings screen
- ✅ Access terminal settings section
- ✅ Change font size controls
- ✅ View shell profiles
- ✅ Settings persistence verification
- ✅ Max shells limit handling
- ✅ Environment variables settings

### Session Management Tests (session_management_test.dart)
- ✅ Toggle fullscreen mode
- ✅ Session selector shows current session
- ✅ Switch between multiple sessions
- ✅ Close a session
- ✅ Session list updates dynamically
- ✅ Unique session names

### E2E Tests Coverage

#### Complete SSH Workflow (e2e_complete_ssh_workflow_test.dart)
- ✅ Full SSH host setup flow from settings
- ✅ Add SSH host with all parameters
- ✅ Navigate back to terminal
- ✅ Open SSH connection from session menu
- ✅ Select configured host
- ✅ Error handling for unreachable hosts
- ✅ Empty state handling (no hosts)

#### Multi-Session Power User (e2e_multi_session_power_user_test.dart)
- ✅ Create multiple shell sessions (3+)
- ✅ Switch between sessions via selector
- ✅ Close sessions individually
- ✅ Session limit enforcement
- ✅ Session isolation verification
- ✅ Fullscreen toggle with multiple sessions
- ✅ Rapid session creation and cleanup

#### Settings Persistence (e2e_settings_persistence_test.dart)
- ✅ Change terminal font settings
- ✅ Modify font family
- ✅ Adjust max shells limit
- ✅ Create and edit shell profiles
- ✅ Add environment variables
- ✅ Theme changes
- ✅ Verify settings persist across navigation

#### Error Recovery (e2e_error_recovery_test.dart)
- ✅ SSH connection failure handling
- ✅ Retry/cancel flows
- ✅ Session limit exceeded warnings
- ✅ Empty state error handling
- ✅ Invalid settings input validation
- ✅ Rapid interaction stress testing
- ✅ App stability after errors

## Debugging Integration Tests

If tests fail:

1. **Check device connection:**
   ```bash
   flutter devices
   ```

2. **Run app manually to verify functionality:**
   ```bash
   flutter run -d macos
   ```

3. **Enable verbose logging:**
   ```bash
   flutter test integration_test/ -d macos --verbose
   ```

4. **Common issues:**
   - App fails to start: Check SharedPreferences initialization
   - Database errors: Verify database migrations
   - BLoC errors: Confirm all providers are set up in main.dart

## CI/CD Notes

Integration tests are not run in CI/CD by default because they:
- Require a running device or emulator
- Have longer execution time (2-3 minutes per test file)
- Need platform-specific setup

To add to CI/CD, configure device/emulator in the workflow:

```yaml
- name: Run Integration Tests
  run: flutter test integration_test/ -d macos
```
