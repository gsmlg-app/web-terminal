import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

/// Verifies foreground-program detection against the real login shell that
/// local tabs spawn, through the native PTY plugin.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> waitFor(
    Future<bool> Function() condition,
    String description,
  ) async {
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    while (!await condition()) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException(description);
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  testWidgets('local shell reports a foreground program only while it runs', (
    WidgetTester tester,
  ) async {
    final session = await LocalHost().shell();
    final subscription = session.output.listen((Uint8List _) {
      session.ackRead();
    });
    try {
      await waitFor(
        () async => !await session.hasForegroundProcess(),
        'shell did not become idle',
      );

      await session.write(utf8.encode('sleep 30\n'));
      await waitFor(
        session.hasForegroundProcess,
        'sleep was not detected as a foreground program',
      );

      await session.write(Uint8List.fromList(<int>[3]));
      await waitFor(
        () async => !await session.hasForegroundProcess(),
        'shell did not become idle after interrupting sleep',
      );
    } finally {
      await session.close();
      await subscription.cancel();
    }
    expect(await session.hasForegroundProcess(), isFalse);
  });
}
