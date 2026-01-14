import 'package:app_ssh/app_ssh.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/ssh_host.dart';

class SSHConnector extends HostConnector<SSHHost> {
  final SshHost record;

  SSHConnector(this.record);

  @override
  Future<SSHHost> createHost() async {
    final SSHSocket socket;
    try {
      socket = await SSHSocket.connect(record.hostname!, record.port!);
    } catch (error) {
      throw 'Failed to connect: $error';
    }

    final client = SSHClient(
      socket,
      username: record.username!,
      onPasswordRequest: () => record.password,
    );

    try {
      await client.authenticated;
    } catch (error) {
      throw 'Failed to authenticate: $error';
    }

    return SSHHost(client);
  }
}
