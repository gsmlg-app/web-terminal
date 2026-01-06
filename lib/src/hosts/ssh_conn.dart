import 'package:gsmlg_ssh/gsmlg_ssh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_terminal/object/ssh_host.dart';
import 'package:web_terminal/src/core/conn.dart';
import 'package:web_terminal/src/hosts/ssh_host.dart';

class SSHConnector extends HostConnector<SSHHost> {
  final SshHost record;

  SSHConnector(this.record);

  @override
  Future<SSHHost> createHost() async {
    final socket = await AsyncValue.guard(
      () => SSHSocket.connect(
        record.hostname!,
        record.port!,
      ),
    );

    if (socket.hasError) {
      final error = socket.error!;
      throw 'Failed to connect: $error';
    }

    final client = SSHClient(
      socket.value!,
      username: record.username!,
      onPasswordRequest: () => record.password,
    );

    final authenticated = await AsyncValue.guard(() => client.authenticated);

    if (authenticated.hasError) {
      final error = authenticated.error!;
      throw 'Failed to authenticate: $error';
    }

    return SSHHost(client);
  }
}
