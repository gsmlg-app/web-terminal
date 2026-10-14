import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_bloc/theme_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DmThemeBloc', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('initial state has default theme and system mode', () {
      final bloc = DmThemeBloc(prefs: prefs);

      expect(bloc.state.themeName, isNotEmpty);
      expect(bloc.state.themeMode, ThemeMode.system);
      expect(bloc.state.entry, isNotNull);
      expect(bloc.state.entry.light, isNotNull);
      expect(bloc.state.entry.dark, isNotNull);
      bloc.close();
    });

    test('DmSetTheme changes theme', () async {
      final bloc = DmThemeBloc(prefs: prefs);
      final themes = DmThemeData.themes;
      final targetName =
          themes.length > 1 ? themes.last.name : themes.first.name;

      bloc.add(DmSetTheme(targetName));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.themeName, targetName);
      bloc.close();
    });

    test('DmSetThemeMode changes mode to dark', () async {
      final bloc = DmThemeBloc(prefs: prefs);

      bloc.add(DmSetThemeMode(ThemeMode.dark));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.themeMode, ThemeMode.dark);
      bloc.close();
    });

    test('DmSetThemeMode changes mode to light', () async {
      final bloc = DmThemeBloc(prefs: prefs);

      bloc.add(DmSetThemeMode(ThemeMode.light));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.themeMode, ThemeMode.light);
      bloc.close();
    });

    test('DmSetTheme persists to SharedPreferences', () async {
      final bloc = DmThemeBloc(prefs: prefs);
      final themes = DmThemeData.themes;
      final targetName =
          themes.length > 1 ? themes.last.name : themes.first.name;

      bloc.add(DmSetTheme(targetName));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(prefs.getString('dm_theme_name'), targetName);
      bloc.close();
    });

    test('DmSetThemeMode persists to SharedPreferences', () async {
      final bloc = DmThemeBloc(prefs: prefs);

      bloc.add(DmSetThemeMode(ThemeMode.dark));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(prefs.getString('dm_theme_mode'), 'dark');
      bloc.close();
    });

    test('restores persisted theme on creation', () async {
      final themes = DmThemeData.themes;
      final targetName =
          themes.length > 1 ? themes.last.name : themes.first.name;

      SharedPreferences.setMockInitialValues({
        'dm_theme_name': targetName,
        'dm_theme_mode': 'dark',
      });
      prefs = await SharedPreferences.getInstance();

      final bloc = DmThemeBloc(prefs: prefs);

      expect(bloc.state.themeName, targetName);
      expect(bloc.state.themeMode, ThemeMode.dark);
      bloc.close();
    });

    test('preserves theme when changing mode', () async {
      final bloc = DmThemeBloc(prefs: prefs);
      final themes = DmThemeData.themes;
      final targetName =
          themes.length > 1 ? themes.last.name : themes.first.name;

      bloc.add(DmSetTheme(targetName));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(DmSetThemeMode(ThemeMode.dark));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.themeName, targetName);
      expect(bloc.state.themeMode, ThemeMode.dark);
      bloc.close();
    });

    test('entry has valid light and dark ThemeData', () {
      final bloc = DmThemeBloc(prefs: prefs);

      expect(bloc.state.entry.light.brightness, Brightness.light);
      expect(bloc.state.entry.dark.brightness, Brightness.dark);
      expect(bloc.state.entry.light.useMaterial3, true);
      expect(bloc.state.entry.dark.useMaterial3, true);
      bloc.close();
    });
  });

  group('DmThemeData.themes', () {
    test('contains expected themes', () {
      expect(DmThemeData.themes.length, greaterThanOrEqualTo(2));

      final names = DmThemeData.themes.map((t) => t.name).toList();
      expect(names, isNotEmpty);
    });

    test('all themes have light and dark variants', () {
      for (final entry in DmThemeData.themes) {
        expect(entry.light, isNotNull);
        expect(entry.dark, isNotNull);
        expect(entry.light.brightness, Brightness.light);
        expect(entry.dark.brightness, Brightness.dark);
      }
    });
  });
}
