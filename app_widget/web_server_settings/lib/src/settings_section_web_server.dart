import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:web_session_bloc/web_session_bloc.dart';

/// Settings section for web server control.
class WebServerSettingsSection extends StatelessWidget {
  /// Callback when "Manage Sessions" is pressed.
  final VoidCallback? onManageSessions;

  const WebServerSettingsSection({
    super.key,
    this.onManageSessions,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebSessionBloc, WebSessionState>(
      builder: (context, state) {
        return SettingsSection(
          title: const Text('Web Server'),
          tiles: [
            SettingsTile.switchTile(
              title: const Text('Enable Web Server'),
              description: state.serverRunning
                  ? Text('Running on port ${state.serverPort}')
                  : const Text('Start web server for remote access'),
              leading: Icon(
                state.serverRunning ? Icons.cloud_done : Icons.cloud_off,
                color: state.serverRunning ? Colors.green : null,
              ),
              initialValue: state.serverRunning,
              onToggle: state.isStarting
                  ? null
                  : (value) {
                      if (value) {
                        context.read<WebSessionBloc>().add(const StartWebServer());
                      } else {
                        context.read<WebSessionBloc>().add(const StopWebServer());
                      }
                    },
            ),
            if (state.serverRunning) ...[
              SettingsTile(
                title: const Text('Server Address'),
                description: Text('http://${state.serverAddress}:${state.serverPort}'),
                leading: const Icon(Icons.link),
              ),
              SettingsTile.navigation(
                title: const Text('Manage Sessions'),
                description: Text(
                  '${state.activeSessions.length} active, '
                  '${state.pendingSessions.length} pending',
                ),
                leading: const Icon(Icons.people),
                trailing: state.hasPendingSessions
                    ? Badge(
                        label: Text('${state.pendingSessions.length}'),
                        child: const Icon(Icons.chevron_right),
                      )
                    : null,
                onPressed: onManageSessions != null ? (_) => onManageSessions!() : null,
              ),
              SettingsTile.navigation(
                title: const Text('Access Tokens'),
                description: Text('${state.tokens.length} tokens'),
                leading: const Icon(Icons.key),
                onPressed: onManageSessions != null ? (_) => onManageSessions!() : null,
              ),
            ],
            if (state.error != null)
              SettingsTile(
                title: const Text('Error'),
                description: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                leading: Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        );
      },
    );
  }
}
