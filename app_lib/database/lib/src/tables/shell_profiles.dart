import 'package:drift/drift.dart';

/// Available shell types for local shell profiles
enum ShellType {
  sh(1),
  bash(2),
  zsh(3),
  fish(4);

  const ShellType(this.value);
  final int value;

  static ShellType? fromValue(int? value) {
    if (value == null) return null;
    return ShellType.values.cast<ShellType?>().firstWhere(
          (e) => e?.value == value,
          orElse: () => null,
        );
  }
}

/// Table for storing shell profile configurations
@DataClassName('ShellProfile')
class ShellProfiles extends Table {
  /// Primary key - auto increment
  IntColumn get id => integer().autoIncrement()();

  /// Display name for the profile
  TextColumn get name => text()();

  /// Shell type (1=sh, 2=bash, 3=zsh, 4=fish)
  IntColumn get shellType => integer().withDefault(const Constant(1))();

  /// Environment variables as JSON string (key-value pairs)
  /// Example: {"TERM": "xterm-256color", "LANG": "en_US.UTF-8"}
  TextColumn get environmentVariables =>
      text().withDefault(const Constant('{}'))();

  /// Alias definitions as JSON string (name-command pairs)
  /// Example: {"ll": "ls -la", "gs": "git status"}
  TextColumn get aliases => text().withDefault(const Constant('{}'))();

  /// Font family for terminal display
  TextColumn get fontFamily =>
      text().withDefault(const Constant('monospace'))();

  /// Font size for terminal display (in logical pixels)
  RealColumn get fontSize => real().withDefault(const Constant(14.0))();

  /// Color theme name (references terminal theme)
  TextColumn get colorTheme => text().withDefault(const Constant('default'))();

  /// Whether this is the default profile for new sessions
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// Last update timestamp
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
