import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:web_terminal/destinations.dart';
import 'package:web_session_bloc/web_session_bloc.dart';
import 'package:web_server/web_server.dart';
import 'package:web_server_settings/web_server_settings.dart';

/// Screen for managing web terminal server and sessions.
class WebTerminalScreen extends StatelessWidget {
  static const name = 'WebTerminalScreen';
  static const path = '/web-terminal';

  const WebTerminalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebSessionBloc, WebSessionState>(
      builder: (context, state) {
        return AppAdaptiveScaffold(
          selectedIndex:
              Destinations.indexOf(const Key(WebTerminalScreen.name), context),
          onSelectedIndexChange: (idx) => Destinations.changeHandler(
            idx,
            context,
          ),
          destinations: Destinations.navs(context),
          body: (context) => _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WebSessionState state) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Web Terminal'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Active'),
            ],
          ),
          actions: [
            if (state.serverRunning)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Chip(
                  avatar: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  label: Text('Port ${state.serverPort}'),
                ),
              ),
            // Button to approve session by code
            if (state.serverRunning)
              IconButton(
                icon: const Icon(Icons.dialpad),
                tooltip: 'Approve by code',
                onPressed: () => _showApproveByCodeDialog(context),
              ),
          ],
        ),
        body: Column(
          children: [
            // Server control section
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.isStarting
                                  ? 'Starting server...'
                                  : state.serverRunning
                                      ? 'Server is running'
                                      : 'Server is stopped',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (state.serverRunning &&
                                state.serverAddress != null)
                              Text(
                                'http://${state.serverAddress}:${state.serverPort}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                          ],
                        ),
                      ),
                      if (state.isStarting)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Switch(
                          value: state.serverRunning,
                          onChanged: (value) {
                            if (value) {
                              context.read<WebSessionBloc>().add(
                                    const StartWebServer(),
                                  );
                            } else {
                                context.read<WebSessionBloc>().add(
                                    const StopWebServer(),
                                  );
                            }
                          },
                        ),
                    ],
                  ),
                  // Error display
                  if (state.error != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  PendingSessionsBadge(
                    child: const SessionApprovalList(),
                  ),
                  ActiveSessionsList(
                    onAttach: (session) => _showTerminalViewer(context, session),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveByCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ApproveByCodeDialog(),
    );
  }

  void _showTerminalViewer(BuildContext context, WebSession session) {
    ReadOnlyTerminalViewer.show(context, session);
  }
}
