import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_terminal/src/core/conn.dart';
import 'package:web_terminal/src/core/fs.dart';
import 'package:web_terminal/src/core/plugin.dart';
import 'package:web_terminal/src/plugins/terminal/terminal_plugin.dart';
import 'package:web_terminal/src/ui/tabs/code_editor_tab.dart';
import 'package:web_terminal/src/ui/tabs/plugin_tab.dart';

class TabsService {
  // final Ref ref;

  // TabsService(this.ref);
  TabsService();

  void openTerminal(HostSpec hostSpec, {Tabs? tabs, bool activate = true}) {
    return openPlugin(hostSpec, TerminalPlugin(),
        tabs: tabs, activate: activate);
  }

  void openPlugin(
    HostSpec host,
    Plugin plugin, {
    Tabs? tabs,
    bool activate = true,
  }) {
    final manager = PluginManager(host);
    openTab(
      PluginTab(plugin, manager),
      tabs: tabs,
      activate: activate,
    );
  }

  void openFile(File file, {Tabs? tabs, bool activate = true}) {
    openTab(CodeEditorTab(file), tabs: tabs, activate: activate);
  }

  void openTab(TabItem tab, {Tabs? tabs, bool activate = true}) {
    final targetTabGroup = tabs;

    if (targetTabGroup == null) {
      return;
    }

    targetTabGroup.add(tab);

    if (activate) {
      tab.activate();
    }
  }
}

final tabsServiceProvider = Provider(
  name: 'tabsServiceProvider',
  (ref) => TabsService(),
);
