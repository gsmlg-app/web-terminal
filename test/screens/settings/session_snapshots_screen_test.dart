import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:web_session_bloc/web_session_bloc.dart';
import 'package:web_terminal/destinations.dart';
import 'package:web_terminal/screens/settings/_setting_route.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';
import 'package:web_terminal/services/session_controller.dart';
import 'package:web_terminal/services/session_store.dart';

class _MockSessionStore extends Mock implements SessionStore {}

class _MockThemeBloc extends MockBloc<DmThemeEvent, DmThemeState>
    implements DmThemeBloc {}

class _MockTerminalSettingsBloc
    extends MockBloc<TerminalSettingsEvent, TerminalSettingsState>
    implements TerminalSettingsBloc {}

class _MockShellProfileBloc
    extends MockBloc<ShellProfileEvent, ShellProfileState>
    implements ShellProfileBloc {}

class _MockWebSessionBloc extends MockBloc<WebSessionEvent, WebSessionState>
    implements WebSessionBloc {}

void main() {
  late _MockSessionStore store;
  late SessionController sessions;
  late TerminalTabBloc tabs;
  late _MockThemeBloc themeBloc;
  late _MockTerminalSettingsBloc settingsBloc;
  late _MockShellProfileBloc profilesBloc;
  late _MockWebSessionBloc webBloc;
  late GoRouter router;

  setUp(() {
    store = _MockSessionStore();
    when(() => store.latest).thenReturn(null);
    when(() => store.recovery).thenReturn(null);
    when(() => store.history).thenReturn([]);
    when(() => store.saved).thenReturn([]);
    tabs = TerminalTabBloc();
    sessions = SessionController(store: store, tabs: tabs);
    themeBloc = _MockThemeBloc();
    when(() => themeBloc.state)
        .thenReturn(const DmThemeState(themeName: 'test'));
    settingsBloc = _MockTerminalSettingsBloc();
    when(() => settingsBloc.state).thenReturn(const TerminalSettingsLoaded());
    profilesBloc = _MockShellProfileBloc();
    when(() => profilesBloc.state).thenReturn(const ShellProfileLoaded([]));
    webBloc = _MockWebSessionBloc();
    when(() => webBloc.state).thenReturn(const WebSessionState.initial());
    router = GoRouter(
      initialLocation: '/settings/sessions',
      routes: [
        settingRoute,
        GoRoute(
          name: Destinations.terminalScreenName,
          path: '/terminal',
          builder: (context, state) => const Scaffold(body: Text('Terminal')),
        ),
        GoRoute(
          name: Destinations.webTerminalScreenName,
          path: '/web-terminal',
          builder: (context, state) =>
              const Scaffold(body: Text('Web Terminal')),
        ),
      ],
    );
  });

  tearDown(() async {
    router.dispose();
    sessions.dispose();
    await tabs.close();
    await themeBloc.close();
    await settingsBloc.close();
    await profilesBloc.close();
    await webBloc.close();
    AppAdaptiveScaffold.navigationRailExtendedNotifier.value = null;
  });

  Future<void> pumpScreen(WidgetTester tester, {double width = 1440}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ChangeNotifierProvider<SessionController>.value(
        value: sessions,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<DmThemeBloc>.value(value: themeBloc),
            BlocProvider<TerminalSettingsBloc>.value(value: settingsBloc),
            BlocProvider<ShellProfileBloc>.value(value: profilesBloc),
            BlocProvider<WebSessionBloc>.value(value: webBloc),
          ],
          child: MaterialApp.router(
            theme: ThemeData(platform: TargetPlatform.macOS),
            localizationsDelegates: AppLocale.localizationsDelegates,
            supportedLocales: AppLocale.supportedLocales,
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('keeps app navigation and settings beside history on desktop', (
    tester,
  ) async {
    await pumpScreen(tester);

    final rail = find.byType(NavigationRail);
    expect(rail, findsOneWidget);
    expect(tester.widget<NavigationRail>(rail).selectedIndex, 2);
    final settings = find.byType(RootSettingList);
    final emptyHistory = find.text('No saved sessions yet.');
    expect(settings, findsOneWidget);
    expect(emptyHistory, findsOneWidget);
    expect(
      tester.getRect(settings).right,
      lessThanOrEqualTo(tester.getRect(emptyHistory).left),
    );
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(
      find.descendant(of: rail, matching: find.byIcon(Icons.terminal_outlined)),
    );
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/terminal');
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('returns to settings in a single pane desktop window', (
    tester,
  ) async {
    await pumpScreen(tester, width: 1000);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(RootSettingList), findsNothing);
    expect(find.text('No saved sessions yet.'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, SettingsScreen.path);
    expect(find.byType(RootSettingList), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('restores a saved session and returns to terminal', (
    tester,
  ) async {
    final snapshot = SessionSnapshot(
      id: 'saved-workspace',
      kind: SessionSnapshotKind.workspace,
      createdAt: DateTime.utc(2026, 11, 16),
      name: 'Work tabs',
      layout: {
        'tabs': [
          {'type': 'local'},
        ],
      },
    );
    when(() => store.saved).thenReturn([snapshot]);
    await pumpScreen(tester);

    expect(find.text('Work tabs'), findsOneWidget);
    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();

    expect(sessions.requestedRestore, same(snapshot));
    expect(router.routeInformationProvider.value.uri.path, '/terminal');
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
