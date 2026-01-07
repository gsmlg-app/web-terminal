import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_server/web_server.dart';
import 'package:web_session_bloc/web_session_bloc.dart';

/// List of active/connected sessions.
class ActiveSessionsList extends StatelessWidget {
  const ActiveSessionsList({super.key});

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
            return ActiveSessionCard(session: session);
          },
        );
      },
    );
  }
}

/// Card for a single active session with disconnect button.
class ActiveSessionCard extends StatelessWidget {
  final WebSession session;

  const ActiveSessionCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = DateTime.now().difference(session.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: const Icon(Icons.computer),
        ),
        title: Text(session.clientAddress),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connected ${_formatDuration(duration)}'),
            Text(
              '${session.ptyCount} terminal${session.ptyCount == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Disconnect',
          onPressed: () {
            _showDisconnectDialog(context, session);
          },
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
