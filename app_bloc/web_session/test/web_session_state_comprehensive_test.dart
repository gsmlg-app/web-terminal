import 'package:flutter_test/flutter_test.dart';
import 'package:web_server/web_server.dart';
import 'package:web_session_bloc/web_session_bloc.dart';

void main() {
  group('WebSessionState', () {
    group('constructor', () {
      test('creates with all parameters', () {
        final session1 = WebSession(
          id: 'session-1',
          approvalCode: 'ABC123',
          clientAddress: '192.168.1.1',
        );
        final session2 = WebSession(
          id: 'session-2',
          approvalCode: 'XYZ789',
          clientAddress: '192.168.1.2',
        );

        final state = WebSessionState(
          serverRunning: true,
          serverPort: 8080,
          serverAddress: '0.0.0.0',
          pendingSessions: [session1],
          activeSessions: [session2],
          error: 'Test error',
          isStarting: false,
          sessionsRevision: 5,
        );

        expect(state.serverRunning, true);
        expect(state.serverPort, 8080);
        expect(state.serverAddress, '0.0.0.0');
        expect(state.pendingSessions, [session1]);
        expect(state.activeSessions, [session2]);
        expect(state.error, 'Test error');
        expect(state.isStarting, false);
        expect(state.sessionsRevision, 5);
      });

      test('has sensible defaults', () {
        const state = WebSessionState();

        expect(state.serverRunning, false);
        expect(state.serverPort, isNull);
        expect(state.serverAddress, isNull);
        expect(state.pendingSessions, isEmpty);
        expect(state.activeSessions, isEmpty);
        expect(state.error, isNull);
        expect(state.isStarting, false);
        expect(state.sessionsRevision, 0);
      });
    });

    group('.initial()', () {
      test('creates state with defaults', () {
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

      test('returns equal states on multiple calls', () {
        const state1 = WebSessionState.initial();
        const state2 = WebSessionState.initial();
        expect(state1, equals(state2));
      });
    });

    group('copyWith', () {
      test('updates serverRunning', () {
        const state = WebSessionState.initial();
        final updated = state.copyWith(serverRunning: true);

        expect(updated.serverRunning, true);
        expect(state.serverRunning, false); // Original unchanged
      });

      test('updates serverPort', () {
        const state = WebSessionState.initial();
        final updated = state.copyWith(serverPort: 9000);

        expect(updated.serverPort, 9000);
        expect(state.serverPort, isNull);
      });

      test('updates serverAddress', () {
        const state = WebSessionState.initial();
        final updated = state.copyWith(serverAddress: '127.0.0.1');

        expect(updated.serverAddress, '127.0.0.1');
        expect(state.serverAddress, isNull);
      });

      test('updates pendingSessions', () {
        const state = WebSessionState.initial();
        final session = WebSession(
          id: 'test',
          approvalCode: 'ABC123',
          clientAddress: '10.0.0.1',
        );
        final updated = state.copyWith(pendingSessions: [session]);

        expect(updated.pendingSessions.length, 1);
        expect(updated.pendingSessions.first, session);
        expect(state.pendingSessions, isEmpty);
      });

      test('updates activeSessions', () {
        const state = WebSessionState.initial();
        final session = WebSession(
          id: 'test',
          approvalCode: 'ABC123',
          clientAddress: '10.0.0.1',
        );
        final updated = state.copyWith(activeSessions: [session]);

        expect(updated.activeSessions.length, 1);
        expect(updated.activeSessions.first, session);
        expect(state.activeSessions, isEmpty);
      });

      test('updates error', () {
        const state = WebSessionState.initial();
        final updated = state.copyWith(error: 'Something went wrong');

        expect(updated.error, 'Something went wrong');
        expect(state.error, isNull);
      });

      test('updates isStarting', () {
        const state = WebSessionState.initial();
        final updated = state.copyWith(isStarting: true);

        expect(updated.isStarting, true);
        expect(state.isStarting, false);
      });

      test('updates sessionsRevision', () {
        const state = WebSessionState.initial();
        final updated = state.copyWith(sessionsRevision: 10);

        expect(updated.sessionsRevision, 10);
        expect(state.sessionsRevision, 0);
      });

      test('clearError sets error to null', () {
        final state = const WebSessionState.initial().copyWith(
          error: 'Existing error',
        );
        final cleared = state.copyWith(clearError: true);

        expect(cleared.error, isNull);
      });

      test('clearServerPort sets serverPort to null', () {
        final state = const WebSessionState.initial().copyWith(
          serverPort: 8080,
        );
        final cleared = state.copyWith(clearServerPort: true);

        expect(cleared.serverPort, isNull);
      });

      test('clearServerAddress sets serverAddress to null', () {
        final state = const WebSessionState.initial().copyWith(
          serverAddress: '0.0.0.0',
        );
        final cleared = state.copyWith(clearServerAddress: true);

        expect(cleared.serverAddress, isNull);
      });

      test('clearError takes precedence over error value', () {
        final state = const WebSessionState.initial().copyWith(
          error: 'Old error',
        );
        final updated =
            state.copyWith(clearError: true, error: 'New error');

        // clearError takes precedence
        expect(updated.error, isNull);
      });

      test('clearServerPort takes precedence over serverPort value', () {
        final state = const WebSessionState.initial().copyWith(
          serverPort: 8080,
        );
        final updated =
            state.copyWith(clearServerPort: true, serverPort: 9000);

        expect(updated.serverPort, isNull);
      });

      test('preserves unchanged fields', () {
        final session = WebSession(
          id: 'test',
          approvalCode: 'ABC123',
          clientAddress: '10.0.0.1',
        );
        final state = WebSessionState(
          serverRunning: true,
          serverPort: 8080,
          serverAddress: '0.0.0.0',
          pendingSessions: [session],
          activeSessions: const [],
          error: 'Error',
          isStarting: false,
          sessionsRevision: 5,
        );

        final updated = state.copyWith(isStarting: true);

        expect(updated.serverRunning, true);
        expect(updated.serverPort, 8080);
        expect(updated.serverAddress, '0.0.0.0');
        expect(updated.pendingSessions.length, 1);
        expect(updated.error, 'Error');
        expect(updated.isStarting, true);
        expect(updated.sessionsRevision, 5);
      });

      test('updates multiple fields at once', () {
        const state = WebSessionState.initial();
        final updated = state.copyWith(
          serverRunning: true,
          serverPort: 3000,
          serverAddress: 'localhost',
          isStarting: false,
        );

        expect(updated.serverRunning, true);
        expect(updated.serverPort, 3000);
        expect(updated.serverAddress, 'localhost');
        expect(updated.isStarting, false);
      });
    });

    group('computed properties', () {
      group('hasPendingSessions', () {
        test('returns false when pendingSessions is empty', () {
          const state = WebSessionState.initial();
          expect(state.hasPendingSessions, false);
        });

        test('returns true when pendingSessions is not empty', () {
          final session = WebSession(
            id: 'test',
            approvalCode: 'ABC123',
            clientAddress: '10.0.0.1',
          );
          final state = WebSessionState(pendingSessions: [session]);

          expect(state.hasPendingSessions, true);
        });

        test('returns true with multiple pending sessions', () {
          final sessions = [
            WebSession(
              id: 'test1',
              approvalCode: 'ABC111',
              clientAddress: '10.0.0.1',
            ),
            WebSession(
              id: 'test2',
              approvalCode: 'ABC222',
              clientAddress: '10.0.0.2',
            ),
          ];
          final state = WebSessionState(pendingSessions: sessions);

          expect(state.hasPendingSessions, true);
        });
      });

      group('totalPtySessions', () {
        test('returns 0 when activeSessions is empty', () {
          const state = WebSessionState.initial();
          expect(state.totalPtySessions, 0);
        });

        test('returns 0 when active sessions have no PTYs', () {
          final session = WebSession(
            id: 'test',
            approvalCode: 'ABC123',
            clientAddress: '10.0.0.1',
          );
          final state = WebSessionState(activeSessions: [session]);

          expect(state.totalPtySessions, 0);
        });

        test('sums ptyCount from multiple sessions', () {
          // Note: We can't easily add PTYs to WebSession in tests
          // without mocking the host, so we test with 0 PTYs
          final sessions = [
            WebSession(
              id: 'test1',
              approvalCode: 'ABC111',
              clientAddress: '10.0.0.1',
            ),
            WebSession(
              id: 'test2',
              approvalCode: 'ABC222',
              clientAddress: '10.0.0.2',
            ),
          ];
          final state = WebSessionState(activeSessions: sessions);

          expect(state.totalPtySessions, 0);
        });
      });
    });

    group('equality', () {
      test('equal states are equal', () {
        const state1 = WebSessionState.initial();
        const state2 = WebSessionState.initial();

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('different serverRunning means not equal', () {
        const state1 = WebSessionState(serverRunning: true);
        const state2 = WebSessionState(serverRunning: false);

        expect(state1, isNot(equals(state2)));
      });

      test('different serverPort means not equal', () {
        const state1 = WebSessionState(serverPort: 8080);
        const state2 = WebSessionState(serverPort: 9000);

        expect(state1, isNot(equals(state2)));
      });

      test('different serverAddress means not equal', () {
        const state1 = WebSessionState(serverAddress: '127.0.0.1');
        const state2 = WebSessionState(serverAddress: '0.0.0.0');

        expect(state1, isNot(equals(state2)));
      });

      test('different error means not equal', () {
        const state1 = WebSessionState(error: 'Error 1');
        const state2 = WebSessionState(error: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });

      test('different isStarting means not equal', () {
        const state1 = WebSessionState(isStarting: true);
        const state2 = WebSessionState(isStarting: false);

        expect(state1, isNot(equals(state2)));
      });

      test('different sessionsRevision means not equal', () {
        const state1 = WebSessionState(sessionsRevision: 1);
        const state2 = WebSessionState(sessionsRevision: 2);

        expect(state1, isNot(equals(state2)));
      });

      test('null vs non-null error means not equal', () {
        const state1 = WebSessionState(error: null);
        const state2 = WebSessionState(error: 'Error');

        expect(state1, isNot(equals(state2)));
      });

      test('null vs non-null serverPort means not equal', () {
        const state1 = WebSessionState(serverPort: null);
        const state2 = WebSessionState(serverPort: 8080);

        expect(state1, isNot(equals(state2)));
      });
    });

    group('props', () {
      test('includes all fields', () {
        const state = WebSessionState(
          serverRunning: true,
          serverPort: 8080,
          serverAddress: '0.0.0.0',
          pendingSessions: [],
          activeSessions: [],
          error: 'error',
          isStarting: true,
          sessionsRevision: 10,
        );

        expect(state.props, [
          true,
          8080,
          '0.0.0.0',
          [],
          [],
          'error',
          true,
          10,
        ]);
      });

      test('includes null values', () {
        const state = WebSessionState.initial();

        expect(state.props, [
          false,
          null,
          null,
          [],
          [],
          null,
          false,
          0,
        ]);
      });
    });

    group('state transitions', () {
      test('server starting to running', () {
        var state = const WebSessionState.initial();
        state = state.copyWith(isStarting: true);

        expect(state.isStarting, true);
        expect(state.serverRunning, false);

        state = state.copyWith(
          isStarting: false,
          serverRunning: true,
          serverPort: 8080,
          serverAddress: '0.0.0.0',
        );

        expect(state.isStarting, false);
        expect(state.serverRunning, true);
        expect(state.serverPort, 8080);
        expect(state.serverAddress, '0.0.0.0');
      });

      test('server stopping clears port and address', () {
        var state = const WebSessionState.initial().copyWith(
          serverRunning: true,
          serverPort: 8080,
          serverAddress: '0.0.0.0',
        );

        state = state.copyWith(
          serverRunning: false,
          clearServerPort: true,
          clearServerAddress: true,
        );

        expect(state.serverRunning, false);
        expect(state.serverPort, isNull);
        expect(state.serverAddress, isNull);
      });

      test('adding then clearing error', () {
        var state = const WebSessionState.initial();
        state = state.copyWith(error: 'Failed to connect');

        expect(state.error, 'Failed to connect');

        state = state.copyWith(clearError: true);

        expect(state.error, isNull);
      });

      test('incrementing sessions revision', () {
        var state = const WebSessionState.initial();
        expect(state.sessionsRevision, 0);

        state = state.copyWith(sessionsRevision: state.sessionsRevision + 1);
        expect(state.sessionsRevision, 1);

        state = state.copyWith(sessionsRevision: state.sessionsRevision + 1);
        expect(state.sessionsRevision, 2);
      });
    });
  });
}
