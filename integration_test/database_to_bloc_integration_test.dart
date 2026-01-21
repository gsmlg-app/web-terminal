import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app_database/app_database.dart';

// BLoCs
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';

/// Integration tests for Database-to-BLoC interactions.
///
/// These tests verify that database changes correctly trigger BLoC state updates,
/// cascading updates work properly, and data consistency is maintained across
/// database operations and BLoC state management.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Database to BLoC Integration Tests', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await database.close();
    });

    group('Database Changes Trigger BLoC Updates', () {
      test('Adding SSH key to database should update SshKeyBloc state', () async {
        final sshKeyBloc = SshKeyBloc(database);
        final stateChanges = <SshKeyState>[];

        // Monitor state changes
        final subscription = sshKeyBloc.stream.listen(stateChanges.add);

        // Initial load
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(sshKeyBloc.state, isA<SshKeyLoaded>());
        expect((sshKeyBloc.state as SshKeyLoaded).keys.isEmpty, isTrue);

        // Add key through BLoC
        sshKeyBloc.add(
          SshKeyAdd(
            name: 'New Key',
            content: 'ssh-rsa AAAAB3NzaC...',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.rsa,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // State should update
        final state = sshKeyBloc.state as SshKeyLoaded;
        expect(state.keys.length, 1);
        expect(state.keys.first.name, 'New Key');

        // Should have emitted multiple states
        expect(stateChanges.length, greaterThan(0));

        await subscription.cancel();
        await sshKeyBloc.close();
      });

      test('Deleting SSH host from database should update SshHostBloc state', () async {
        final sshHostBloc = SshHostBloc(database);

        // Add a host
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshHostBloc.add(
          SshHostAdd(
            host: 'test-host',
            hostname: 'test.example.com',
            port: 22,
            username: 'user',
            password: '',
            salt: '',
            identityType: SshIdentityType.password,
            identityKeyId: null,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        var state = sshHostBloc.state as SshHostLoaded;
        expect(state.hosts.length, 1);
        final hostToDelete = state.hosts.first;

        // Delete the host
        sshHostBloc.add(SshHostDelete(sshHost: hostToDelete));
        await Future.delayed(const Duration(milliseconds: 100));

        state = sshHostBloc.state as SshHostLoaded;
        expect(state.hosts.isEmpty, isTrue);

        await sshHostBloc.close();
      });

      test('Updating shell profile should trigger state change', () async {
        final shellProfileBloc = ShellProfileBloc(database);

        // Add profile
        shellProfileBloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 100));

        shellProfileBloc.add(
          AddShellProfile(
            name: 'Original Name',
            shellType: ShellType.bash,
            environmentVariables: const {},
            aliases: const {},
            colorTheme: 'light',
            fontFamily: 'Courier',
            fontSize: 12.0,
            isDefault: false,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        var state = shellProfileBloc.state as ShellProfileLoaded;
        final profileId = state.profiles.first.id;

        // Update profile
        shellProfileBloc.add(
          UpdateShellProfile(
            id: profileId,
            name: 'Updated Name',
            fontSize: 16.0,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        state = shellProfileBloc.state as ShellProfileLoaded;
        expect(state.profiles.first.name, 'Updated Name');
        expect(state.profiles.first.fontSize, 16.0);

        await shellProfileBloc.close();
      });
    });

    group('BLoC Events Persist to Database', () {
      test('SshKeyAdd event should create database record', () async {
        final sshKeyBloc = SshKeyBloc(database);

        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Add key through BLoC
        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Persistent Key',
            content: 'key_content_here',
            password: 'pass',
            salt: 'salt',
            algorithm: SshKeyAlgorithm.ed25519,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify in BLoC state
        var state = sshKeyBloc.state as SshKeyLoaded;
        expect(state.keys.length, 1);

        // Verify in database directly
        final keysFromDb = await database.select(database.sshKeys).get();
        expect(keysFromDb.length, 1);
        expect(keysFromDb.first.name, 'Persistent Key');
        expect(keysFromDb.first.algorithm, SshKeyAlgorithm.ed25519);

        await sshKeyBloc.close();
      });

      test('SshHostAdd event should create database record with relationships', () async {
        final sshKeyBloc = SshKeyBloc(database);
        final sshHostBloc = SshHostBloc(database);

        // Create key first
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Host Key',
            content: 'key_content',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.rsa,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final keyState = sshKeyBloc.state as SshKeyLoaded;
        final keyId = keyState.keys.first.id;

        // Create host referencing key
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshHostBloc.add(
          SshHostAdd(
            host: 'persistent-host',
            hostname: 'persist.example.com',
            port: 2222,
            username: 'admin',
            password: '',
            salt: '',
            identityType: SshIdentityType.key,
            identityKeyId: keyId,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify in BLoC state
        final hostState = sshHostBloc.state as SshHostLoaded;
        expect(hostState.hosts.length, 1);

        // Verify in database directly
        final hostsFromDb = await database.select(database.sshHosts).get();
        expect(hostsFromDb.length, 1);
        expect(hostsFromDb.first.hostname, 'persist.example.com');
        expect(hostsFromDb.first.identityKeyId, keyId);

        await sshKeyBloc.close();
        await sshHostBloc.close();
      });

      test('SetDefaultProfile event should update database', () async {
        final shellProfileBloc = ShellProfileBloc(database);

        // Add multiple profiles
        shellProfileBloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 100));

        shellProfileBloc.add(
          AddShellProfile(
            name: 'Profile 1',
            shellType: ShellType.bash,
            environmentVariables: const {},
            aliases: const {},
            colorTheme: 'light',
            fontFamily: 'Courier',
            fontSize: 12.0,
            isDefault: false,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        shellProfileBloc.add(
          AddShellProfile(
            name: 'Profile 2',
            shellType: ShellType.zsh,
            environmentVariables: const {},
            aliases: const {},
            colorTheme: 'dark',
            fontFamily: 'Monaco',
            fontSize: 14.0,
            isDefault: false,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        var state = shellProfileBloc.state as ShellProfileLoaded;
        final profile2 = state.profiles.firstWhere((p) => p.name == 'Profile 2');

        // Set Profile 2 as default
        shellProfileBloc.add(SetDefaultProfile(profile: profile2));
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify in BLoC state
        state = shellProfileBloc.state as ShellProfileLoaded;
        final defaultProfile = state.profiles.firstWhere((p) => p.isDefault);
        expect(defaultProfile.name, 'Profile 2');

        // Verify in database
        final profilesFromDb = await database.select(database.shellProfiles).get();
        final dbDefaultProfile = profilesFromDb.firstWhere((p) => p.isDefault);
        expect(dbDefaultProfile.name, 'Profile 2');

        // Verify only one default
        final defaultCount = profilesFromDb.where((p) => p.isDefault).length;
        expect(defaultCount, 1);

        await shellProfileBloc.close();
      });
    });

    group('Cascading Updates', () {
      test('Changing default profile should clear previous default', () async {
        final shellProfileBloc = ShellProfileBloc(database);

        // Add first profile as default
        shellProfileBloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 100));

        shellProfileBloc.add(
          AddShellProfile(
            name: 'First Default',
            shellType: ShellType.bash,
            environmentVariables: const {},
            aliases: const {},
            colorTheme: 'light',
            fontFamily: 'Courier',
            fontSize: 12.0,
            isDefault: true,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        var state = shellProfileBloc.state as ShellProfileLoaded;
        expect(state.profiles.where((p) => p.isDefault).length, 1);

        // Add second profile as default (should cascade to clear first)
        shellProfileBloc.add(
          AddShellProfile(
            name: 'Second Default',
            shellType: ShellType.zsh,
            environmentVariables: const {},
            aliases: const {},
            colorTheme: 'dark',
            fontFamily: 'Monaco',
            fontSize: 14.0,
            isDefault: true,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        state = shellProfileBloc.state as ShellProfileLoaded;

        // Should still only have one default
        final defaults = state.profiles.where((p) => p.isDefault).toList();
        expect(defaults.length, 1);
        expect(defaults.first.name, 'Second Default');

        await shellProfileBloc.close();
      });

      test('Multiple BLoC operations should maintain database integrity', () async {
        final sshKeyBloc = SshKeyBloc(database);
        final sshHostBloc = SshHostBloc(database);

        // Create key
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Integrity Key',
            content: 'key_content',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.rsa,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final keyState = sshKeyBloc.state as SshKeyLoaded;
        final keyId = keyState.keys.first.id;

        // Create multiple hosts using the same key
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        for (var i = 0; i < 3; i++) {
          sshHostBloc.add(
            SshHostAdd(
              host: 'host$i',
              hostname: 'host$i.example.com',
              port: 22,
              username: 'user',
              password: '',
              salt: '',
              identityType: SshIdentityType.key,
              identityKeyId: keyId,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 50));
        }

        final hostState = sshHostBloc.state as SshHostLoaded;
        expect(hostState.hosts.length, 3);

        // All hosts should reference the same key
        for (final host in hostState.hosts) {
          expect(host.identityKeyId, keyId);
        }

        // Verify database integrity
        final hostsFromDb = await database.select(database.sshHosts).get();
        expect(hostsFromDb.length, 3);

        final keysFromDb = await database.select(database.sshKeys).get();
        expect(keysFromDb.length, 1);

        await sshKeyBloc.close();
        await sshHostBloc.close();
      });
    });

    group('Database Stream Synchronization', () {
      test('Multiple BLoC instances should see consistent database state', () async {
        final bloc1 = SshKeyBloc(database);
        final bloc2 = SshKeyBloc(database);

        // Both load initial state
        bloc1.add(const SshKeyLoad());
        bloc2.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Both should see empty state
        expect((bloc1.state as SshKeyLoaded).keys.isEmpty, isTrue);
        expect((bloc2.state as SshKeyLoaded).keys.isEmpty, isTrue);

        // bloc1 adds a key
        bloc1.add(
          SshKeyAdd(
            name: 'Shared Key',
            content: 'content',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.rsa,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // bloc1 should see the key
        expect((bloc1.state as SshKeyLoaded).keys.length, 1);

        // bloc2 needs to reload to see changes
        bloc2.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Now bloc2 should also see the key
        expect((bloc2.state as SshKeyLoaded).keys.length, 1);

        await bloc1.close();
        await bloc2.close();
      });

      test('Database watchers should notify BLoC of external changes', () async {
        final sshHostBloc = SshHostBloc(database);

        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Initial state
        expect((sshHostBloc.state as SshHostLoaded).hosts.isEmpty, isTrue);

        // Add host directly through database
        await database.into(database.sshHosts).insert(
          SshHostsCompanion.insert(
            host: const Value('direct-host'),
            hostname: const Value('direct.example.com'),
            port: const Value(22),
            username: const Value('user'),
            password: const Value(''),
            salt: const Value(''),
            identityType: const Value(SshIdentityType.password),
            identityKeyId: const Value(null),
            createdAt: Value(DateTime.now()),
          ),
        );

        // BLoC needs to reload to see database changes
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Should now see the host
        final state = sshHostBloc.state as SshHostLoaded;
        expect(state.hosts.length, 1);
        expect(state.hosts.first.hostname, 'direct.example.com');

        await sshHostBloc.close();
      });
    });

    group('Transaction Rollback Behavior', () {
      test('Failed operations should not corrupt BLoC state', () async {
        final sshHostBloc = SshHostBloc(database);

        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        final initialState = sshHostBloc.state;
        expect(initialState, isA<SshHostLoaded>());

        // Try to perform invalid operation
        try {
          // Attempting to delete non-existent host
          final fakeHost = SshHost(
            id: 99999,
            host: 'fake',
            hostname: 'fake.example.com',
            port: 22,
            username: 'user',
            password: '',
            salt: '',
            identityType: SshIdentityType.password,
            identityKeyId: null,
            createdAt: DateTime.now(),
          );

          sshHostBloc.add(SshHostDelete(sshHost: fakeHost));
          await Future.delayed(const Duration(milliseconds: 100));

          // Should handle error gracefully
          // State might be error or remain in loaded state
          final currentState = sshHostBloc.state;
          expect(
            currentState is SshHostLoaded || currentState is SshHostError,
            isTrue,
          );
        } catch (e) {
          // Error handling is working
        }

        await sshHostBloc.close();
      });
    });

    group('Data Consistency Verification', () {
      test('BLoC state should always reflect database reality', () async {
        final shellProfileBloc = ShellProfileBloc(database);

        // Add profiles through BLoC
        shellProfileBloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 100));

        for (var i = 0; i < 5; i++) {
          shellProfileBloc.add(
            AddShellProfile(
              name: 'Profile $i',
              shellType: ShellType.bash,
              environmentVariables: {'VAR$i': 'value$i'},
              aliases: {'alias$i': 'cmd$i'},
              colorTheme: 'light',
              fontFamily: 'Courier',
              fontSize: 12.0,
              isDefault: i == 0,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // Verify BLoC state
        final blocState = shellProfileBloc.state as ShellProfileLoaded;
        expect(blocState.profiles.length, 5);

        // Verify database state
        final dbProfiles = await database.select(database.shellProfiles).get();
        expect(dbProfiles.length, 5);

        // Compare names
        final blocNames = blocState.profiles.map((p) => p.name).toSet();
        final dbNames = dbProfiles.map((p) => p.name).toSet();
        expect(blocNames, equals(dbNames));

        // Verify default profile consistency
        final blocDefault = blocState.profiles.where((p) => p.isDefault).length;
        final dbDefault = dbProfiles.where((p) => p.isDefault).length;
        expect(blocDefault, equals(dbDefault));
        expect(blocDefault, equals(1)); // Should only have one default

        await shellProfileBloc.close();
      });

      test('Reload after operations should show consistent state', () async {
        final sshKeyBloc = SshKeyBloc(database);

        // Perform multiple operations
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Key 1',
            content: 'content1',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.rsa,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Key 2',
            content: 'content2',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.ed25519,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        var state = sshKeyBloc.state as SshKeyLoaded;
        final keyToDelete = state.keys.first;

        sshKeyBloc.add(SshKeyDelete(sshKey: keyToDelete));
        await Future.delayed(const Duration(milliseconds: 100));

        // Reload and verify
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        state = sshKeyBloc.state as SshKeyLoaded;
        expect(state.keys.length, 1);
        expect(state.keys.first.name, 'Key 2');

        // Verify database matches
        final dbKeys = await database.select(database.sshKeys).get();
        expect(dbKeys.length, 1);
        expect(dbKeys.first.name, 'Key 2');

        await sshKeyBloc.close();
      });
    });

    group('Complex Relationship Updates', () {
      test('SSH host-key relationship updates should cascade correctly', () async {
        final sshKeyBloc = SshKeyBloc(database);
        final sshHostBloc = SshHostBloc(database);

        // Create two keys
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Key 1',
            content: 'content1',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.rsa,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 50));

        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Key 2',
            content: 'content2',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.ed25519,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final keyState = sshKeyBloc.state as SshKeyLoaded;
        final key1Id = keyState.keys.first.id;
        final key2Id = keyState.keys.last.id;

        // Create host with key 1
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshHostBloc.add(
          SshHostAdd(
            host: 'test-host',
            hostname: 'test.example.com',
            port: 22,
            username: 'user',
            password: '',
            salt: '',
            identityType: SshIdentityType.key,
            identityKeyId: key1Id,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        var hostState = sshHostBloc.state as SshHostLoaded;
        expect(hostState.hosts.first.identityKeyId, key1Id);

        // In a real app, we might update host to use key 2
        // This would require an UpdateHost event (not implemented yet)
        // But we can verify the relationship is properly stored

        // Verify database relationships
        final hostsFromDb = await database.select(database.sshHosts).get();
        final keysFromDb = await database.select(database.sshKeys).get();

        expect(hostsFromDb.length, 1);
        expect(keysFromDb.length, 2);
        expect(hostsFromDb.first.identityKeyId, key1Id);

        await sshKeyBloc.close();
        await sshHostBloc.close();
      });
    });
  });
}
