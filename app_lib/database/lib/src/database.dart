import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/shell_profiles.dart';
import 'tables/ssh_hosts.dart';
import 'tables/ssh_keys.dart';

export 'tables/shell_profiles.dart' show ShellType, CursorStyleType;
export 'tables/ssh_hosts.dart' show SshIdentityType;
export 'tables/ssh_keys.dart' show SshKeyAlgorithm;

part 'database.g.dart';

@DriftDatabase(tables: [SshKeys, SshHosts, ShellProfiles])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  // Add this factory for tests
  factory AppDatabase.forTesting() {
    return AppDatabase(NativeDatabase.memory());
  }

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add shell_profiles table in version 2
          await m.createTable(shellProfiles);
        }
        if (from >= 2 && from < 3) {
          // Add new shell profile columns in version 3
          await m.addColumn(shellProfiles, shellProfiles.workingDirectory);
          await m.addColumn(shellProfiles, shellProfiles.startupCommand);
          await m.addColumn(shellProfiles, shellProfiles.cursorStyle);
          await m.addColumn(shellProfiles, shellProfiles.scrollbackLines);
        }
        if (from >= 2 && from < 4) {
          // Add shell profile state inheritance option in version 4
          await m.addColumn(shellProfiles, shellProfiles.inheritCurrentState);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'web_terminal',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  }
}
