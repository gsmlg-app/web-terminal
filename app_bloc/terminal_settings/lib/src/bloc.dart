import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:app_secure_storage/app_secure_storage.dart';

part 'event.dart';
part 'state.dart';

/// BLoC for managing terminal settings including environment variables.
///
/// Environment variables are stored securely using [VaultRepository] as they
/// may contain sensitive information like API keys and tokens.
class TerminalSettingsBloc
    extends Bloc<TerminalSettingsEvent, TerminalSettingsState> {
  /// Prefix for environment variable keys in secure storage.
  static const _envKeyPrefix = 'terminal_env_';

  final VaultRepository _vault;

  TerminalSettingsBloc({required VaultRepository vault})
      : _vault = vault,
        super(const TerminalSettingsInitial()) {
    on<TerminalSettingsLoad>(_onLoad);
    on<TerminalSettingsUpdateEnvVar>(_onUpdateEnvVar);
    on<TerminalSettingsRemoveEnvVar>(_onRemoveEnvVar);
    on<TerminalSettingsClearEnvVars>(_onClearEnvVars);
  }

  Future<void> _onLoad(
    TerminalSettingsLoad event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    emit(const TerminalSettingsLoading());

    try {
      final allSecrets = await _vault.readAll();
      final envVars = <String, String>{};

      // Filter for environment variable keys
      for (final entry in allSecrets.entries) {
        if (entry.key.startsWith(_envKeyPrefix)) {
          final envKey = entry.key.substring(_envKeyPrefix.length);
          envVars[envKey] = entry.value;
        }
      }

      emit(TerminalSettingsLoaded(environmentVariables: envVars));
    } catch (e) {
      emit(TerminalSettingsError(error: e));
    }
  }

  Future<void> _onUpdateEnvVar(
    TerminalSettingsUpdateEnvVar event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    if (state is! TerminalSettingsLoaded) return;

    final currentState = state as TerminalSettingsLoaded;
    final newEnvVars = Map<String, String>.from(currentState.environmentVariables);

    if (event.value.isEmpty) {
      newEnvVars.remove(event.key);
      await _vault.delete(key: '$_envKeyPrefix${event.key}');
    } else {
      newEnvVars[event.key] = event.value;
      await _vault.write(key: '$_envKeyPrefix${event.key}', value: event.value);
    }

    emit(currentState.copyWith(environmentVariables: newEnvVars));
  }

  Future<void> _onRemoveEnvVar(
    TerminalSettingsRemoveEnvVar event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    if (state is! TerminalSettingsLoaded) return;

    final currentState = state as TerminalSettingsLoaded;
    final newEnvVars = Map<String, String>.from(currentState.environmentVariables);
    newEnvVars.remove(event.key);

    await _vault.delete(key: '$_envKeyPrefix${event.key}');
    emit(currentState.copyWith(environmentVariables: newEnvVars));
  }

  Future<void> _onClearEnvVars(
    TerminalSettingsClearEnvVars event,
    Emitter<TerminalSettingsState> emit,
  ) async {
    if (state is! TerminalSettingsLoaded) return;

    final currentState = state as TerminalSettingsLoaded;

    // Delete all environment variable keys from vault
    for (final key in currentState.environmentVariables.keys) {
      await _vault.delete(key: '$_envKeyPrefix$key');
    }

    emit(const TerminalSettingsLoaded(environmentVariables: {}));
  }
}
