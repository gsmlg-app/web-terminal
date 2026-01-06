import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_feedback/app_feedback.dart';
import 'package:app_theme/app_theme.dart';
import 'package:web_terminal/l10n/l10n.dart';
import 'package:web_terminal/router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();

    return BlocBuilder<ThemeBloc, ThemeState>(
      bloc: themeBloc,
      builder: (context, state) {
        return MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          themeMode: state.themeMode,
          theme: state.theme.lightTheme,
          darkTheme: state.theme.darkTheme,
          localizationsDelegates: L10n.localizationsDelegates,
          supportedLocales: L10n.supportedLocales,
        );
      },
    );
  }
}
