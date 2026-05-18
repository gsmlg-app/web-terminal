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

  /// Optional working directory to start the shell in.
  final String? _workingDirectory;

  LocalHost({
    Map<String, String> environment = const {},
    String? initCommands,
    String? workingDirectory,
  }) : _profileEnvironment = environment,
       _initCommands = initCommands,
       _workingDirectory = workingDirectory;

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
      workingDirectory: _workingDirectory,
      rows: height,
      columns: width,
      ackRead: true, // Enable backpressure to prevent message queue flooding
    );

    // Wait briefly for shell prompt before installing cwd tracking hooks.
    Future.delayed(const Duration(milliseconds: 100), () {
      final startupCommands = Platform.isWindows
          ? _initCommands ?? ''
          : buildLocalShellStartupCommands(
              workingDirectory: _workingDirectory,
              initCommands: _initCommands,
            );
      if (startupCommands.isEmpty) return;
      pty.write(utf8.encode('$startupCommands\n'));
    });

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

  @override
  void ackRead() {
    _pty.ackRead();
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

String buildLocalShellStartupCommands({
  String? workingDirectory,
  String? initCommands,
}) {
  final commands = <String>[
    'stty -echo',
    r'''
__web_terminal_update_cwd() {
  printf '\033]7;file://%s%s\007' "${HOSTNAME:-localhost}" "$PWD"
}
if [ -n "${ZSH_VERSION-}" ]; then
  autoload -Uz add-zsh-hook 2>/dev/null
  if command -v add-zsh-hook >/dev/null 2>&1; then
    add-zsh-hook precmd __web_terminal_update_cwd
  else
    eval 'precmd_functions+=(__web_terminal_update_cwd)'
  fi
fi
if [ -n "${BASH_VERSION-}" ]; then
  PROMPT_COMMAND="__web_terminal_update_cwd${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi
'''
        .trim(),
  ];

  final directory = workingDirectory;
  if (directory != null && directory.isNotEmpty) {
    commands.add('cd ${_quotePosixShellArgument(directory)}');
  }

  commands.add('__web_terminal_update_cwd');

  final profileCommands = initCommands;
  if (profileCommands != null && profileCommands.isNotEmpty) {
    commands.add(profileCommands);
  }

  commands.add(r"printf '\033[H\033[2J\033[3J'");
  commands.add('stty echo');

  return commands.join('\n');
}

String _quotePosixShellArgument(String value) {
  return "'${value.replaceAll("'", r"'\''")}'";
}
