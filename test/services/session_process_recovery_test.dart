import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Hive recovers the last flushed layout after SIGKILL',
    () async {
      final directory = await Directory.systemTemp.createTemp('hive-crash-');
      Process? writer;
      addTearDown(() async {
        writer?.kill();
        await directory.delete(recursive: true);
      });
      writer = await Process.start('dart', [
        'test/fixtures/session_store_probe.dart',
        directory.path,
        'write',
      ]);
      final ready = await writer.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .first
          .timeout(const Duration(seconds: 20));
      expect(ready, 'flushed');
      writer.kill(ProcessSignal.sigkill);
      await writer.exitCode;
      final reader = await Process.run('dart', [
        'test/fixtures/session_store_probe.dart',
        directory.path,
        'read',
      ]);
      expect(reader.exitCode, 0, reason: '${reader.stderr}');
      expect(
        (jsonDecode(
          reader.stdout as String,
        ) as Map)['tabs'].single['workingDirectory'],
        '/crash-recovered',
      );
    },
    skip: Platform.isWindows,
    timeout: const Timeout(Duration(seconds: 60)),
  );
}
