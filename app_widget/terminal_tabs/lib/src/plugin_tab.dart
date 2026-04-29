import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

class PluginTab extends TabItem {
  static int _nextTabNumber = 1;

  final Plugin plugin;

  final PluginManager manager;

  final int tabNumber;

  PluginTab(this.plugin, this.manager) : tabNumber = _nextTabNumber++ {
    manager.add(plugin);

    _updateTitle();

    plugin.title.addListener(_updateTitle);

    manager.addListener(_onPluginManagerChanged);

    content.value = PluginTabView(key: ValueKey(plugin), plugin);
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
    final titleText = displayTitle;
    title.value = Row(
      mainAxisSize: MainAxisSize.min,
      children: [Flexible(child: Text(titleText, softWrap: false))],
    );
  }

  String get displayTitle {
    final workingDirectory = _extractWorkingDirectory(plugin.title.value);
    final prefix = '$tabNumber';
    if (manager.hostSpec is SSHHostSpec) {
      final sshHostSpec = manager.hostSpec as SSHHostSpec;
      return '$prefix ${sshHostSpec.name} $workingDirectory';
    }
    return '$prefix $workingDirectory';
  }

  String _extractWorkingDirectory(String? title) {
    final cleaned = _removeTerminalSize(title?.trim() ?? '');
    final directory = _parseWorkingDirectory(cleaned);
    if (directory != null) return directory;

    if (manager.hostSpec is LocalHostSpec) {
      final localHostSpec = manager.hostSpec as LocalHostSpec;
      final configuredDirectory = localHostSpec.workingDirectory;
      if (configuredDirectory != null && configuredDirectory.isNotEmpty) {
        return configuredDirectory;
      }
    }

    return '~';
  }

  String _removeTerminalSize(String title) {
    return title
        .replaceFirst(RegExp(r'\s*[—-]\s*\d+x\d+\s*$'), '')
        .replaceFirst(RegExp(r'\s+\d+x\d+\s*$'), '')
        .trim();
  }

  String? _parseWorkingDirectory(String title) {
    if (title.isEmpty) return null;
    if (_isConnectionStatus(title)) return null;
    if (_looksLikeDirectory(title)) return title;

    final colonIndex = title.lastIndexOf(':');
    if (colonIndex >= 0 && colonIndex < title.length - 1) {
      final afterColon = title.substring(colonIndex + 1).trim();
      if (_looksLikeDirectory(afterColon)) {
        return afterColon;
      }
    }

    final spaceParts = title.split(RegExp(r'\s+'));
    for (final part in spaceParts.reversed) {
      if (_looksLikeDirectory(part)) return part;
    }

    return null;
  }

  bool _isConnectionStatus(String title) {
    return switch (title) {
      'Connecting' ||
      'Terminal' ||
      'Disconnected' ||
      'Connection Failed' => true,
      _ => false,
    };
  }

  bool _looksLikeDirectory(String value) {
    if (value == '~') return true;
    return value.startsWith('~/') ||
        value.startsWith('/') ||
        RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value);
  }

  void _onPluginManagerChanged() {
    if (!plugin.mounted) {
      detach();
    }
  }
}

class PluginTabView extends StatefulWidget {
  const PluginTabView(this.plugin, {super.key});

  final Plugin plugin;

  @override
  State<PluginTabView> createState() => _PluginTabViewState();
}

class _PluginTabViewState extends State<PluginTabView> {
  Plugin get plugin => widget.plugin;

  HostConnector? connector;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Guard: plugin may have been detached if tab was closed during build.
      if (!widget.plugin.mounted) return;

      // Skip if already connected (e.g., during hot reload)
      if (widget.plugin.manager.isConnected) {
        return;
      }

      setState(() {
        connector = widget.plugin.hostSpec.createConnector();
        connector?.addListener(_onConnectionChanged);
        connector?.connect().then((_) {
          if (!mounted) return;
          if (connector?.host != null) {
            widget.plugin.manager.didConnected(connector!.host!);
          } else if (connector?.lastError != null) {
            widget.plugin.manager.didConnectionError(connector!.lastError!);
          }
        });
      });
    });
  }

  void _onConnectionChanged() {
    if (connector != null && plugin.mounted) {
      plugin.manager.didConnectionStatusChanged(connector!.status);
    }
  }

  @override
  void dispose() {
    connector?.removeListener(_onConnectionChanged);
    connector?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return plugin.build(context);
  }
}
