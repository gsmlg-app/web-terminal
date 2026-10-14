import 'package:app_database/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Database CRUD API Tests', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting();
    });

    tearDown(() async {
      await db.close();
    });

    group('SSH Keys CRUD Operations', () {
      test('CREATE: insert SSH key with all fields', () async {
        final now = DateTime.now();
        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('Production Key'),
                content: const Value(
                    '-----BEGIN RSA PRIVATE KEY-----\ntest\n-----END RSA PRIVATE KEY-----'),
                password: const Value('keypass123'),
                salt: const Value('salt_value'),
                algorithm: Value(SshKeyAlgorithm.rsa.value),
                createdAt: Value(now),
              ),
            );

        expect(id, greaterThan(0));

        final key = await (db.select(db.sshKeys)..where((t) => t.id.equals(id)))
            .getSingle();

        expect(key.name, 'Production Key');
        expect(key.content, contains('RSA PRIVATE KEY'));
        expect(key.password, 'keypass123');
        expect(key.salt, 'salt_value');
        expect(key.algorithm, SshKeyAlgorithm.rsa.value);
        expect(key.createdAt, isNotNull);
      });

      test('CREATE: insert SSH key with minimal fields', () async {
        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(),
            );

        expect(id, greaterThan(0));

        final key = await (db.select(db.sshKeys)..where((t) => t.id.equals(id)))
            .getSingle();

        expect(key.name, isNull);
        expect(key.content, isNull);
        expect(key.algorithm, isNull);
      });

      test('CREATE: insert multiple SSH keys', () async {
        final ids = <int>[];
        for (var i = 0; i < 5; i++) {
          final id = await db.into(db.sshKeys).insert(
                SshKeysCompanion.insert(
                  name: Value('Key $i'),
                  algorithm: Value(SshKeyAlgorithm.ed25519.value),
                ),
              );
          ids.add(id);
        }

        expect(ids.length, 5);
        expect(ids.toSet().length, 5); // All unique IDs

        final keys = await db.select(db.sshKeys).get();
        expect(keys.length, 5);
      });

      test('READ: get SSH key by ID', () async {
        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('Test Key'),
                content: const Value('key_content'),
              ),
            );

        final key = await (db.select(db.sshKeys)..where((t) => t.id.equals(id)))
            .getSingleOrNull();

        expect(key, isNotNull);
        expect(key?.id, id);
        expect(key?.name, 'Test Key');
      });

      test('READ: get non-existent SSH key returns null', () async {
        final key = await (db.select(db.sshKeys)
              ..where((t) => t.id.equals(99999)))
            .getSingleOrNull();

        expect(key, isNull);
      });

      test('READ: list all SSH keys', () async {
        await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: const Value('Key 1')),
            );
        await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: const Value('Key 2')),
            );
        await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: const Value('Key 3')),
            );

        final keys = await db.select(db.sshKeys).get();

        expect(keys.length, 3);
        expect(keys.map((k) => k.name).toList(), ['Key 1', 'Key 2', 'Key 3']);
      });

      test('READ: filter SSH keys by algorithm', () async {
        await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('RSA Key'),
                algorithm: Value(SshKeyAlgorithm.rsa.value),
              ),
            );
        await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('ED25519 Key'),
                algorithm: Value(SshKeyAlgorithm.ed25519.value),
              ),
            );

        final rsaKeys = await (db.select(db.sshKeys)
              ..where((t) => t.algorithm.equals(SshKeyAlgorithm.rsa.value)))
            .get();

        expect(rsaKeys.length, 1);
        expect(rsaKeys.first.name, 'RSA Key');
      });

      test('UPDATE: modify SSH key name', () async {
        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: const Value('Old Name')),
            );

        await (db.update(db.sshKeys)..where((t) => t.id.equals(id)))
            .write(const SshKeysCompanion(name: Value('New Name')));

        final key = await (db.select(db.sshKeys)..where((t) => t.id.equals(id)))
            .getSingle();

        expect(key.name, 'New Name');
      });

      test('UPDATE: modify multiple fields', () async {
        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('Original'),
                algorithm: Value(SshKeyAlgorithm.rsa.value),
              ),
            );

        await (db.update(db.sshKeys)..where((t) => t.id.equals(id))).write(
          SshKeysCompanion(
            name: const Value('Updated'),
            algorithm: Value(SshKeyAlgorithm.ed25519.value),
            content: const Value('new_content'),
          ),
        );

        final key = await (db.select(db.sshKeys)..where((t) => t.id.equals(id)))
            .getSingle();

        expect(key.name, 'Updated');
        expect(key.algorithm, SshKeyAlgorithm.ed25519.value);
        expect(key.content, 'new_content');
      });

      test('DELETE: remove SSH key by ID', () async {
        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: const Value('To Delete')),
            );

        final deleteCount =
            await (db.delete(db.sshKeys)..where((t) => t.id.equals(id))).go();

        expect(deleteCount, 1);

        final key = await (db.select(db.sshKeys)..where((t) => t.id.equals(id)))
            .getSingleOrNull();

        expect(key, isNull);
      });

      test('DELETE: remove non-existent key returns 0', () async {
        final deleteCount = await (db.delete(db.sshKeys)
              ..where((t) => t.id.equals(99999)))
            .go();

        expect(deleteCount, 0);
      });

      test('DELETE: remove all SSH keys', () async {
        await db.into(db.sshKeys).insert(SshKeysCompanion.insert());
        await db.into(db.sshKeys).insert(SshKeysCompanion.insert());
        await db.into(db.sshKeys).insert(SshKeysCompanion.insert());

        final deleteCount = await db.delete(db.sshKeys).go();

        expect(deleteCount, 3);

        final keys = await db.select(db.sshKeys).get();
        expect(keys, isEmpty);
      });
    });

    group('SSH Hosts CRUD Operations', () {
      test('CREATE: insert SSH host with password auth', () async {
        final now = DateTime.now();
        final id = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                host: const Value('Production Server'),
                hostname: const Value('prod.example.com'),
                port: const Value(22),
                username: const Value('admin'),
                password: const Value('encrypted_pass'),
                salt: const Value('salt_123'),
                identityType: Value(SshIdentityType.password.value),
                createdAt: Value(now),
              ),
            );

        expect(id, greaterThan(0));

        final host = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(host.host, 'Production Server');
        expect(host.hostname, 'prod.example.com');
        expect(host.port, 22);
        expect(host.username, 'admin');
        expect(host.identityType, SshIdentityType.password.value);
      });

      test('CREATE: insert SSH host with key auth', () async {
        final keyId = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: const Value('Server Key')),
            );

        final hostId = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                host: const Value('Key Server'),
                hostname: const Value('key.example.com'),
                port: const Value(2222),
                username: const Value('keyuser'),
                identityKeyId: Value(keyId),
                identityType: Value(SshIdentityType.key.value),
              ),
            );

        final host = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(hostId)))
            .getSingle();

        expect(host.identityKeyId, keyId);
        expect(host.identityType, SshIdentityType.key.value);
        expect(host.password, isNull);
      });

      test('CREATE: insert SSH host with minimal fields', () async {
        final id = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(),
            );

        expect(id, greaterThan(0));

        final host = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(host.host, isNull);
        expect(host.hostname, isNull);
        expect(host.port, isNull);
      });

      test('READ: get SSH host by ID', () async {
        final id = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                hostname: const Value('test.com'),
              ),
            );

        final host = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();

        expect(host, isNotNull);
        expect(host?.hostname, 'test.com');
      });

      test('READ: list all SSH hosts', () async {
        await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(hostname: const Value('host1.com')),
            );
        await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(hostname: const Value('host2.com')),
            );

        final hosts = await db.select(db.sshHosts).get();

        expect(hosts.length, 2);
      });

      test('READ: filter hosts by identity type', () async {
        await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                hostname: const Value('pass.com'),
                identityType: Value(SshIdentityType.password.value),
              ),
            );
        await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                hostname: const Value('key.com'),
                identityType: Value(SshIdentityType.key.value),
              ),
            );

        final passwordHosts = await (db.select(db.sshHosts)
              ..where(
                  (t) => t.identityType.equals(SshIdentityType.password.value)))
            .get();

        expect(passwordHosts.length, 1);
        expect(passwordHosts.first.hostname, 'pass.com');
      });

      test('UPDATE: modify SSH host hostname', () async {
        final id = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(hostname: const Value('old.com')),
            );

        await (db.update(db.sshHosts)..where((t) => t.id.equals(id)))
            .write(const SshHostsCompanion(hostname: Value('new.com')));

        final host = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(host.hostname, 'new.com');
      });

      test('UPDATE: change from password to key auth', () async {
        final hostId = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                hostname: const Value('server.com'),
                password: const Value('oldpass'),
                identityType: Value(SshIdentityType.password.value),
              ),
            );

        final keyId = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: const Value('New Key')),
            );

        await (db.update(db.sshHosts)..where((t) => t.id.equals(hostId))).write(
          SshHostsCompanion(
            password: const Value.absent(),
            identityKeyId: Value(keyId),
            identityType: Value(SshIdentityType.key.value),
          ),
        );

        final host = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(hostId)))
            .getSingle();

        expect(host.identityType, SshIdentityType.key.value);
        expect(host.identityKeyId, keyId);
      });

      test('DELETE: remove SSH host', () async {
        final id = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(hostname: const Value('delete.me')),
            );

        await (db.delete(db.sshHosts)..where((t) => t.id.equals(id))).go();

        final host = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();

        expect(host, isNull);
      });

      test('DELETE: removing key does not cascade to hosts', () async {
        final keyId = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: const Value('Key')),
            );

        await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                hostname: const Value('host.com'),
                identityKeyId: Value(keyId),
              ),
            );

        await (db.delete(db.sshKeys)..where((t) => t.id.equals(keyId))).go();

        final hosts = await (db.select(db.sshHosts)
              ..where((t) => t.identityKeyId.equals(keyId)))
            .get();

        expect(hosts.length, 1); // Host still exists with dangling reference
      });
    });

    group('Shell Profiles CRUD Operations', () {
      test('CREATE: insert profile with all fields', () async {
        final now = DateTime.now();
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Development Profile',
                shellType: Value(ShellType.zsh.value),
                environmentVariables: const Value(
                    '{"PATH":"/usr/local/bin","TERM":"xterm-256color"}'),
                aliases: const Value('{"ll":"ls -la","gs":"git status"}'),
                fontFamily: const Value('JetBrains Mono'),
                fontSize: const Value(14.0),
                colorTheme: const Value('dracula'),
                isDefault: const Value(true),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );

        expect(id, greaterThan(0));

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(profile.name, 'Development Profile');
        expect(profile.shellType, ShellType.zsh.value);
        expect(profile.environmentVariables, contains('PATH'));
        expect(profile.aliases, contains('ll'));
        expect(profile.fontFamily, 'JetBrains Mono');
        expect(profile.fontSize, 14.0);
        expect(profile.colorTheme, 'dracula');
        expect(profile.isDefault, true);
      });

      test('CREATE: insert profile with defaults', () async {
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Simple Profile'),
            );

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(profile.shellType, ShellType.sh.value);
        expect(profile.environmentVariables, '{}');
        expect(profile.aliases, '{}');
        expect(profile.fontFamily, 'monospace');
        expect(profile.fontSize, 14.0);
        expect(profile.colorTheme, 'default');
        expect(profile.isDefault, false);
      });

      test('CREATE: insert multiple profiles', () async {
        for (var i = 0; i < 3; i++) {
          await db.into(db.shellProfiles).insert(
                ShellProfilesCompanion.insert(name: 'Profile $i'),
              );
        }

        final profiles = await db.select(db.shellProfiles).get();
        expect(profiles.length, 3);
      });

      test('READ: get profile by ID', () async {
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Test Profile'),
            );

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();

        expect(profile, isNotNull);
        expect(profile?.name, 'Test Profile');
      });

      test('READ: list all profiles', () async {
        await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Profile 1'),
            );
        await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Profile 2'),
            );

        final profiles = await db.select(db.shellProfiles).get();
        expect(profiles.length, 2);
      });

      test('READ: filter by shell type', () async {
        await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Bash Profile',
                shellType: Value(ShellType.bash.value),
              ),
            );
        await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Zsh Profile',
                shellType: Value(ShellType.zsh.value),
              ),
            );

        final bashProfiles = await (db.select(db.shellProfiles)
              ..where((t) => t.shellType.equals(ShellType.bash.value)))
            .get();

        expect(bashProfiles.length, 1);
        expect(bashProfiles.first.name, 'Bash Profile');
      });

      test('READ: find default profile', () async {
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

        final defaultProfile = await (db.select(db.shellProfiles)
              ..where((t) => t.isDefault.equals(true)))
            .getSingleOrNull();

        expect(defaultProfile, isNotNull);
        expect(defaultProfile?.name, 'Default');
      });

      test('UPDATE: modify profile name', () async {
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Old Name'),
            );

        await (db.update(db.shellProfiles)..where((t) => t.id.equals(id)))
            .write(const ShellProfilesCompanion(name: Value('New Name')));

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(profile.name, 'New Name');
      });

      test('UPDATE: change shell type', () async {
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Profile',
                shellType: Value(ShellType.bash.value),
              ),
            );

        await (db.update(db.shellProfiles)..where((t) => t.id.equals(id)))
            .write(
                ShellProfilesCompanion(shellType: Value(ShellType.zsh.value)));

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(profile.shellType, ShellType.zsh.value);
      });

      test('UPDATE: modify environment variables', () async {
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'Profile'),
            );

        await (db.update(db.shellProfiles)..where((t) => t.id.equals(id)))
            .write(
          const ShellProfilesCompanion(
            environmentVariables: Value('{"NEW_VAR":"value"}'),
          ),
        );

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(profile.environmentVariables, contains('NEW_VAR'));
      });

      test('UPDATE: set as default profile', () async {
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Profile',
                isDefault: const Value(false),
              ),
            );

        await (db.update(db.shellProfiles)..where((t) => t.id.equals(id)))
            .write(const ShellProfilesCompanion(isDefault: Value(true)));

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(profile.isDefault, true);
      });

      test('DELETE: remove profile', () async {
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: 'To Delete'),
            );

        await (db.delete(db.shellProfiles)..where((t) => t.id.equals(id))).go();

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();

        expect(profile, isNull);
      });
    });

    group('Edge Cases and Complex Scenarios', () {
      test('handles very long text fields', () async {
        final longName = 'x' * 1000;
        final longContent = 'y' * 10000;

        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(
                name: Value(longName),
                content: Value(longContent),
              ),
            );

        final key = await (db.select(db.sshKeys)..where((t) => t.id.equals(id)))
            .getSingle();

        expect(key.name?.length, 1000);
        expect(key.content?.length, 10000);
      });

      test('handles special characters in text', () async {
        final specialText =
            'Test\nWith\tSpecial\r\nCharacters "quotes" \'quotes\' & < >';

        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(name: Value(specialText)),
            );

        final key = await (db.select(db.sshKeys)..where((t) => t.id.equals(id)))
            .getSingle();

        expect(key.name, specialText);
      });

      test('handles Unicode text', () async {
        final unicodeText = 'Hello 世界 🌍 Привет مرحبا';

        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(name: unicodeText),
            );

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(profile.name, unicodeText);
      });

      test('handles concurrent inserts', () async {
        final futures = <Future<int>>[];
        for (var i = 0; i < 10; i++) {
          futures.add(db.into(db.sshKeys).insert(
                SshKeysCompanion.insert(name: Value('Concurrent $i')),
              ));
        }

        final ids = await Future.wait(futures);
        expect(ids.length, 10);
        expect(ids.toSet().length, 10); // All unique
      });

      test('handles empty JSON in shell profile', () async {
        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Empty JSON',
                environmentVariables: const Value('{}'),
                aliases: const Value('{}'),
              ),
            );

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(profile.environmentVariables, '{}');
        expect(profile.aliases, '{}');
      });

      test('handles complex JSON in shell profile', () async {
        final complexEnv =
            '{"PATH":"/bin:/usr/bin","LANG":"en_US.UTF-8","CUSTOM":"value with spaces"}';
        final complexAliases =
            '{"ll":"ls -la","gs":"git status","deploy":"npm run build && npm run deploy"}';

        final id = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Complex',
                environmentVariables: Value(complexEnv),
                aliases: Value(complexAliases),
              ),
            );

        final profile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(id)))
            .getSingle();

        expect(profile.environmentVariables, contains('PATH'));
        expect(profile.aliases, contains('deploy'));
      });

      test('handles boundary font sizes', () async {
        final tiny = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Tiny Font',
                fontSize: const Value(1.0),
              ),
            );

        final huge = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Huge Font',
                fontSize: const Value(100.0),
              ),
            );

        final tinyProfile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(tiny)))
            .getSingle();
        final hugeProfile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(huge)))
            .getSingle();

        expect(tinyProfile.fontSize, 1.0);
        expect(hugeProfile.fontSize, 100.0);
      });

      test('handles boundary port numbers', () async {
        final minPort = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                hostname: const Value('min.com'),
                port: const Value(1),
              ),
            );

        final maxPort = await db.into(db.sshHosts).insert(
              SshHostsCompanion.insert(
                hostname: const Value('max.com'),
                port: const Value(65535),
              ),
            );

        final minHost = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(minPort)))
            .getSingle();
        final maxHost = await (db.select(db.sshHosts)
              ..where((t) => t.id.equals(maxPort)))
            .getSingle();

        expect(minHost.port, 1);
        expect(maxHost.port, 65535);
      });

      test('handles null timestamp fields', () async {
        final id = await db.into(db.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('No Timestamp'),
                createdAt: const Value.absent(),
              ),
            );

        final key = await (db.select(db.sshKeys)..where((t) => t.id.equals(id)))
            .getSingle();

        expect(key.createdAt, isNull);
      });

      test('handles past and future timestamps', () async {
        final past = DateTime(2000, 1, 1);
        final future = DateTime(2100, 12, 31);

        final pastId = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Past',
                createdAt: Value(past),
              ),
            );

        final futureId = await db.into(db.shellProfiles).insert(
              ShellProfilesCompanion.insert(
                name: 'Future',
                createdAt: Value(future),
              ),
            );

        final pastProfile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(pastId)))
            .getSingle();
        final futureProfile = await (db.select(db.shellProfiles)
              ..where((t) => t.id.equals(futureId)))
            .getSingle();

        expect(pastProfile.createdAt, past);
        expect(futureProfile.createdAt, future);
      });
    });
  });
}
