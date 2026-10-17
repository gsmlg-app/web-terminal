import 'dart:async';
import 'dart:typed_data';

import 'package:terminal_core/terminal_core.dart';

/// A PTY session wrapper that manages a single terminal process.
class PtySession {
  /// Unique identifier for this PTY session.
  final String id;

  /// The underlying execution session.
  final ExecutionSession executionSession;

  /// Callback for output data.
  final void Function(String ptyId, Uint8List data) onOutput;

  /// Callback when PTY exits.
  final void Function(String ptyId, int exitCode) onExit;

  /// Stream subscription for output.
  StreamSubscription<Uint8List>? _outputSubscription;

  /// Whether the PTY has been closed.
  bool _isClosed = false;

  PtySession({
    required this.id,
    required this.executionSession,
    required this.onOutput,
    required this.onExit,
  }) {
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to output stream
    _outputSubscription = executionSession.output.listen(
      (data) {
        try {
          onOutput(id, data);
        } finally {
          executionSession.ackRead();
        }
      },
      onError: (error) {
        // Log error but continue
      },
    );

    // Listen for exit code
    executionSession.exitCode.then((code) {
      if (!_isClosed) {
        onExit(id, code);
      }
    });
  }

  /// Write input data to the PTY.
  Future<void> write(Uint8List data) async {
    if (_isClosed) return;
    await executionSession.write(data);
  }

  /// Resize the PTY terminal.
  Future<void> resize(int cols, int rows) async {
    if (_isClosed) return;
    await executionSession.resize(cols, rows);
  }

  /// Close the PTY session.
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;

    await _outputSubscription?.cancel();
    await executionSession.close();
  }

  /// Whether the PTY is closed.
  bool get isClosed => _isClosed;
}
