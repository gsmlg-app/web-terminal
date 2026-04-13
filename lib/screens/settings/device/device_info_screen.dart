import 'package:flutter/material.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:web_terminal/destinations.dart';

class DeviceInfoScreen extends StatelessWidget {
  static const name = SettingsScreenNames.deviceInfo;
  static const path = 'device-info';
  const DeviceInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String title = 'Device Info';

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
                  SettingsSectionDeviceInfo.build(context),
                ],
              ),
            ),
          ],
        ),
      ),
      largeBody: (context) => const SafeArea(
        child: RootSettingList(config: rootSettingListConfig),
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
                  SettingsSectionDeviceInfo.build(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
