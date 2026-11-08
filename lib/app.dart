import 'package:context_menus/context_menus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_feedback/app_feedback.dart';
import 'package:app_locale/app_locale.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:theme_bloc/theme_bloc.dart';
import 'package:web_terminal/router.dart';
import 'package:web_terminal/screens/terminal/close_confirmation.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<DmThemeBloc>();

    return BlocBuilder<DmThemeBloc, DmThemeState>(
      bloc: themeBloc,
      builder: (context, state) {
        Widget app = MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          themeMode: state.themeMode,
          theme: state.entry.light,
          darkTheme: state.entry.dark,
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          builder: (context, child) {
            return AppExitGuard(
              navigatorKey: navigatorKey,
              interceptWindowClose:
                  !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS,
              child: ContextMenuOverlay(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );

        if (defaultTargetPlatform == TargetPlatform.macOS) {
          app = GlobalPlatformMenu(child: app);
        }

        return app;
      },
    );
  }
}
