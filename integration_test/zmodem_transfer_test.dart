import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';

import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';

/// Download folder and scripted upload picks backed by real files.
class _Files implements ZmodemFileAccess {
  _Files(this.downloads);

  final io.Directory downloads;
  List<ZmodemLocalFile>? uploads;
  late final _io = IoZmodemFileAccess(
    settings: () =>
        (mode: ZmodemDownloadMode.saveToFolder, directory: downloads.path),
  );

  @override
  Future<String?> resolveDownloadDirectory() async => downloads.path;

  @override
  Future<List<ZmodemLocalFile>?> pickUploadFiles() async => uploads;

  @override
  Future<ZmodemDownloadTarget> createDownload(String dir, String name) =>
      _io.createDownload(dir, name);

  @override
  Future<void> reveal(String path) async {}
}

Uint8List _random(int length, int seed) {
  final random = Random(seed);
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

String? _which(String name) {
  final result = io.Process.runSync('/usr/bin/which', [name]);
  return result.exitCode == 0 ? (result.stdout as String).trim() : null;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final sz = _which('sz');
  final rz = _which('rz');
  final skip = sz == null || rz == null ? 'lrzsz not installed' : false;

  late io.Directory work;
  late io.Directory downloads;
  late _Files files;
  late TerminalPlugin plugin;
  late LocalExecutionSession session;

  Future<void> start(WidgetTester tester) async {
    work = io.Directory.systemTemp.createTempSync('zmodem-it-work-');
    downloads = io.Directory.systemTemp.createTempSync('zmodem-it-dl-');
    files = _Files(downloads);
    plugin = TerminalPlugin(fileAccess: files);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: Scaffold(body: TerminalTabView(plugin)),
      ),
    );
    plugin.didMounted();
    session = await LocalHost(workingDirectory: work.path).shell();
    plugin.debugAttachSession(session);
    await tester.pump();
  }

  Future<void> stop(WidgetTester tester) async {
    await session.close();
    await tester.pumpWidget(const SizedBox.shrink());
    plugin.terminal.dispose();
    work.deleteSync(recursive: true);
    downloads.deleteSync(recursive: true);
  }

  Future<void> type(String text) => session.write(utf8.encode(text));

  Future<T> waitFor<T>(
    WidgetTester tester,
    T? Function() probe,
    String description, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (true) {
      final value = probe();
      if (value != null) return value;
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException(description);
      }
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  String screenText() {
    final buffer = plugin.terminal.buffer;
    return [for (var i = 0; i < buffer.lines.length; i++) buffer.lines[i]]
        .join('\n');
  }

  Future<void> expectShellUsable(WidgetTester tester) async {
    await type('echo DONE\$((40+2))\r');
    await waitFor(
      tester,
      () => screenText().contains('DONE42') ? true : null,
      'shell did not answer after the transfer',
    );
  }

  testWidgets('sz in a local tab downloads byte-identically', (tester) async {
    await start(tester);
    try {
      final data = _random(2 << 20, 1);
      io.File('${work.path}/f.bin').writeAsBytesSync(data);
      final results = <ZmodemTransferResult>[];
      final subscription = plugin.transferResults.listen(results.add);

      await type('$sz --binary f.bin\r');
      final result = await waitFor(
        tester,
        () => results.isEmpty ? null : results.first,
        'no transfer result',
      );
      await subscription.cancel();

      expect(result, isA<ZmodemDownloadCompleted>());
      expect(io.File('${downloads.path}/f.bin').readAsBytesSync(), data);
      await expectShellUsable(tester);
    } finally {
      await stop(tester);
    }
  }, skip: skip != false);

  testWidgets('rz in a local tab uploads the picked file', (tester) async {
    await start(tester);
    try {
      final data = _random(1 << 20, 2);
      final source = io.File('${downloads.path}/up.bin')
        ..writeAsBytesSync(data);
      files.uploads = [
        ZmodemLocalFile(path: source.path, name: 'up.bin', length: data.length),
      ];
      final results = <ZmodemTransferResult>[];
      final subscription = plugin.transferResults.listen(results.add);

      await type('$rz --binary\r');
      final result = await waitFor(
        tester,
        () => results.isEmpty ? null : results.first,
        'no transfer result',
      );
      await subscription.cancel();

      expect(result, isA<ZmodemUploadCompleted>());
      await waitFor(
        tester,
        () =>
            io.File('${work.path}/up.bin').existsSync() &&
                io.File('${work.path}/up.bin').lengthSync() == data.length
            ? true
            : null,
        'uploaded file did not appear',
      );
      expect(io.File('${work.path}/up.bin').readAsBytesSync(), data);
      await expectShellUsable(tester);
    } finally {
      await stop(tester);
    }
  }, skip: skip != false);

  testWidgets('cancel during a large sz leaves no partial file', (
    tester,
  ) async {
    await start(tester);
    try {
      io.File('${work.path}/big.bin').writeAsBytesSync(_random(50 << 20, 3));
      final results = <ZmodemTransferResult>[];
      final subscription = plugin.transferResults.listen(results.add);

      await type('$sz --binary big.bin\r');
      await waitFor(
        tester,
        () => (plugin.transferProgress.value?.bytesDone ?? 0) > 0 ? true : null,
        'transfer did not start',
      );
      plugin.cancelTransfer();
      final result = await waitFor(
        tester,
        () => results.isEmpty ? null : results.first,
        'no transfer result',
      );
      await subscription.cancel();

      expect(result, isA<ZmodemTransferCancelled>());
      expect(downloads.listSync(), isEmpty);
      // Output is discarded until sz stops streaming; then a prompt returns.
      await waitFor(
        tester,
        () => plugin.zmodem!.isDraining ? null : true,
        'output never settled after the cancel',
      );
      await expectShellUsable(tester);
    } finally {
      await stop(tester);
    }
  }, skip: skip != false);
}
