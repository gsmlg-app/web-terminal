import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:web_terminal/screens/terminal/terminal_screen.dart';

class _UnusedVault extends Fake implements VaultRepository {}

class _Profiles extends ShellProfileBloc {
  _Profiles(super.database);

  void publish(ShellProfileState state) => emit(state);
}

class _Settings extends TerminalSettingsBloc {
  _Settings() : super(vault: _UnusedVault());

  void publish(TerminalSettingsState state) => emit(state);
}

class _Tabs extends TerminalTabBloc {
  final opened = <PluginTab>[];

  @override
  void add(TerminalTabEvent event) {
    if (event is TerminalTabOpenTab && event.tabItem is PluginTab) {
      final tab = event.tabItem as PluginTab;
      opened.add(tab);
      // Inspect the real host configuration without mounting its native view.
      tab.content.value = const SizedBox.shrink();
    }
    super.add(event);
  }
}

ShellProfile _profile() => ShellProfile(
  id: 42,
  name: 'Configured shell',
  shellType: ShellType.fish.value,
  environmentVariables: '{"PROFILE":"ready","SHARED":"profile"}',
  aliases: '{}',
  fontFamily: 'Configured Font',
  fontSize: 19,
  colorTheme: 'default',
  workingDirectory: '/tmp/profile',
  startupCommand: 'echo profile-started',
  cursorStyle: 0,
  scrollbackLines: 2000,
  isDefault: true,
  inheritCurrentState: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late AppDatabase database;
  late _Profiles profiles;
  late _Settings settings;
  late _Tabs tabs;
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    database = AppDatabase.forTesting();
    profiles = _Profiles(database);
    settings = _Settings();
    tabs = _Tabs();
    tabs.add(TerminalTabStart());
    await tabs.stream.firstWhere((state) => state is TerminalTabLoaded);
  });

  tearDown(() async {
    for (final tab in tabs.opened) {
      tab.dispose();
      (tab.plugin as TerminalPlugin).terminal.dispose();
    }
    await tabs.close();
    await settings.close();
    await profiles.close();
    await database.close();
  });

  Future<void> mount(WidgetTester tester) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SharedPreferences>.value(value: preferences),
          RepositoryProvider<AppDatabase>.value(value: database),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<TerminalTabBloc>.value(value: tabs),
            BlocProvider<TerminalSettingsBloc>.value(value: settings),
            BlocProvider<ShellProfileBloc>.value(value: profiles),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocale.localizationsDelegates,
            supportedLocales: AppLocale.supportedLocales,
            home: const TerminalScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  for (final restore in [false]) {
    for (final profilesFirst in [false, true]) {
      testWidgets(
        'startup applies profile with restore=$restore profilesFirst=$profilesFirst',
        (tester) async {
          if (restore) {
            await preferences.setString(
              'terminal.open_tabs.v1',
              '{"tabs":[{"type":"local","profileId":42,'
                  '"workingDirectory":"/tmp/restored"}],"activeIndex":0}',
            );
          }
          final readySettings = TerminalSettingsLoaded(
            environmentVariables: const {'GLOBAL': 'yes', 'SHARED': 'global'},
          );
          if (profilesFirst) {
            profiles.publish(ShellProfileLoaded([_profile()]));
          } else {
            settings.publish(readySettings);
            profiles.publish(const ShellProfileLoading());
          }
          await mount(tester);
          expect(tabs.opened, isEmpty);

          if (profilesFirst) {
            settings.publish(readySettings);
          } else {
            profiles.publish(ShellProfileLoaded([_profile()]));
          }
          await tester.pump();
          await tester.pump();
          expect(tabs.opened, hasLength(1));
          final tab = tabs.opened.single;
          final host = tab.manager.hostSpec as LocalHostSpec;
          final plugin = tab.plugin as TerminalPlugin;
          expect(tab.shellProfileId, 42);
          expect(host.shellCommand, 'fish');
          expect(host.environment, {
            'GLOBAL': 'yes',
            'PROFILE': 'ready',
            'SHARED': 'profile',
          });
          expect(host.initCommands, contains('echo profile-started'));
          expect(
            host.workingDirectory,
            restore ? '/tmp/restored' : '/tmp/profile',
          );
          expect(plugin.profileFontFamily, 'Configured Font');
          expect(plugin.profileFontSize, 19);

          profiles.publish(const ShellProfileLoading());
          profiles.publish(ShellProfileLoaded([_profile()]));
          settings.publish(
            readySettings.copyWith(downloadMode: TerminalDownloadMode.ask),
          );
          await tester.pump();
          expect(tabs.opened, hasLength(1));
          await unmount(tester);
          await mount(tester);
          expect(tabs.opened, hasLength(1));
          await unmount(tester);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'startup blocks and shows profile failure with restore=$restore',
      (tester) async {
        settings.publish(TerminalSettingsLoaded());
        profiles.publish(
          ShellProfileError(StateError('profile storage failed')),
        );
        await mount(tester);
        expect(tabs.opened, isEmpty);
        expect(find.textContaining('profile storage failed'), findsOneWidget);
        profiles.publish(ShellProfileLoaded([_profile()]));
        await tester.pump();
        await tester.pump();
        expect(tabs.opened, hasLength(1));
        await unmount(tester);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final pending in [
    const ShellProfileInitial(),
    const ShellProfileLoading(),
  ]) {
    testWidgets('manual local opens wait for ${pending.runtimeType}', (
      tester,
    ) async {
      settings.publish(const TerminalSettingsLoaded());
      profiles.publish(pending);
      await mount(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Open Local Shell'));
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyT);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(tabs.opened, isEmpty);
      profiles.publish(ShellProfileLoaded([_profile()]));
      await tester.pump();
      await tester.pump();
      expect(tabs.opened, hasLength(1));
      await unmount(tester);
    });
  }
}
