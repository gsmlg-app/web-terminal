import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_server/web_server.dart';

/// Dialog that displays a token for copying.
class TokenDisplayDialog extends StatelessWidget {
  final SessionToken token;

  const TokenDisplayDialog({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.key),
          const SizedBox(width: 8),
          Text(token.label ?? 'Access Token'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Copy this token and enter it in your browser to connect:',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: SelectableText(
              token.token,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                token.isExpired
                    ? 'Expired'
                    : 'Expires in ${_formatDuration(token.timeRemaining)}',
                style: TextStyle(
                  color: token.isExpired
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () => _copyToken(context),
          icon: const Icon(Icons.copy),
          label: const Text('Copy'),
        ),
      ],
    );
  }

  void _copyToken(BuildContext context) {
    Clipboard.setData(ClipboardData(text: token.token));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours';
    } else {
      return '${duration.inDays} days';
    }
  }
}
