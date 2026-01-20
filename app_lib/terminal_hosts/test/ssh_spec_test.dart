import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  group('SSHHostSpec', () {
    late SshHost testHostPassword;
    late SshHost testHostKey;

    setUp(() {
      testHostPassword = SshHost(
        id: 1,
        host: 'My Server',
        hostname: 'example.com',
        port: 22,
        username: 'user',
        password: 'pass123',
        identityType: SshIdentityType.password.value,
      );

      testHostKey = SshHost(
        id: 2,
        host: 'Key Server',
        hostname: 'keyserver.example.com',
        port: 2222,
        username: 'keyuser',
        identityType: SshIdentityType.key.value,
        identityKeyId: 10,
      );
    });

    test('name returns host when available', () {
      final spec = SSHHostSpec(testHostPassword);
      expect(spec.name, equals('My Server'));
    });

    test('name falls back to hostname when host is null', () {
      final hostNoName = SshHost(
        id: 3,
        hostname: 'fallback.example.com',
        port: 22,
        username: 'test',
      );
      final spec = SSHHostSpec(hostNoName);
      expect(spec.name, equals('fallback.example.com'));
    });

    test('name returns "SSH Host" when host and hostname are null', () {
      final hostMinimal = SshHost(
        id: 4,
        port: 22,
        username: 'test',
      );
      final spec = SSHHostSpec(hostMinimal);
      expect(spec.name, equals('SSH Host'));
    });

    test('createConnector returns SSHConnector', () {
      final spec = SSHHostSpec(testHostPassword);
      final connector = spec.createConnector();

      expect(connector, isA<SSHConnector>());
    });

    test('passes keyData to connector when provided', () {
      const keyData = SshKeyData(content: 'test-key-content');
      final spec = SSHHostSpec(testHostKey, keyData: keyData);

      expect(spec.keyData, equals(keyData));
      expect(spec.record.identityType, equals(SshIdentityType.key.value));
    });

    test('connector receives keyData from spec', () {
      const keyData = SshKeyData(content: 'test-key-content');
      final spec = SSHHostSpec(testHostKey, keyData: keyData);
      final connector = spec.createConnector() as SSHConnector;

      expect(connector.keyData, isNotNull);
      expect(connector.keyData!.content, equals('test-key-content'));
    });

    test('connector has null keyData when not provided', () {
      final spec = SSHHostSpec(testHostPassword);
      final connector = spec.createConnector() as SSHConnector;

      expect(connector.keyData, isNull);
    });

    test('spec holds reference to original record', () {
      final spec = SSHHostSpec(testHostPassword);

      expect(spec.record.id, equals(1));
      expect(spec.record.hostname, equals('example.com'));
      expect(spec.record.port, equals(22));
      expect(spec.record.username, equals('user'));
    });
  });

  group('SSHConnector', () {
    test('stores record reference', () {
      final host = SshHost(
        id: 1,
        hostname: 'test.example.com',
        port: 22,
        username: 'testuser',
        password: 'testpass',
        identityType: SshIdentityType.password.value,
      );

      final connector = SSHConnector(host);

      expect(connector.record, equals(host));
      expect(connector.keyData, isNull);
    });

    test('stores keyData when provided', () {
      final host = SshHost(
        id: 2,
        hostname: 'key.example.com',
        port: 22,
        username: 'keyuser',
        identityType: SshIdentityType.key.value,
        identityKeyId: 5,
      );

      const keyData = SshKeyData(
        content: '-----BEGIN RSA PRIVATE KEY-----\ntest\n-----END RSA PRIVATE KEY-----',
        passphrase: 'keypass',
      );

      final connector = SSHConnector(host, keyData: keyData);

      expect(connector.record, equals(host));
      expect(connector.keyData, equals(keyData));
      expect(connector.keyData!.content, contains('BEGIN RSA'));
      expect(connector.keyData!.passphrase, equals('keypass'));
    });
  });
}
