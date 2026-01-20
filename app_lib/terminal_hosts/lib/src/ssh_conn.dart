import 'package:app_ssh/app_ssh.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/ssh_host.dart';

/// SSH key data for authentication.
class SshKeyData {
  /// PEM-encoded private key content.
  final String content;

  /// Passphrase for encrypted keys (null for unencrypted).
  final String? passphrase;

  const SshKeyData({
    required this.content,
    this.passphrase,
  });
}

class SSHConnector extends HostConnector<SSHHost> {
  final SshHost record;

  /// Optional SSH key for key-based authentication.
  /// When provided and [record.identityType] is key, this will be used
  /// instead of password authentication.
  final SshKeyData? keyData;

  SSHConnector(this.record, {this.keyData});

  @override
  Future<SSHHost> createHost() async {
    final SSHSocket socket;
    try {
      socket = await SSHSocket.connect(record.hostname!, record.port!);
    } catch (error) {
      throw 'Failed to connect: $error';
    }

    // Determine authentication method
    final identityType = SshIdentityType.fromValue(record.identityType);
    final useKeyAuth = identityType == SshIdentityType.key && keyData != null;

    List<SSHKeyPair>? identities;
    if (useKeyAuth) {
      try {
        identities = SSHKeyPair.fromPem(
          keyData!.content,
          keyData!.passphrase,
        );
      } catch (error) {
        socket.close();
        throw 'Failed to parse SSH key: $error';
      }
    }

    final client = SSHClient(
      socket,
      username: record.username!,
      onPasswordRequest: useKeyAuth ? null : () => record.password,
      identities: identities,
    );

    try {
      await client.authenticated;
    } catch (error) {
      throw 'Failed to authenticate: $error';
    }

    return SSHHost(client);
  }
}
