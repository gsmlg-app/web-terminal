import 'package:flutter_test/flutter_test.dart';
import 'package:web_server/web_server.dart';
import 'package:web_session_bloc/web_session_bloc.dart';

void main() {
  group('WebSessionEvent', () {
    group('StartWebServer', () {
      test('constructs with port', () {
        const event = StartWebServer(port: 8080);
        expect(event.port, 8080);
      });

      test('constructs without port (defaults to null)', () {
        const event = StartWebServer();
        expect(event.port, isNull);
      });

      test('supports value equality', () {
        const event1 = StartWebServer(port: 8080);
        const event2 = StartWebServer(port: 8080);
        expect(event1, equals(event2));
      });

      test('different ports are not equal', () {
        const event1 = StartWebServer(port: 8080);
        const event2 = StartWebServer(port: 9000);
        expect(event1, isNot(equals(event2)));
      });

      test('props contains port', () {
        const event = StartWebServer(port: 3000);
        expect(event.props, [3000]);
      });

      test('props contains null when no port', () {
        const event = StartWebServer();
        expect(event.props, [null]);
      });
    });

    group('StopWebServer', () {
      test('constructs correctly', () {
        const event = StopWebServer();
        expect(event, isA<WebSessionEvent>());
      });

      test('supports value equality', () {
        const event1 = StopWebServer();
        const event2 = StopWebServer();
        expect(event1, equals(event2));
      });

      test('props is empty list', () {
        const event = StopWebServer();
        expect(event.props, isEmpty);
      });
    });

    group('ApproveSessionByCode', () {
      test('constructs with approval code', () {
        const event = ApproveSessionByCode('ABC123');
        expect(event.approvalCode, 'ABC123');
      });

      test('supports value equality', () {
        const event1 = ApproveSessionByCode('XYZ789');
        const event2 = ApproveSessionByCode('XYZ789');
        expect(event1, equals(event2));
      });

      test('different codes are not equal', () {
        const event1 = ApproveSessionByCode('ABC123');
        const event2 = ApproveSessionByCode('XYZ789');
        expect(event1, isNot(equals(event2)));
      });

      test('props contains approval code', () {
        const event = ApproveSessionByCode('TEST00');
        expect(event.props, ['TEST00']);
      });

      test('case-sensitive comparison', () {
        const event1 = ApproveSessionByCode('abc123');
        const event2 = ApproveSessionByCode('ABC123');
        expect(event1, isNot(equals(event2)));
      });
    });

    group('ApproveSession', () {
      test('constructs with session ID', () {
        const event = ApproveSession('session-uuid-123');
        expect(event.sessionId, 'session-uuid-123');
      });

      test('supports value equality', () {
        const event1 = ApproveSession('session-1');
        const event2 = ApproveSession('session-1');
        expect(event1, equals(event2));
      });

      test('different session IDs are not equal', () {
        const event1 = ApproveSession('session-1');
        const event2 = ApproveSession('session-2');
        expect(event1, isNot(equals(event2)));
      });

      test('props contains session ID', () {
        const event = ApproveSession('my-session');
        expect(event.props, ['my-session']);
      });
    });

    group('RejectSessionByCode', () {
      test('constructs with approval code', () {
        const event = RejectSessionByCode('REJ123');
        expect(event.approvalCode, 'REJ123');
      });

      test('supports value equality', () {
        const event1 = RejectSessionByCode('CODE01');
        const event2 = RejectSessionByCode('CODE01');
        expect(event1, equals(event2));
      });

      test('different codes are not equal', () {
        const event1 = RejectSessionByCode('CODE01');
        const event2 = RejectSessionByCode('CODE02');
        expect(event1, isNot(equals(event2)));
      });

      test('props contains approval code', () {
        const event = RejectSessionByCode('REJECT');
        expect(event.props, ['REJECT']);
      });
    });

    group('RejectSession', () {
      test('constructs with session ID', () {
        const event = RejectSession('reject-session-id');
        expect(event.sessionId, 'reject-session-id');
      });

      test('supports value equality', () {
        const event1 = RejectSession('session-x');
        const event2 = RejectSession('session-x');
        expect(event1, equals(event2));
      });

      test('different session IDs are not equal', () {
        const event1 = RejectSession('session-x');
        const event2 = RejectSession('session-y');
        expect(event1, isNot(equals(event2)));
      });

      test('props contains session ID', () {
        const event = RejectSession('to-reject');
        expect(event.props, ['to-reject']);
      });
    });

    group('DisconnectSession', () {
      test('constructs with session ID', () {
        const event = DisconnectSession('disconnect-me');
        expect(event.sessionId, 'disconnect-me');
      });

      test('supports value equality', () {
        const event1 = DisconnectSession('disc-1');
        const event2 = DisconnectSession('disc-1');
        expect(event1, equals(event2));
      });

      test('different session IDs are not equal', () {
        const event1 = DisconnectSession('disc-1');
        const event2 = DisconnectSession('disc-2');
        expect(event1, isNot(equals(event2)));
      });

      test('props contains session ID', () {
        const event = DisconnectSession('session-id');
        expect(event.props, ['session-id']);
      });
    });

    group('RefreshStateEvent', () {
      test('constructs correctly', () {
        const event = RefreshStateEvent();
        expect(event, isA<WebSessionEvent>());
      });

      test('supports value equality', () {
        const event1 = RefreshStateEvent();
        const event2 = RefreshStateEvent();
        expect(event1, equals(event2));
      });

      test('props is empty list', () {
        const event = RefreshStateEvent();
        expect(event.props, isEmpty);
      });
    });

    group('SessionManagerEventReceived', () {
      late WebSession testSession;

      setUp(() {
        testSession = WebSession(
          id: 'test-session',
          approvalCode: 'ABC123',
          clientAddress: '192.168.1.1',
        );
      });

      test('constructs with SessionPendingEvent', () {
        final sessionEvent = SessionPendingEvent(testSession);
        final event = SessionManagerEventReceived(sessionEvent);
        expect(event.event, sessionEvent);
      });

      test('constructs with SessionApprovedEvent', () {
        final sessionEvent = SessionApprovedEvent(testSession);
        final event = SessionManagerEventReceived(sessionEvent);
        expect(event.event, sessionEvent);
      });

      test('constructs with SessionRejectedEvent', () {
        final sessionEvent = SessionRejectedEvent(testSession);
        final event = SessionManagerEventReceived(sessionEvent);
        expect(event.event, sessionEvent);
      });

      test('constructs with SessionDisconnectedEvent', () {
        final sessionEvent = SessionDisconnectedEvent(testSession);
        final event = SessionManagerEventReceived(sessionEvent);
        expect(event.event, sessionEvent);
      });

      test('constructs with SessionConnectedEvent', () {
        final sessionEvent = SessionConnectedEvent(testSession);
        final event = SessionManagerEventReceived(sessionEvent);
        expect(event.event, sessionEvent);
      });

      test('constructs with SessionUpdatedEvent', () {
        final sessionEvent = SessionUpdatedEvent(testSession);
        final event = SessionManagerEventReceived(sessionEvent);
        expect(event.event, sessionEvent);
      });

      test('props contains session manager event', () {
        final sessionEvent = SessionPendingEvent(testSession);
        final event = SessionManagerEventReceived(sessionEvent);
        expect(event.props, [sessionEvent]);
      });
    });

    group('event type checks', () {
      test('StartWebServer is a WebSessionEvent', () {
        const event = StartWebServer();
        expect(event, isA<WebSessionEvent>());
      });

      test('StopWebServer is a WebSessionEvent', () {
        const event = StopWebServer();
        expect(event, isA<WebSessionEvent>());
      });

      test('ApproveSessionByCode is a WebSessionEvent', () {
        const event = ApproveSessionByCode('code');
        expect(event, isA<WebSessionEvent>());
      });

      test('ApproveSession is a WebSessionEvent', () {
        const event = ApproveSession('id');
        expect(event, isA<WebSessionEvent>());
      });

      test('RejectSessionByCode is a WebSessionEvent', () {
        const event = RejectSessionByCode('code');
        expect(event, isA<WebSessionEvent>());
      });

      test('RejectSession is a WebSessionEvent', () {
        const event = RejectSession('id');
        expect(event, isA<WebSessionEvent>());
      });

      test('DisconnectSession is a WebSessionEvent', () {
        const event = DisconnectSession('id');
        expect(event, isA<WebSessionEvent>());
      });

      test('RefreshStateEvent is a WebSessionEvent', () {
        const event = RefreshStateEvent();
        expect(event, isA<WebSessionEvent>());
      });

      test('SessionManagerEventReceived is a WebSessionEvent', () {
        final session = WebSession(
          id: 'id',
          approvalCode: 'ABC123',
          clientAddress: '127.0.0.1',
        );
        final event = SessionManagerEventReceived(
          SessionPendingEvent(session),
        );
        expect(event, isA<WebSessionEvent>());
      });
    });

    group('different event types are not equal', () {
      test('StartWebServer vs StopWebServer', () {
        const start = StartWebServer();
        const stop = StopWebServer();
        expect(start, isNot(equals(stop)));
      });

      test('ApproveSession vs RejectSession with same ID', () {
        const approve = ApproveSession('session-1');
        const reject = RejectSession('session-1');
        expect(approve, isNot(equals(reject)));
      });

      test('ApproveSessionByCode vs RejectSessionByCode with same code', () {
        const approve = ApproveSessionByCode('ABC123');
        const reject = RejectSessionByCode('ABC123');
        expect(approve, isNot(equals(reject)));
      });
    });
  });
}
