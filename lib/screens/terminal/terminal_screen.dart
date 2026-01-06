import 'dart:async';

import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:web_terminal/src/components/destinations.dart';
import 'package:web_terminal/src/core/plugin.dart';
import 'package:web_terminal/src/core/service/tabs_service.dart';
import 'package:web_terminal/src/hosts/local_spec.dart';
import 'package:web_terminal/src/plugins/terminal/terminal_plugin.dart';
import 'package:web_terminal/src/ui/context_menu.dart';
import 'package:web_terminal/src/ui/platform_menu.dart';
import 'package:web_terminal/src/ui/shared/app_menu_card.dart';
import 'package:web_terminal/src/ui/shortcut/global_actions.dart';
import 'package:web_terminal/src/ui/shortcut/global_shortcuts.dart';
import 'package:web_terminal/src/ui/tabs/plugin_tab.dart';
import 'package:window_manager/window_manager.dart';

class TerminalScreen extends ConsumerStatefulWidget {
  static const name = 'TerminalScreen';
  static const path = '/terminal';

  const TerminalScreen({super.key});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  GlobalKey<ContextMenuOverlayState> contextMenuOverlayKey =
      GlobalKey<ContextMenuOverlayState>();

  @override
  void initState() {
    super.initState();
    context.read<TerminalTabBloc>().add(TerminalTabStart());
  }

  @override
  void dispose() {
    context.read<TerminalTabBloc>().add(TerminalTabStop());
    super.dispose();
  }

  Future<void> initTabs() async {
    final root = Tabs();

    ref.read(tabsServiceProvider).openTerminal(LocalHostSpec(), tabs: root);
  }

  @override
  Widget build(BuildContext context) {
    final tabsTheme = TabsViewThemeData(
      selectedLabelColor: Theme.of(context).colorScheme.onPrimary,
      labelColor: Theme.of(context).colorScheme.onSecondary,
      selectedBackgroundColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      hoverBackgroundColor: Theme.of(context).colorScheme.secondary,
      tabSeparatorColor: Theme.of(context).colorScheme.surface,
      groupDividerColor: Theme.of(context).colorScheme.surface,
      groupDividerThickness: Theme.of(context).dividerTheme.thickness ?? 4,
      selctedCloseButtonColor: Theme.of(context).colorScheme.onPrimary,
      closeButtonColor: Theme.of(context).colorScheme.onSecondary,
    );

    Widget widget = GlobalShortcuts(
      child: GlobalActions(
        child: ContextMenuOverlay(
          key: contextMenuOverlayKey,
          cardBuilder: (context, children) => AppMenuCard(children: children),
          child: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverFillRemaining(
                  child: BlocBuilder<TerminalTabBloc, TerminalTabState>(
                      builder: (context, state) {
                    if (state is! TerminalTabLoaded) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return TabsView(
                      state.tabsDocument,
                      theme: tabsTheme,
                      actionBuilder: buildTabActions(context),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      widget = GlobalPlatformMenu(
        child: widget,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.windows) {
      widget = VirtualWindowFrame(child: widget);
    }

    return AppAdaptiveScaffold(
      selectedIndex:
          Destinations.indexOf(const Key(TerminalScreen.name), context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(
        idx,
        context,
      ),
      destinations: Destinations.navs(context),
      body: (context) => widget,
    );
  }

  List<TabsViewAction> Function(Tabs) buildTabActions(BuildContext context) =>
      (Tabs tabs) {
        return [
          TabsViewAction(
            icon: CupertinoIcons.chevron_down,
            onPressed: () {
              final ContextMenuOverlayState? overlay =
                  contextMenuOverlayKey.currentState;
              overlay?.show(
                DropdownContextMenu(tabs),
              );
            },
          ),
          TabsViewAction(
            icon: CupertinoIcons.add,
            onPressed: () {
              final plugin = TerminalPlugin();
              final manager = PluginManager(LocalHostSpec());
              final tabItem = PluginTab(plugin, manager);
              context.read<TerminalTabBloc>().add(TerminalTabOpenTab(tabItem));
            },
          ),
        ];
      };
}
