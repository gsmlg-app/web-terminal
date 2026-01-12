import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_server/web_server.dart';
import 'package:xterm/xterm.dart';

/// Dialog that displays a read-only view of a connected session's terminals.
class ReadOnlyTerminalViewer extends StatefulWidget {
  final WebSession session;

  const ReadOnlyTerminalViewer({
    super.key,
    required this.session,
  });

  /// Shows the viewer as a full-screen dialog.
  static Future<void> show(BuildContext context, WebSession session) {
    return showDialog(
      context: context,
      builder: (context) => ReadOnlyTerminalViewer(session: session),
    );
  }

  @override
  State<ReadOnlyTerminalViewer> createState() => _ReadOnlyTerminalViewerState();
}

class _ReadOnlyTerminalViewerState extends State<ReadOnlyTerminalViewer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, Terminal> _terminals = {};
  StreamSubscription? _eventSubscription;
  List<String> _ptyIds = [];

  @override
  void initState() {
    super.initState();
    _initializePtyList();
    _tabController = TabController(
      length: _ptyIds.length,
      vsync: this,
    );
    _subscribeToEvents();
  }

  void _initializePtyList() {
    _ptyIds = widget.session.ptySessions.keys.toList();
    for (final ptyId in _ptyIds) {
      _terminals[ptyId] = Terminal(maxLines: 10000);
    }
  }

  void _subscribeToEvents() {
    _eventSubscription = widget.session.events.listen((event) {
      if (!mounted) return;

      switch (event) {
        case WsPtyOutputEvent(ptyId: final ptyId, data: final data):
          // Get or create terminal for this PTY
          if (!_terminals.containsKey(ptyId)) {
            setState(() {
              _ptyIds.add(ptyId);
              _terminals[ptyId] = Terminal(maxLines: 10000);
              _tabController.dispose();
              _tabController = TabController(
                length: _ptyIds.length,
                vsync: this,
              );
            });
          }
          // Write data to terminal
          _terminals[ptyId]?.write(String.fromCharCodes(data));

        case WsPtyCreatedEvent(ptyId: final ptyId):
          if (!_terminals.containsKey(ptyId)) {
            setState(() {
              _ptyIds.add(ptyId);
              _terminals[ptyId] = Terminal(maxLines: 10000);
              _tabController.dispose();
              _tabController = TabController(
                length: _ptyIds.length,
                vsync: this,
              );
            });
          }

        case WsPtyClosedEvent(ptyId: final ptyId, exitCode: _):
          setState(() {
            _ptyIds.remove(ptyId);
            _terminals.remove(ptyId);
            if (_ptyIds.isNotEmpty) {
              _tabController.dispose();
              _tabController = TabController(
                length: _ptyIds.length,
                vsync: this,
              );
            }
          });
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Viewing: ${widget.session.clientAddress}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: _ptyIds.length > 1
              ? TabBar(
                  controller: _tabController,
                  tabs: _ptyIds
                      .map((id) => Tab(text: 'Terminal ${_ptyIds.indexOf(id) + 1}'))
                      .toList(),
                )
              : null,
        ),
        body: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_ptyIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.terminal,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No active terminals',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for terminal activity...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_ptyIds.length == 1) {
      return _buildTerminalView(_ptyIds.first, theme);
    }

    return TabBarView(
      controller: _tabController,
      children: _ptyIds.map((id) => _buildTerminalView(id, theme)).toList(),
    );
  }

  Widget _buildTerminalView(String ptyId, ThemeData theme) {
    final terminal = _terminals[ptyId];
    if (terminal == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        TerminalView(
          terminal,
          readOnly: true,
          theme: theme.brightness == Brightness.dark
              ? TerminalThemes.defaultTheme
              : TerminalThemes.whiteOnBlack,
          padding: const EdgeInsets.all(8),
        ),
        // Read-only indicator
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility,
                  size: 14,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  'Read-only',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
