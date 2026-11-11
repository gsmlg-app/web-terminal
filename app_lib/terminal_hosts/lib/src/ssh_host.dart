import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_ssh/app_ssh.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/ssh_fs.dart';
import 'package:terminal_hosts/src/ssh_shell_wrapper.dart';

/// How long a wrapped shell may take to report its pid.
const _wrapperStartTimeout = Duration(seconds: 10);

/// How long a working directory lookup may take.
const _workingDirectoryTimeout = Duration(seconds: 2);

class SSHHost implements Host, DirectoryShellHost {
  SSHHost(this.client);

  final SSHClient client;

  @override
  Future<ExecutionResult> execute(
    String executable, {
    List<String> args = const [],
    bool root = false,
    Map<String, String>? environment,
  }) async {
    final command = [executable, ...args].join(' ');
    final result = await client.execute(command, environment: environment);
    return _collectResult(result);
  }

  @override
  Future<FileSystem> connectFileSystem() async {
    final sftp = await client.sftp();
    try {
      final currentDirectory = await sftp.absolute('.');
      return SSHFileSystem(sftp, currentDirectory);
    } catch (_) {
      sftp.close();
      rethrow;
    }
  }

  @override
  Future<ExecutionSession> shell({
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) => shellIn(null, width: width, height: height, environment: environment);

  /// Starts the login shell through [wrappedShellCommand] so its pid, and
  /// with it the working directory, can be looked up later. Falls back to a
  /// plain shell when the wrapper cannot run on the server.
  @override
  Future<ExecutionSession> shellIn(
    String? workingDirectory, {
    int width = 80,
    int height = 25,
    Map<String, String>? environment,
  }) async {
    final pty = SSHPtyConfig(height: height, width: width);
    try {
      final wrapped = _SSHExecutionSession(
        await client.execute(
          wrappedShellCommand(workingDirectory: workingDirectory),
          pty: pty,
          environment: environment,
        ),
        client: client,
        filter: ShellPidFilter(),
      );
      if (await wrapped.started.timeout(
        _wrapperStartTimeout,
        onTimeout: () => true,
      )) {
        return wrapped;
      }
      wrapped.discard();
    } on SSHChannelOpenError {
      rethrow;
    } catch (_) {
      // The server refused the command; use a plain shell.
    }
    return _SSHExecutionSession(
      await client.shell(environment: environment, pty: pty),
      client: client,
    );
  }

  @override
  Future<void> disconnect() async {
    client.close();
  }

  @override
  Future<void> get done => client.done;
}

Future<_SSHExecutionResult> _collectResult(SSHSession session) async {
  final stdout = StringBuffer();
  final stderr = StringBuffer();

  final stdoutStream = session.stdout.listen(
    (data) => stdout.write(String.fromCharCodes(data)),
  );

  final stderrStream = session.stderr.listen(
    (data) => stderr.write(String.fromCharCodes(data)),
  );

  await Future.wait<void>([
    session.done,
    stdoutStream.asFuture<void>(),
    stderrStream.asFuture<void>(),
  ]);

  return _SSHExecutionResult(
    exitCode: session.exitCode ?? 0,
    stdout: stdout.toString(),
    stderr: stderr.toString(),
  );
}

class _SSHExecutionResult implements ExecutionResult {
  _SSHExecutionResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  @override
  final int exitCode;

  @override
  final String stderr;

  @override
  final String stdout;
}

class _SSHExecutionSession implements ExecutionSession, WorkingDirectoryAware {
  _SSHExecutionSession(this.session, {required this.client, this.filter}) {
    final filter = this.filter;
    if (filter == null) _started.complete(true);
    _subscription = session.stdout.listen(
      (data) {
        if (filter == null) {
          _output.add(data);
          return;
        }
        final visible = filter.process(data);
        if (visible.isNotEmpty) _output.add(visible);
        if (filter.pid != null && !_started.isCompleted) {
          _started.complete(true);
        }
      },
      onDone: () {
        final rest = filter?.flush();
        if (rest != null && rest.isNotEmpty) _output.add(rest);
        if (!_started.isCompleted) _started.complete(false);
        _output.close();
      },
    );
  }

  final SSHSession session;
  final SSHClient client;

  /// Strips the wrapper's pid marker; null for a plain shell.
  final ShellPidFilter? filter;

  final _output = StreamController<Uint8List>();
  final _started = Completer<bool>();
  late final StreamSubscription<Uint8List> _subscription;
  String? _lastWorkingDirectory;

  /// Completes with true once the shell is running, or false when the
  /// session ended before the wrapper reported the shell's pid.
  Future<bool> get started => _started.future;

  /// Drops a session that is not used, with its buffered output.
  void discard() {
    _subscription.cancel();
    session.close();
  }

  @override
  Future<String?> currentWorkingDirectory() async {
    final pid = filter?.pid;
    if (pid == null) return null;
    try {
      final output = await client
          .run(workingDirectoryQueryCommand(pid), stderr: false)
          .timeout(_workingDirectoryTimeout);
      final directory = parseWorkingDirectoryQuery(utf8.decode(output));
      if (directory != null) _lastWorkingDirectory = directory;
    } catch (_) {
      // Keep the last known directory.
    }
    return _lastWorkingDirectory;
  }

  @override
  Future<void> close() async {
    session.close();
    await session.done;
  }

  @override
  Future<void> resize(int width, int height) async {
    session.resizeTerminal(width, height);
  }

  @override
  Stream<Uint8List> get output => _output.stream;

  @override
  Future<void> write(Uint8List data) async {
    session.stdin.add(data);
  }

  @override
  Future<int> get exitCode async {
    await session.done;
    return session.exitCode ?? 0;
  }

  @override
  void ackRead() {
    // SSH sessions don't use PTY backpressure, no-op
  }
}
