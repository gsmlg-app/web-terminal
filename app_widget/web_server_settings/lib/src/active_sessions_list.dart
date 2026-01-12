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
class ActiveSessionCard extends StatelessWidget {
  final WebSession session;
  final OnAttachSession? onAttach;

  const ActiveSessionCard({
    super.key,
    required this.session,
    this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = DateTime.now().difference(session.createdAt);
    final hasTerminals = session.ptyCount > 0;

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
}
