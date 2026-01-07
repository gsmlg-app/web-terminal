import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_server/web_server.dart';
import 'package:web_session_bloc/web_session_bloc.dart';

import 'token_display_dialog.dart';

/// List of access tokens.
class TokenList extends StatelessWidget {
  const TokenList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebSessionBloc, WebSessionState>(
      builder: (context, state) {
        return Column(
          children: [
            // Create token button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _createToken(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Token'),
                ),
              ),
            ),

            // Token list
            Expanded(
              child: state.tokens.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.key_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No tokens created',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Create a token to allow web access',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.tokens.length,
                      itemBuilder: (context, index) {
                        final token = state.tokens[index];
                        return TokenCard(token: token);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _createToken(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateTokenDialog(),
    );
  }
}

/// Card for a single token.
class TokenCard extends StatelessWidget {
  final SessionToken token;

  const TokenCard({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = token.isExpired;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpired
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.primaryContainer,
          child: Icon(
            isExpired ? Icons.key_off : Icons.key,
            color: isExpired
                ? theme.colorScheme.onErrorContainer
                : theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(token.label ?? 'Token ${token.id.substring(0, 6)}'),
        subtitle: Text(
          isExpired
              ? 'Expired'
              : 'Expires in ${_formatDuration(token.timeRemaining)}',
          style: TextStyle(
            color: isExpired ? theme.colorScheme.error : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility),
              tooltip: 'Show token',
              onPressed: () => _showToken(context, token),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Revoke token',
              onPressed: () => _revokeToken(context, token),
            ),
          ],
        ),
      ),
    );
  }

  void _showToken(BuildContext context, SessionToken token) {
    showDialog(
      context: context,
      builder: (context) => TokenDisplayDialog(token: token),
    );
  }

  void _revokeToken(BuildContext context, SessionToken token) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Token'),
        content: Text(
          'Are you sure you want to revoke this token? '
          'All sessions using this token will be disconnected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<WebSessionBloc>().add(RevokeToken(token.id));
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inDays}d';
    }
  }
}

/// Dialog for creating a new token.
class CreateTokenDialog extends StatefulWidget {
  const CreateTokenDialog({super.key});

  @override
  State<CreateTokenDialog> createState() => _CreateTokenDialogState();
}

class _CreateTokenDialogState extends State<CreateTokenDialog> {
  final _labelController = TextEditingController();
  Duration _validity = const Duration(hours: 24);

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Access Token'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Label (optional)',
              hintText: 'e.g., My Laptop',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Duration>(
            initialValue: _validity,
            decoration: const InputDecoration(
              labelText: 'Valid for',
            ),
            items: const [
              DropdownMenuItem(
                value: Duration(hours: 1),
                child: Text('1 hour'),
              ),
              DropdownMenuItem(
                value: Duration(hours: 8),
                child: Text('8 hours'),
              ),
              DropdownMenuItem(
                value: Duration(hours: 24),
                child: Text('24 hours'),
              ),
              DropdownMenuItem(
                value: Duration(days: 7),
                child: Text('7 days'),
              ),
              DropdownMenuItem(
                value: Duration(days: 30),
                child: Text('30 days'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _validity = value);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            context.read<WebSessionBloc>().add(CreateToken(
                  label: _labelController.text.isEmpty
                      ? null
                      : _labelController.text,
                  validity: _validity,
                ));
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
