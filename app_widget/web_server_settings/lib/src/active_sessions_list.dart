import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_server/web_server.dart';
import 'package:web_session_bloc/web_session_bloc.dart';

/// List of active/connected sessions.
class ActiveSessionsList extends StatelessWidget {
  final OnAttachSession? onAttach;

  const ActiveSessionsList({
    super.key,
    this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebSessionBloc, WebSessionState>(
      builder: (context, state) {
        if (state.activeSessions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No active sessions',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: state.activeSessions.length,
          itemBuilder: (context, index) {
            final session = state.activeSessions[index];
            return ActiveSessionCard(
              session: session,
              onAttach: onAttach,
            );
          },
        );
      },
    );
  }
}

/// Callback for when attach is requested on a session.
typedef OnAttachSession = void Function(WebSession session);

/// Card for a single active session with attach and disconnect buttons.
class ActiveSessionCard extends StatefulWidget {
  final WebSession session;
  final OnAttachSession? onAttach;

  const ActiveSessionCard({
    super.key,
    required this.session,
    this.onAttach,
  });

  @override
  State<ActiveSessionCard> createState() => _ActiveSessionCardState();
}

class _ActiveSessionCardState extends State<ActiveSessionCard> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant ActiveSessionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session != widget.session) {
      _subscription?.cancel();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribe() {
    _subscription = widget.session.events.listen((event) {
      if (!mounted) return;
      if (event is WsPtyCreatedEvent || event is WsPtyClosedEvent) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final onAttach = widget.onAttach;
    final theme = Theme.of(context);
    final duration = DateTime.now().difference(session.createdAt);
    final hasTerminals = session.ptyCount > 0;
    final sessionData = session.toJson();
    final inboundBytes = (sessionData['bytesReceived'] as int?) ?? 0;
    final outboundBytes = (sessionData['bytesSent'] as int?) ?? 0;
    final totalBytes = inboundBytes + outboundBytes;
    final inboundRate = (sessionData['inboundRate'] as num?)?.toDouble() ?? 0;
    final outboundRate = (sessionData['outboundRate'] as num?)?.toDouble() ?? 0;
    final latencyMs = sessionData['latencyMs'] as int?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: const Icon(Icons.computer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.clientAddress,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (session.userAgent != null)
                        Text(
                          session.userAgent!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      Text(
                        'Connected ${_formatDuration(duration)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Terminal list
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.terminal,
                    size: 20,
                    color: hasTerminals
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasTerminals
                        ? '${session.ptyCount} active terminal${session.ptyCount == 1 ? '' : 's'}'
                        : 'No active terminals',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hasTerminals
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transfer: ${_formatBytes(totalBytes)} '
                  '(↓${_formatBytes(inboundBytes)} '
                  '↑${_formatBytes(outboundBytes)})',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Speed: ↓${_formatSpeed(inboundRate)} '
                  '↑${_formatSpeed(outboundRate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Latency: ${_formatLatency(latencyMs)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (hasTerminals && onAttach != null)
                  OutlinedButton.icon(
                    onPressed: () => onAttach!(session),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Attach'),
                  ),
                if (hasTerminals && onAttach != null) const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDisconnectDialog(context, session),
                  icon: const Icon(Icons.close),
                  label: const Text('Disconnect'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context, WebSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Session'),
        content: Text(
          'Are you sure you want to disconnect the session from ${session.clientAddress}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<WebSessionBloc>().add(DisconnectSession(session.id));
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return 'just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }

  String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double value = bytes.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex += 1;
    }
    final precision = value >= 100 ? 0 : (value >= 10 ? 1 : 2);
    return '${value.toStringAsFixed(precision)} ${units[unitIndex]}';
  }

  String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond <= 0) {
      return '0 B/s';
    }
    final formatted = _formatBytes(bytesPerSecond.round());
    return '$formatted/s';
  }

  String _formatLatency(int? latencyMs) {
    if (latencyMs == null) {
      return '—';
    }
    if (latencyMs >= 1000) {
      final seconds = latencyMs / 1000;
      return '${seconds.toStringAsFixed(1)}s';
    }
    return '${latencyMs}ms';
  }
}
