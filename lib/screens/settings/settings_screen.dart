import 'package:flutter/material.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:web_terminal/src/components/destinations.dart';
import 'package:web_terminal/src/components/setting/root_setting_list.dart';
import 'package:web_terminal/src/extensions/buildcontext/l10n.dart';

class SettingsScreen extends StatelessWidget {
  static const name = 'Settings';
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
              child: RootSettingList(),
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
              child: RootSettingList(),
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
