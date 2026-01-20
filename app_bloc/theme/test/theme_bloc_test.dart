import 'package:app_theme/app_theme.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_bloc/theme_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeEvent', () {
    test('ChangeTheme stores theme', () {
      final theme = themeList.first;
      final event = ChangeTheme(theme);
      expect(event.theme, theme);
    });

    test('ChangeThemeMode stores themeMode for light', () {
      const event = ChangeThemeMode(ThemeMode.light);
      expect(event.themeMode, ThemeMode.light);
    });

    test('ChangeThemeMode stores themeMode for dark', () {
      const event = ChangeThemeMode(ThemeMode.dark);
      expect(event.themeMode, ThemeMode.dark);
    });

    test('ChangeThemeMode stores themeMode for system', () {
      const event = ChangeThemeMode(ThemeMode.system);
      expect(event.themeMode, ThemeMode.system);
    });
  });

  group('ThemeState', () {
    test('has correct props', () {
      final theme = themeList.first;
      final state = ThemeState(theme: theme, themeMode: ThemeMode.dark);
      expect(state.props, [theme, ThemeMode.dark]);
    });

    test('default themeMode is system', () {
      final theme = themeList.first;
      final state = ThemeState(theme: theme);
      expect(state.themeMode, ThemeMode.system);
    });

    test('copyWith creates new state with updated theme', () {
      final theme1 = themeList.first;
      final theme2 = themeList.last;
      final state1 = ThemeState(theme: theme1, themeMode: ThemeMode.light);

      final state2 = state1.copyWith(theme: theme2);

      expect(state2.theme, theme2);
      expect(state2.themeMode, ThemeMode.light); // unchanged
    });

    test('copyWith creates new state with updated themeMode', () {
      final theme = themeList.first;
      final state1 = ThemeState(theme: theme, themeMode: ThemeMode.light);

      final state2 = state1.copyWith(themeMode: ThemeMode.dark);

      expect(state2.theme, theme); // unchanged
      expect(state2.themeMode, ThemeMode.dark);
    });

    test('copyWith with no changes returns equivalent state', () {
      final theme = themeList.first;
      final state1 = ThemeState(theme: theme, themeMode: ThemeMode.light);

      final state2 = state1.copyWith();

      expect(state2.theme, state1.theme);
      expect(state2.themeMode, state1.themeMode);
    });

    group('initial factory', () {
      test('uses default theme when no saved theme', () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        final state = ThemeState.initial(prefs);

        expect(state.theme, themeList.first);
        expect(state.themeMode, ThemeMode.system);
      });

      test('loads saved theme name', () async {
        final savedTheme = themeList.last;
        SharedPreferences.setMockInitialValues({
          'themeName': savedTheme.name,
        });
        final prefs = await SharedPreferences.getInstance();

        final state = ThemeState.initial(prefs);

        expect(state.theme.name, savedTheme.name);
      });

      test('loads light themeMode', () async {
        SharedPreferences.setMockInitialValues({
          'themeMode': 'light',
        });
        final prefs = await SharedPreferences.getInstance();

        final state = ThemeState.initial(prefs);

        expect(state.themeMode, ThemeMode.light);
      });

      test('loads dark themeMode', () async {
        SharedPreferences.setMockInitialValues({
          'themeMode': 'dark',
        });
        final prefs = await SharedPreferences.getInstance();

        final state = ThemeState.initial(prefs);

        expect(state.themeMode, ThemeMode.dark);
      });

      test('uses system themeMode for unknown value', () async {
        SharedPreferences.setMockInitialValues({
          'themeMode': 'unknown',
        });
        final prefs = await SharedPreferences.getInstance();

        final state = ThemeState.initial(prefs);

        expect(state.themeMode, ThemeMode.system);
      });

      test('uses default theme for unknown theme name', () async {
        SharedPreferences.setMockInitialValues({
          'themeName': 'non_existent_theme',
        });
        final prefs = await SharedPreferences.getInstance();

        final state = ThemeState.initial(prefs);

        expect(state.theme, themeList.first);
      });
    });
  });

  group('ThemeBloc', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('initial state loads from preferences', () async {
      SharedPreferences.setMockInitialValues({
        'themeName': themeList.last.name,
        'themeMode': 'dark',
      });
      prefs = await SharedPreferences.getInstance();

      final bloc = ThemeBloc(prefs);

      expect(bloc.state.theme.name, themeList.last.name);
      expect(bloc.state.themeMode, ThemeMode.dark);
      bloc.close();
    });

    blocTest<ThemeBloc, ThemeState>(
      'emits updated state on ChangeTheme',
      build: () => ThemeBloc(prefs),
      act: (bloc) => bloc.add(ChangeTheme(themeList.last)),
      expect: () => [
        isA<ThemeState>().having(
          (s) => s.theme,
          'theme',
          themeList.last,
        ),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits updated state on ChangeThemeMode to light',
      build: () => ThemeBloc(prefs),
      act: (bloc) => bloc.add(const ChangeThemeMode(ThemeMode.light)),
      expect: () => [
        isA<ThemeState>().having(
          (s) => s.themeMode,
          'themeMode',
          ThemeMode.light,
        ),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits updated state on ChangeThemeMode to dark',
      build: () => ThemeBloc(prefs),
      act: (bloc) => bloc.add(const ChangeThemeMode(ThemeMode.dark)),
      expect: () => [
        isA<ThemeState>().having(
          (s) => s.themeMode,
          'themeMode',
          ThemeMode.dark,
        ),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'emits updated state on ChangeThemeMode to system',
      build: () => ThemeBloc(prefs),
      seed: () => ThemeState(
        theme: themeList.first,
        themeMode: ThemeMode.dark,
      ),
      act: (bloc) => bloc.add(const ChangeThemeMode(ThemeMode.system)),
      expect: () => [
        isA<ThemeState>().having(
          (s) => s.themeMode,
          'themeMode',
          ThemeMode.system,
        ),
      ],
    );

    test('ChangeTheme persists to SharedPreferences', () async {
      final bloc = ThemeBloc(prefs);
      final newTheme = themeList.last;

      bloc.add(ChangeTheme(newTheme));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(prefs.getString('themeName'), newTheme.name);
      bloc.close();
    });

    test('ChangeThemeMode persists to SharedPreferences', () async {
      final bloc = ThemeBloc(prefs);

      bloc.add(const ChangeThemeMode(ThemeMode.dark));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(prefs.getString('themeMode'), 'dark');

      bloc.add(const ChangeThemeMode(ThemeMode.light));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(prefs.getString('themeMode'), 'light');

      bloc.add(const ChangeThemeMode(ThemeMode.system));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(prefs.getString('themeMode'), 'system');
      bloc.close();
    });

    blocTest<ThemeBloc, ThemeState>(
      'can change theme multiple times',
      build: () => ThemeBloc(prefs),
      act: (bloc) async {
        bloc.add(ChangeTheme(themeList[1]));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(ChangeTheme(themeList[2]));
      },
      expect: () => [
        isA<ThemeState>().having((s) => s.theme, 'theme', themeList[1]),
        isA<ThemeState>().having((s) => s.theme, 'theme', themeList[2]),
      ],
    );

    blocTest<ThemeBloc, ThemeState>(
      'preserves theme when changing themeMode',
      build: () => ThemeBloc(prefs),
      seed: () => ThemeState(
        theme: themeList.last,
        themeMode: ThemeMode.light,
      ),
      act: (bloc) => bloc.add(const ChangeThemeMode(ThemeMode.dark)),
      verify: (bloc) {
        expect(bloc.state.theme, themeList.last);
        expect(bloc.state.themeMode, ThemeMode.dark);
      },
    );

    blocTest<ThemeBloc, ThemeState>(
      'preserves themeMode when changing theme',
      build: () => ThemeBloc(prefs),
      seed: () => ThemeState(
        theme: themeList.first,
        themeMode: ThemeMode.dark,
      ),
      act: (bloc) => bloc.add(ChangeTheme(themeList.last)),
      verify: (bloc) {
        expect(bloc.state.theme, themeList.last);
        expect(bloc.state.themeMode, ThemeMode.dark);
      },
    );
  });

  group('themeList', () {
    test('contains expected themes', () {
      expect(themeList.length, greaterThanOrEqualTo(4));

      final names = themeList.map((t) => t.name).toList();
      expect(names, contains('Violet'));
      expect(names, contains('Green'));
      expect(names, contains('Fire'));
      expect(names, contains('Wheat'));
    });

    test('all themes have light and dark variants', () {
      for (final theme in themeList) {
        expect(theme.lightTheme, isNotNull);
        expect(theme.darkTheme, isNotNull);
        expect(theme.lightTheme.brightness, Brightness.light);
        expect(theme.darkTheme.brightness, Brightness.dark);
      }
    });
  });
}
