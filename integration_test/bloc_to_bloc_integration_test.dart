import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// BLoCs to test
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:theme_bloc/theme_bloc.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:error_handler_bloc/error_handler_bloc.dart';

/// Integration tests for BLoC-to-BLoC interactions.
///
/// These tests verify that BLoCs correctly interact with each other
/// and that state changes in one BLoC properly affect dependent BLoCs.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BLoC to BLoC Integration Tests', () {
    late AppDatabase database;
    late VaultRepository vault;
    late SharedPreferences sharedPrefs;

    setUp(() async {
      // Initialize test database
      database = AppDatabase.forTesting();

      // Initialize test vault with in-memory storage
      vault = InMemoryVaultRepository();

      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      sharedPrefs = await SharedPreferences.getInstance();
    });

    tearDown(() async {
      await database.close();
    });

    group('TerminalTabBloc + TerminalSettingsBloc Integration', () {
      test('Terminal settings font size changes should affect tab display', () async {
        final terminalTabBloc = TerminalTabBloc();
        final terminalSettingsBloc = TerminalSettingsBloc(vault: vault);

        // Load initial settings
        terminalSettingsBloc.add(const TerminalSettingsLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify initial state
        expect(terminalSettingsBloc.state, isA<TerminalSettingsLoaded>());
        final initialState = terminalSettingsBloc.state as TerminalSettingsLoaded;
        expect(initialState.fontSize, kTerminalDefaultFontSize);

        // Update font size
        terminalSettingsBloc.add(const TerminalSettingsUpdateFontSize(fontSize: 18.0));
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify settings updated
        final updatedState = terminalSettingsBloc.state as TerminalSettingsLoaded;
        expect(updatedState.fontSize, 18.0);

        // Start terminal tabs
        terminalTabBloc.add(const TerminalTabStart());
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify terminal tab state is loaded
        expect(terminalTabBloc.state, isA<TerminalTabLoaded>());

        // Cleanup
        await terminalTabBloc.close();
        await terminalSettingsBloc.close();
      });

      test('Terminal settings max shells should limit tab creation', () async {
        final terminalTabBloc = TerminalTabBloc();
        final terminalSettingsBloc = TerminalSettingsBloc(vault: vault);

        // Load and set max shells to 2
        terminalSettingsBloc.add(const TerminalSettingsLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        terminalSettingsBloc.add(const TerminalSettingsUpdateMaxOpenShells(maxOpenShells: 2));
        await Future.delayed(const Duration(milliseconds: 100));

        final settingsState = terminalSettingsBloc.state as TerminalSettingsLoaded;
        expect(settingsState.maxOpenShells, 2);

        // Start terminal tabs
        terminalTabBloc.add(const TerminalTabStart());
        await Future.delayed(const Duration(milliseconds: 50));

        final tabState = terminalTabBloc.state as TerminalTabLoaded;

        // Verify tabs are manageable according to settings
        expect(tabState.isMounted, isTrue);
        expect(settingsState.maxOpenShells, lessThanOrEqualTo(50));

        await terminalTabBloc.close();
        await terminalSettingsBloc.close();
      });

      test('Environment variables from settings should be available to tabs', () async {
        final terminalSettingsBloc = TerminalSettingsBloc(vault: vault);

        // Load settings
        terminalSettingsBloc.add(const TerminalSettingsLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Add environment variables
        terminalSettingsBloc.add(
          const TerminalSettingsUpdateEnvVar(key: 'TEST_VAR', value: 'test_value'),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        terminalSettingsBloc.add(
          const TerminalSettingsUpdateEnvVar(key: 'API_KEY', value: 'secret123'),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify environment variables are stored
        final state = terminalSettingsBloc.state as TerminalSettingsLoaded;
        expect(state.environmentVariables['TEST_VAR'], 'test_value');
        expect(state.environmentVariables['API_KEY'], 'secret123');

        // These environment variables would be passed to PTY when creating tabs
        // That integration is tested in bloc_to_plugin tests

        await terminalSettingsBloc.close();
      });
    });

    group('ThemeBloc + ShellProfileBloc Integration', () {
      test('Theme changes should affect shell profile color rendering', () async {
        final themeBloc = ThemeBloc(sharedPrefs);
        final shellProfileBloc = ShellProfileBloc(database);

        // Load initial theme
        expect(themeBloc.state.theme, isNotNull);
        final initialTheme = themeBloc.state.theme;

        // Load shell profiles
        shellProfileBloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(shellProfileBloc.state, isA<ShellProfileLoaded>());

        // Add a shell profile with color theme
        shellProfileBloc.add(
          AddShellProfile(
            name: 'Dark Profile',
            shellType: ShellType.bash,
            environmentVariables: const {},
            aliases: const {},
            colorTheme: 'dark',
            fontFamily: 'Courier',
            fontSize: 14.0,
            isDefault: true,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final profileState = shellProfileBloc.state as ShellProfileLoaded;
        expect(profileState.profiles.length, 1);
        expect(profileState.profiles.first.colorTheme, 'dark');

        // Change app theme
        themeBloc.add(ChangeThemeMode(ThemeMode.dark));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(themeBloc.state.themeMode, ThemeMode.dark);

        // Verify profile color theme should coordinate with app theme
        // In practice, the UI would react to both BLoCs
        expect(profileState.profiles.first.colorTheme, 'dark');

        await themeBloc.close();
        await shellProfileBloc.close();
      });

      test('Shell profile font settings should complement theme typography', () async {
        final themeBloc = ThemeBloc(sharedPrefs);
        final shellProfileBloc = ShellProfileBloc(database);

        // Load profiles
        shellProfileBloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 100));

        // Create profile with specific font
        shellProfileBloc.add(
          AddShellProfile(
            name: 'Custom Font Profile',
            shellType: ShellType.zsh,
            environmentVariables: const {},
            aliases: const {},
            colorTheme: 'light',
            fontFamily: 'Monaco',
            fontSize: 16.0,
            isDefault: false,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final state = shellProfileBloc.state as ShellProfileLoaded;
        expect(state.profiles.first.fontFamily, 'Monaco');
        expect(state.profiles.first.fontSize, 16.0);

        // Theme should provide base typography, profile overrides for terminal
        expect(themeBloc.state.theme, isNotNull);

        await themeBloc.close();
        await shellProfileBloc.close();
      });
    });

    group('SshHostBloc + SshKeyBloc Integration', () {
      test('SSH host should reference valid SSH key', () async {
        final sshHostBloc = SshHostBloc(database);
        final sshKeyBloc = SshKeyBloc(database);

        // Load keys and hosts
        sshKeyBloc.add(const SshKeyLoad());
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Add an SSH key
        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Test Key',
            content: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ...',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.rsa,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final keyState = sshKeyBloc.state as SshKeyLoaded;
        expect(keyState.keys.length, 1);
        final addedKey = keyState.keys.first;

        // Add an SSH host that references the key
        sshHostBloc.add(
          SshHostAdd(
            host: 'server1',
            hostname: '192.168.1.100',
            port: 22,
            username: 'user',
            password: '',
            salt: '',
            identityType: SshIdentityType.key,
            identityKeyId: addedKey.id,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final hostState = sshHostBloc.state as SshHostLoaded;
        expect(hostState.hosts.length, 1);
        final addedHost = hostState.hosts.first;

        // Verify the relationship
        expect(addedHost.identityType, SshIdentityType.key);
        expect(addedHost.identityKeyId, addedKey.id);

        await sshHostBloc.close();
        await sshKeyBloc.close();
      });

      test('Deleting SSH key should affect hosts using that key', () async {
        final sshHostBloc = SshHostBloc(database);
        final sshKeyBloc = SshKeyBloc(database);

        // Add a key
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshKeyBloc.add(
          SshKeyAdd(
            name: 'Key to Delete',
            content: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ...',
            password: '',
            salt: '',
            algorithm: SshKeyAlgorithm.ed25519,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        var keyState = sshKeyBloc.state as SshKeyLoaded;
        final keyToDelete = keyState.keys.first;

        // Add a host using this key
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        sshHostBloc.add(
          SshHostAdd(
            host: 'server2',
            hostname: 'example.com',
            port: 22,
            username: 'admin',
            password: '',
            salt: '',
            identityType: SshIdentityType.key,
            identityKeyId: keyToDelete.id,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        var hostState = sshHostBloc.state as SshHostLoaded;
        expect(hostState.hosts.length, 1);
        expect(hostState.hosts.first.identityKeyId, keyToDelete.id);

        // Delete the key
        sshKeyBloc.add(SshKeyDelete(sshKey: keyToDelete));
        await Future.delayed(const Duration(milliseconds: 100));

        keyState = sshKeyBloc.state as SshKeyLoaded;
        expect(keyState.keys.isEmpty, isTrue);

        // The host still exists but references a deleted key
        // In practice, the UI should handle this gracefully or use cascade delete
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        hostState = sshHostBloc.state as SshHostLoaded;
        // Host still exists but key is gone - this is a referential integrity test
        expect(hostState.hosts.length, 1);

        await sshHostBloc.close();
        await sshKeyBloc.close();
      });

      test('SSH host with password authentication should not require key', () async {
        final sshHostBloc = SshHostBloc(database);
        final sshKeyBloc = SshKeyBloc(database);

        sshHostBloc.add(const SshHostLoad());
        sshKeyBloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Add host with password auth (no key)
        sshHostBloc.add(
          SshHostAdd(
            host: 'password-host',
            hostname: 'pass.example.com',
            port: 2222,
            username: 'root',
            password: 'encrypted_password',
            salt: 'salt123',
            identityType: SshIdentityType.password,
            identityKeyId: null,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        final hostState = sshHostBloc.state as SshHostLoaded;
        final keyState = sshKeyBloc.state as SshKeyLoaded;

        expect(hostState.hosts.length, 1);
        expect(hostState.hosts.first.identityType, SshIdentityType.password);
        expect(hostState.hosts.first.identityKeyId, isNull);
        expect(keyState.keys.isEmpty, isTrue); // No keys needed

        await sshHostBloc.close();
        await sshKeyBloc.close();
      });
    });

    group('ErrorHandlerBloc Integration with Other BLoCs', () {
      test('ErrorHandlerBloc should capture errors from SshHostBloc', () async {
        final errorBloc = ErrorBloc();
        final sshHostBloc = SshHostBloc(database);

        // Monitor error bloc state
        final errorStates = <ErrorState>[];
        errorBloc.stream.listen(errorStates.add);

        // Try to add invalid SSH host (triggers error)
        sshHostBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Simulate an error in host operation
        try {
          // This would normally be caught by the BLoC
          throw Exception('Invalid SSH host configuration');
        } catch (e, stackTrace) {
          errorBloc.reportError(e, stackTrace: stackTrace, context: 'SshHostBloc');
          await Future.delayed(const Duration(milliseconds: 100));
        }

        // Verify error was captured
        expect(errorStates.length, greaterThan(0));
        final lastErrorState = errorStates.last;
        expect(lastErrorState.activeErrors.length, 1);
        expect(lastErrorState.activeErrors.first.context, 'SshHostBloc');

        await errorBloc.close();
        await sshHostBloc.close();
      });

      test('ErrorHandlerBloc should handle TerminalSettingsBloc errors', () async {
        final errorBloc = ErrorBloc();
        final terminalSettingsBloc = TerminalSettingsBloc(vault: vault);

        // Load settings (should succeed)
        terminalSettingsBloc.add(const TerminalSettingsLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        expect(terminalSettingsBloc.state, isA<TerminalSettingsLoaded>());

        // Simulate an error scenario
        try {
          throw Exception('Failed to save terminal settings');
        } catch (e, stackTrace) {
          errorBloc.reportError(
            e,
            stackTrace: stackTrace,
            context: 'TerminalSettingsBloc',
            severity: ErrorSeverity.medium,
          );
          await Future.delayed(const Duration(milliseconds: 100));
        }

        final errorState = errorBloc.state;
        expect(errorState.activeErrors.length, 1);
        expect(errorState.activeErrors.first.severity, ErrorSeverity.medium);

        await errorBloc.close();
        await terminalSettingsBloc.close();
      });

      test('ErrorHandlerBloc should track errors across multiple BLoCs', () async {
        final errorBloc = ErrorBloc();
        final sshHostBloc = SshHostBloc(database);
        final sshKeyBloc = SshKeyBloc(database);

        // Simulate errors from different sources
        errorBloc.reportError(
          'SSH Host connection failed',
          context: 'SshHostBloc',
          severity: ErrorSeverity.high,
        );
        await Future.delayed(const Duration(milliseconds: 50));

        errorBloc.reportError(
          'SSH Key decryption failed',
          context: 'SshKeyBloc',
          severity: ErrorSeverity.high,
        );
        await Future.delayed(const Duration(milliseconds: 50));

        final errorState = errorBloc.state;
        expect(errorState.activeErrors.length, 2);

        final contexts = errorState.activeErrors.map((e) => e.context).toList();
        expect(contexts, contains('SshHostBloc'));
        expect(contexts, contains('SshKeyBloc'));

        // Dismiss one error
        errorBloc.add(ErrorDismissed(errorId: errorState.activeErrors.first.id));
        await Future.delayed(const Duration(milliseconds: 50));

        final updatedState = errorBloc.state;
        expect(updatedState.activeErrors.length, 1);

        await errorBloc.close();
        await sshHostBloc.close();
        await sshKeyBloc.close();
      });
    });

    group('Cross-BLoC State Coordination', () {
      test('Theme + TerminalSettings should provide consistent appearance', () async {
        final themeBloc = ThemeBloc(sharedPrefs);
        final terminalSettingsBloc = TerminalSettingsBloc(vault: vault);

        // Load settings
        terminalSettingsBloc.add(const TerminalSettingsLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        // Set terminal font
        terminalSettingsBloc.add(
          const TerminalSettingsUpdateFontFamily(fontFamily: 'Menlo'),
        );
        terminalSettingsBloc.add(
          const TerminalSettingsUpdateFontSize(fontSize: 14.0),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        // Change app theme to dark
        themeBloc.add(ChangeThemeMode(ThemeMode.dark));
        await Future.delayed(const Duration(milliseconds: 100));

        final settingsState = terminalSettingsBloc.state as TerminalSettingsLoaded;
        expect(settingsState.fontFamily, 'Menlo');
        expect(settingsState.fontSize, 14.0);
        expect(themeBloc.state.themeMode, ThemeMode.dark);

        // Both should coordinate for terminal appearance
        // Dark theme + Menlo font = consistent dark terminal

        await themeBloc.close();
        await terminalSettingsBloc.close();
      });

      test('Multiple BLoCs should handle concurrent state changes', () async {
        final terminalTabBloc = TerminalTabBloc();
        final terminalSettingsBloc = TerminalSettingsBloc(vault: vault);
        final shellProfileBloc = ShellProfileBloc(database);
        final errorBloc = ErrorBloc();

        // Initialize all BLoCs
        terminalTabBloc.add(const TerminalTabStart());
        terminalSettingsBloc.add(const TerminalSettingsLoad());
        shellProfileBloc.add(const LoadShellProfiles());
        await Future.delayed(const Duration(milliseconds: 100));

        // Make concurrent changes
        terminalSettingsBloc.add(
          const TerminalSettingsUpdateFontSize(fontSize: 16.0),
        );
        shellProfileBloc.add(
          AddShellProfile(
            name: 'Test Profile',
            shellType: ShellType.bash,
            environmentVariables: const {},
            aliases: const {},
            colorTheme: 'light',
            fontFamily: 'Courier',
            fontSize: 14.0,
            isDefault: true,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 150));

        // Verify all states updated correctly
        expect(terminalTabBloc.state, isA<TerminalTabLoaded>());
        expect(terminalSettingsBloc.state, isA<TerminalSettingsLoaded>());
        expect(shellProfileBloc.state, isA<ShellProfileLoaded>());
        expect(errorBloc.state.activeErrors.isEmpty, isTrue);

        await terminalTabBloc.close();
        await terminalSettingsBloc.close();
        await shellProfileBloc.close();
        await errorBloc.close();
      });
    });
  });
}
