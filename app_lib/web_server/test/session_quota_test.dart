import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_server/web_server.dart';

void main() {
  test('rejects excess pending sessions before allocation or notification',
      () async {
    final manager = SessionManager();
    addTearDown(manager.dispose);
    final events = <SessionManagerEvent>[];
    manager.events.listen(events.add);
    var refused = 0;
    for (var attempt = 0; attempt < 20; attempt++) {
      try {
        manager.createSession(clientAddress: '127.0.0.1');
      } on SessionLimitException {
        refused++;
      }
    }
    await Future<void>.delayed(Duration.zero);
    expect(refused, greaterThan(0));
    expect(manager.sessions.length, lessThanOrEqualTo(3));
    expect(events.length, manager.sessions.length);
  });

  test('global pending and active quotas are independent and reusable',
      () async {
    final manager = SessionManager(
        config: const ServerConfig(
      staticFilesPath: '',
      maxPendingSessions: 2,
      maxActiveSessions: 1,
    ));
    addTearDown(manager.dispose);
    final first = manager.createSession(clientAddress: 'one');
    final second = manager.createSession(clientAddress: 'two');
    expect(() => manager.createSession(clientAddress: 'three'),
        throwsA(isA<SessionLimitException>()));
    expect(manager.approveSession(first.id), isTrue);
    final third = manager.createSession(clientAddress: 'three');
    expect(manager.approveSession(second.id), isFalse);
    expect(second.isPending, isTrue);
    manager.disconnectSession(first.id);
    expect(manager.approveSession(second.id), isTrue);
    expect(manager.getSession(third.id), same(third));
  });

  test('pending TTL clears both indexes without expiring approved sessions',
      () async {
    var now = DateTime(2026, 10, 25);
    final manager = SessionManager(now: () => now);
    addTearDown(manager.dispose);
    final pending = manager.createSession(clientAddress: 'one');
    final approved = manager.createSession(clientAddress: 'two');
    manager.approveSession(approved.id);
    now = now.add(const Duration(minutes: 5));
    manager.cleanup();
    expect(manager.getSession(pending.id), isNull);
    expect(manager.getSessionByApprovalCode(pending.approvalCode), isNull);
    expect(manager.approveByCode(pending.approvalCode), isFalse);
    expect(pending.status, WebSessionStatus.expired);
    expect(manager.getSession(approved.id), same(approved));
    expect(manager.createSession(clientAddress: 'one').isPending, isTrue);
  });

  test('global and client creation rates survive rejection and reset with time',
      () async {
    var now = DateTime(2026, 10, 25);
    final manager = SessionManager(
      now: () => now,
      config: const ServerConfig(
        staticFilesPath: '',
        maxSessionCreationsPerMinute: 3,
        maxSessionCreationsPerClientPerMinute: 2,
      ),
    );
    addTearDown(manager.dispose);
    for (var attempt = 0; attempt < 2; attempt++) {
      final session = manager.createSession(clientAddress: 'one');
      manager.rejectSession(session.id);
    }
    expect(manager.sessions, isEmpty);
    expect(() => manager.createSession(clientAddress: 'one'),
        throwsA(isA<SessionLimitException>()));
    final third = manager.createSession(clientAddress: 'two');
    manager.rejectSession(third.id);
    expect(() => manager.createSession(clientAddress: 'three'),
        throwsA(isA<SessionLimitException>()));
    now = now.add(const Duration(minutes: 1));
    expect(manager.createSession(clientAddress: 'one').isPending, isTrue);
  });

  test('legacy per-client cap includes approved and pending sessions',
      () async {
    final manager = SessionManager(
        config: const ServerConfig(
      staticFilesPath: '',
      maxSessionsPerToken: 2,
    ));
    addTearDown(manager.dispose);
    final first = manager.createSession(clientAddress: 'one');
    manager.approveSession(first.id);
    manager.createSession(clientAddress: 'one');
    expect(() => manager.createSession(clientAddress: 'one'),
        throwsA(isA<SessionLimitException>()));
    expect(manager.sessions.length, 2);
  });

  test('HTTP quota uses the peer address and allows existing cookie reuse',
      () async {
    final directory = await Directory.systemTemp.createTemp('web-quota-');
    addTearDown(() => directory.delete(recursive: true));
    final manager = SessionManager();
    addTearDown(manager.dispose);
    final server = WebTerminalServer(
      config: ServerConfig(
        staticFilesPath: directory.path,
        bindAddress: '127.0.0.1',
        port: 0,
      ),
      sessionManager: manager,
    );
    await server.start();
    addTearDown(server.stop);
    final client = HttpClient();
    addTearDown(() => client.close(force: true));
    final url = Uri.parse('http://127.0.0.1:${server.port}/');
    Cookie? cookie;
    var refused = 0;
    for (var attempt = 0; attempt < 20; attempt++) {
      final request = await client.getUrl(url);
      request.headers.set('X-Forwarded-For', '10.0.0.$attempt');
      request.headers.set('X-Real-IP', '10.0.0.$attempt');
      final response = await request.close();
      if (attempt == 0) cookie = response.cookies.single;
      if (response.statusCode == 429) {
        refused++;
        expect(response.cookies, isEmpty);
        expect(response.headers.value('retry-after'), isNotNull);
      }
      await response.drain<void>();
    }
    expect(refused, greaterThan(0));
    expect(manager.sessions.length, lessThanOrEqualTo(3));
    final request = await client.getUrl(url);
    request.cookies.add(cookie!);
    final response = await request.close();
    expect(response.statusCode, 200);
    await response.drain<void>();
  });
}
