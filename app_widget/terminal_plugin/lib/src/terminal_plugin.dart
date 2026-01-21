import 'dart:convert';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_plugin/src/terminal_menu.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:xterm/xterm.dart';

class TerminalPlugin extends Plugin {
  final terminal = Terminal(
    maxLines: 10000,
    batchWrites: true, // Enable write batching for better performance
  );

  final terminalController = TerminalController();

  var terminalTitle = '';

  ExecutionSession? session;

  void _updateTitle() {
    if (session != null) {
      title.value =
          '$terminalTitle — ${terminal.viewWidth}x${terminal.viewHeight}';
    }
  }

  @override
  void didMounted() {
    title.value = 'Connecting';

    terminal.onTitleChange = (title) {
      terminalTitle = title;
      _updateTitle();
    };

    terminal.onOutput = (data) {
      session?.write(const Utf8Encoder().convert(data));
    };

    terminal.onResize = (w, h, pw, ph) {
      session?.resize(w, h);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _updateTitle();
      });
    };

    super.didMounted();
  }

  @override
  void didConnected() async {
    title.value = 'Terminal';

    session = await host.shell(
      width: terminal.viewWidth,
      height: terminal.viewHeight,
    );

    // Add welcome message
    terminal.write('\r\nWelcome to Web Terminal!\r\n');
    terminal
        .write('Type "help" for available commands or start typing...\r\n\r\n');

    session!.output
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .listen(terminal.write);

    session!.exitCode.then((code) {
      session = null;
      if (mounted) {
        manager.remove(this);
      }
    });
  }

  @override
  void didDisconnected() {
    session = null;
    title.value = 'Disconnected';
  }

  @override
  void onConnectionStatus(HostConnectorStatus status) {
    switch (status) {
      case HostConnectorStatus.connecting:
        title.value = 'Connecting';
        break;
      case HostConnectorStatus.connected:
        title.value = 'Terminal';
        break;
      case HostConnectorStatus.disconnected:
        title.value = 'Disconnected';
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return TerminalTabView(this);
  }
}

class TerminalTabView extends StatefulWidget {
  const TerminalTabView(this.plugin, {super.key});

  final TerminalPlugin plugin;

  @override
  State<StatefulWidget> createState() => _TerminalTabViewState();
}

class _TerminalTabViewState extends State<TerminalTabView> {
  @override
  void dispose() {
    widget.plugin.terminal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TerminalSettingsBloc, TerminalSettingsState>(
      builder: (context, state) {
        // Get font settings from state or use defaults
        final fontSize = state is TerminalSettingsLoaded
            ? state.fontSize
            : kTerminalDefaultFontSize;
        final fontFamily = state is TerminalSettingsLoaded
            ? state.fontFamily
            : kTerminalDefaultFontFamily;

        return CupertinoPageScaffold(
          key: ValueKey(widget.plugin),
          backgroundColor: Colors.transparent,
          child: SafeArea(
            child: ClipRect(
              child: TerminalView(
                widget.plugin.terminal,
                controller: widget.plugin.terminalController,
                onSecondaryTapDown: (_, __) => showMenu(),
                backgroundOpacity: 0.8,
                autofocus: true,
                textStyle: TerminalStyle(
                  fontSize: fontSize,
                  fontFamily: fontFamily,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showMenu() {
    final menu = TerminalContextMenu(plugin: widget.plugin);
    context.contextMenuOverlay.show(menu);
  }
}
