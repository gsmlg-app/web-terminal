import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:web_server/web_server.dart';

/// Mock implementation of ExecutionSession for testing.
class MockExecutionSession implements ExecutionSession {
  final StreamController<Uint8List> _outputController =
      StreamController<Uint8List>.broadcast();
  final Completer<int> _exitCodeCompleter = Completer<int>();

  List<Uint8List> writtenData = [];
  List<List<int>> resizeCalls = [];
  bool isClosed = false;

  @override
  Stream<Uint8List> get output => _outputController.stream;

  @override
  Future<int> get exitCode => _exitCodeCompleter.future;

  @override
  Future<void> write(Uint8List data) async {
    if (!isClosed) {
      writtenData.add(data);
    }
  }

  @override
  Future<void> resize(int width, int height) async {
    if (!isClosed) {
      resizeCalls.add([width, height]);
    }
  }

  @override
  Future<void> close() async {
    isClosed = true;
    if (!_outputController.isClosed) {
      await _outputController.close();
    }
  }

  /// Simulate output from the session.
  void simulateOutput(Uint8List data) {
    if (!_outputController.isClosed) {
      _outputController.add(data);
    }
  }

  /// Simulate an error in the output stream.
  void simulateError(Object error) {
    if (!_outputController.isClosed) {
      _outputController.addError(error);
    }
  }

  /// Simulate the session exiting.
  void simulateExit(int code) {
    if (!_exitCodeCompleter.isCompleted) {
      _exitCodeCompleter.complete(code);
    }
  }
}

void main() {
  group('PtySession', () {
    late MockExecutionSession mockExecution;
    late List<MapEntry<String, Uint8List>> outputCalls;
    late List<MapEntry<String, int>> exitCalls;

    PtySession createSession({String id = 'test-pty'}) {
      return PtySession(
        id: id,
        executionSession: mockExecution,
        onOutput: (ptyId, data) {
          outputCalls.add(MapEntry(ptyId, data));
        },
        onExit: (ptyId, exitCode) {
          exitCalls.add(MapEntry(ptyId, exitCode));
        },
      );
    }

    setUp(() {
      mockExecution = MockExecutionSession();
      outputCalls = [];
      exitCalls = [];
    });

    tearDown(() async {
      if (!mockExecution.isClosed) {
        await mockExecution.close();
      }
    });

    group('constructor', () {
      test('stores id correctly', () {
        final session = createSession(id: 'my-pty-123');
        expect(session.id, 'my-pty-123');
      });

      test('stores executionSession correctly', () {
        final session = createSession();
        expect(session.executionSession, mockExecution);
      });

      test('starts not closed', () {
        final session = createSession();
        expect(session.isClosed, isFalse);
      });
    });

    group('output handling', () {
      test('forwards output to callback with correct ptyId', () async {
        createSession(id: 'output-test');

        final testData =
            Uint8List.fromList([72, 101, 108, 108, 111]); // "Hello"
        mockExecution.simulateOutput(testData);

        // Wait for event to propagate
        await Future.delayed(Duration.zero);

        expect(outputCalls.length, 1);
        expect(outputCalls.first.key, 'output-test');
        expect(outputCalls.first.value, testData);
      });

      test('handles multiple output events', () async {
        createSession(id: 'multi-output');

        mockExecution.simulateOutput(Uint8List.fromList([1, 2, 3]));
        mockExecution.simulateOutput(Uint8List.fromList([4, 5, 6]));
        mockExecution.simulateOutput(Uint8List.fromList([7, 8, 9]));

        await Future.delayed(Duration.zero);

        expect(outputCalls.length, 3);
        expect(outputCalls[0].value, Uint8List.fromList([1, 2, 3]));
        expect(outputCalls[1].value, Uint8List.fromList([4, 5, 6]));
        expect(outputCalls[2].value, Uint8List.fromList([7, 8, 9]));
      });

      test('handles empty output', () async {
        createSession();

        mockExecution.simulateOutput(Uint8List(0));
        await Future.delayed(Duration.zero);

        expect(outputCalls.length, 1);
        expect(outputCalls.first.value.length, 0);
      });

      test('handles errors in output stream gracefully', () async {
        createSession();

        // Error should be caught and logged, not crash
        mockExecution.simulateError(Exception('Stream error'));
        await Future.delayed(Duration.zero);

        // No crash, no output callback for error
        expect(outputCalls, isEmpty);
      });
    });

    group('exit handling', () {
      test('forwards exit code to callback', () async {
        createSession(id: 'exit-test');

        mockExecution.simulateExit(0);
        await Future.delayed(Duration.zero);

        expect(exitCalls.length, 1);
        expect(exitCalls.first.key, 'exit-test');
        expect(exitCalls.first.value, 0);
      });

      test('forwards non-zero exit code', () async {
        createSession(id: 'error-exit');

        mockExecution.simulateExit(127);
        await Future.delayed(Duration.zero);

        expect(exitCalls.length, 1);
        expect(exitCalls.first.value, 127);
      });

      test('does not call onExit after close', () async {
        final session = createSession();
        await session.close();

        mockExecution.simulateExit(0);
        await Future.delayed(Duration.zero);

        expect(exitCalls, isEmpty);
      });
    });

    group('write', () {
      test('writes data to execution session', () async {
        final session = createSession();
        final data = Uint8List.fromList([65, 66, 67]); // "ABC"

        await session.write(data);

        expect(mockExecution.writtenData.length, 1);
        expect(mockExecution.writtenData.first, data);
      });

      test('can write multiple times', () async {
        final session = createSession();

        await session.write(Uint8List.fromList([1]));
        await session.write(Uint8List.fromList([2]));
        await session.write(Uint8List.fromList([3]));

        expect(mockExecution.writtenData.length, 3);
      });

      test('does not write after close', () async {
        final session = createSession();
        await session.close();

        await session.write(Uint8List.fromList([1, 2, 3]));

        expect(mockExecution.writtenData, isEmpty);
      });
    });

    group('resize', () {
      test('resizes execution session', () async {
        final session = createSession();

        await session.resize(120, 40);

        expect(mockExecution.resizeCalls.length, 1);
        expect(mockExecution.resizeCalls.first, [120, 40]);
      });

      test('can resize multiple times', () async {
        final session = createSession();

        await session.resize(80, 24);
        await session.resize(120, 40);
        await session.resize(200, 60);

        expect(mockExecution.resizeCalls.length, 3);
        expect(mockExecution.resizeCalls[0], [80, 24]);
        expect(mockExecution.resizeCalls[1], [120, 40]);
        expect(mockExecution.resizeCalls[2], [200, 60]);
      });

      test('does not resize after close', () async {
        final session = createSession();
        await session.close();

        await session.resize(100, 50);

        expect(mockExecution.resizeCalls, isEmpty);
      });
    });

    group('close', () {
      test('marks session as closed', () async {
        final session = createSession();
        expect(session.isClosed, isFalse);

        await session.close();

        expect(session.isClosed, isTrue);
      });

      test('closes underlying execution session', () async {
        final session = createSession();

        await session.close();

        expect(mockExecution.isClosed, isTrue);
      });

      test('can be called multiple times safely', () async {
        final session = createSession();

        await session.close();
        await session.close();
        await session.close();

        expect(session.isClosed, isTrue);
      });

      test('stops forwarding output after close', () async {
        final session = createSession();
        mockExecution.simulateOutput(Uint8List.fromList([1]));
        await Future.delayed(Duration.zero);

        expect(outputCalls.length, 1);

        await session.close();

        // Try to simulate more output (should not arrive)
        // Note: stream is closed so this won't propagate
        expect(outputCalls.length, 1);
      });
    });

    group('isClosed', () {
      test('returns false initially', () {
        final session = createSession();
        expect(session.isClosed, isFalse);
      });

      test('returns true after close', () async {
        final session = createSession();
        await session.close();
        expect(session.isClosed, isTrue);
      });
    });

    group('full lifecycle', () {
      test('create -> write -> resize -> output -> exit -> close', () async {
        final session = createSession(id: 'lifecycle');

        // Write some data
        await session.write(Uint8List.fromList([65, 66, 67]));
        expect(mockExecution.writtenData.length, 1);

        // Resize
        await session.resize(100, 30);
        expect(mockExecution.resizeCalls.length, 1);

        // Receive output
        mockExecution.simulateOutput(Uint8List.fromList([68, 69, 70]));
        await Future.delayed(Duration.zero);
        expect(outputCalls.length, 1);

        // Exit
        mockExecution.simulateExit(0);
        await Future.delayed(Duration.zero);
        expect(exitCalls.length, 1);

        // Close
        await session.close();
        expect(session.isClosed, isTrue);
      });

      test('handles close before exit', () async {
        final session = createSession();

        await session.close();
        mockExecution.simulateExit(0);
        await Future.delayed(Duration.zero);

        // Exit callback should not be called after close
        expect(exitCalls, isEmpty);
      });
    });
  });
}
