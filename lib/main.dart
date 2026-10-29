import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_security/app_security.dart';
import 'package:theme_bloc/theme_bloc.dart';
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

  if (PlatformExt.isDesktop) {
    await initWindow();
  }

  final sharedPrefs = await SharedPreferences.getInstance();
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
          BlocProvider<TerminalTabBloc>(
            create: (BuildContext context) => TerminalTabBloc(),
          ),
          BlocProvider<TerminalSettingsBloc>(
            create: (BuildContext context) => TerminalSettingsBloc(
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
        child: const App(),
      ),
    ),
  );
}

Future<void> initWindow() async {
  await windowManager.ensureInitialized();
  // await windowManager.setTitle('Web Terminal');

  if (defaultTargetPlatform != TargetPlatform.macOS) {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    // backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    minimumSize: Size(360, 720),
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
