import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';

import 'session_menu.dart';

/// AppBar for the terminal screen with session management controls.
///
/// Features:
/// - Title showing current session name with popup menu for switching
/// - Left action: fullscreen toggle
/// - Right action: plus menu for creating new sessions
class TerminalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TerminalAppBar({
    super.key,
    required this.currentSessionName,
    required this.sessions,
    required this.onSessionSelected,
    required this.onNewLocalShell,
    required this.onNewSshSession,
    required this.onNewSftpSession,
  });

  /// Name of the currently active session
  final String currentSessionName;

  /// List of all sessions with their names and IDs
  final List<SessionInfo> sessions;

  /// Called when user selects a different session from the popup menu
  final void Function(String sessionId) onSessionSelected;

  /// Called when user requests a new local shell session
  final VoidCallback onNewLocalShell;

  /// Called when user requests a new SSH session
  final VoidCallback onNewSshSession;

  /// Called when user requests a new SFTP session
  final VoidCallback onNewSftpSession;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: _buildFullscreenToggle(context),
      title: _buildSessionSelector(context),
      centerTitle: true,
      actions: [
        SessionMenu(
          onNewLocalShell: onNewLocalShell,
          onNewSshSession: onNewSshSession,
          onNewSftpSession: onNewSftpSession,
        ),
      ],
    );
  }

  Widget _buildFullscreenToggle(BuildContext context) {
    return BlocBuilder<TerminalTabBloc, TerminalTabState>(
      buildWhen: (previous, current) {
        if (previous is TerminalTabLoaded && current is TerminalTabLoaded) {
          return previous.isFullscreen != current.isFullscreen;
        }
        return true;
      },
      builder: (context, state) {
        final isFullscreen =
            state is TerminalTabLoaded ? state.isFullscreen : false;
        return Semantics(
          label: isFullscreen
              ? 'Exit fullscreen mode'
              : 'Enter fullscreen mode',
          hint: isFullscreen
              ? 'Double tap to show navigation'
              : 'Double tap to hide navigation and maximize terminal',
          button: true,
          child: IconButton(
            icon: Icon(
              isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            ),
            tooltip: isFullscreen ? 'Exit fullscreen' : 'Enter fullscreen',
            onPressed: () {
              context.read<TerminalTabBloc>().add(TerminalTabToggleFullscreen());
            },
          ),
        );
      },
    );
  }

  Widget _buildSessionSelector(BuildContext context) {
    if (sessions.isEmpty) {
      return Semantics(
        label: 'Terminal',
        header: true,
        child: const Text('Terminal'),
      );
    }

    final sessionCount = sessions.length;
    return Semantics(
      label: 'Current session: $currentSessionName. $sessionCount session${sessionCount == 1 ? '' : 's'} open.',
      hint: 'Double tap to switch between sessions',
      button: true,
      child: PopupMenuButton<String>(
        onSelected: onSessionSelected,
        tooltip: 'Switch session',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                currentSessionName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
        itemBuilder: (context) {
          return sessions.map((session) {
            final isActive = session.name == currentSessionName;
            return PopupMenuItem<String>(
              value: session.id,
              child: Semantics(
                label: '${session.name}${isActive ? ', active session' : ''}',
                hint: isActive
                    ? 'Currently selected'
                    : 'Double tap to switch to this session',
                selected: isActive,
                child: Row(
                  children: [
                    if (isActive)
                      Icon(
                        Icons.check,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        session.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Semantics(
                      label: 'Close ${session.name}',
                      hint: 'Double tap to close this session',
                      button: true,
                      excludeSemantics: true,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Navigator.of(context).pop();
                          session.onClose?.call();
                        },
                        tooltip: 'Close session',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }
}

/// Information about a terminal session for the session selector.
class SessionInfo {
  const SessionInfo({
    required this.id,
    required this.name,
    this.onClose,
  });

  /// Unique identifier for the session
  final String id;

  /// Display name for the session
  final String name;

  /// Callback when user requests to close this session
  final VoidCallback? onClose;
}
