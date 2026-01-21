part of 'bloc.dart';

sealed class TerminalSettingsEvent extends Equatable {
  const TerminalSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load terminal settings from storage.
class TerminalSettingsLoad extends TerminalSettingsEvent {
  const TerminalSettingsLoad();
}

/// Update or add an environment variable.
class TerminalSettingsUpdateEnvVar extends TerminalSettingsEvent {
  final String key;
  final String value;

  const TerminalSettingsUpdateEnvVar({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

/// Remove an environment variable.
class TerminalSettingsRemoveEnvVar extends TerminalSettingsEvent {
  final String key;

  const TerminalSettingsRemoveEnvVar({required this.key});

  @override
  List<Object?> get props => [key];
}

/// Clear all custom environment variables.
class TerminalSettingsClearEnvVars extends TerminalSettingsEvent {
  const TerminalSettingsClearEnvVars();
}

/// Update the maximum number of open shells.
class TerminalSettingsUpdateMaxOpenShells extends TerminalSettingsEvent {
  final int maxOpenShells;

  const TerminalSettingsUpdateMaxOpenShells({required this.maxOpenShells});

  @override
  List<Object?> get props => [maxOpenShells];
}

/// Update the terminal font size.
class TerminalSettingsUpdateFontSize extends TerminalSettingsEvent {
  final double fontSize;

  const TerminalSettingsUpdateFontSize({required this.fontSize});

  @override
  List<Object?> get props => [fontSize];
}

/// Update the terminal font family.
class TerminalSettingsUpdateFontFamily extends TerminalSettingsEvent {
  final String fontFamily;

  const TerminalSettingsUpdateFontFamily({required this.fontFamily});

  @override
  List<Object?> get props => [fontFamily];
}
