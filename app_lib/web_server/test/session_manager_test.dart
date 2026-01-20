import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_server/web_server.dart';

void main() {
  group('SessionManagerEvent', () {
    test('SessionPendingEvent stores session', () {
      final session = WebSession(
        id: 'test-id',
        approvalCode: 'ABC123',
        clientAddress: '127.0.0.1',
      );
      final event = SessionPendingEvent(session);

      expect(event.session, session);
      expect(event, isA<SessionManagerEvent>());
    });

    test('SessionApprovedEvent stores session', () {
      final session = WebSession(
        id: 'test-id',
        approvalCode: 'ABC123',
        clientAddress: '127.0.0.1',
      );
      final event = SessionApprovedEvent(session);

      expect(event.session, session);
      expect(event, isA<SessionManagerEvent>());
    });

    test('SessionConnectedEvent stores session', () {
      final session = WebSession(
        id: 'test-id',
        approvalCode: 'ABC123',
        clientAddress: '127.0.0.1',
      );
      final event = SessionConnectedEvent(session);

      expect(event.session, session);
      expect(event, isA<SessionManagerEvent>());
    });

    test('SessionRejectedEvent stores session', () {
      final session = WebSession(
        id: 'test-id',
        approvalCode: 'ABC123',
        clientAddress: '127.0.0.1',
      );
      final event = SessionRejectedEvent(session);

      expect(event.session, session);
      expect(event, isA<SessionManagerEvent>());
    });

    test('SessionDisconnectedEvent stores session', () {
      final session = WebSession(
        id: 'test-id',
        approvalCode: 'ABC123',
        clientAddress: '127.0.0.1',
      );
      final event = SessionDisconnectedEvent(session);

      expect(event.session, session);
      expect(event, isA<SessionManagerEvent>());
    });

    test('SessionUpdatedEvent stores session', () {
      final session = WebSession(
        id: 'test-id',
        approvalCode: 'ABC123',
        clientAddress: '127.0.0.1',
      );
      final event = SessionUpdatedEvent(session);

      expect(event.session, session);
      expect(event, isA<SessionManagerEvent>());
    });
  });

  group('SessionManager', () {
    late SessionManager manager;

    setUp(() {
      manager = SessionManager(sessionExpiry: const Duration(hours: 1));
    });

    tearDown(() async {
      await manager.dispose();
    });

    group('constructor', () {
      test('uses default session expiry when not specified', () async {
        final defaultManager = SessionManager();
        expect(defaultManager.sessions, isEmpty);
        await defaultManager.dispose();
      });

      test('uses custom session expiry', () async {
        final customManager =
            SessionManager(sessionExpiry: const Duration(minutes: 30));
        expect(customManager.sessions, isEmpty);
        await customManager.dispose();
      });
    });

    group('createSession', () {
      test('creates session with unique id', () {
        final session1 = manager.createSession(clientAddress: '127.0.0.1');
        final session2 = manager.createSession(clientAddress: '127.0.0.2');

        expect(session1.id, isNotEmpty);
        expect(session2.id, isNotEmpty);
        expect(session1.id, isNot(session2.id));
      });

      test('creates session with approval code', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');

        expect(session.approvalCode, isNotEmpty);
        expect(session.approvalCode.length, 6);
      });

      test('stores client address', () {
        final session = manager.createSession(clientAddress: '192.168.1.100');

        expect(session.clientAddress, '192.168.1.100');
      });

      test('stores user agent when provided', () {
        final session = manager.createSession(
          clientAddress: '127.0.0.1',
          userAgent: 'Mozilla/5.0',
        );

        expect(session.userAgent, 'Mozilla/5.0');
      });

      test('user agent is null when not provided', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');

        expect(session.userAgent, isNull);
      });

      test('sets initial status to pending', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');

        expect(session.status, WebSessionStatus.pending);
      });

      test('adds session to sessions list', () {
        expect(manager.sessions, isEmpty);

        manager.createSession(clientAddress: '127.0.0.1');

        expect(manager.sessions.length, 1);
      });

      test('emits SessionPendingEvent', () async {
        final events = <SessionManagerEvent>[];
        manager.events.listen(events.add);

        final session = manager.createSession(clientAddress: '127.0.0.1');
        await Future.delayed(Duration.zero);

        expect(events.length, 1);
        expect(events.first, isA<SessionPendingEvent>());
        expect((events.first as SessionPendingEvent).session, session);
      });
    });

    group('getOrCreateSession', () {
      test('creates new session when no existing id', () {
        final session = manager.getOrCreateSession(
          existingSessionId: null,
          clientAddress: '127.0.0.1',
        );

        expect(session.status, WebSessionStatus.pending);
        expect(manager.sessions.length, 1);
      });

      test('returns existing session when id is valid', () {
        final created = manager.createSession(clientAddress: '127.0.0.1');

        final retrieved = manager.getOrCreateSession(
          existingSessionId: created.id,
          clientAddress: '127.0.0.1',
        );

        expect(retrieved.id, created.id);
        expect(manager.sessions.length, 1);
      });

      test('creates new session when id not found', () {
        final session = manager.getOrCreateSession(
          existingSessionId: 'non-existent-id',
          clientAddress: '127.0.0.1',
        );

        expect(session.id, isNot('non-existent-id'));
        expect(manager.sessions.length, 1);
      });
    });

    group('approveByCode', () {
      test('approves pending session by approval code', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');

        final result = manager.approveByCode(session.approvalCode);

        expect(result, isTrue);
        expect(session.status, WebSessionStatus.approved);
      });

      test('returns false for unknown code', () {
        final result = manager.approveByCode('UNKNOWN');

        expect(result, isFalse);
      });

      test('emits SessionApprovedEvent', () async {
        final events = <SessionManagerEvent>[];
        manager.events.listen(events.add);

        final session = manager.createSession(clientAddress: '127.0.0.1');
        await Future.delayed(Duration.zero); // Let pending event emit

        manager.approveByCode(session.approvalCode);
        await Future.delayed(Duration.zero);

        expect(events.length, 2);
        expect(events.last, isA<SessionApprovedEvent>());
      });
    });

    group('approveSession', () {
      test('approves pending session by id', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');

        final result = manager.approveSession(session.id);

        expect(result, isTrue);
        expect(session.status, WebSessionStatus.approved);
      });

      test('returns false for non-existent session', () {
        final result = manager.approveSession('non-existent');

        expect(result, isFalse);
      });

      test('returns false for non-pending session', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');
        manager.approveSession(session.id);

        // Try to approve again
        final result = manager.approveSession(session.id);

        expect(result, isFalse);
      });
    });

    group('markConnected', () {
      test('changes status to connected', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');

        manager.markConnected(session.id);

        expect(session.status, WebSessionStatus.connected);
      });

      test('emits SessionConnectedEvent', () async {
        final events = <SessionManagerEvent>[];
        manager.events.listen(events.add);

        final session = manager.createSession(clientAddress: '127.0.0.1');
        await Future.delayed(Duration.zero);

        manager.markConnected(session.id);
        await Future.delayed(Duration.zero);

        expect(events.last, isA<SessionConnectedEvent>());
      });

      test('does nothing for non-existent session', () {
        manager.markConnected('non-existent');
        // No crash
      });
    });

    group('markDisconnected', () {
      test('changes status to disconnected', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');
        manager.markConnected(session.id);

        manager.markDisconnected(session.id);

        expect(session.status, WebSessionStatus.disconnected);
      });

      test('emits SessionDisconnectedEvent', () async {
        final events = <SessionManagerEvent>[];
        manager.events.listen(events.add);

        final session = manager.createSession(clientAddress: '127.0.0.1');
        manager.markConnected(session.id);
        await Future.delayed(Duration.zero);

        manager.markDisconnected(session.id);
        await Future.delayed(Duration.zero);

        expect(events.last, isA<SessionDisconnectedEvent>());
      });

      test('does nothing for non-existent session', () {
        manager.markDisconnected('non-existent');
        // No crash
      });
    });

    group('notifySessionUpdated', () {
      test('emits SessionUpdatedEvent', () async {
        final events = <SessionManagerEvent>[];
        manager.events.listen(events.add);

        final session = manager.createSession(clientAddress: '127.0.0.1');
        await Future.delayed(Duration.zero);

        manager.notifySessionUpdated(session);
        await Future.delayed(Duration.zero);

        expect(events.last, isA<SessionUpdatedEvent>());
      });
    });

    group('rejectByCode', () {
      test('rejects pending session by approval code', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');

        final result = manager.rejectByCode(session.approvalCode);

        expect(result, isTrue);
        expect(session.status, WebSessionStatus.rejected);
      });

      test('returns false for unknown code', () {
        final result = manager.rejectByCode('UNKNOWN');

        expect(result, isFalse);
      });

      test('removes session from manager', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');
        manager.rejectByCode(session.approvalCode);

        expect(manager.getSession(session.id), isNull);
      });

      test('emits SessionRejectedEvent', () async {
        final events = <SessionManagerEvent>[];
        manager.events.listen(events.add);

        final session = manager.createSession(clientAddress: '127.0.0.1');
        await Future.delayed(Duration.zero);

        manager.rejectByCode(session.approvalCode);
        await Future.delayed(Duration.zero);

        expect(events.last, isA<SessionRejectedEvent>());
      });
    });

    group('rejectSession', () {
      test('rejects pending session by id', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');

        final result = manager.rejectSession(session.id);

        expect(result, isTrue);
        expect(session.status, WebSessionStatus.rejected);
      });

      test('returns false for non-existent session', () {
        final result = manager.rejectSession('non-existent');

        expect(result, isFalse);
      });

      test('returns false for non-pending session', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');
        manager.approveSession(session.id);

        final result = manager.rejectSession(session.id);

        expect(result, isFalse);
      });
    });

    group('disconnectSession', () {
      test('disconnects and removes session', () {
        final session = manager.createSession(clientAddress: '127.0.0.1');

        manager.disconnectSession(session.id);

        expect(session.status, WebSessionStatus.disconnected);
        expect(manager.getSession(session.id), isNull);
      });

      test('emits SessionDisconnectedEvent', () async {
        final events = <SessionManagerEvent>[];
        manager.events.listen(events.add);

        final session = manager.createSession(clientAddress: '127.0.0.1');
        await Future.delayed(Duration.zero);

        manager.disconnectSession(session.id);
        await Future.delayed(Duration.zero);

        expect(events.last, isA<SessionDisconnectedEvent>());
      });

      test('does nothing for non-existent session', () {
        manager.disconnectSession('non-existent');
        // No crash
      });
    });

    group('getSession', () {
      test('returns session by id', () {
        final created = manager.createSession(clientAddress: '127.0.0.1');

        final retrieved = manager.getSession(created.id);

        expect(retrieved, created);
      });

      test('returns null for non-existent id', () {
        final retrieved = manager.getSession('non-existent');

        expect(retrieved, isNull);
      });
    });

    group('getSessionByApprovalCode', () {
      test('returns session by approval code', () {
        final created = manager.createSession(clientAddress: '127.0.0.1');

        final retrieved = manager.getSessionByApprovalCode(created.approvalCode);

        expect(retrieved, created);
      });

      test('returns null for non-existent code', () {
        final retrieved = manager.getSessionByApprovalCode('UNKNOWN');

        expect(retrieved, isNull);
      });
    });

    group('sessions list', () {
      test('returns all sessions', () {
        manager.createSession(clientAddress: '127.0.0.1');
        manager.createSession(clientAddress: '127.0.0.2');
        manager.createSession(clientAddress: '127.0.0.3');

        expect(manager.sessions.length, 3);
      });

      test('returns empty list when no sessions', () {
        expect(manager.sessions, isEmpty);
      });
    });

    group('sessionsByStatus', () {
      test('filters sessions by status', () {
        final session1 = manager.createSession(clientAddress: '127.0.0.1');
        final session2 = manager.createSession(clientAddress: '127.0.0.2');
        manager.createSession(clientAddress: '127.0.0.3');

        manager.approveSession(session1.id);
        manager.approveSession(session2.id);

        final approved = manager.sessionsByStatus(WebSessionStatus.approved);
        final pending = manager.sessionsByStatus(WebSessionStatus.pending);

        expect(approved.length, 2);
        expect(pending.length, 1);
      });
    });

    group('pendingSessions', () {
      test('returns only pending sessions', () {
        manager.createSession(clientAddress: '127.0.0.1');
        final session2 = manager.createSession(clientAddress: '127.0.0.2');
        manager.createSession(clientAddress: '127.0.0.3');

        manager.approveSession(session2.id);

        expect(manager.pendingSessions.length, 2);
      });
    });

    group('activeSessions', () {
      test('returns only connected sessions', () {
        final session1 = manager.createSession(clientAddress: '127.0.0.1');
        final session2 = manager.createSession(clientAddress: '127.0.0.2');
        manager.createSession(clientAddress: '127.0.0.3');

        manager.markConnected(session1.id);
        manager.markConnected(session2.id);

        expect(manager.activeSessions.length, 2);
      });
    });

    group('approvedSessions', () {
      test('returns only approved sessions', () {
        final session1 = manager.createSession(clientAddress: '127.0.0.1');
        manager.createSession(clientAddress: '127.0.0.2');

        manager.approveSession(session1.id);

        expect(manager.approvedSessions.length, 1);
      });
    });

    group('cleanup', () {
      test('removes expired sessions', () async {
        final shortExpiryManager =
            SessionManager(sessionExpiry: const Duration(milliseconds: 50));

        shortExpiryManager.createSession(clientAddress: '127.0.0.1');
        expect(shortExpiryManager.sessions.length, 1);

        // Wait for expiry
        await Future.delayed(const Duration(milliseconds: 100));
        shortExpiryManager.cleanup();

        expect(shortExpiryManager.sessions, isEmpty);

        await shortExpiryManager.dispose();
      });

      test('does not remove non-expired sessions', () {
        manager.createSession(clientAddress: '127.0.0.1');
        manager.cleanup();

        expect(manager.sessions.length, 1);
      });
    });

    group('dispose', () {
      test('clears all sessions', () async {
        manager.createSession(clientAddress: '127.0.0.1');
        manager.createSession(clientAddress: '127.0.0.2');

        await manager.dispose();

        expect(manager.sessions, isEmpty);
      });
    });

    group('events stream', () {
      test('is a broadcast stream', () async {
        final listener1 = <SessionManagerEvent>[];
        final listener2 = <SessionManagerEvent>[];

        manager.events.listen(listener1.add);
        manager.events.listen(listener2.add);

        manager.createSession(clientAddress: '127.0.0.1');
        await Future.delayed(Duration.zero);

        expect(listener1.length, 1);
        expect(listener2.length, 1);
      });
    });
  });
}
