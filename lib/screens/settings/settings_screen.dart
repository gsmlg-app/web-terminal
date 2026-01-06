import 'package:flutter/material.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:app_locale/app_locale.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';

class SettingsScreen extends StatelessWidget {
  static const name = SettingsScreenNames.settings;
  static const path = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(const Key(name), context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(
        idx,
        context,
      ),
      destinations: Destinations.navs(context),
      body: (context) => SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: Text(context.l10n.settingsTitle),
            ),
            const SliverFillRemaining(
              child: RootSettingList(config: rootSettingListConfig),
            ),
          ],
        ),
      ),
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
      largeBody: (context) => SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              title: Text(context.l10n.settingsTitle),
            ),
            const SliverFillRemaining(
              child: RootSettingList(config: rootSettingListConfig),
            ),
          ],
        ),
      ),
      largeSecondaryBody: (_) => SafeArea(
        child: Container(),
      ),
    );
  }
}
