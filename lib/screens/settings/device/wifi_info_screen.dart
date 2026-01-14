import 'package:flutter/material.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:web_terminal/destinations.dart';
import 'package:app_locale/app_locale.dart';

class WifiInfoScreen extends StatelessWidget {
  static const name = SettingsScreenNames.wifiInfo;
  static const path = 'wifi-info';
  const WifiInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String title = 'Wifi Info';

    return AppAdaptiveScaffold(
      selectedIndex:
          Destinations.indexOf(const Key(SettingsScreen.name), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (context) => SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text(title),
            ),
            SliverFillRemaining(
              child: SettingsList(
                sections: [
                  SettingsSectionWifiInfo.build(context),
                ],
              ),
            ),
          ],
        ),
      ),
      largeBody: (context) => SafeArea(
        child: CustomScrollView(
          slivers: [
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
      largeSecondaryBody: (context) => SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
            ),
            SliverFillRemaining(
              child: SettingsList(
                sections: [
                  SettingsSectionWifiInfo.build(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
