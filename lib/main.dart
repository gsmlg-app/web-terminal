import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gsmlg_security/gsmlg_security.dart';
import 'package:app_theme/app_theme.dart';
import 'package:theme_bloc/theme_bloc.dart';
import 'package:gsmlg_utils/gsmlg_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_terminal/app.dart';
import 'package:web_terminal/constant.dart';
import 'package:app_database/app_database.dart';
import 'package:connection_bloc/connection_bloc.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:app_provider/app_provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (PlatformExt.isDesktop) {
    await initWindow();
  }

  final sharedPrefs = await SharedPreferences.getInstance();
  final database = AppDatabase();

  runApp(
    ProviderScope(
      observers: const [ProviderLogger()],
      child: MultiRepositoryProvider(
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
          RepositoryProvider<AesHelper>(
            create: (BuildContext context) => AesHelper(Constant.appName),
          ),
        ],
        child: MultiBlocProvider(providers: [
          BlocProvider<ThemeBloc>(
            create: (BuildContext context) => ThemeBloc(
              sharedPrefs,
            ),
          ),
          BlocProvider<SshKeyBloc>(
            create: (BuildContext context) => SshKeyBloc(
              database,
            ),
          ),
          BlocProvider<SshKeyFormBloc>(
            create: (BuildContext context) => SshKeyFormBloc(
              context.read<SshKeyBloc>(),
            ),
          ),
          BlocProvider<SshHostBloc>(
            create: (BuildContext context) => SshHostBloc(
              database,
            ),
          ),
          BlocProvider<SshHostFormBloc>(
            create: (BuildContext context) => SshHostFormBloc(
              context.read<SshHostBloc>(),
            ),
          ),
          BlocProvider<TerminalTabBloc>(
            create: (BuildContext context) => TerminalTabBloc(),
          ),
          BlocProvider<ConnectionBloc>(
            create: (BuildContext context) => ConnectionBloc(),
          ),
        ], child: const App()),
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
