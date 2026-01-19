part of 'bloc.dart';

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

  const TerminalSettingsLoaded({
    this.environmentVariables = const {},
  });

  @override
  List<Object?> get props => [environmentVariables];

  TerminalSettingsLoaded copyWith({
    Map<String, String>? environmentVariables,
  }) {
    return TerminalSettingsLoaded(
      environmentVariables: environmentVariables ?? this.environmentVariables,
    );
  }
}

final class TerminalSettingsError extends TerminalSettingsState {
  final Object error;

  const TerminalSettingsError({required this.error});

  @override
  List<Object?> get props => [error];
}
