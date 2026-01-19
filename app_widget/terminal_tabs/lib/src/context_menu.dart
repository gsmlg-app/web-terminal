import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_tabs/src/plugin_tab.dart';

class DropdownContextMenu extends StatefulWidget {
  const DropdownContextMenu(this.tabs, {super.key});

  final Tabs tabs;

  @override
  DropdownContextMenuState createState() => DropdownContextMenuState();
}

class DropdownContextMenuState extends State<DropdownContextMenu>
    with ContextMenuStateMixin {
  Tabs get tabs => widget.tabs;

  @override
  void initState() {
    super.initState();
    // Load SSH hosts if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<SshHostBloc>().state;
      if (state is! SshHostLoaded) {
        context.read<SshHostBloc>().add(SshHostLoad());
      }
    });
  }

  void _openLocalTerminal(BuildContext context) {
    handlePressed(context, () {
      final plugin = TerminalPlugin();
      final manager = PluginManager(createDefaultHostSpec());
      final tabItem = PluginTab(plugin, manager);
      context.read<TerminalTabBloc>().add(TerminalTabOpenTab(tabItem));
    });
  }

  void _openSSHTerminal(BuildContext context, SshHost host) {
    handlePressed(context, () {
      final plugin = TerminalPlugin();
      final manager = PluginManager(SSHHostSpec(host));
      final tabItem = PluginTab(plugin, manager);
      context.read<TerminalTabBloc>().add(TerminalTabOpenTab(tabItem));
    });
  }

  @override
  Widget build(BuildContext context) {
    return cardBuilder(context, [
      // Local terminal option
      buttonBuilder(
        context,
        ContextMenuButtonConfig(
          'Local',
          icon: const Icon(Icons.computer),
          iconHover: const Icon(Icons.computer_outlined),
          onPressed: () => _openLocalTerminal(context),
        ),
      ),

      // SSH hosts section
      BlocBuilder<SshHostBloc, SshHostState>(
        builder: (context, state) {
          if (state is! SshHostLoaded || state.sshHosts.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 8),
              ...state.sshHosts.map(
                (host) => buttonBuilder(
                  context,
                  ContextMenuButtonConfig(
                    host.host ?? host.hostname ?? 'SSH Host',
                    icon: const Icon(Icons.dns),
                    iconHover: const Icon(Icons.dns_outlined),
                    onPressed: () => _openSSHTerminal(context, host),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ]);
  }
}
