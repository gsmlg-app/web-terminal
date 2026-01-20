import 'package:app_database/app_database.dart';
import 'package:app_database/src/type_converter.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringListConverter', () {
    const converter = StringListConverter();

    test('toSql converts empty list to JSON', () {
      expect(converter.toSql([]), '[]');
    });

    test('toSql converts single item list to JSON', () {
      expect(converter.toSql(['item']), '["item"]');
    });

    test('toSql converts multiple items to JSON', () {
      expect(converter.toSql(['a', 'b', 'c']), '["a","b","c"]');
    });

    test('toSql handles special characters', () {
      final result = converter.toSql(['hello world', 'test "quoted"']);
      expect(result, contains('hello world'));
    });

    test('fromSql parses empty list', () {
      expect(converter.fromSql('[]'), <String>[]);
    });

    test('fromSql parses single item', () {
      expect(converter.fromSql('["item"]'), ['item']);
    });

    test('fromSql parses multiple items', () {
      expect(converter.fromSql('["a","b","c"]'), ['a', 'b', 'c']);
    });

    test('fromSql converts non-string items to strings', () {
      // JSON numbers get converted to strings
      expect(converter.fromSql('[1, 2, 3]'), ['1', '2', '3']);
    });

    test('roundtrip preserves data', () {
      final original = ['test1', 'test2', 'test3'];
      final json = converter.toSql(original);
      final restored = converter.fromSql(json);
      expect(restored, original);
    });
  });

  group('SshKeyAlgorithm', () {
    test('has correct values', () {
      expect(SshKeyAlgorithm.rsa.value, 1);
      expect(SshKeyAlgorithm.dsa.value, 2);
      expect(SshKeyAlgorithm.ecdsa.value, 3);
      expect(SshKeyAlgorithm.ed25519.value, 4);
    });

    test('values list is complete', () {
      expect(SshKeyAlgorithm.values.length, 4);
    });

    test('fromValue returns correct algorithm', () {
      expect(SshKeyAlgorithm.fromValue(1), SshKeyAlgorithm.rsa);
      expect(SshKeyAlgorithm.fromValue(2), SshKeyAlgorithm.dsa);
      expect(SshKeyAlgorithm.fromValue(3), SshKeyAlgorithm.ecdsa);
      expect(SshKeyAlgorithm.fromValue(4), SshKeyAlgorithm.ed25519);
    });

    test('fromValue returns null for null input', () {
      expect(SshKeyAlgorithm.fromValue(null), isNull);
    });

    test('fromValue returns null for invalid value', () {
      expect(SshKeyAlgorithm.fromValue(0), isNull);
      expect(SshKeyAlgorithm.fromValue(99), isNull);
      expect(SshKeyAlgorithm.fromValue(-1), isNull);
    });
  });

  group('SshIdentityType', () {
    test('has correct values', () {
      expect(SshIdentityType.password.value, 1);
      expect(SshIdentityType.key.value, 2);
    });

    test('values list is complete', () {
      expect(SshIdentityType.values.length, 2);
    });

    test('fromValue returns correct type', () {
      expect(SshIdentityType.fromValue(1), SshIdentityType.password);
      expect(SshIdentityType.fromValue(2), SshIdentityType.key);
    });

    test('fromValue returns null for null input', () {
      expect(SshIdentityType.fromValue(null), isNull);
    });

    test('fromValue returns null for invalid value', () {
      expect(SshIdentityType.fromValue(0), isNull);
      expect(SshIdentityType.fromValue(99), isNull);
      expect(SshIdentityType.fromValue(-1), isNull);
    });
  });

  group('ShellType', () {
    test('has correct values', () {
      expect(ShellType.sh.value, 1);
      expect(ShellType.bash.value, 2);
      expect(ShellType.zsh.value, 3);
      expect(ShellType.fish.value, 4);
    });

    test('values list is complete', () {
      expect(ShellType.values.length, 4);
    });

    test('fromValue returns correct type', () {
      expect(ShellType.fromValue(1), ShellType.sh);
      expect(ShellType.fromValue(2), ShellType.bash);
      expect(ShellType.fromValue(3), ShellType.zsh);
      expect(ShellType.fromValue(4), ShellType.fish);
    });

    test('fromValue returns null for null input', () {
      expect(ShellType.fromValue(null), isNull);
    });

    test('fromValue returns null for invalid value', () {
      expect(ShellType.fromValue(0), isNull);
      expect(ShellType.fromValue(99), isNull);
      expect(ShellType.fromValue(-1), isNull);
    });
  });

  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting();
    });

    tearDown(() async {
      await db.close();
    });

    test('creates in-memory database for testing', () {
      expect(db, isNotNull);
      expect(db.schemaVersion, 2);
    });

    group('SshKeys table', () {
      test('inserts SSH key', () async {
        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('Test Key'),
                content: const Value('-----BEGIN RSA PRIVATE KEY-----'),
                algorithm: const Value(1),
              ),
            );
        expect(id, greaterThan(0));
      });

      test('retrieves SSH key by id', () async {
        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('My Key'),
                content: const Value('key content'),
                algorithm: const Value(4),
              ),
            );

        final key = await (db.select(db.sshKeys)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(key.name, 'My Key');
        expect(key.content, 'key content');
        expect(key.algorithm, 4);
      });

      test('updates SSH key', () async {
        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('Original'),
              ),
            );

        await (db.update(db.sshKeys)..where((t) => t.id.equals(id)))
            .write(const SshKeysCompanion(name: Value('Updated')));

        final key = await (db.select(db.sshKeys)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(key.name, 'Updated');
      });

      test('deletes SSH key', () async {
        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('To Delete'),
              ),
            );

        await (db.delete(db.sshKeys)..where((t) => t.id.equals(id))).go();

        final keys = await (db.select(db.sshKeys)
              ..where((t) => t.id.equals(id)))
            .get();

        expect(keys, isEmpty);
      });

      test('lists all SSH keys', () async {
        await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: const Value('Key 1')),
            );
        await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: const Value('Key 2')),
            );

        final keys = await db.select(db.sshKeys).get();

        expect(keys.length, 2);
      });
    });

    group('SshHosts table', () {
      test('inserts SSH host', () async {
        final id = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                host: const Value('My Server'),
                hostname: const Value('example.com'),
                port: const Value(22),
                username: const Value('admin'),
                identityType: const Value(1),
              ),
            );
        expect(id, greaterThan(0));
      });

      test('retrieves SSH host by id', () async {
        final id = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                host: const Value('Test Server'),
                hostname: const Value('test.example.com'),
                port: const Value(2222),
                username: const Value('user'),
              ),
            );

        final host = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(host.host, 'Test Server');
        expect(host.hostname, 'test.example.com');
        expect(host.port, 2222);
        expect(host.username, 'user');
      });

      test('updates SSH host', () async {
        final id = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                hostname: const Value('old.host'),
              ),
            );

        await (db.update(db.sshHosts)..where((t) => t.id.equals(id)))
            .write(const SshHostsCompanion(hostname: Value('new.host')));

        final host = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(host.hostname, 'new.host');
      });

      test('deletes SSH host', () async {
        final id = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                hostname: const Value('delete.me'),
              ),
            );

        await (db.delete(db.sshHosts)..where((t) => t.id.equals(id))).go();

        final hosts = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(id)))
            .get();

        expect(hosts, isEmpty);
      });

      test('links SSH host to key via identityKeyId', () async {
        final keyId = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: const Value('Link Key')),
            );

        final hostId = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                hostname: const Value('linked.host'),
                identityKeyId: Value(keyId),
                identityType: const Value(2),
              ),
            );

        final host = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(hostId)))
            .getSingle();

        expect(host.identityKeyId, keyId);
        expect(host.identityType, 2);
      });
    });

    group('ShellProfiles table', () {
      test('inserts shell profile with defaults', () async {
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Default Profile'),
            );
        expect(id, greaterThan(0));

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        // Check default values
        expect(profile.shellType, 1); // sh
        expect(profile.environmentVariables, '{}');
        expect(profile.aliases, '{}');
        expect(profile.fontFamily, 'monospace');
        expect(profile.fontSize, 14.0);
        expect(profile.colorTheme, 'default');
        expect(profile.isDefault, false);
      });

      test('inserts shell profile with custom values', () async {
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Custom Profile',
                shellType: const Value(3), // zsh
                environmentVariables:
                    const Value('{"TERM":"xterm-256color"}'),
                aliases: const Value('{"ll":"ls -la"}'),
                fontFamily: const Value('JetBrains Mono'),
                fontSize: const Value(16.0),
                colorTheme: const Value('dark'),
                isDefault: const Value(true),
              ),
            );

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(profile.name, 'Custom Profile');
        expect(profile.shellType, 3);
        expect(profile.environmentVariables, '{"TERM":"xterm-256color"}');
        expect(profile.aliases, '{"ll":"ls -la"}');
        expect(profile.fontFamily, 'JetBrains Mono');
        expect(profile.fontSize, 16.0);
        expect(profile.colorTheme, 'dark');
        expect(profile.isDefault, true);
      });

      test('updates shell profile', () async {
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Original Name'),
            );

        await (db.update(db.shellProfiles)..where((t) => t.id.equals(id)))
            .write(const ShellProfilesCompanion(
              name: Value('Updated Name'),
              shellType: Value(2), // bash
            ));

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(profile.name, 'Updated Name');
        expect(profile.shellType, 2);
      });

      test('deletes shell profile', () async {
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'To Delete'),
            );

        await (db.delete(db.shellProfiles)..where((t) => t.id.equals(id)))
            .go();

        final profiles = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .get();

        expect(profiles, isEmpty);
      });

      test('queries default profile', () async {
        await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Non-default',
                isDefault: const Value(false),
              ),
            );
        await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Default',
                isDefault: const Value(true),
              ),
            );

        final defaultProfiles = await (db.select(db.shellProfiles)
              ..where((t) => t.isDefault.equals(true)))
            .get();

        expect(defaultProfiles.length, 1);
        expect(defaultProfiles.first.name, 'Default');
      });

      test('stores timestamps', () async {
        final now = DateTime.now();
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Timestamped',
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(profile.createdAt, isNotNull);
        expect(profile.updatedAt, isNotNull);
      });
    });

    group('Cross-table operations', () {
      test('cascade considerations: deleting key with linked host', () async {
        // Note: Current schema doesn't enforce cascade delete
        // This test documents current behavior
        final keyId = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: const Value('Linked Key')),
            );

        await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                hostname: const Value('uses.key'),
                identityKeyId: Value(keyId),
                identityType: const Value(2),
              ),
            );

        // Delete the key
        await (db.delete(db.sshKeys)..where((t) => t.id.equals(keyId))).go();

        // Host still exists with dangling reference
        final hosts = await (db.select(db.sshHosts)
              ..where((t) => t.identityKeyId.equals(keyId)))
            .get();

        // Current behavior: host remains with invalid key reference
        expect(hosts.length, 1);
      });
    });
  });
}
