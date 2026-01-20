import 'package:flutter_test/flutter_test.dart';
import 'package:web_session_bloc/web_session_bloc.dart';

void main() {
  group('WebSessionState', () {
    test('initial state has correct default values', () {
      const state = WebSessionState.initial();

      expect(state.serverRunning, false);
      expect(state.serverPort, isNull);
      expect(state.serverAddress, isNull);
      expect(state.pendingSessions, isEmpty);
      expect(state.activeSessions, isEmpty);
      expect(state.error, isNull);
      expect(state.isStarting, false);
      expect(state.sessionsRevision, 0);
    });

    test('supports value equality', () {
      const state1 = WebSessionState.initial();
      const state2 = WebSessionState.initial();

      expect(state1, equals(state2));
    });

    test('copyWith updates specified fields', () {
      const state = WebSessionState.initial();
      final updated = state.copyWith(
        serverRunning: true,
        serverPort: 8080,
        serverAddress: '127.0.0.1',
      );

      expect(updated.serverRunning, true);
      expect(updated.serverPort, 8080);
      expect(updated.serverAddress, '127.0.0.1');
      expect(updated.pendingSessions, isEmpty);
    });

    test('copyWith with clearError removes error', () {
      final state = const WebSessionState.initial().copyWith(
        error: 'Some error',
      );
      expect(state.error, 'Some error');

      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });

    test('copyWith with clearServerPort removes port', () {
      final state = const WebSessionState.initial().copyWith(
        serverPort: 8080,
      );
      expect(state.serverPort, 8080);

      final cleared = state.copyWith(clearServerPort: true);
      expect(cleared.serverPort, isNull);
    });

    test('copyWith with clearServerAddress removes address', () {
      final state = const WebSessionState.initial().copyWith(
        serverAddress: '127.0.0.1',
      );
      expect(state.serverAddress, '127.0.0.1');

      final cleared = state.copyWith(clearServerAddress: true);
      expect(cleared.serverAddress, isNull);
    });

    test('hasPendingSessions returns false when empty', () {
      const state = WebSessionState.initial();
      expect(state.hasPendingSessions, false);
    });

    test('totalPtySessions returns 0 when no sessions', () {
      const state = WebSessionState.initial();
      expect(state.totalPtySessions, 0);
    });
  });

  group('WebSessionEvent', () {
    test('StartWebServer with port', () {
      const event = StartWebServer(port: 9000);
      expect(event.port, 9000);
      expect(event.props, [9000]);
    });

    test('StartWebServer without port', () {
      const event = StartWebServer();
      expect(event.port, isNull);
      expect(event.props, [null]);
    });

    test('StopWebServer is equatable', () {
      const event1 = StopWebServer();
      const event2 = StopWebServer();
      expect(event1, equals(event2));
    });

    test('ApproveSessionByCode with code', () {
      const event = ApproveSessionByCode('ABC123');
      expect(event.approvalCode, 'ABC123');
      expect(event.props, ['ABC123']);
    });

    test('ApproveSession with sessionId', () {
      const event = ApproveSession('session-1');
      expect(event.sessionId, 'session-1');
      expect(event.props, ['session-1']);
    });

    test('RejectSessionByCode with code', () {
      const event = RejectSessionByCode('XYZ789');
      expect(event.approvalCode, 'XYZ789');
      expect(event.props, ['XYZ789']);
    });

    test('RejectSession with sessionId', () {
      const event = RejectSession('session-2');
      expect(event.sessionId, 'session-2');
      expect(event.props, ['session-2']);
    });

    test('DisconnectSession with sessionId', () {
      const event = DisconnectSession('session-3');
      expect(event.sessionId, 'session-3');
      expect(event.props, ['session-3']);
    });

    test('RefreshStateEvent is equatable', () {
      const event1 = RefreshStateEvent();
      const event2 = RefreshStateEvent();
      expect(event1, equals(event2));
    });
  });
}
