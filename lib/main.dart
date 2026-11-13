import 'dart:async';
import 'dart:io';

import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:app_locale/app_locale.dart';
import 'package:hive_ce/hive_ce.dart';

import 'services/session_store.dart';
import 'services/session_controller.dart';
import 'services/desktop_instance.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_security/app_security.dart';
import 'package:app_utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_terminal/app.dart';
import 'package:web_terminal/constant.dart';
import 'package:web_terminal/web_client_assets.dart';
import 'package:app_database/app_database.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:window_manager/window_manager.dart';
import 'package:web_session_bloc/web_session_bloc.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDir = await getApplicationSupportDirectory();
  DesktopInstance? instance;
  if (PlatformExt.isDesktop) {
    instance = await DesktopInstance.acquire(
      appDir,
      onActivate: () async {
        final window = WindowManager.instance.getCurrent();
        window?.show();
        window?.focus();
      },
    );
    if (instance == null) exit(0);
    await initWindow();
  }
  final sharedPrefs = await SharedPreferences.getInstance();
  final SessionStore store;
  final Box<dynamic> configuration;
  try {
    configuration = await Hive.openBox<dynamic>(
      'preferences',
      path: appDir.path,
    );
    store = await SessionStore.open(
      Directory(path.join(appDir.path, 'sessions')),
      legacy: sharedPrefs.getString('terminal.open_tabs.v1'),
    );
  } catch (error) {
    runApp(
      MaterialApp(
        localizationsDelegates: AppLocale.localizationsDelegates,
        supportedLocales: AppLocale.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SelectableText(
                  '${context.l10n.sessionStorageUnavailable}\n$error',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }
  final tabs = TerminalTabBloc();
  final sessions = SessionController(store: store, tabs: tabs);
  final savedRailExtended = sharedPrefs.getBool('app_navigation_rail_extended');
  if (savedRailExtended != null) {
    AppAdaptiveScaffold.navigationRailExtendedNotifier.value =
        savedRailExtended;
  }
  AppAdaptiveScaffold.navigationRailExtendedNotifier.addListener(() {
    final val = AppAdaptiveScaffold.navigationRailExtendedNotifier.value;
    if (val != null) {
      sharedPrefs.setBool('app_navigation_rail_extended', val);
    }
  });

  final database = AppDatabase();
  final credentials = SshCredentialRepository(database);

  // Get static files path for web server
  // In debug mode, use the source directory directly for hot reload
  String staticFilesPath;
  if (kDebugMode) {
    // Use the source web client directory during development
    staticFilesPath = path.join(
      Directory.current.path,
      'web',
      'terminal-client',
      'dist',
    );
  } else {
    // In release mode, use the app's data directory
    final appDir = await getApplicationSupportDirectory();
    staticFilesPath = (await materializeWebClientAssets(appDir)).path;
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        ChangeNotifierProvider<SessionController>.value(value: sessions),
        RepositoryProvider<SharedPreferences>(
          create: (BuildContext context) => sharedPrefs,
        ),
        RepositoryProvider<FlutterSecureStorage>(
          create: (BuildContext context) => const FlutterSecureStorage(),
        ),
        RepositoryProvider<AppDatabase>(
          create: (BuildContext context) => database,
        ),
        RepositoryProvider<SshCredentialRepository>.value(value: credentials),
        RepositoryProvider<SshHostKeyStore>(
          create: (BuildContext context) => SshHostKeyStore(),
        ),
        RepositoryProvider<AesHelper>(
          create: (BuildContext context) => AesHelper(Constant.appName),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DmThemeBloc>(
            create: (BuildContext context) => DmThemeBloc(prefs: sharedPrefs),
          ),
          BlocProvider<SshKeyBloc>(
            lazy: false,
            create: (BuildContext context) =>
                SshKeyBloc(database, credentials: credentials)
                  ..add(SshKeyLoad()),
          ),
          BlocProvider<SshKeyFormBloc>(
            create: (BuildContext context) =>
                SshKeyFormBloc(context.read<SshKeyBloc>()),
          ),
          BlocProvider<SshHostBloc>(
            lazy: false,
            create: (BuildContext context) =>
                SshHostBloc(database, credentials: credentials)
                  ..add(SshHostLoad()),
          ),
          BlocProvider<SshHostFormBloc>(
            create: (BuildContext context) =>
                SshHostFormBloc(context.read<SshHostBloc>()),
          ),
          BlocProvider<TerminalTabBloc>.value(value: tabs),
          BlocProvider<TerminalSettingsBloc>(
            create: (BuildContext context) => TerminalSettingsBloc(
              preferences: sharedPrefs,
              configuration: configuration,
              vault: SecureStorageVaultRepository(
                storage: context.read<FlutterSecureStorage>(),
                namespace: 'terminal',
              ),
            )..add(const TerminalSettingsLoad()),
          ),
          BlocProvider<WebSessionBloc>(
            create: (BuildContext context) {
              debugPrint(
                '[Main] Creating WebSessionBloc with debugMode=$kDebugMode',
              );
              debugPrint('[Main] Static files path: $staticFilesPath');
              return WebSessionBloc(
                staticFilesPath: staticFilesPath,
                debugMode: kDebugMode,
                sharedPreferences: sharedPrefs,
              );
            },
          ),
          BlocProvider<ShellProfileBloc>(
            create: (BuildContext context) =>
                ShellProfileBloc(database)..add(const EnsureDefaultProfile()),
          ),
        ],
        child: Builder(
          builder: (context) {
            Future<void>? closing;
            return App(
              onBeforeExit: () {
                final web = context.read<WebSessionBloc>();
                final hostForm = context.read<SshHostFormBloc>();
                final keyForm = context.read<SshKeyFormBloc>();
                final hosts = context.read<SshHostBloc>();
                final keys = context.read<SshKeyBloc>();
                final profiles = context.read<ShellProfileBloc>();
                final settings = context.read<TerminalSettingsBloc>();
                return closing ??= () async {
                  try {
                    await sessions.prepareExit();
                    await sessions.finishExit();
                  } catch (_) {
                    sessions.resumeAfterCanceledExit();
                    closing = null;
                    rethrow;
                  }
                  await _closeForExit(web.close);
                  final state = tabs.state;
                  if (state is TerminalTabLoaded) {
                    final managers = state.allTabs
                        .whereType<PluginTab>()
                        .map((tab) => tab.manager)
                        .toSet();
                    for (final manager in managers) {
                      await _closeForExit(manager.closeForAppExit);
                    }
                  }
                  await _closeForExit(hostForm.close);
                  await _closeForExit(keyForm.close);
                  await _closeForExit(hosts.close);
                  await _closeForExit(keys.close);
                  await _closeForExit(profiles.close);
                  await _closeForExit(settings.close);
                  await _closeForExit(database.close);
                  await _closeForExit(store.close);
                  await _closeForExit(configuration.close);
                  await instance?.close();
                }();
              },
            );
          },
        ),
      ),
    ),
  );
}

Future<void> initWindow() async {
  final window = WindowManager.instance.getCurrent();
  if (window == null) return;
  window
    ..titleBarStyle = TitleBarStyle.normal
    ..isVisibleInTaskbar = true
    ..minimumSize = const Size(360, 720).toNative()
    ..setSize(const Size(800, 600).toNative(), false)
    ..center()
    ..show()
    ..focus();
}

Future<void> _closeForExit(Future<void> Function() close) async {
  try {
    await close();
  } catch (error, stack) {
    debugPrint('Failed to close app resource: $error\n$stack');
  }
}
