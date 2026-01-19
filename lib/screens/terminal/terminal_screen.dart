import 'dart:async';

import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:web_terminal/destinations.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:window_manager/window_manager.dart';

class TerminalScreen extends StatefulWidget {
  static const name = 'TerminalScreen';
  static const path = '/terminal';

  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  GlobalKey<ContextMenuOverlayState> contextMenuOverlayKey =
      GlobalKey<ContextMenuOverlayState>();

  late final TerminalTabBloc _terminalTabBloc;
  StreamSubscription<TerminalTabState>? _stateSubscription;
  bool _initialTabOpened = false;

  @override
  void initState() {
    super.initState();
    _terminalTabBloc = context.read<TerminalTabBloc>();
    _terminalTabBloc.add(TerminalTabStart());
    // Listen for state changes to open initial tab when loaded
    _stateSubscription = _terminalTabBloc.stream.listen(_onStateChanged);
    // Also check immediately in case state is already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryOpenInitialTab();
    });
  }

  void _onStateChanged(TerminalTabState state) {
    _tryOpenInitialTab();
  }

  void _tryOpenInitialTab() {
    if (_initialTabOpened) return;
    final state = _terminalTabBloc.state;
    if (state is TerminalTabLoaded && state.tabs.children.isEmpty) {
      _initialTabOpened = true;
      final plugin = TerminalPlugin();
      final manager = PluginManager(LocalHostSpec());
      final tabItem = PluginTab(plugin, manager);
      _terminalTabBloc.add(TerminalTabOpenTab(tabItem));
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _terminalTabBloc.add(TerminalTabStop());
    super.dispose();
  }

  Future<void> initTabs() async {
    final root = Tabs();

    context.read<TabsService>().openPlugin(
          LocalHostSpec(),
          TerminalPlugin(),
          tabs: root,
        );
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

    // Wrap with Actions to handle fullscreen toggle
    widget = Actions(
      actions: {
        ToggleFullscreenIntent: CallbackAction<ToggleFullscreenIntent>(
          onInvoke: (_) {
            _terminalTabBloc.add(TerminalTabToggleFullscreen());
            return null;
          },
        ),
      },
      child: Focus(
        autofocus: true,
        child: widget,
      ),
    );

    return BlocBuilder<TerminalTabBloc, TerminalTabState>(
      buildWhen: (previous, current) {
        // Only rebuild when fullscreen state changes
        if (previous is TerminalTabLoaded && current is TerminalTabLoaded) {
          return previous.isFullscreen != current.isFullscreen;
        }
        return true;
      },
      builder: (context, state) {
        final isFullscreen =
            state is TerminalTabLoaded ? state.isFullscreen : false;

        return AppAdaptiveScaffold(
          selectedIndex:
              Destinations.indexOf(const Key(TerminalScreen.name), context),
          onSelectedIndexChange: (idx) => Destinations.changeHandler(
            idx,
            context,
          ),
          destinations: Destinations.navs(context),
          hideNavigation: isFullscreen,
          body: (context) => widget,
        );
      },
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
