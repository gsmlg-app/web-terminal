import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_database/app_database.dart';
import 'package:app_logging/app_logging.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:web_terminal/destinations.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_tabs/terminal_tabs.dart';
import 'package:window_manager/window_manager.dart';

import 'widgets/widgets.dart';

class TerminalScreen extends StatefulWidget {
  static const name = 'TerminalScreen';
  static const path = '/terminal';

  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  late final TerminalTabBloc _terminalTabBloc;
  final _analytics = TerminalAnalytics();
  StreamSubscription<TerminalTabState>? _stateSubscription;
  bool _initialTabOpened = false;
  bool? _previousFullscreenState;

  @override
  void initState() {
    super.initState();
    _terminalTabBloc = context.read<TerminalTabBloc>();
    _terminalTabBloc.add(TerminalTabStart());
    // Listen for state changes to open initial tab when loaded
    _stateSubscription = _terminalTabBloc.stream.listen(_onStateChanged);
    // Also check immediately in case state is already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryOpenInitialTab();
    });
  }

  void _onStateChanged(TerminalTabState state) {
    _tryOpenInitialTab();
    _trackFullscreenChange(state);
  }

  void _trackFullscreenChange(TerminalTabState state) {
    if (state is! TerminalTabLoaded) return;
    final isFullscreen = state.isFullscreen;
    if (_previousFullscreenState != null &&
        _previousFullscreenState != isFullscreen) {
      _analytics.trackFullscreenToggled(isFullscreen);
    }
    _previousFullscreenState = isFullscreen;
  }

  void _tryOpenInitialTab() {
    if (_initialTabOpened) return;
    final state = _terminalTabBloc.state;
    if (state is TerminalTabLoaded && state.tabs.children.isEmpty) {
      _initialTabOpened = true;
      _openLocalShell();
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _terminalTabBloc.add(TerminalTabStop());
    super.dispose();
  }

  void _openLocalShell() {
    if (!_checkMaxShellsLimit()) return;

    selectProfileAndOpenShell(
      context: context,
      onProfileSelected: (profile) {
        _openLocalShellWithProfile(profile);
      },
    );
  }

  void _openLocalShellWithProfile(ShellProfile? profile) {
    final plugin = TerminalPlugin();
    HostSpec hostSpec;

    if (profile != null) {
      // Create host spec with profile settings
      hostSpec = createDefaultHostSpec(
        name: profile.name,
        environment: profile.parsedEnvironmentVariables,
        initCommands: profile.generateInitCommands(),
      );
    } else {
      // Default shell without profile
      hostSpec = createDefaultHostSpec();
    }

    final manager = PluginManager(hostSpec);
    final tabItem = PluginTab(plugin, manager);
    _terminalTabBloc.add(TerminalTabOpenTab(tabItem));

    // Track session creation
    _analytics.trackSessionCreated(
      SessionType.local,
      metadata: profile != null ? {'profile': profile.name} : null,
    );
  }

  /// Checks if opening a new shell would exceed the max open shells limit.
  /// Returns true if a new shell can be opened, false otherwise.
  bool _checkMaxShellsLimit() {
    final tabState = _terminalTabBloc.state;
    if (tabState is! TerminalTabLoaded) return true;

    final settingsState = context.read<TerminalSettingsBloc>().state;
    final maxShells = settingsState is TerminalSettingsLoaded
        ? settingsState.maxOpenShells
        : kTerminalDefaultMaxOpenShells;

    if (tabState.tabCount >= maxShells) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maximum of $maxShells open sessions reached. '
            'Close a session or increase the limit in Settings.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _openSshSession() async {
    if (!_checkMaxShellsLimit()) return;

    final host = await SshHostSelector.show(context);
    if (host != null && mounted) {
      // Load SSH key if using key authentication
      SshKeyData? keyData;
      final identityType = SshIdentityType.fromValue(host.identityType);
      if (identityType == SshIdentityType.key) {
        if (host.identityKeyId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('No SSH key selected for this host. Please edit the host and select a key.'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }
        try {
          keyData = await _loadSshKeyData(host.identityKeyId!);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load SSH key: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }
      }

      final plugin = TerminalPlugin();
      final manager = PluginManager(SSHHostSpec(host, keyData: keyData));
      final tabItem = PluginTab(plugin, manager);
      _terminalTabBloc.add(TerminalTabOpenTab(tabItem));

      // Track SSH session creation
      _analytics.trackSessionCreated(
        SessionType.ssh,
        metadata: {
          'host': host.hostname ?? 'unknown',
          'auth_type': keyData != null ? 'key' : 'password',
        },
      );
    }
  }

  /// Loads SSH key data from the database by key ID.
  Future<SshKeyData> _loadSshKeyData(int keyId) async {
    final database = context.read<AppDatabase>();
    final key = await (database.select(database.sshKeys)
          ..where((t) => t.id.equals(keyId)))
        .getSingleOrNull();

    if (key == null) {
      throw Exception('SSH key not found');
    }

    // Use the extension method to decrypt the key content
    final pemContent = key.getPrivateKeyPem();

    // The key.password is for the SSH key passphrase (if the key itself is encrypted)
    // Note: This password is stored encrypted in the database and decrypted with AesHelper
    return SshKeyData(
      content: pemContent,
      passphrase: key.password, // SSH key passphrase (null for unencrypted keys)
    );
  }

  void _openSftpSession() {
    // SFTP is planned for future release
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SFTP support coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onSessionSelected(String sessionId) {
    _terminalTabBloc.add(TerminalTabSelectSession(sessionId));
  }

  List<SessionInfo> _buildSessionList(TerminalTabLoaded state) {
    return state.allTabs.map((tab) {
      String name = 'Terminal';
      if (tab is PluginTab) {
        name = tab.plugin.title.value ?? tab.manager.hostSpec.name;
      }
      return SessionInfo(
        id: tab.hashCode.toString(),
        name: name,
        onClose: () {
          _terminalTabBloc.add(TerminalTabCloseSession(tab.hashCode.toString()));
        },
      );
    }).toList();
  }

  String _getCurrentSessionName(TerminalTabLoaded state) {
    final activeTab = state.activeTab;
    if (activeTab == null) return 'Terminal';
    if (activeTab is PluginTab) {
      return activeTab.plugin.title.value ?? activeTab.manager.hostSpec.name;
    }
    return 'Terminal';
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = GlobalShortcuts(
      child: GlobalActions(
        child: SafeArea(
          child: BlocBuilder<TerminalTabBloc, TerminalTabState>(
            builder: (context, state) {
              if (state is! TerminalTabLoaded) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Column(
                children: [
                  // AppBar for session management
                  TerminalAppBar(
                    currentSessionName: _getCurrentSessionName(state),
                    sessions: _buildSessionList(state),
                    onSessionSelected: _onSessionSelected,
                    onNewLocalShell: _openLocalShell,
                    onNewSshSession: _openSshSession,
                    onNewSftpSession: _openSftpSession,
                  ),
                  // Terminal content area
                  Expanded(
                    child: _buildTerminalContent(state),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    if (defaultTargetPlatform == TargetPlatform.windows) {
      widget = VirtualWindowFrame(child: widget);
    }

    // Wrap with Actions to handle fullscreen toggle
    widget = Actions(
      actions: {
        ToggleFullscreenIntent: CallbackAction<ToggleFullscreenIntent>(
          onInvoke: (_) {
            _terminalTabBloc.add(TerminalTabToggleFullscreen());
            // Analytics tracking is done via _trackFullscreenChange listener
            return null;
          },
        ),
      },
      child: Focus(
        autofocus: true,
        child: widget,
      ),
    );

    return BlocBuilder<TerminalTabBloc, TerminalTabState>(
      buildWhen: (previous, current) {
        // Only rebuild when fullscreen state changes
        if (previous is TerminalTabLoaded && current is TerminalTabLoaded) {
          return previous.isFullscreen != current.isFullscreen;
        }
        return true;
      },
      builder: (context, state) {
        final isFullscreen =
            state is TerminalTabLoaded ? state.isFullscreen : false;

        return AppAdaptiveScaffold(
          selectedIndex:
              Destinations.indexOf(const Key(TerminalScreen.name), context),
          onSelectedIndexChange: (idx) => Destinations.changeHandler(
            idx,
            context,
          ),
          destinations: Destinations.navs(context),
          hideNavigation: isFullscreen,
          body: (context) => widget,
        );
      },
    );
  }

  Widget _buildTerminalContent(TerminalTabLoaded state) {
    final activeTab = state.activeTab;

    if (activeTab == null) {
      // No active tab, show empty state
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.terminal,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No active session',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _openLocalShell,
              icon: const Icon(Icons.add),
              label: const Text('Open Local Shell'),
            ),
          ],
        ),
      );
    }

    // Show the active tab's content
    final content = activeTab.content.value;
    if (content != null) {
      return content;
    }

    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
