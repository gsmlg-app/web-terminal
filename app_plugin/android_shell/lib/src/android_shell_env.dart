import 'dart:io';

import 'package:path/path.dart' as p;

import 'android_shell_plugin.dart';

/// Callback for reporting initialization progress.
typedef ProgressCallback = void Function(String message, double progress);

/// Singleton managing the Android sandboxed shell environment.
///
/// Provides paths and environment variables for the self-contained shell.
/// Uses native Android code to extract and manage busybox binaries.
class AndroidShellEnv {
  AndroidShellEnv._();

  static AndroidShellEnv? _instance;

  /// Gets the singleton instance.
  ///
  /// You must call [initialize] before using other properties.
  static AndroidShellEnv get instance {
    _instance ??= AndroidShellEnv._();
    return _instance!;
  }

  bool _initialized = false;
  late String _filesDir;
  late String _arch;
  late String _shellPath;
  bool _usesSystemShell = false;

  /// Whether the environment has been initialized.
  bool get isInitialized => _initialized;

  /// The app's internal files directory.
  /// e.g., /data/data/app.gsmlg.webterminal/files
  String get filesDir => _filesDir;

  /// The usr prefix directory.
  /// e.g., /data/data/app.gsmlg.webterminal/files/usr
  String get prefix => p.join(_filesDir, 'usr');

  /// The bin directory containing shell binaries.
  /// e.g., /data/data/app.gsmlg.webterminal/files/usr/bin
  String get binPath => p.join(prefix, 'bin');

  /// The etc directory containing configuration files.
  /// e.g., /data/data/app.gsmlg.webterminal/files/usr/etc
  String get etcPath => p.join(prefix, 'etc');

  /// The user's home directory.
  /// e.g., /data/data/app.gsmlg.webterminal/files/home
  String get homePath => p.join(_filesDir, 'home');

  /// The temporary files directory.
  /// e.g., /data/data/app.gsmlg.webterminal/files/tmp
  String get tmpPath => p.join(_filesDir, 'tmp');

  /// The default shell executable path.
  /// This may be /system/bin/sh if busybox isn't available.
  String get shellPath => _shellPath;

  /// Whether we're using the system shell instead of busybox.
  bool get usesSystemShell => _usesSystemShell;

  /// The detected CPU architecture.
  String get arch => _arch;

  /// Initializes the shell environment.
  ///
  /// This extracts busybox and creates necessary directories on first run.
  /// Subsequent calls are no-ops if already initialized.
  ///
  /// [onProgress] - Optional callback for progress updates during extraction.
  Future<void> initialize({ProgressCallback? onProgress}) async {
    if (_initialized) return;

    onProgress?.call('Initializing shell environment...', 0.1);

    // Call native plugin to initialize
    final paths = await AndroidShellPlugin.initialize();

    _filesDir = paths['filesDir'] ?? '';
    _arch = paths['arch'] ?? 'arm64-v8a';

    // Get the shell path from the plugin, which may be /system/bin/sh if busybox isn't available
    final reportedShellPath = paths['shellPath'] ?? '';

    // Check if we're using busybox or system shell
    // The plugin creates a wrapper script at binPath/sh that calls the actual shell
    final wrapperShPath = p.join(binPath, 'sh');
    if (await File(wrapperShPath).exists()) {
      // Check the content of the wrapper to see if it's a busybox wrapper or system shell
      try {
        final content = await File(wrapperShPath).readAsString();
        if (content.contains('/system/bin/sh')) {
          // Wrapper calls system shell, use it directly
          _usesSystemShell = true;
          _shellPath = '/system/bin/sh';
        } else {
          // Using busybox
          _usesSystemShell = false;
          _shellPath = wrapperShPath;
        }
      } catch (e) {
        // Can't read wrapper, fall back to system shell
        _usesSystemShell = true;
        _shellPath = '/system/bin/sh';
      }
    } else {
      // No wrapper, use system shell directly
      _usesSystemShell = true;
      _shellPath = '/system/bin/sh';
    }

    // Ensure home and tmp directories exist
    await Directory(homePath).create(recursive: true);
    await Directory(tmpPath).create(recursive: true);

    onProgress?.call('Shell environment ready', 1.0);
    _initialized = true;
  }

  /// Path to the shell profile.
  String get profilePath => p.join(etcPath, 'profile');

  /// Returns environment variables for the sandboxed shell.
  ///
  /// These should be passed to the PTY when starting a shell session.
  Map<String, String> getEnvironment() {
    return {
      'PREFIX': prefix,
      'HOME': homePath,
      'PATH': '$binPath:/system/bin:/system/xbin',
      'SHELL': shellPath,
      'TERM': 'xterm-256color',
      'LANG': 'en_US.UTF-8',
      'TMPDIR': tmpPath,
      'ANDROID_DATA': '/data',
      'ANDROID_ROOT': '/system',
      // ENV tells busybox sh where to find the profile for interactive shells
      'ENV': profilePath,
    };
  }

  /// Returns the shell command and arguments for starting a login shell.
  ///
  /// Uses busybox sh with explicit HOME navigation. The PTY workingDirectory
  /// parameter doesn't work reliably on Android, and the -l flag for login
  /// shells only reads /etc/profile (hardcoded), not our custom profile path.
  /// The ENV variable is only read for interactive non-login shells.
  ///
  /// Solution: Use -c to run a command that:
  /// 1. Changes to HOME directory
  /// 2. Sources our custom profile
  /// 3. Execs an interactive shell (replaces current process)
  (String, List<String>) getShellCommand() {
    if (_usesSystemShell) {
      // When using system shell, start it directly in interactive mode
      // The system shell is more limited but at least it works
      return (
        shellPath,
        ['-i'],
      );
    }

    // Chain: cd to HOME, source profile for aliases/settings, exec interactive shell
    // The exec ensures we don't have nested shell processes
    return (
      shellPath,
      ['-c', 'cd "\$HOME" 2>/dev/null; . "\$ENV" 2>/dev/null; exec sh -i'],
    );
  }

  /// Resets the singleton instance (useful for testing).
  static void reset() {
    _instance = null;
  }
}
