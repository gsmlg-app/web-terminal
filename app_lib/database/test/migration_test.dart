import 'dart:io';

import 'package:app_database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final version in [1, 2, 3]) {
    test('upgrades v$version to v4 and preserves stored data', () async {
      final directory = await Directory.systemTemp.createTemp('db-migration-');
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/database.sqlite');
      final database = AppDatabase(NativeDatabase(file, setup: (sqlite) {
        sqlite.execute('''
          CREATE TABLE ssh_keys (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            name TEXT, content TEXT, password TEXT, salt TEXT,
            algorithm INTEGER, created_at INTEGER
          );
          CREATE TABLE ssh_hosts (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            host TEXT, hostname TEXT, port INTEGER, username TEXT,
            password TEXT, salt TEXT, identity_key_id INTEGER REFERENCES ssh_keys(id),
            identity_type INTEGER, created_at INTEGER
          );
          INSERT INTO ssh_keys (id, name, content, algorithm)
            VALUES (42, 'existing key', 'vault:key-reference', 4);
          INSERT INTO ssh_hosts
            (id, hostname, username, identity_key_id, identity_type, password)
            VALUES (7, 'example.test', 'tester', 42, 2, 'vault:host-reference');
        ''');
        if (version >= 2) {
          sqlite.execute('''
            CREATE TABLE shell_profiles (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              shell_type INTEGER NOT NULL DEFAULT 1,
              environment_variables TEXT NOT NULL DEFAULT '{}',
              aliases TEXT NOT NULL DEFAULT '{}',
              font_family TEXT NOT NULL DEFAULT 'monospace',
              font_size REAL NOT NULL DEFAULT 14.0,
              color_theme TEXT NOT NULL DEFAULT 'default',
              is_default INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER, updated_at INTEGER
            );
            INSERT INTO shell_profiles
              (id, name, shell_type, environment_variables, aliases, font_size)
              VALUES (9, 'existing profile', 2, '{"TEST":"kept"}',
                '{"ll":"ls -la"}', 17.0);
          ''');
        }
        if (version >= 3) {
          sqlite.execute('''
            ALTER TABLE shell_profiles ADD COLUMN working_directory TEXT NOT NULL DEFAULT '';
            ALTER TABLE shell_profiles ADD COLUMN startup_command TEXT NOT NULL DEFAULT '';
            ALTER TABLE shell_profiles ADD COLUMN cursor_style INTEGER NOT NULL DEFAULT 0;
            ALTER TABLE shell_profiles ADD COLUMN scrollback_lines INTEGER NOT NULL DEFAULT 10000;
            UPDATE shell_profiles SET working_directory = '/tmp',
              startup_command = 'echo restored', cursor_style = 2,
              scrollback_lines = 1234 WHERE id = 9;
          ''');
        }
        sqlite.execute('PRAGMA user_version = $version');
      }));

      Future<void> verify(AppDatabase database) async {
        final hosts = await database.select(database.sshHosts).get();
        final keys = await database.select(database.sshKeys).get();
        expect(hosts.single.id, 7);
        expect(hosts.single.identityKeyId, keys.single.id);
        expect(hosts.single.password, 'vault:host-reference');
        expect(keys.single.content, 'vault:key-reference');
        final profiles = await database.select(database.shellProfiles).get();
        if (version == 1) {
          expect(profiles, isEmpty);
        } else {
          final profile = profiles.single;
          expect(profile.id, 9);
          expect(profile.name, 'existing profile');
          expect(profile.shellType, 2);
          expect(profile.environmentVariables, '{"TEST":"kept"}');
          expect(profile.aliases, '{"ll":"ls -la"}');
          expect(profile.fontSize, 17.0);
          expect(profile.inheritCurrentState, isFalse);
          expect(profile.workingDirectory, version == 3 ? '/tmp' : '');
          expect(profile.startupCommand, version == 3 ? 'echo restored' : '');
          expect(profile.cursorStyle, version == 3 ? 2 : 0);
          expect(profile.scrollbackLines, version == 3 ? 1234 : 10000);
        }
        final schema =
            await database.customSelect('PRAGMA user_version').getSingle();
        expect(schema.read<int>('user_version'), 4);
        expect(await database.customSelect('PRAGMA foreign_key_check').get(),
            isEmpty);
      }

      try {
        await verify(database);
      } finally {
        await database.close();
      }
      final reopened = AppDatabase(NativeDatabase(file));
      try {
        await verify(reopened);
      } finally {
        await reopened.close();
      }
    });
  }
}
