import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:terminal_tabs/src/playground.dart';
import 'package:xterm/xterm.dart';

class DevToolsTab extends TabItem {
  DevToolsTab() {
    title.value = const Text('DevTools');
    content.value = DevToolsTabView(this);
  }

  final terminal = Terminal();
}

class DevToolsTabView extends StatefulWidget {
  const DevToolsTabView(this.tab, {super.key});

  final DevToolsTab tab;

  @override
  State<DevToolsTabView> createState() => _DevToolsTabViewState();
}

class _DevToolsTabViewState extends State<DevToolsTabView> {
  DevToolsTab get tab => widget.tab;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        constraints: const BoxConstraints.expand(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                PushButton(
                  controlSize: ControlSize.large,
                  onPressed: _openAddHostTab,
                  child: const Text('Add SSH host'),
                ),
                PushButton(
                  controlSize: ControlSize.large,
                  onPressed: _clearHosts,
                  child: const Text('Clear SSH hosts'),
                ),
                PushButton(
                  controlSize: ControlSize.large,
                  onPressed: () => tab.replace(PlaygroundTab()),
                  child: const Text('Playground'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Expanded(child: TerminalView(tab.terminal)),
            // const PlayGround(),
          ],
        ),
      ),
    );
  }

  void _openAddHostTab() {
    // TODO: Integrate with app's tab opening mechanism
    // ref.openTab(AddHostTab());
  }

  void _clearHosts() async {
    tab.terminal.write('Cleared SSH hosts\r\n');
  }
}

class PlayGround extends StatelessWidget {
  const PlayGround({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(16),
      color: const Color.fromARGB(255, 251, 251, 251),
      // child:
    );
  }
}
