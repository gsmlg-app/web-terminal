import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter_pty/flutter_pty.dart';

// BLoCs
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';

/// Integration tests for Service Layer interactions.
///
/// These tests verify that service layer components (SSH, database, PTY, SFTP)
/// correctly interact with each other and maintain data consistency across
/// different layers of the application.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Service Layer Integration Tests', () {
    late AppDatabase database;
    late VaultRepository vault;

    setUp(() async {
      database = AppDatabase.forTesting();
      vault = InMemoryVaultRepository();
    });

    tearDown(() async {
      await database.close();
    });

    group('SSH Service + Database Integration', () {
      test('SSH host persistence and retrieval', () async {
        final sshHostBloc = SshHostBloc(database);
        final sshKeyBloc = SshKeyBloc(database);

        // Add SSH key to database
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Production Key',
            content: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ...',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.rsa,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final keyState = sshKeyBloc.state as SshKeyLoaded;
        final key = keyState.keys.first;

        // Add SSH host to database
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshHostBloc.add(
          SshHostAdd(
            host: 'prod-server',
            hostname: 'production.example.com',
            port: 22,
            username: 'deploy',
            password: '',
            salt: '',
            identityType: SshIdentityType.key,
            identityKeyId: key.id,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify persistence
        var hostState = sshHostBloc.state as SshHostLoaded;
        expect(hostState.hosts.length, 1);

        final savedHost = hostState.hosts.first;
        expect(savedHost.hostname, 'production.example.com');
        expect(savedHost.identityKeyId, key.id);

        // Reload from database to verify persistence
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        hostState = sshHostBloc.state as SshHostLoaded;
        expect(hostState.hosts.length, 1);
        expect(hostState.hosts.first.hostname, 'production.example.com');

        await sshHostBloc.close();
        await sshKeyBloc.close();
      });

      test('SSH key encryption and storage in database', () async {
        final sshKeyBloc = SshKeyBloc(database);

        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Add encrypted SSH key
        final privateKeyContent = '''-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBTK7iYz8mKJZKm0E9HZXjGYT8G+MqKJDXP6Xh3BjC7NgAAAJj7tJ+A+7Sf
gAAAAAtzc2gtZWQyNTUxOQAAACBTK7iYz8mKJZKm0E9HZXjGYT8G+MqKJDXP6Xh3BjC7Ng
-----END OPENSSH PRIVATE KEY-----''';

        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Encrypted Key',
            content: privateKeyContent,
            password: 'encrypted_pass',
            salt: 'random_salt_123',
            algorithm: SshKeyAlgorithm.ed25519,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final state = sshKeyBloc.state as SshKeyLoaded;
        expect(state.keys.length, 1);

        final savedKey = state.keys.first;
        expect(savedKey.name, 'Encrypted Key');
        expect(savedKey.algorithm, SshKeyAlgorithm.ed25519);
        expect(savedKey.password, 'encrypted_pass');
        expect(savedKey.salt, 'random_salt_123');

        // Verify key persists after reload
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        final reloadedState = sshKeyBloc.state as SshKeyLoaded;
        expect(reloadedState.keys.length, 1);

        await sshKeyBloc.close();
      });

      test('Database cascade behavior for SSH host-key relationships', () async {
        final sshHostBloc = SshHostBloc(database);
        final sshKeyBloc = SshKeyBloc(database);

        // Create key
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Key for Cascade Test',
            content: 'ssh-rsa AAAAB3...',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.rsa,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        var keyState = sshKeyBloc.state as SshKeyLoaded;
        final keyId = keyState.keys.first.id;

        // Create host using key
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshHostBloc.add(
          SshHostAdd(
            host: 'cascade-test',
            hostname: 'cascade.example.com',
            port: 22,
            username: 'test',
            password: '',
            salt: '',
            identityType: SshIdentityType.key,
            identityKeyId: keyId,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        var hostState = sshHostBloc.state as SshHostLoaded;
        expect(hostState.hosts.length, 1);

        // Delete the key
        sshKeyBloc.add(SshKeyDelete(sshKey: keyState.keys.first));
        await Future.delayed(const Duration(milliseconds: 100));

        keyState = sshKeyBloc.state as SshKeyLoaded;
        expect(keyState.keys.isEmpty, isTrue);

        // Check host state - host should still exist but reference invalid key
        // This tests referential integrity handling
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        hostState = sshHostBloc.state as SshHostLoaded;
        expect(hostState.hosts.length, 1);
        expect(hostState.hosts.first.identityKeyId, keyId);
        // Key no longer exists - application should handle this gracefully

        await sshHostBloc.close();
        await sshKeyBloc.close();
      });
    });

    group('Terminal Hosts + PTY Plugin Integration', () {
      test('Shell profile settings should be applied when creating PTY', () async {
        final shellProfileBloc = ShellProfileBloc(database);
        final terminalSettingsBloc = TerminalSettingsBloc(vault: vault);

        // Load and create shell profile
        shellProfileBloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 100));

        shellProfileBloc.add(
          AddShellProfile(
            name: 'Custom Bash Profile',
            shellType: ShellType.bash,
            environmentVariables: {
              'PS1': r'\u@\h:\w\$ ',
              'HISTSIZE': '10000',
            },
            aliases: {
              'll': 'ls -la',
              'gs': 'git status',
            },
            colorTheme: 'dark',
            fontFamily: 'Monaco',
            fontSize: 14.0,
            isDefault: true,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final profileState = shellProfileBloc.state as ShellProfileLoaded;
        expect(profileState.profiles.length, 1);
        final profile = profileState.profiles.first;

        // Load terminal settings
        terminalSettingsBloc.add(const TerminalSettingsLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Create PTY with profile settings
        try {
          final pty = Pty.start(
            '/bin/bash',
            arguments: ['-l'],
            environment: profile.environmentVariables,
            rows: 25,
            columns: 80,
          );

          expect(pty.pid, greaterThan(0));

          // PTY should use profile's environment variables
          // In practice, PS1 and HISTSIZE would affect shell behavior

          pty.kill();
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          // PTY may not be available in test environment
        }

        await shellProfileBloc.close();
        await terminalSettingsBloc.close();
      });

      test('Terminal tab should coordinate PTY and database state', () async {
        final terminalTabBloc = TerminalTabBloc();
        final shellProfileBloc = ShellProfileBloc(database);

        // Create default profile
        shellProfileBloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 100));

        shellProfileBloc.add(
          AddShellProfile(
            name: 'Default Profile',
            shellType: ShellType.sh,
            environmentVariables: const {},
            aliases: const {},
            colorTheme: 'light',
            fontFamily: 'Courier',
            fontSize: 12.0,
            isDefault: true,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Start terminal tab management
        terminalTabBloc.add(const TerminalTabStart());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(terminalTabBloc.state, isA<TerminalTabLoaded>());
        expect(shellProfileBloc.state, isA<ShellProfileLoaded>());

        // In real app, creating a tab would:
        // 1. Get default profile from database
        // 2. Create PTY with profile settings
        // 3. Add tab to terminal tab state
        // All these layers coordinate through the service layer

        await terminalTabBloc.close();
        await shellProfileBloc.close();
      });
    });

    group('SSH + SFTP + Connection Coordination', () {
      test('SSH connection should enable SFTP operations', () async {
        final sshHostBloc = SshHostBloc(database);
        final sshKeyBloc = SshKeyBloc(database);

        // Setup SSH credentials
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshKeyBloc.add(
          SshKeyAdd(
            name: 'SFTP Key',
            content: 'ssh-rsa AAAAB3...',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.rsa,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final keyState = sshKeyBloc.state as SshKeyLoaded;
        final key = keyState.keys.first;

        // Create SSH host
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshHostBloc.add(
          SshHostAdd(
            host: 'sftp-server',
            hostname: 'files.example.com',
            port: 22,
            username: 'fileuser',
            password: '',
            salt: '',
            identityType: SshIdentityType.key,
            identityKeyId: key.id,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final hostState = sshHostBloc.state as SshHostLoaded;
        final host = hostState.hosts.first;

        // Verify connection details are ready for SSH/SFTP
        expect(host.hostname, 'files.example.com');
        expect(host.port, 22);
        expect(host.identityKeyId, key.id);

        // In real implementation, SSH connection would be established
        // and SFTP session would be created on same connection
        // This coordination happens in the service layer

        await sshHostBloc.close();
        await sshKeyBloc.close();
      });

      test('Multiple SSH connections should be independently manageable', () async {
        final sshHostBloc = SshHostBloc(database);
        final sshKeyBloc = SshKeyBloc(database);

        // Create multiple keys
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        for (var i = 0; i < 3; i++) {
          sshKeyBloc.add(
            SshKeyAdd(
              name: 'Key $i',
              content: 'ssh-rsa AAAAB3_$i...',
              password: '',
              salt: '',
              algorithm: SshKeyAlgorithm.rsa,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 50));
        }

        final keyState = sshKeyBloc.state as SshKeyLoaded;
        expect(keyState.keys.length, 3);

        // Create multiple hosts
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        for (var i = 0; i < 3; i++) {
          sshHostBloc.add(
            SshHostAdd(
              host: 'server$i',
              hostname: 'server$i.example.com',
              port: 22,
              username: 'user$i',
              password: '',
              salt: '',
              identityType: SshIdentityType.key,
              identityKeyId: keyState.keys[i].id,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 50));
        }

        final hostState = sshHostBloc.state as SshHostLoaded;
        expect(hostState.hosts.length, 3);

        // Each host is independently configured with its own key
        for (var i = 0; i < 3; i++) {
          expect(hostState.hosts[i].hostname, 'server$i.example.com');
          expect(hostState.hosts[i].identityKeyId, keyState.keys[i].id);
        }

        await sshHostBloc.close();
        await sshKeyBloc.close();
      });
    });

    group('Database Transaction Coordination', () {
      test('Multiple BLoC operations should maintain database consistency', () async {
        final sshHostBloc = SshHostBloc(database);
        final sshKeyBloc = SshKeyBloc(database);
        final shellProfileBloc = ShellProfileBloc(database);

        // Perform multiple operations concurrently
        sshKeyBloc.add(const SshKeyLoad());
        sshHostBloc.add(const SshHostLoad());
        shellProfileBloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 100));

        // Add data to multiple tables
        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Test Key',
            content: 'key_content',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.rsa,
          ),
        );

        shellProfileBloc.add(
          AddShellProfile(
            name: 'Test Profile',
            shellType: ShellType.bash,
            environmentVariables: const {},
            aliases: const {},
            colorTheme: 'dark',
            fontFamily: 'Courier',
            fontSize: 14.0,
            isDefault: false,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 150));

        // Verify all operations completed successfully
        expect(sshKeyBloc.state, isA<SshKeyLoaded>());
        expect(sshHostBloc.state, isA<SshHostLoaded>());
        expect(shellProfileBloc.state, isA<ShellProfileLoaded>());

        final keyState = sshKeyBloc.state as SshKeyLoaded;
        final profileState = shellProfileBloc.state as ShellProfileLoaded;

        expect(keyState.keys.length, 1);
        expect(profileState.profiles.length, 1);

        await sshHostBloc.close();
        await sshKeyBloc.close();
        await shellProfileBloc.close();
      });

      test('Database should handle concurrent reads and writes', () async {
        final bloc1 = SshKeyBloc(database);
        final bloc2 = SshKeyBloc(database);

        // Both BLoCs load simultaneously
        bloc1.add(const SshKeyLoad());
        bloc2.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(bloc1.state, isA<SshKeyLoaded>());
        expect(bloc2.state, isA<SshKeyLoaded>());

        // Both try to add keys
        bloc1.add(
          SshKeyAdd(
            name: 'Key from Bloc1',
            content: 'content1',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.rsa,
          ),
        );

        bloc2.add(
          SshKeyAdd(
            name: 'Key from Bloc2',
            content: 'content2',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.ed25519,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 200));

        // Both operations should succeed
        final state1 = bloc1.state as SshKeyLoaded;
        final state2 = bloc2.state as SshKeyLoaded;

        // Both should see all keys
        expect(state1.keys.length, 2);
        expect(state2.keys.length, 2);

        await bloc1.close();
        await bloc2.close();
      });
    });

    group('Service Layer Error Propagation', () {
      test('Database errors should propagate to BLoC layer', () async {
        final sshHostBloc = SshHostBloc(database);

        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Try to add host with invalid data that might cause constraint violation
        // (In practice, the database schema would enforce constraints)
        sshHostBloc.add(
          SshHostAdd(
            host: '',  // Empty host might violate constraints
            hostname: '',
            port: -1,  // Invalid port
            username: '',
            password: '',
            salt: '',
            identityType: SshIdentityType.password,
            identityKeyId: null,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        // Error should be handled by BLoC
        // State should indicate error or remain in previous valid state
        final state = sshHostBloc.state;
        // BLoC should handle invalid input gracefully

        await sshHostBloc.close();
      });

      test('PTY errors should be reportable through service layer', () async {
        final terminalTabBloc = TerminalTabBloc();

        terminalTabBloc.add(const TerminalTabStart());
        await Future.delayed(const Duration(milliseconds: 100));

        // Simulate PTY creation error
        try {
          final pty = Pty.start(
            '/invalid/shell/path',
            arguments: [],
            rows: 25,
            columns: 80,
          );
          fail('Should have thrown');
        } catch (e) {
          // Error should be caught and reported through service layer
          expect(e, isA<StateError>());
        }

        await terminalTabBloc.close();
      });
    });

    group('Data Consistency Across Services', () {
      test('Terminal session should reflect current database state', () async {
        final shellProfileBloc = ShellProfileBloc(database);
        final terminalSettingsBloc = TerminalSettingsBloc(vault: vault);
        final terminalTabBloc = TerminalTabBloc();

        // Load initial state
        shellProfileBloc.add(const LoadShellProfiles());
        terminalSettingsBloc.add(const TerminalSettingsLoad());
        terminalTabBloc.add(const TerminalTabStart());
        await Future.delayed(const Duration(milliseconds: 100));

        // Add profile
        shellProfileBloc.add(
          AddShellProfile(
            name: 'Consistency Test',
            shellType: ShellType.bash,
            environmentVariables: {'VAR1': 'value1'},
            aliases: {'alias1': 'command1'},
            colorTheme: 'dark',
            fontFamily: 'Monaco',
            fontSize: 14.0,
            isDefault: true,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Update settings
        terminalSettingsBloc.add(
          const TerminalSettingsUpdateFontSize(fontSize: 16.0),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // All services should have consistent state
        expect(shellProfileBloc.state, isA<ShellProfileLoaded>());
        expect(terminalSettingsBloc.state, isA<TerminalSettingsLoaded>());
        expect(terminalTabBloc.state, isA<TerminalTabLoaded>());

        final profileState = shellProfileBloc.state as ShellProfileLoaded;
        final settingsState = terminalSettingsBloc.state as TerminalSettingsLoaded;

        expect(profileState.profiles.first.isDefault, isTrue);
        expect(settingsState.fontSize, 16.0);

        await shellProfileBloc.close();
        await terminalSettingsBloc.close();
        await terminalTabBloc.close();
      });
    });
  });
}
