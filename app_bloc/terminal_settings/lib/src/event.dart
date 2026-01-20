part of 'bloc.dart';

@immutable
sealed class TerminalSettingsEvent {}

/// Load terminal settings from storage.
class TerminalSettingsLoad extends TerminalSettingsEvent {}

/// Update or add an environment variable.
class TerminalSettingsUpdateEnvVar extends TerminalSettingsEvent {
  final String key;
  final String value;

  TerminalSettingsUpdateEnvVar({required this.key, required this.value});
}

/// Remove an environment variable.
class TerminalSettingsRemoveEnvVar extends TerminalSettingsEvent {
  final String key;

  TerminalSettingsRemoveEnvVar({required this.key});
}

/// Clear all custom environment variables.
class TerminalSettingsClearEnvVars extends TerminalSettingsEvent {}

/// Update the maximum number of open shells.
class TerminalSettingsUpdateMaxOpenShells extends TerminalSettingsEvent {
  final int maxOpenShells;

  TerminalSettingsUpdateMaxOpenShells({required this.maxOpenShells});
}

/// Update the terminal font size.
class TerminalSettingsUpdateFontSize extends TerminalSettingsEvent {
  final double fontSize;

  TerminalSettingsUpdateFontSize({required this.fontSize});
}

/// Update the terminal font family.
class TerminalSettingsUpdateFontFamily extends TerminalSettingsEvent {
  final String fontFamily;

  TerminalSettingsUpdateFontFamily({required this.fontFamily});
}
