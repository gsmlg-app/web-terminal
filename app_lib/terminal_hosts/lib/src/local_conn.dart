import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/local_host.dart';

class LocalConnector extends HostConnector<LocalHost> {
  /// Additional environment variables for the shell session.
  final Map<String, String> environment;

  /// Optional init commands to run when shell starts.
  final String? initCommands;

  LocalConnector({
    this.environment = const {},
    this.initCommands,
  });

  @override
  Future<LocalHost> createHost() async {
    return LocalHost(
      environment: environment,
      initCommands: initCommands,
    );
  }
}
