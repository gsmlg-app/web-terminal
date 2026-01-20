import 'package:flutter/material.dart';

/// Dropdown menu for creating new terminal sessions.
///
/// Provides options for:
/// - Local shell (platform-specific: Android, iOS, or native PTY)
/// - Remote SSH shell
/// - Remote SFTP server (file manager)
class SessionMenu extends StatelessWidget {
  const SessionMenu({
    super.key,
    required this.onNewLocalShell,
    required this.onNewSshSession,
    required this.onNewSftpSession,
  });

  /// Called when user requests a new local shell session
  final VoidCallback onNewLocalShell;

  /// Called when user requests a new SSH session
  final VoidCallback onNewSshSession;

  /// Called when user requests a new SFTP session
  final VoidCallback onNewSftpSession;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_SessionType>(
      icon: const Icon(Icons.add),
      tooltip: 'New session',
      onSelected: (type) {
        switch (type) {
          case _SessionType.localShell:
            onNewLocalShell();
          case _SessionType.sshShell:
            onNewSshSession();
          case _SessionType.sftpServer:
            onNewSftpSession();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _SessionType.localShell,
          child: ListTile(
            leading: Icon(Icons.terminal),
            title: Text('Local Shell'),
            subtitle: Text('Open a terminal on this device'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: _SessionType.sshShell,
          child: ListTile(
            leading: Icon(Icons.cloud),
            title: Text('SSH Shell'),
            subtitle: Text('Connect to a remote server'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: _SessionType.sftpServer,
          enabled: false, // SFTP is planned for future release
          child: ListTile(
            leading: Icon(Icons.folder),
            title: Text('SFTP Server'),
            subtitle: Text('Browse remote files (coming soon)'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

enum _SessionType {
  localShell,
  sshShell,
  sftpServer,
}
