import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:web_server/web_server.dart';

class _Execution implements ExecutionSession {
  final outputController = StreamController<Uint8List>();
  final exit = Completer<int>();
  int acknowledgements = 0;
  bool closed = false;
  bool resizeStarted = false;
  Completer<void>? resizeGate;

  @override
  Stream<Uint8List> get output => outputController.stream;
  @override
  Future<int> get exitCode => exit.future;
  @override
  void ackRead() => acknowledgements++;
  @override
  Future<void> write(Uint8List data) async {}
  @override
  Future<void> resize(int width, int height) async {
    resizeStarted = true;
    await resizeGate?.future;
  }

  @override
  Future<void> close() async {
    closed = true;
    await outputController.close();
  }
}

Future<void> _until(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) fail('Condition did not become true');
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  test('acknowledges every raw chunk, including incomplete UTF-8', () async {
    final execution = _Execution();
    final chunks = <Uint8List>[];
    final pty = PtySession(
      id: 'pty-1',
      executionSession: execution,
      onOutput: (_, data) => chunks.add(data),
      onExit: (id, code) {},
    );
    execution.outputController.add(Uint8List.fromList([0xe4]));
    execution.outputController.add(Uint8List.fromList([0xb8, 0xad]));
    await _until(() => chunks.length == 2);
    expect(execution.acknowledgements, 2);
    await pty.close();
  });

  group('real HTTP and WebSocket lifecycle', () {
    late io.Directory directory;
    late SessionManager manager;
    late WebTerminalServer server;
    final sockets = <io.WebSocket>[];

    Future<({io.WebSocket socket, List<Map<String, dynamic>> messages})>
        connect(
      WebSession session,
    ) async {
      final socket = await io.WebSocket.connect(
        'ws://127.0.0.1:${server.port}/ws',
        headers: {'Cookie': 'wt_session=${session.id}'},
      );
      sockets.add(socket);
      final messages = <Map<String, dynamic>>[];
      socket.listen((data) {
        if (data is String) {
          messages.add(jsonDecode(data) as Map<String, dynamic>);
        }
      });
      await _until(() => messages.isNotEmpty);
      return (socket: socket, messages: messages);
    }

    setUp(() async {
      directory =
          await io.Directory.systemTemp.createTemp('web-reconnect-test');
      manager = SessionManager();
      server = WebTerminalServer(
        config: ServerConfig(
          staticFilesPath: directory.path,
          bindAddress: '127.0.0.1',
          port: 0,
        ),
        sessionManager: manager,
      );
      await server.start();
    });

    tearDown(() async {
      for (final socket in sockets) {
        await socket.close();
      }
      sockets.clear();
      await server.stop();
      await manager.dispose();
      await directory.delete(recursive: true);
    });

    test('stop closes multiple clients and remains idempotent', () async {
      final first = manager.createSession(clientAddress: '127.0.0.1');
      final second = manager.createSession(clientAddress: '127.0.0.1');
      await connect(first);
      await connect(second);
      await Future.wait([server.stop(), server.stop()]);
      expect(server.isRunning, isFalse);
      await _until(() =>
          sockets.every((socket) => socket.readyState == io.WebSocket.closed));
      expect(
          sockets.every((socket) => socket.readyState == io.WebSocket.closed),
          isTrue);
      await server.stop();
    });

    test('approved reconnect retains PTYs and sends a snapshot', () async {
      final session = manager.createSession(clientAddress: '127.0.0.1');
      manager.approveSession(session.id);
      final first = await connect(session);
      final execution = _Execution();
      final pty = PtySession(
        id: 'pty-7',
        executionSession: execution,
        onOutput: (id, data) {},
        onExit: (id, code) {},
      );
      session.ptySessions[pty.id] = pty;
      session.ptySizes[pty.id] = const PtySize(cols: 100, rows: 30);
      session.ptyBuffers[pty.id] = String.fromCharCodes([0xe4]);
      await first.socket.close();
      await _until(() => session.status == WebSessionStatus.disconnected);
      expect(execution.closed, isFalse);
      final second = await connect(session);
      final status = second.messages.firstWhere(
        (message) => message['type'] == 'session_status',
      );
      expect(status['status'], 'connected');
      expect((status['ptys'] as List).single['id'], 'pty-7');
      expect(base64Decode((status['ptys'] as List).single['data'] as String),
          [0xe4]);
      expect(session.ptySessions[pty.id], same(pty));
      second.socket.add(jsonEncode({
        'type': 'create_pty',
        'ptyId': pty.id,
        'cols': 100,
        'rows': 30,
      }));
      await _until(() => second.messages
          .any((message) => message['type'] == 'create_pty_response'));
      expect(session.ptySessions[pty.id], same(pty));
      expect(session.ptyCount, 1);
      await server.stop();
      expect(execution.closed, isTrue);
    });

    test('closing a superseded socket does not detach its replacement',
        () async {
      final session = manager.createSession(clientAddress: '127.0.0.1');
      manager.approveSession(session.id);
      final first = await connect(session);
      final second = await connect(session);
      await _until(() => first.socket.readyState == io.WebSocket.closed);
      expect(first.socket.closeCode, 4001);
      await first.socket.close();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(session.status, WebSessionStatus.connected);
      expect(session.isConnected, isTrue);
      second.socket.add(jsonEncode({'type': 'ping', 'sentAt': 42}));
      await _until(() => second.messages.any(
          (message) => message['type'] == 'pong' && message['sentAt'] == 42));
    });

    test('a disconnected pending client still requires approval', () async {
      final session = manager.createSession(clientAddress: '127.0.0.1');
      final first = await connect(session);
      await first.socket.close();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final second = await connect(session);
      expect(second.messages.first['status'], 'pending');
      expect(session.isApproved, isFalse);
      second.socket.add(jsonEncode({
        'type': 'create_pty',
        'ptyId': 'unauthorized',
        'cols': 80,
        'rows': 24,
      }));
      await _until(() => second.messages.any((message) =>
          message['type'] == 'create_pty_response' &&
          message['success'] == false));
      expect(session.ptyCount, 0);
      manager.approveSession(session.id);
      await _until(() => second.messages.any((message) =>
          message['type'] == 'session_status' &&
          message['status'] == 'connected'));
    });

    test('revoked session cannot reconnect', () async {
      final session = manager.createSession(clientAddress: '127.0.0.1');
      manager.approveSession(session.id);
      await connect(session);
      manager.disconnectSession(session.id);
      final second = await connect(session);
      expect(second.messages.first['code'], 'invalid_session');
      expect(manager.getSession(session.id), isNull);
    });

    test('server restart requires a fresh approval', () async {
      final session = manager.createSession(clientAddress: '127.0.0.1');
      manager.approveSession(session.id);
      await connect(session);
      await server.stop();
      expect(manager.sessions, isEmpty);
      await server.start();
      final second = await connect(session);
      expect(second.messages.first['code'], 'invalid_session');
    });

    test('resize completing after disconnect does not access a stale socket',
        () async {
      final session = manager.createSession(clientAddress: '127.0.0.1');
      manager.approveSession(session.id);
      final first = await connect(session);
      final execution = _Execution()..resizeGate = Completer<void>();
      session.ptySessions['pty-1'] = PtySession(
        id: 'pty-1',
        executionSession: execution,
        onOutput: (id, data) {},
        onExit: (id, code) {},
      );
      first.socket.add(jsonEncode({
        'type': 'resize_pty',
        'ptyId': 'pty-1',
        'cols': 90,
        'rows': 30,
      }));
      await _until(() => execution.resizeStarted);
      await first.socket.close();
      await _until(() => session.status == WebSessionStatus.disconnected);
      execution.resizeGate!.complete();
      await _until(() => session.ptySizes['pty-1']?.cols == 90);
    });

    test('expired sessions cannot reconnect before periodic cleanup', () async {
      final expiredManager = SessionManager(
        sessionExpiry: const Duration(milliseconds: 1),
      );
      final session = expiredManager.createSession(clientAddress: '127.0.0.1');
      expiredManager.approveSession(session.id);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(expiredManager.getSession(session.id), isNull);
      expect(expiredManager.approveSession(session.id), isFalse);
      await expiredManager.dispose();
    });
  });
}
