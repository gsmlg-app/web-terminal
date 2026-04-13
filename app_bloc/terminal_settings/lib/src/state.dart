part of 'bloc.dart';

/// Default maximum number of open shells.
const kTerminalDefaultMaxOpenShells = 10;

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

  const TerminalSettingsLoaded({
    this.environmentVariables = const {},
    this.maxOpenShells = kTerminalDefaultMaxOpenShells,
  });

  @override
  List<Object?> get props => [
    environmentVariables,
    maxOpenShells,
  ];

  TerminalSettingsLoaded copyWith({
    Map<String, String>? environmentVariables,
    int? maxOpenShells,
  }) {
    return TerminalSettingsLoaded(
      environmentVariables: environmentVariables ?? this.environmentVariables,
      maxOpenShells: maxOpenShells ?? this.maxOpenShells,
    );
  }
}

final class TerminalSettingsError extends TerminalSettingsState {
  final Object error;

  const TerminalSettingsError({required this.error});

  @override
  List<Object?> get props => [error];
}
