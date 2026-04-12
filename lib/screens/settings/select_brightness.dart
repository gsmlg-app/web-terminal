import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:theme_bloc/theme_bloc.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:web_terminal/destinations.dart';
import 'package:app_locale/app_locale.dart';

class SettingsSelectBrightness extends StatelessWidget {
  static const name = SettingsScreenNames.selectBrightness;
  static const path = 'select_brightness';

  static const String fullPath = '${SettingsScreen.path}/$path';
  const SettingsSelectBrightness({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();

    return AppAdaptiveScaffold(
      selectedIndex:
          Destinations.indexOf(const Key(SettingsScreen.name), context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(
        idx,
        context,
      ),
      destinations: Destinations.navs(context),
      body: (context) => SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              title: Text(context.l10n.titleSelectAppearance),
            ),
            BlocBuilder<ThemeBloc, ThemeState>(
              bloc: themeBloc,
              builder: (context, state) {
                return SliverFillRemaining(
                  child: SettingsList(
                    sections: [
                      BlocSettingsSectionAppearance.buildSection(context),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      largeBody: (context) => SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              title: Text(context.l10n.settingsTitle),
              automaticallyImplyLeading: false,
            ),
            SliverFillRemaining(
              child: RootSettingList(config: rootSettingListConfig),
            ),
          ],
        ),
      ),
      largeSecondaryBody: (_) => SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              title: Text(context.l10n.titleSelectAppearance),
              automaticallyImplyLeading: false,
            ),
            BlocBuilder<ThemeBloc, ThemeState>(
              bloc: themeBloc,
              builder: (context, state) {
                return SliverFillRemaining(
                  child: SettingsList(
                    sections: [
                      BlocSettingsSectionAppearance.buildSection(context),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
