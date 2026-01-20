part of 'bloc.dart';

/// Default maximum number of open shells.
const kTerminalDefaultMaxOpenShells = 10;

/// Default terminal font size.
const kTerminalDefaultFontSize = 13.0;

/// Default terminal font family.
const kTerminalDefaultFontFamily = 'monospace';

@immutable
sealed class TerminalSettingsState extends Equatable {
  const TerminalSettingsState();

  @override
  List<Object?> get props => [];
}

final class TerminalSettingsInitial extends TerminalSettingsState {
  const TerminalSettingsInitial();
}

final class TerminalSettingsLoading extends TerminalSettingsState {
  const TerminalSettingsLoading();
}

final class TerminalSettingsLoaded extends TerminalSettingsState {
  /// Custom environment variables to inject into new shell sessions.
  final Map<String, String> environmentVariables;

  /// Maximum number of concurrent shell sessions allowed.
  final int maxOpenShells;

  /// Terminal font size in logical pixels.
  final double fontSize;

  /// Terminal font family name.
  final String fontFamily;

  const TerminalSettingsLoaded({
    this.environmentVariables = const {},
    this.maxOpenShells = kTerminalDefaultMaxOpenShells,
    this.fontSize = kTerminalDefaultFontSize,
    this.fontFamily = kTerminalDefaultFontFamily,
  });

  @override
  List<Object?> get props => [
        environmentVariables,
        maxOpenShells,
        fontSize,
        fontFamily,
      ];

  TerminalSettingsLoaded copyWith({
    Map<String, String>? environmentVariables,
    int? maxOpenShells,
    double? fontSize,
    String? fontFamily,
  }) {
    return TerminalSettingsLoaded(
      environmentVariables: environmentVariables ?? this.environmentVariables,
      maxOpenShells: maxOpenShells ?? this.maxOpenShells,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

final class TerminalSettingsError extends TerminalSettingsState {
  final Object error;

  const TerminalSettingsError({required this.error});

  @override
  List<Object?> get props => [error];
}
