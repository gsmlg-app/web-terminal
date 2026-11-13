import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'second process activates owner, lock survives metadata and releases after exit/crash',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'terminal-instance-',
      );
      final processes = <Process>[];
      addTearDown(() async {
        for (final process in processes) {
          process.kill();
        }
        await directory.delete(recursive: true);
      });
      Future<(Process, StreamIterator<String>)> launch() async {
        final process = await Process.start('dart', [
          'test/fixtures/desktop_instance_probe.dart',
          directory.path,
        ]);
        processes.add(process);
        final lines = StreamIterator(
          process.stdout
              .transform(utf8.decoder)
              .transform(const LineSplitter()),
        );
        return (process, lines);
      }

      final (owner, ownerLines) = await launch();
      expect(
        await ownerLines.moveNext().timeout(const Duration(seconds: 20)),
        isTrue,
      );
      expect(ownerLines.current, 'owner');
      final (secondary, secondaryLines) = await launch();
      expect(
        await secondaryLines.moveNext().timeout(const Duration(seconds: 20)),
        isTrue,
      );
      expect(secondaryLines.current, 'secondary');
      expect(await ownerLines.moveNext(), isTrue);
      expect(ownerLines.current, 'activated');
      expect(await secondary.exitCode, 0);
      owner.stdin.writeln('close');
      expect(await owner.exitCode, 0);
      final (next, nextLines) = await launch();
      expect(await nextLines.moveNext(), isTrue);
      expect(nextLines.current, 'owner');
      next.kill(ProcessSignal.sigkill);
      await next.exitCode;
      final (afterCrash, crashLines) = await launch();
      expect(await crashLines.moveNext(), isTrue);
      expect(crashLines.current, 'owner');
      afterCrash.stdin.writeln('close');
      expect(await afterCrash.exitCode, 0);
    },
    timeout: const Timeout(Duration(seconds: 60)),
    skip: !(Platform.isMacOS || Platform.isLinux || Platform.isWindows),
  );
}
