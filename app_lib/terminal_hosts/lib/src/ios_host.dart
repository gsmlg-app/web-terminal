import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ios_shell/ios_shell.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/local_fs.dart';

/// Host implementation for iOS using the ios_system framework.
///
/// Note: iOS doesn't support traditional PTY/fork like Unix systems.
/// This implementation uses ios_system for command execution with
/// a simulated shell session that processes commands line by line.
class IosHost implements Host {
  final IosShellEnv _env;

  IosHost(this._env);

  @override
  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  }) async {
    // Build command string
    final command = args.isEmpty ? executable : '$executable ${args.join(' ')}';

    // Execute using ios_system
    final result = await _env.execute(command);

    return IosExecutionResult(
      exitCode: result.exitCode,
      stdout: result.stdout,
      stderr: result.stderr,
    );
  }

  @override
  Future<FileSystem> connectFileSystem() async {
    return LocalFileSystem();
  }

  @override
  Future<IosExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async {
    // Create a simulated shell session for iOS
    // Note: width/height are accepted for API compatibility but iOS
    // doesn't support true PTY resizing
    return IosExecutionSession(_env);
  }

  final _doneCompleter = Completer<void>();

  @override
  Future<void> disconnect() async {
    _doneCompleter.complete();
  }

  @override
  Future<void> get done => _doneCompleter.future;
}

/// Result of executing a command on iOS.
class IosExecutionResult implements ExecutionResult {
  @override
  final int exitCode;

  @override
  final String stdout;

  @override
  final String stderr;

  IosExecutionResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });
}

/// Session for an interactive shell on iOS.
///
/// iOS doesn't support true PTY, so this simulates a shell by:
/// - Displaying a prompt
/// - Reading lines of input
/// - Executing commands via ios_system
/// - Outputting results
class IosExecutionSession implements ExecutionSession {
  final IosShellEnv _env;

  final _outputController = StreamController<Uint8List>.broadcast();
  final _exitCodeCompleter = Completer<int>();

  String _inputBuffer = '';
  bool _closed = false;

  IosExecutionSession(this._env) {
    _showPrompt();
  }

  @override
  Future<int> get exitCode => _exitCodeCompleter.future;

  @override
  Stream<Uint8List> get output => _outputController.stream;

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _outputController.close();
    if (!_exitCodeCompleter.isCompleted) {
      _exitCodeCompleter.complete(0);
    }
  }

  @override
  Future<void> resize(int width, int height) async {
    // iOS shell doesn't have true PTY, resize is a no-op
  }

  @override
  Future<void> write(Uint8List data) async {
    if (_closed) return;

    final input = utf8.decode(data);

    for (final char in input.split('')) {
      if (char == '\r' || char == '\n') {
        // Execute the command
        _output('\r\n');
        await _executeCommand(_inputBuffer.trim());
        _inputBuffer = '';
        if (!_closed) {
          _showPrompt();
        }
      } else if (char == '\x7f' || char == '\b') {
        // Backspace
        if (_inputBuffer.isNotEmpty) {
          _inputBuffer = _inputBuffer.substring(0, _inputBuffer.length - 1);
          _output('\b \b'); // Move back, clear, move back
        }
      } else if (char == '\x03') {
        // Ctrl+C
        _inputBuffer = '';
        _output('^C\r\n');
        _showPrompt();
      } else if (char == '\x04') {
        // Ctrl+D - exit
        if (_inputBuffer.isEmpty) {
          _output('exit\r\n');
          close();
        }
      } else if (char.codeUnitAt(0) >= 32) {
        // Printable character
        _inputBuffer += char;
        _output(char);
      }
    }
  }

  void _showPrompt() {
    final cwd = _env.homePath;
    final shortCwd = cwd.split('/').last;
    _output('$shortCwd \$ ');
  }

  void _output(String text) {
    if (!_closed) {
      _outputController.add(Uint8List.fromList(utf8.encode(text)));
    }
  }

  Future<void> _executeCommand(String command) async {
    if (command.isEmpty) return;

    // Handle built-in commands
    if (command == 'exit' || command == 'logout') {
      close();
      return;
    }

    if (command.startsWith('cd ')) {
      final path = command.substring(3).trim();
      await _handleCd(path);
      return;
    }

    if (command == 'cd') {
      await _handleCd(_env.homePath);
      return;
    }

    // Execute via ios_system
    try {
      final result = await _env.execute(command);

      if (result.stdout.isNotEmpty) {
        // Normalize line endings for terminal display
        final stdout = result.stdout.replaceAll('\n', '\r\n');
        _output(stdout);
        if (!stdout.endsWith('\r\n')) {
          _output('\r\n');
        }
      }

      if (result.stderr.isNotEmpty) {
        final stderr = result.stderr.replaceAll('\n', '\r\n');
        _output(stderr);
        if (!stderr.endsWith('\r\n')) {
          _output('\r\n');
        }
      }
    } catch (e) {
      _output('Error: $e\r\n');
    }
  }

  Future<void> _handleCd(String path) async {
    final success = await IosShellPlugin.setCurrentDirectory(path);
    if (!success) {
      _output('cd: no such file or directory: $path\r\n');
    }
  }
}
