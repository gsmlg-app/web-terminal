import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/screens/terminal/terminal_tab_persistence_test.dart'
    as persistence;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('local tab metadata persists across isolated device launches', (
    tester,
  ) async {
    final phase = await persistence.verifyDeviceTabPersistence(tester);
    debugPrint('TERMINAL7_DEVICE_PHASE=$phase');
    expect(tester.takeException(), isNull);
  });
}
