import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/ssh_conn.dart';

/// SSH host specification implementing the HostSpec interface.
///
/// This bridges the database [SshHost] model to the terminal plugin system
/// by implementing [HostSpec], allowing SSH hosts to be used with
/// [PluginManager] and [PluginTab].
class SSHHostSpec implements HostSpec {
  /// The SSH host record from the database.
  final SshHost record;

  /// Optional SSH key data for key-based authentication.
  /// Must be provided when [record.identityType] is [SshIdentityType.key].
  final SshKeyData? keyData;

  SSHHostSpec(this.record, {this.keyData});

  @override
  String get name => record.host ?? record.hostname ?? 'SSH Host';

  @override
  HostConnector createConnector() => SSHConnector(record, keyData: keyData);
}
