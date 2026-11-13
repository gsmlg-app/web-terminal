import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// The OS releases the lock even after a crash. The loopback endpoint only
/// accepts an activation token; it cannot execute commands or access tabs.
class DesktopInstance {
  DesktopInstance._(this._lock, this._server, this._metadata);

  final RandomAccessFile _lock;
  final ServerSocket _server;
  final File _metadata;
  bool _closed = false;

  static Future<DesktopInstance?> acquire(
    Directory directory, {
    required Future<void> Function() onActivate,
  }) async {
    await directory.create(recursive: true);
    final lock = await File('${directory.path}/instance.lock')
        .open(mode: FileMode.append);
    final metadata = File('${directory.path}/instance.json');
    try {
      await lock.lock(FileLock.exclusive);
    } on FileSystemException {
      await lock.close();
      for (var attempt = 0; attempt < 30; attempt++) {
        Socket? socket;
        try {
          final data = jsonDecode(await metadata.readAsString()) as Map;
          socket = await Socket.connect(
            InternetAddress.loopbackIPv4,
            data['port'] as int,
            timeout: const Duration(seconds: 1),
          );
          socket.writeln(data['token'] as String);
          await socket.flush();
          final response = await socket
              .cast<List<int>>()
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .first
              .timeout(const Duration(seconds: 5));
          if (response == 'activated') return null;
        } on Exception {
          if (attempt == 29) rethrow;
          await Future<void>.delayed(const Duration(milliseconds: 100));
        } finally {
          socket?.destroy();
        }
      }
      throw StateError('The running WebTerminal instance did not respond');
    }

    try {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final random = Random.secure();
      final token = base64UrlEncode(
        List.generate(32, (_) => random.nextInt(256)),
      );
      server.listen((socket) async {
        try {
          final supplied = await socket
              .cast<List<int>>()
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .first
              .timeout(const Duration(seconds: 2));
          if (supplied == token) {
            await onActivate();
            socket.writeln('activated');
            await socket.flush();
          }
        } on Exception {
          // An incomplete activation request must not affect the owner.
        } finally {
          socket.destroy();
        }
      });
      final temporary = File('${metadata.path}.tmp');
      await temporary.writeAsString(
        jsonEncode({'port': server.port, 'token': token}),
        flush: true,
      );
      await temporary.rename(metadata.path);
      return DesktopInstance._(lock, server, metadata);
    } catch (_) {
      await lock.close();
      rethrow;
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _server.close();
    if (await _metadata.exists()) await _metadata.delete();
    await _lock.close();
  }
}
