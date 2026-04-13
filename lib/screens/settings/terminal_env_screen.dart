import 'package:flutter/material.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:web_terminal/destinations.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';

class TerminalEnvScreen extends StatelessWidget {
  static const name = SettingsScreenNames.terminalEnv;
  static const path = 'terminal-env';

  const TerminalEnvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreenNames.settings),
        context,
      ),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(
        idx,
        context,
      ),
      destinations: Destinations.navs(context),
      body: (context) => SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            const SliverAppBar(
              title: Text('Environment Variables'),
            ),
            const SliverFillRemaining(
              child: EnvSettingsList(),
            ),
          ],
        ),
      ),
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
      largeBody: (context) => const SafeArea(
        child: RootSettingList(config: rootSettingListConfig),
      ),
      largeSecondaryBody: (_) => SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: const <Widget>[
            SliverAppBar(
              title: Text('Environment Variables'),
              automaticallyImplyLeading: false,
            ),
            SliverFillRemaining(
              child: EnvSettingsList(),
            ),
          ],
        ),
      ),
    );
  }
}
