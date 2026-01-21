import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/local_fs.dart';

class LocalHost implements Host {
  /// Additional environment variables from shell profile.
  final Map<String, String> _profileEnvironment;

  /// Optional init commands to run when shell starts.
  final String? _initCommands;

  LocalHost({Map<String, String> environment = const {}, String? initCommands})
    : _profileEnvironment = environment,
      _initCommands = initCommands;

  @override
  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  }) async {
    final result = await Process.run(
      executable,
      args,
      environment: environment,
    );
    return LocalExecutionResult(result);
  }

  @override
  Future<FileSystem> connectFileSystem() async {
    return LocalFileSystem();
  }

  @override
  Future<LocalExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async {
    final shell = _platformShell;
    final mergedEnv = {
      ...Platform.environment,
      ..._profileEnvironment,
      ...environment ?? {},
    };
    final pty = Pty.start(
      shell.command,
      arguments: shell.args,
      environment: mergedEnv,
      rows: height,
      columns: width,
    );

    // Send init commands if provided (after a short delay for shell to start)
    final initCmds = _initCommands;
    if (initCmds != null && initCmds.isNotEmpty) {
      // Wait briefly for shell prompt
      Future.delayed(const Duration(milliseconds: 100), () {
        pty.write(utf8.encode('$initCmds\n'));
      });
    }

    return LocalExecutionSession(pty);
  }

  final _doneCompleter = Completer<void>();

  @override
  Future<void> disconnect() async {
    _doneCompleter.complete();
  }

  @override
  Future<void> get done => _doneCompleter.future;
}

class LocalExecutionResult implements ExecutionResult {
  final ProcessResult _result;

  LocalExecutionResult(this._result);

  @override
  int get exitCode => _result.exitCode;

  @override
  String get stderr => _result.stderr;

  @override
  String get stdout => _result.stdout;
}

class LocalExecutionSession implements ExecutionSession {
  final Pty _pty;

  LocalExecutionSession(this._pty);

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

class _ShellCommand {
  final String command;

  final List<String> args;

  _ShellCommand(this.command, this.args);
}

_ShellCommand get _platformShell {
  if (Platform.isMacOS) {
    final user = Platform.environment['USER'];
    return _ShellCommand('login', ['-fp', user!]);
  }

  if (Platform.isWindows) {
    return _ShellCommand('powershell.exe', []);
  }

  final shell = Platform.environment['SHELL'] ?? 'sh';
  return _ShellCommand(shell, []);
}
