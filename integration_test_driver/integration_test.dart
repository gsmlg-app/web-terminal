import 'package:integration_test/integration_test_driver.dart';

/// Driver for running integration tests.
///
/// Usage:
/// ```bash
/// flutter drive \
///   --driver=integration_test_driver/integration_test.dart \
///   --target=integration_test/app_startup_test.dart
/// ```
Future<void> main() => integrationDriver();
