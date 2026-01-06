import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';
import 'package:web_terminal/src/components/destinations.dart';
import 'package:web_terminal/src/components/setting/root_setting_list.dart';
import 'package:web_terminal/src/extensions/buildcontext/l10n.dart';

class WifiInfoScreen extends ConsumerWidget {
  static const name = 'Wifi Info';
  static const path = 'wifi-info';
  const WifiInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const String title = 'Wifi Info';

    return GAdaptiveScaffold(
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
                  SettingsSectionWifiInfo.build(context, ref),
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
            const SliverFillRemaining(
              child: RootSettingList(),
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
                  SettingsSectionWifiInfo.build(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
