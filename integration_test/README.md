# Integration Tests

Integration tests for the web terminal application. These tests verify end-to-end functionality across multiple components and services.

## Running Integration Tests

### Run all integration tests

```bash
flutter test integration_test
```

### Run a specific test file

```bash
flutter test integration_test/app_startup_test.dart
```

### Run with a specific device

```bash
flutter test integration_test --device-id=<device-id>
```

### Run using flutter drive (for performance profiling)

```bash
flutter drive \
  --driver=integration_test_driver/integration_test.dart \
  --target=integration_test/app_startup_test.dart
```

## Test Organization

- `app_startup_test.dart` - App initialization and startup flows
- Future tests can be added for specific user journeys:
  - Terminal session management
  - SSH connection flows
  - Settings management
  - Shell profile switching

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

## Coverage Goals

- ✅ App startup and initialization
- 🔸 Terminal session creation (local, SSH)
- 🔸 Settings management flows
- 🔸 SSH host configuration
- 🔸 Shell profile switching
- 🔸 Environment variable management

Legend:
- ✅ Implemented
- 🔸 Planned
