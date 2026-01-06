import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:app_theme/app_theme.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';
import 'package:web_terminal/src/components/destinations.dart';
import 'package:web_terminal/src/components/setting/root_setting_list.dart';
import 'package:web_terminal/src/extensions/buildcontext/l10n.dart';

class SettingsSelectBrightness extends StatelessWidget {
  static const name = 'Select Brightness';
  static const path = 'select_brightness';

  static const String fullPath = '${SettingsScreen.path}/$path';
  const SettingsSelectBrightness({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();

    return GAdaptiveScaffold(
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
            const SliverFillRemaining(
              child: RootSettingList(),
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
