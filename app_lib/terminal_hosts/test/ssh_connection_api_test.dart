import 'package:app_ssh/app_ssh.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  group('SSH Connection API Tests', () {
    group('SSHConnector with password authentication', () {
      late SshHost testHost;

      setUp(() {
        testHost = SshHost(
          id: 1,
          host: 'Test Server',
          hostname: 'example.com',
          port: 22,
          username: 'testuser',
          password: 'testpass',
          salt: null,
          identityType: SshIdentityType.password.value,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );
      });

      test('creates connector with password authentication', () {
        final connector = SSHConnector(testHost);

        expect(connector.record, testHost);
        expect(connector.record.identityType, SshIdentityType.password.value);
        expect(connector.record.password, 'testpass');
        expect(connector.keyData, isNull);
      });

      test('uses default connection timeout', () {
        final connector = SSHConnector(testHost);
        expect(connector.connectionTimeout, kSshConnectionTimeout);
        expect(connector.connectionTimeout.inSeconds, 30);
      });

      test('uses default authentication timeout', () {
        final connector = SSHConnector(testHost);
        expect(connector.authenticationTimeout, kSshAuthenticationTimeout);
        expect(connector.authenticationTimeout.inSeconds, 60);
      });

      test('allows custom connection timeout', () {
        final connector = SSHConnector(
          testHost,
          connectionTimeout: const Duration(seconds: 15),
        );
        expect(connector.connectionTimeout.inSeconds, 15);
      });

      test('allows custom authentication timeout', () {
        final connector = SSHConnector(
          testHost,
          authenticationTimeout: const Duration(seconds: 45),
        );
        expect(connector.authenticationTimeout.inSeconds, 45);
      });

      test('returns Future<SSHHost> from createHost', () {
        final connector = SSHConnector(testHost);
        expect(connector.createHost(), isA<Future<SSHHost>>());
      });

      test('handles empty password', () {
        final hostWithEmptyPassword = SshHost(
          id: 2,
          host: 'Empty Pass Server',
          hostname: 'example.com',
          port: 22,
          username: 'user',
          password: '',
          salt: null,
          identityType: SshIdentityType.password.value,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final connector = SSHConnector(hostWithEmptyPassword);
        expect(connector.record.password, '');
      });

      test('handles null hostname', () {
        final hostWithNullHostname = SshHost(
          id: 3,
          host: 'No Hostname',
          hostname: null,
          port: 22,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: SshIdentityType.password.value,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final connector = SSHConnector(hostWithNullHostname);
        expect(connector.record.hostname, isNull);
      });

      test('handles custom port', () {
        final hostWithCustomPort = SshHost(
          id: 4,
          host: 'Custom Port',
          hostname: 'example.com',
          port: 2222,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: SshIdentityType.password.value,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final connector = SSHConnector(hostWithCustomPort);
        expect(connector.record.port, 2222);
      });
    });

    group('SSHConnector with key-based authentication', () {
      late SshHost keyBasedHost;
      late SshKeyData keyData;

      setUp(() {
        keyBasedHost = SshHost(
          id: 5,
          host: 'Key Server',
          hostname: 'keyserver.com',
          port: 22,
          username: 'keyuser',
          password: null,
          salt: null,
          identityType: SshIdentityType.key.value,
          identityKeyId: 1,
          createdAt: DateTime.now(),
        );

        keyData = const SshKeyData(
          content: '-----BEGIN OPENSSH PRIVATE KEY-----\ntest\n-----END OPENSSH PRIVATE KEY-----',
        );
      });

      test('creates connector with key authentication', () {
        final connector = SSHConnector(keyBasedHost, keyData: keyData);

        expect(connector.record, keyBasedHost);
        expect(connector.record.identityType, SshIdentityType.key.value);
        expect(connector.record.identityKeyId, 1);
        expect(connector.keyData, keyData);
      });

      test('key data is accessible', () {
        final connector = SSHConnector(keyBasedHost, keyData: keyData);

        expect(connector.keyData?.content, contains('BEGIN OPENSSH PRIVATE KEY'));
        expect(connector.keyData?.content, contains('END OPENSSH PRIVATE KEY'));
      });

      test('supports encrypted keys with passphrase', () {
        const encryptedKeyData = SshKeyData(
          content: '-----BEGIN ENCRYPTED PRIVATE KEY-----\ntest\n-----END ENCRYPTED PRIVATE KEY-----',
          passphrase: 'keypassphrase',
        );

        final connector = SSHConnector(keyBasedHost, keyData: encryptedKeyData);

        expect(connector.keyData?.content, contains('ENCRYPTED'));
        expect(connector.keyData?.passphrase, 'keypassphrase');
      });

      test('key data can be null initially', () {
        final connector = SSHConnector(keyBasedHost);
        expect(connector.keyData, isNull);
      });

      test('multiple key formats supported', () {
        const rsaKey = SshKeyData(
          content: '-----BEGIN RSA PRIVATE KEY-----\ntest\n-----END RSA PRIVATE KEY-----',
        );

        const ed25519Key = SshKeyData(
          content: '-----BEGIN OPENSSH PRIVATE KEY-----\ntest\n-----END OPENSSH PRIVATE KEY-----',
        );

        final rsaConnector = SSHConnector(keyBasedHost, keyData: rsaKey);
        final ed25519Connector = SSHConnector(keyBasedHost, keyData: ed25519Key);

        expect(rsaConnector.keyData?.content, contains('RSA PRIVATE KEY'));
        expect(ed25519Connector.keyData?.content, contains('OPENSSH PRIVATE KEY'));
      });
    });

    group('SSH Exception Types', () {
      test('SshConnectionException with message', () {
        const exception = SshConnectionException('Failed to connect to server');

        expect(exception.message, 'Failed to connect to server');
        expect(exception.cause, isNull);
        expect(exception.toString(), 'Failed to connect to server');
      });

      test('SshConnectionException with cause', () {
        final cause = Exception('Network unreachable');
        final exception = SshConnectionException('Connection failed', cause);

        expect(exception.message, 'Connection failed');
        expect(exception.cause, isNotNull);
        expect(exception.toString(), contains('Connection failed'));
        expect(exception.toString(), contains('Network unreachable'));
      });

      test('SshAuthenticationException with message', () {
        const exception = SshAuthenticationException('Invalid credentials');

        expect(exception.message, 'Invalid credentials');
        expect(exception.cause, isNull);
        expect(exception.toString(), 'Invalid credentials');
      });

      test('SshAuthenticationException with cause', () {
        final cause = Exception('Password incorrect');
        final exception = SshAuthenticationException('Auth failed', cause);

        expect(exception.message, 'Auth failed');
        expect(exception.cause, isNotNull);
        expect(exception.toString(), contains('Auth failed'));
        expect(exception.toString(), contains('Password incorrect'));
      });

      test('SshKeyParseException with message', () {
        const exception = SshKeyParseException('Invalid key format');

        expect(exception.message, 'Invalid key format');
        expect(exception.cause, isNull);
        expect(exception.toString(), 'Invalid key format');
      });

      test('SshKeyParseException with cause', () {
        final cause = FormatException('Not a valid PEM');
        final exception = SshKeyParseException('Key parsing failed', cause);

        expect(exception.message, 'Key parsing failed');
        expect(exception.cause, isNotNull);
        expect(exception.toString(), contains('Key parsing failed'));
      });

      test('SshTimeoutException with duration', () {
        const exception = SshTimeoutException(
          'Connection timeout',
          Duration(seconds: 30),
        );

        expect(exception.message, 'Connection timeout');
        expect(exception.timeout, const Duration(seconds: 30));
        expect(exception.toString(), 'Connection timeout (timeout: 30s)');
      });

      test('SshTimeoutException formats duration correctly', () {
        const shortTimeout = SshTimeoutException(
          'Quick timeout',
          Duration(seconds: 5),
        );
        const longTimeout = SshTimeoutException(
          'Long timeout',
          Duration(seconds: 120),
        );

        expect(shortTimeout.toString(), contains('5s'));
        expect(longTimeout.toString(), contains('120s'));
      });
    });

    group('SSHHostSpec', () {
      test('creates spec with password host', () {
        final host = SshHost(
          id: 1,
          host: 'My Server',
          hostname: 'server.com',
          port: 22,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: SshIdentityType.password.value,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final spec = SSHHostSpec(host);

        expect(spec.record, host);
        expect(spec.keyData, isNull);
        expect(spec.name, 'My Server');
      });

      test('creates spec with key-based host', () {
        final host = SshHost(
          id: 2,
          host: 'Key Server',
          hostname: 'key.com',
          port: 22,
          username: 'keyuser',
          password: null,
          salt: null,
          identityType: SshIdentityType.key.value,
          identityKeyId: 1,
          createdAt: DateTime.now(),
        );
        const keyData = SshKeyData(content: '-----BEGIN KEY-----');

        final spec = SSHHostSpec(host, keyData: keyData);

        expect(spec.record, host);
        expect(spec.keyData, keyData);
        expect(spec.name, 'Key Server');
      });

      test('name fallback chain: host -> hostname -> default', () {
        final hostWithName = SshHost(
          id: 1,
          host: 'Display Name',
          hostname: 'actual.com',
          port: 22,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final hostWithoutName = SshHost(
          id: 2,
          host: null,
          hostname: 'hostname.com',
          port: 22,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final hostWithNeither = SshHost(
          id: 3,
          host: null,
          hostname: null,
          port: 22,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        expect(SSHHostSpec(hostWithName).name, 'Display Name');
        expect(SSHHostSpec(hostWithoutName).name, 'hostname.com');
        expect(SSHHostSpec(hostWithNeither).name, 'SSH Host');
      });

      test('createConnector produces SSHConnector', () {
        final host = SshHost(
          id: 1,
          host: 'Test',
          hostname: 'test.com',
          port: 22,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final spec = SSHHostSpec(host);
        final connector = spec.createConnector();

        expect(connector, isA<SSHConnector>());
        expect(connector, isA<HostConnector<SSHHost>>());
        expect(connector.record, host);
      });

      test('throws ArgumentError if key-based auth without keyData', () {
        final host = SshHost(
          id: 1,
          host: 'Key Host',
          hostname: 'key.com',
          port: 22,
          username: 'user',
          password: null,
          salt: null,
          identityType: SshIdentityType.key.value,
          identityKeyId: 1,
          createdAt: DateTime.now(),
        );

        expect(
          () => SSHHostSpec(host),
          throwsArgumentError,
        );
      });

      test('implements HostSpec interface', () {
        final host = SshHost(
          id: 1,
          host: 'Test',
          hostname: 'test.com',
          port: 22,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final spec = SSHHostSpec(host);
        expect(spec, isA<HostSpec>());
      });
    });

    group('SshKeyData', () {
      test('creates with content only', () {
        const keyData = SshKeyData(
          content: '-----BEGIN RSA PRIVATE KEY-----',
        );

        expect(keyData.content, '-----BEGIN RSA PRIVATE KEY-----');
        expect(keyData.passphrase, isNull);
      });

      test('creates with content and passphrase', () {
        const keyData = SshKeyData(
          content: '-----BEGIN ENCRYPTED PRIVATE KEY-----',
          passphrase: 'secret123',
        );

        expect(keyData.content, '-----BEGIN ENCRYPTED PRIVATE KEY-----');
        expect(keyData.passphrase, 'secret123');
      });

      test('allows empty content', () {
        const keyData = SshKeyData(content: '');
        expect(keyData.content, isEmpty);
      });

      test('allows empty passphrase', () {
        const keyData = SshKeyData(content: 'key', passphrase: '');
        expect(keyData.passphrase, isEmpty);
        expect(keyData.passphrase, isNot(isNull));
      });

      test('is const constructible', () {
        const keyData1 = SshKeyData(content: 'same');
        const keyData2 = SshKeyData(content: 'same');

        expect(identical(keyData1, keyData2), isTrue);
      });
    });

    group('SSH Constants', () {
      test('kSshConnectionTimeout is 30 seconds', () {
        expect(kSshConnectionTimeout, const Duration(seconds: 30));
        expect(kSshConnectionTimeout.inSeconds, 30);
        expect(kSshConnectionTimeout.inMilliseconds, 30000);
      });

      test('kSshAuthenticationTimeout is 60 seconds', () {
        expect(kSshAuthenticationTimeout, const Duration(seconds: 60));
        expect(kSshAuthenticationTimeout.inSeconds, 60);
        expect(kSshAuthenticationTimeout.inMilliseconds, 60000);
      });

      test('connection timeout is less than authentication timeout', () {
        expect(
          kSshConnectionTimeout.inSeconds,
          lessThan(kSshAuthenticationTimeout.inSeconds),
        );
      });
    });

    group('Edge cases and error conditions', () {
      test('handles very long hostnames', () {
        final longHostname = 'a' * 255;
        final host = SshHost(
          id: 1,
          host: 'Long Host',
          hostname: longHostname,
          port: 22,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final connector = SSHConnector(host);
        expect(connector.record.hostname?.length, 255);
      });

      test('handles very long passwords', () {
        final longPassword = 'x' * 1000;
        final host = SshHost(
          id: 1,
          host: 'Test',
          hostname: 'test.com',
          port: 22,
          username: 'user',
          password: longPassword,
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final connector = SSHConnector(host);
        expect(connector.record.password?.length, 1000);
      });

      test('handles special characters in username', () {
        final host = SshHost(
          id: 1,
          host: 'Test',
          hostname: 'test.com',
          port: 22,
          username: 'user@domain.com',
          password: 'pass',
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final connector = SSHConnector(host);
        expect(connector.record.username, 'user@domain.com');
      });

      test('handles port at boundary values', () {
        final minPort = SshHost(
          id: 1,
          host: 'Min Port',
          hostname: 'test.com',
          port: 1,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final maxPort = SshHost(
          id: 2,
          host: 'Max Port',
          hostname: 'test.com',
          port: 65535,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        expect(SSHConnector(minPort).record.port, 1);
        expect(SSHConnector(maxPort).record.port, 65535);
      });

      test('handles zero timeout values', () {
        final host = SshHost(
          id: 1,
          host: 'Test',
          hostname: 'test.com',
          port: 22,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final connector = SSHConnector(
          host,
          connectionTimeout: Duration.zero,
          authenticationTimeout: Duration.zero,
        );

        expect(connector.connectionTimeout, Duration.zero);
        expect(connector.authenticationTimeout, Duration.zero);
      });

      test('handles very large timeout values', () {
        final host = SshHost(
          id: 1,
          host: 'Test',
          hostname: 'test.com',
          port: 22,
          username: 'user',
          password: 'pass',
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );

        final connector = SSHConnector(
          host,
          connectionTimeout: const Duration(hours: 1),
          authenticationTimeout: const Duration(hours: 2),
        );

        expect(connector.connectionTimeout.inHours, 1);
        expect(connector.authenticationTimeout.inHours, 2);
      });
    });
  });
}
