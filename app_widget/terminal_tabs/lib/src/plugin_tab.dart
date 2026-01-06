import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:terminal_core/terminal_core.dart';

class PluginTab extends TabItem {
  final Plugin plugin;

  final PluginManager manager;

  PluginTab(this.plugin, this.manager) {
    manager.add(plugin);

    _updateTitle();

    plugin.title.addListener(_updateTitle);

    manager.addListener(_onPluginManagerChanged);

    content.value = PluginTabView(
      key: ValueKey(plugin),
      plugin,
    );
  }

  @override
  void didDispose() {
    if (plugin.mounted) {
      manager.remove(plugin);
    }
    plugin.title.removeListener(_updateTitle);
    manager.removeListener(_onPluginManagerChanged);
    super.didDispose();
  }

  void _updateTitle() {
    final titleWidget = plugin.title.value;
    title.value = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (titleWidget != null)
          Flexible(
            child: Text(
              titleWidget,
              softWrap: false,
            ),
          ),
        if (titleWidget != null) const SizedBox(width: 4),
        Text(
          manager.hostSpec.name,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  void _onPluginManagerChanged() {
    if (!plugin.mounted) {
      detach();
    }
  }
}

class PluginTabView extends ConsumerStatefulWidget {
  const PluginTabView(this.plugin, {super.key});

  final Plugin plugin;

  @override
  ConsumerState<PluginTabView> createState() => _PluginTabViewState();
}

class _PluginTabViewState extends ConsumerState<PluginTabView> {
  Plugin get plugin => widget.plugin;

  HostConnector? connector;

  RemoveListener? _connectorListener;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        connector = widget.plugin.hostSpec.createConnector();
        _connectorListener = connector?.addListener(_onConnectionChanged);
        connector?.connect().then((_) {
          widget.plugin.manager.didConnected(connector!.host!);
        });
      });
    });
  }

  void _onConnectionChanged(HostConnectorStatus status) {
    plugin.manager.didConnectionStatusChanged(status);
  }

  @override
  void dispose() {
    _connectorListener?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return plugin.build(context);
  }
}
