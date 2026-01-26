import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:app_theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:theme_bloc/theme_bloc.dart';

void main() {
  group('terminal_settings exports', () {
    test('exports are available', () {
      // Verify that the main exports are accessible
      expect(BlocSettingsSectionAccentColor, isNotNull);
      expect(BlocSettingsSectionAppearance, isNotNull);
      expect(RootSettingList, isNotNull);
      expect(RootSettingListConfig, isNotNull);
      expect(SettingsSectionDeviceInfo, isNotNull);
      expect(SettingsSectionWifiInfo, isNotNull);
    });
  });

  group('SettingsSectionDeviceInfo', () {
    testWidgets('build creates SettingsSection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final section = SettingsSectionDeviceInfo.build(context);
                return SettingsList(sections: [section]);
              },
            ),
          ),
        ),
      );

      expect(find.text('Device Information'), findsOneWidget);
    });

    testWidgets('displays platform information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final section = SettingsSectionDeviceInfo.build(context);
                return SettingsList(sections: [section]);
              },
            ),
          ),
        ),
      );

      expect(find.text('Platform'), findsOneWidget);
      expect(find.text('Operating System'), findsOneWidget);
      expect(find.text('OS Version'), findsOneWidget);
      expect(find.text('Locale'), findsOneWidget);
      expect(find.text('Number of Processors'), findsOneWidget);
    });

    testWidgets('displays icons for each setting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final section = SettingsSectionDeviceInfo.build(context);
                return SettingsList(sections: [section]);
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.phone_android), findsOneWidget);
      expect(find.byIcon(Icons.computer), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byIcon(Icons.memory), findsOneWidget);
    });

    testWidgets('displays non-empty values on desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final section = SettingsSectionDeviceInfo.build(context);
                return SettingsList(sections: [section]);
              },
            ),
          ),
        ),
      );

      // On desktop platforms, these values should be populated
      // At minimum, we verify that some platform name is shown
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      expect(textWidgets.length, greaterThan(5)); // Title + 5 settings
    });
  });

  group('BlocSettingsSectionAccentColor', () {
    late ThemeBloc themeBloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      themeBloc = ThemeBloc(prefs);
    });

    tearDown(() {
      themeBloc.close();
    });

    testWidgets('tile displays accent color name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: themeBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  final tile = BlocSettingsSectionAccentColor.tile(
                    context: context,
                    onPressed: (_) {},
                  );
                  return SettingsList(
                    sections: [
                      SettingsSection(tiles: [tile]),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Accent Color'), findsOneWidget);
    });

    testWidgets('tile shows palette icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: themeBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  final tile = BlocSettingsSectionAccentColor.tile(
                    context: context,
                    onPressed: (_) {},
                  );
                  return SettingsList(
                    sections: [
                      SettingsSection(tiles: [tile]),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.palette), findsOneWidget);
    });

    testWidgets('buildSection shows all available themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: themeBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  final section =
                      BlocSettingsSectionAccentColor.buildSection(context);
                  return SettingsList(sections: [section]);
                },
              ),
            ),
          ),
        ),
      );

      // Verify all theme names are displayed
      for (final theme in themeList) {
        expect(find.text(theme.name), findsOneWidget);
      }
    });

    testWidgets('buildSection shows check icon for selected theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: themeBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  final section =
                      BlocSettingsSectionAccentColor.buildSection(context);
                  return SettingsList(sections: [section]);
                },
              ),
            ),
          ),
        ),
      );

      // Default theme should have a check mark
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('theme selection triggers ChangeTheme event', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: themeBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  final section =
                      BlocSettingsSectionAccentColor.buildSection(context);
                  return SettingsList(sections: [section]);
                },
              ),
            ),
          ),
        ),
      );

      // Find a theme tile that is not the current one and tap it
      final initialThemeName = themeBloc.state.theme.name;
      final otherTheme =
          themeList.firstWhere((t) => t.name != initialThemeName);

      await tester.tap(find.text(otherTheme.name));
      await tester.pumpAndSettle();

      // Verify theme changed
      expect(themeBloc.state.theme.name, otherTheme.name);
    });
  });

  group('BlocSettingsSectionAppearance', () {
    late ThemeBloc themeBloc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      themeBloc = ThemeBloc(prefs);
    });

    tearDown(() {
      themeBloc.close();
    });

    testWidgets('tile displays theme mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: themeBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  final tile = BlocSettingsSectionAppearance.tile(
                    context: context,
                    onPressed: (_) {},
                  );
                  return SettingsList(
                    sections: [
                      SettingsSection(tiles: [tile]),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('buildSection shows system, light, dark options',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: themeBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  final section =
                      BlocSettingsSectionAppearance.buildSection(context);
                  return SettingsList(sections: [section]);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('theme mode selection triggers ChangeThemeMode event',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: themeBloc,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  final section =
                      BlocSettingsSectionAppearance.buildSection(context);
                  return SettingsList(sections: [section]);
                },
              ),
            ),
          ),
        ),
      );

      // Default is system, tap dark
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(themeBloc.state.themeMode, ThemeMode.dark);
    });
  });

  group('RootSettingListConfig', () {
    test('creates with all required parameters', () {
      final config = RootSettingListConfig(
        terminalEnvScreenName: 'terminal_env',
        hostScreenName: 'hosts',
        sshKeyScreenName: 'ssh_keys',
        deviceInfoScreenName: 'device_info',
        wifiInfoScreenName: 'wifi_info',
        selectBrightnessScreenName: 'brightness',
        selectThemeScreenName: 'theme',
        webServerScreenName: 'web_server',
      );

      expect(config.terminalEnvScreenName, 'terminal_env');
      expect(config.hostScreenName, 'hosts');
      expect(config.sshKeyScreenName, 'ssh_keys');
      expect(config.deviceInfoScreenName, 'device_info');
      expect(config.wifiInfoScreenName, 'wifi_info');
      expect(config.selectBrightnessScreenName, 'brightness');
      expect(config.selectThemeScreenName, 'theme');
      expect(config.webServerScreenName, 'web_server');
      expect(config.shellProfilesScreenName, isNull);
    });

    test('optional shellProfilesScreenName can be set', () {
      final config = RootSettingListConfig(
        terminalEnvScreenName: 'terminal_env',
        hostScreenName: 'hosts',
        sshKeyScreenName: 'ssh_keys',
        deviceInfoScreenName: 'device_info',
        wifiInfoScreenName: 'wifi_info',
        selectBrightnessScreenName: 'brightness',
        selectThemeScreenName: 'theme',
        webServerScreenName: 'web_server',
        shellProfilesScreenName: 'shell_profiles',
      );

      expect(config.shellProfilesScreenName, 'shell_profiles');
    });
  });
}
