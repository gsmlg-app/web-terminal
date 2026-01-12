import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:web_server/web_server.dart';
import 'package:web_server_settings/web_server_settings.dart';
import 'package:web_session_bloc/web_session_bloc.dart';
import 'package:web_terminal/destinations.dart';
import 'package:web_terminal/screens/settings/web_server/web_server_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          selectedIndex: Destinations.indexOf(
            const Key(WebTerminalScreen.name),
            context,
          ),
          onSelectedIndexChange: (idx) =>
              Destinations.changeHandler(idx, context),
          destinations: Destinations.navs(context),
          body: (context) => _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WebSessionState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Terminal'),
        bottom: _buildServerStatus(context, state),
        actions: [
          PendingSessionsBadge(
            child: IconButton(
              icon: const Icon(Icons.pending_actions),
              tooltip: 'Pending approvals',
              onPressed: () => _showPendingSessionsDialog(context),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Web server settings',
            onPressed: () => context.goNamed(WebServerScreen.name),
          ),
        ],
      ),
      body: ActiveSessionsList(
        onAttach: (session) => _showTerminalViewer(context, session),
      ),
    );
  }

  PreferredSizeWidget _buildServerStatus(
    BuildContext context,
    WebSessionState state,
  ) {
    final statusText = state.isStarting
        ? 'Starting server...'
        : state.serverRunning
        ? 'Server is running'
        : 'Server is stopped';
    final theme = Theme.of(context);
    final prefs = context.read<SharedPreferences>();
    final listenIp =
        prefs.getString('web_server_listen_ip') ??
        state.serverAddress ??
        '0.0.0.0';
    final port = prefs.getInt('web_server_port') ?? state.serverPort ?? 8080;
    final useSsl = prefs.getBool('web_server_ssl') ?? false;
    final scheme = useSsl ? 'https' : 'http';

    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(statusText, style: theme.textTheme.titleMedium),
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
            Text(
              '$scheme://$listenIp:$port',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPendingSessionsDialog(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pending Approvals'),
        content: SizedBox(
          width: size.width * 0.8,
          height: size.height * 0.6,
          child: const SessionApprovalList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTerminalViewer(BuildContext context, WebSession session) {
    ReadOnlyTerminalViewer.show(context, session);
  }
}
