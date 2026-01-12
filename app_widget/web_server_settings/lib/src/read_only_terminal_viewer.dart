import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_server/web_server.dart';
import 'package:web_session_bloc/web_session_bloc.dart';
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
  late WebSession _session;
  final Map<String, Terminal> _terminals = {};
  final Map<String, String> _outputBuffers = {};
  StreamSubscription? _eventSubscription;
  StreamSubscription? _managerSubscription;
  Timer? _refreshTimer;
  List<String> _ptyIds = [];
  static const int _maxBufferSize = 100000;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _initializePtyList();
    _subscribeToEvents();
    _managerSubscription = context
        .read<WebSessionBloc>()
        .sessionManager
        .events
        .listen((_) => _syncPtyList());
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _syncPtyList(),
    );
  }

  @override
  void didUpdateWidget(covariant ReadOnlyTerminalViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session != widget.session) {
      _eventSubscription?.cancel();
      _session = widget.session;
      _initializePtyList();
      _subscribeToEvents();
    }
  }

  void _initializePtyList() {
    _ptyIds = _session.ptySessions.keys.toList();
    for (final ptyId in _ptyIds) {
      _terminals[ptyId] = Terminal(maxLines: 10000);
      final buffer = _getPtyBuffer(_session, ptyId);
      _outputBuffers[ptyId] = buffer;
      _applyPtySize(ptyId);
      if (buffer.isNotEmpty) {
        _terminals[ptyId]?.write(buffer);
      }
    }
  }

  void _syncPtyList() {
    final latestSession =
        context.read<WebSessionBloc>().sessionManager.getSession(_session.id) ??
            _session;
    if (!identical(latestSession, _session)) {
      _eventSubscription?.cancel();
      _session = latestSession;
      _subscribeToEvents();
    } else {
      _session = latestSession;
    }

    final sessionIds = latestSession.ptySessions.keys.toSet();
    final currentIds = _ptyIds.toSet();

    setState(() {
      for (final ptyId in currentIds.difference(sessionIds)) {
        _ptyIds.remove(ptyId);
        _terminals.remove(ptyId);
        _outputBuffers.remove(ptyId);
      }

      for (final ptyId in sessionIds.difference(currentIds)) {
        _ptyIds.add(ptyId);
        _terminals[ptyId] = Terminal(maxLines: 10000);
        final buffer = _getPtyBuffer(_session, ptyId);
        _outputBuffers[ptyId] = buffer;
        _applyPtySize(ptyId);
        if (buffer.isNotEmpty) {
          _terminals[ptyId]?.write(buffer);
        }
      }
    });
  }

  void _subscribeToEvents() {
    _eventSubscription = _session.events.listen((event) {
      if (!mounted) return;

      switch (event) {
        case WsPtyOutputEvent(ptyId: final ptyId, data: final data):
          // Get or create terminal for this PTY
          if (!_terminals.containsKey(ptyId)) {
            setState(() {
              _ptyIds.add(ptyId);
              _terminals[ptyId] = Terminal(maxLines: 10000);
              final buffer = _getPtyBuffer(_session, ptyId);
              _outputBuffers[ptyId] = buffer;
              _applyPtySize(ptyId);
              if (buffer.isNotEmpty) {
                _terminals[ptyId]?.write(buffer);
              }
            });
            return;
          }
          final chunk = String.fromCharCodes(data);
          _appendToBuffer(ptyId, chunk);
          _terminals[ptyId]?.write(chunk);

        case WsPtyCreatedEvent(ptyId: final ptyId):
          if (!_terminals.containsKey(ptyId)) {
            setState(() {
              _ptyIds.add(ptyId);
              _terminals[ptyId] = Terminal(maxLines: 10000);
              final buffer = _getPtyBuffer(_session, ptyId);
              _outputBuffers[ptyId] = buffer;
              _applyPtySize(ptyId);
              if (buffer.isNotEmpty) {
                _terminals[ptyId]?.write(buffer);
              }
            });
          }

        case WsPtyClosedEvent(ptyId: final ptyId, exitCode: _):
          setState(() {
            _ptyIds.remove(ptyId);
            _terminals.remove(ptyId);
            _outputBuffers.remove(ptyId);
          });
        default:
          break;
      }
    });
  }

  String _getPtyBuffer(WebSession session, String ptyId) {
    final dynamic dynamicSession = session;
    final dynamic buffer = dynamicSession.getPtyBuffer(ptyId);
    if (buffer is String) {
      return buffer;
    }
    return '';
  }

  void _appendToBuffer(String ptyId, String chunk) {
    final current = _outputBuffers[ptyId] ?? '';
    final updated = current + chunk;
    if (updated.length > _maxBufferSize) {
      _outputBuffers[ptyId] =
          updated.substring(updated.length - _maxBufferSize);
    } else {
      _outputBuffers[ptyId] = updated;
    }
  }

  void _applyPtySize(String ptyId) {
    final terminal = _terminals[ptyId];
    if (terminal == null) {
      return;
    }
    final dynamic session = _session;
    final dynamic sizes = session.ptySizes;
    final dynamic size = sizes is Map ? sizes[ptyId] : null;
    if (size == null) {
      return;
    }
    terminal.resize(size.cols as int, size.rows as int);
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _managerSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WebSessionBloc, WebSessionState>(
      listener: (context, state) {
        WebSession? updated;
        for (final session in state.activeSessions) {
          if (session.id == _session.id) {
            updated = session;
            break;
          }
        }
        if (updated == null) {
          return;
        }
        _session = updated;
        _syncPtyList();
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog.fullscreen(
      child: DefaultTabController(
        key: ValueKey(_ptyIds.length),
        length: _ptyIds.length > 1 ? _ptyIds.length : 1,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Viewing: ${_session.clientAddress}'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: _ptyIds.length > 1
                ? TabBar(
                    tabs: _ptyIds
                        .map((id) =>
                            Tab(text: 'Terminal ${_ptyIds.indexOf(id) + 1}'))
                        .toList(),
                  )
                : null,
          ),
          body: _buildBody(theme),
        ),
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
                  'Read Only',
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
