import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:android_shell/android_shell.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/local_fs.dart';

/// Host implementation for Android using the sandboxed shell environment.
class AndroidHost implements Host {
  final AndroidShellEnv _env;

  AndroidHost(this._env);

  @override
  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  }) async {
    // Resolve executable path in sandboxed bin directory
    final execPath = _resolveExecutable(executable);

    final result = await io.Process.run(
      execPath,
      args,
      environment: {..._env.getEnvironment(), ...environment ?? {}},
      workingDirectory: _env.homePath,
    );
    return AndroidExecutionResult(result);
  }

  @override
  Future<FileSystem> connectFileSystem() async {
    return LocalFileSystem();
  }

  @override
  Future<AndroidExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async {
    final (command, args) = _env.getShellCommand();

    final pty = Pty.start(
      command,
      arguments: args,
      environment: {..._env.getEnvironment(), ...environment ?? {}},
      workingDirectory: _env.homePath,
      rows: height,
      columns: width,
    );
    return AndroidExecutionSession(pty);
  }

  final _doneCompleter = Completer<void>();

  @override
  Future<void> disconnect() async {
    _doneCompleter.complete();
  }

  @override
  Future<void> get done => _doneCompleter.future;

  /// Resolves an executable name to its full path.
  ///
  /// If the executable is not an absolute path, looks for it in the
  /// sandboxed bin directory first.
  String _resolveExecutable(String executable) {
    if (executable.startsWith('/')) {
      return executable;
    }

    // Check if it exists in our bin directory
    final sandboxedPath = '${_env.binPath}/$executable';
    if (io.File(sandboxedPath).existsSync()) {
      return sandboxedPath;
    }

    // Fall back to system PATH resolution
    return executable;
  }
}

/// Result of executing a command on Android.
class AndroidExecutionResult implements ExecutionResult {
  final io.ProcessResult _result;

  /// Creates an [AndroidExecutionResult] from a [io.ProcessResult].
  AndroidExecutionResult(this._result);

  @override
  int get exitCode => _result.exitCode;

  @override
  String get stderr => _result.stderr;

  @override
  String get stdout => _result.stdout;
}

/// Session for an interactive shell on Android.
class AndroidExecutionSession implements ExecutionSession {
  final Pty _pty;

  /// Creates an [AndroidExecutionSession] from a [Pty].
  AndroidExecutionSession(this._pty);

  @override
  Future<int> get exitCode => _pty.exitCode;

  @override
  Stream<Uint8List> get output => _pty.output;

  @override
  Future<void> close() async {
    _pty.kill();
  }

  @override
  Future<void> resize(int width, int height) async {
    _pty.resize(height, width);
  }

  @override
  Future<void> write(Uint8List data) async {
    _pty.write(data);
  }
}
