import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:web_terminal/screens/terminal/terminal_screen.dart';

class _FakeVaultRepository implements VaultRepository {
  final _storage = <String, String>{};

  @override
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.of(_storage);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }
}

void main() {
  testWidgets(
    'disposes without looking up providers from a deactivated context',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting();
      addTearDown(database.close);

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<SharedPreferences>.value(value: prefs),
            RepositoryProvider<AppDatabase>.value(value: database),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<TerminalTabBloc>(
                create: (context) => TerminalTabBloc(),
              ),
              BlocProvider<TerminalSettingsBloc>(
                create: (context) =>
                    TerminalSettingsBloc(vault: _FakeVaultRepository()),
              ),
              BlocProvider<ShellProfileBloc>(
                create: (context) => ShellProfileBloc(database),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocale.localizationsDelegates,
              supportedLocales: AppLocale.supportedLocales,
              home: const TerminalScreen(),
            ),
          ),
        ),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
