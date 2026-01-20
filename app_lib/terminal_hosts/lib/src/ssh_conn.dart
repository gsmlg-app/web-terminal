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

/// Exception thrown when SSH connection fails.
class SshConnectionException implements Exception {
  final String message;
  final Object? cause;

  const SshConnectionException(this.message, [this.cause]);

  @override
  String toString() => cause != null ? '$message: $cause' : message;
}

/// Exception thrown when SSH authentication fails.
class SshAuthenticationException implements Exception {
  final String message;
  final Object? cause;

  const SshAuthenticationException(this.message, [this.cause]);

  @override
  String toString() => cause != null ? '$message: $cause' : message;
}

/// Exception thrown when SSH key parsing fails.
class SshKeyParseException implements Exception {
  final String message;
  final Object? cause;

  const SshKeyParseException(this.message, [this.cause]);

  @override
  String toString() => cause != null ? '$message: $cause' : message;
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
    // Validate required fields
    final hostname = record.hostname;
    final port = record.port;
    final username = record.username;

    if (hostname == null || hostname.isEmpty) {
      throw const SshConnectionException('Hostname is required');
    }
    if (port == null || port <= 0 || port > 65535) {
      throw const SshConnectionException('Invalid port number');
    }
    if (username == null || username.isEmpty) {
      throw const SshAuthenticationException('Username is required');
    }

    // Establish socket connection
    final SSHSocket socket;
    try {
      socket = await SSHSocket.connect(hostname, port);
    } catch (error) {
      throw SshConnectionException('Failed to connect to $hostname:$port', error);
    }

    // Determine authentication method
    final identityType = SshIdentityType.fromValue(record.identityType);
    final useKeyAuth = identityType == SshIdentityType.key && keyData != null;

    // Parse SSH key if using key authentication
    List<SSHKeyPair>? identities;
    if (useKeyAuth) {
      if (keyData!.content.isEmpty) {
        socket.close();
        throw const SshKeyParseException('SSH key content is empty');
      }
      try {
        identities = SSHKeyPair.fromPem(
          keyData!.content,
          keyData!.passphrase,
        );
      } catch (error) {
        socket.close();
        throw SshKeyParseException('Failed to parse SSH key', error);
      }
    }

    // Create SSH client
    final client = SSHClient(
      socket,
      username: username,
      onPasswordRequest: useKeyAuth ? null : () => record.password,
      identities: identities,
    );

    // Authenticate
    try {
      await client.authenticated;
    } catch (error) {
      client.close();
      throw SshAuthenticationException('Authentication failed for $username@$hostname', error);
    }

    return SSHHost(client);
  }
}
