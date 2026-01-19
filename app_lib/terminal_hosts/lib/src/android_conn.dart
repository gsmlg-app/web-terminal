import 'package:android_shell/android_shell.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/android_host.dart';

/// Connector for Android shell environment.
///
/// Ensures the sandboxed shell environment is initialized before creating
/// the host.
class AndroidConnector extends HostConnector<AndroidHost> {
  AndroidConnector();

  @override
  Future<AndroidHost> createHost() async {
    // Ensure shell environment is initialized
    final env = AndroidShellEnv.instance;
    if (!env.isInitialized) {
      await env.initialize();
    }

    return AndroidHost(env);
  }
}
