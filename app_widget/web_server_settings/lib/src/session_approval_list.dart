import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_server/web_server.dart';
import 'package:web_session_bloc/web_session_bloc.dart';

/// List of pending sessions awaiting approval.
class SessionApprovalList extends StatelessWidget {
  const SessionApprovalList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebSessionBloc, WebSessionState>(
      builder: (context, state) {
        if (state.pendingSessions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No pending sessions',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: state.pendingSessions.length,
          itemBuilder: (context, index) {
            final session = state.pendingSessions[index];
            return SessionApprovalCard(session: session);
          },
        );
      },
    );
  }
}

/// Card for a single pending session with approve/reject buttons.
class SessionApprovalCard extends StatelessWidget {
  final WebSession session;

  const SessionApprovalCard({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeSinceCreated = DateTime.now().difference(session.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pending_actions, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connection Request',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        'From: ${session.clientAddress}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDuration(timeSinceCreated),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            if (session.userAgent != null) ...[
              const SizedBox(height: 8),
              Text(
                session.userAgent!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    context.read<WebSessionBloc>().add(RejectSession(session.id));
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    context.read<WebSessionBloc>().add(ApproveSession(session.id));
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }
}
