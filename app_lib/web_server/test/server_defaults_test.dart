import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:web_server/web_server.dart';

Future<String?> _sessionCookie(Uri uri) async {
  final client = io.HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    await response.drain<void>();
    return response.headers.value(io.HttpHeaders.setCookieHeader);
  } finally {
    client.close(force: true);
  }
}

void main() {
  late io.Directory directory;
  late SessionManager manager;
  late WebTerminalServer server;

  setUp(() async {
    directory = await io.Directory.systemTemp.createTemp('web-defaults-test');
    manager = SessionManager();
  });

  tearDown(() async {
    await server.stop();
    await manager.dispose();
    await directory.delete(recursive: true);
  });

  test('binds to loopback when no listen address is configured', () async {
    server = WebTerminalServer(
      config: ServerConfig(staticFilesPath: directory.path, port: 0),
      sessionManager: manager,
    );
    await server.start();

    expect(server.address, io.InternetAddress.loopbackIPv4.address);
  });

  test('session cookie is not marked Secure over plain HTTP', () async {
    server = WebTerminalServer(
      config: ServerConfig(staticFilesPath: directory.path, port: 0),
      sessionManager: manager,
    );
    await server.start();

    final cookie =
        await _sessionCookie(Uri.parse('http://127.0.0.1:${server.port}/'));

    expect(cookie, contains('wt_session='));
    expect(cookie, isNot(contains('Secure')));
  });

  test('session cookie is marked Secure over HTTPS', () async {
    server = WebTerminalServer(
      config: ServerConfig(
        staticFilesPath: directory.path,
        port: 0,
        useSsl: true,
      ),
      sessionManager: manager,
    );
    await server.start();

    final cookie =
        await _sessionCookie(Uri.parse('https://127.0.0.1:${server.port}/'));

    expect(cookie, contains('wt_session='));
    expect(cookie, contains('Secure'));
  });
}
