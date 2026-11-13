import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_manager_plugin/file_manager_plugin.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_plugin/terminal_plugin.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_tabs/terminal_tabs.dart';

import 'session_store.dart';

/// A tab whose descriptor survived restoration but cannot currently connect.
class UnavailableSessionTab extends TabItem implements TerminalTabTitleRenamer {
  UnavailableSessionTab({
    required this.descriptor,
    required this.label,
    required Widget child,
  }) {
    title.value = Text(label);
    content.value = child;
  }

  final Map<String, dynamic> descriptor;
  String label;

  @override
  void renameTitle(String value) {
    label = value;
    descriptor['customTitle'] = value;
    title.value = Text(value);
  }
}

/// Persists the workspace independently of whichever route is currently shown.
class SessionController extends ChangeNotifier {
  SessionController({required this.store, required this.tabs}) {
    _subscription = tabs.stream.listen(_onState);
  }

  final SessionStore store;
  final TerminalTabBloc tabs;
  late final StreamSubscription<TerminalTabState> _subscription;
  final _titleListeners = <PluginTab, VoidCallback>{};
  final _directories = <PluginTab, String>{};
  Timer? _directoryTimer;
  bool _ready = false;
  bool _closing = false;
  bool _polling = false;
  String? _lastLayout;
  Object? persistenceError;
  bool startupPromptDismissed = false;
  SessionSnapshot? requestedRestore;
  final _baselineTabs = <PluginTab>{};
  bool _hasChanges = false;

  void requestRestore(SessionSnapshot snapshot) {
    requestedRestore = snapshot;
    notifyListeners();
  }

  SessionSnapshot? takeRestoreRequest() {
    final snapshot = requestedRestore;
    requestedRestore = null;
    return snapshot;
  }

  void dismissStartupPrompt() {
    startupPromptDismissed = true;
    notifyListeners();
  }

  void rememberDirectory(PluginTab tab, String directory) {
    _directories[tab] = directory;
  }

  void resumeAfterCanceledExit() {
    _closing = false;
    _directoryTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => unawaited(refreshDirectories()),
    );
  }

  void markReady() {
    if (_ready) return;
    _ready = true;
    _syncListeners();
    _baselineTabs.addAll(_titleListeners.keys);
    for (final tab in _baselineTabs) {
      final directory = tab.currentWorkingDirectory;
      _directories[tab] = directory == '~'
          ? Platform.environment['HOME'] ?? directory
          : directory;
    }
    _lastLayout = jsonEncode(layout());
    _directoryTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => unawaited(refreshDirectories()),
    );
  }

  void _onState(TerminalTabState state) {
    _syncListeners();
    if (_ready && !_closing && state is TerminalTabLoaded) {
      unawaited(capture());
    }
  }

  void _syncListeners() {
    final state = tabs.state;
    final live = state is TerminalTabLoaded
        ? state.allTabs.whereType<PluginTab>().toSet()
        : <PluginTab>{};
    for (final tab in _titleListeners.keys.toList()) {
      if (live.contains(tab)) continue;
      final listener = _titleListeners.remove(tab)!;
      tab.plugin.title.removeListener(listener);
      if (tab.plugin is FileManagerPlugin) {
        (tab.plugin as FileManagerPlugin).currentPath.removeListener(listener);
      }
      _directories.remove(tab);
    }
    for (final tab in live) {
      if (_titleListeners.containsKey(tab)) continue;
      void changed() {
        if (!_ready || _closing) return;
        unawaited(capture());
        unawaited(refreshDirectories());
      }

      _titleListeners[tab] = changed;
      tab.plugin.title.addListener(changed);
      if (tab.plugin is FileManagerPlugin) {
        (tab.plugin as FileManagerPlugin).currentPath.addListener(changed);
      }
    }
  }

  Future<void> refreshDirectories() async {
    if (_polling || !_ready || _closing) return;
    _polling = true;
    try {
      await Future.wait([
        for (final tab in _titleListeners.keys.toList())
          if (tab.plugin case final TerminalPlugin plugin)
            () async {
              try {
                final directory = await plugin.liveWorkingDirectory().timeout(
                  const Duration(seconds: 1),
                );
                if (directory != null && _titleListeners.containsKey(tab)) {
                  _directories[tab] = directory;
                  if (_baselineTabs.remove(tab) && !_hasChanges) {
                    _lastLayout = jsonEncode(layout());
                  }
                }
              } catch (_) {
                // Keep the last known directory when a host cannot answer.
              }
            }(),
      ]);
      if (!_closing) await capture();
    } finally {
      _polling = false;
    }
  }

  Map<String, dynamic>? _descriptor(TabItem tab) {
    if (tab is UnavailableSessionTab) return Map.of(tab.descriptor);
    if (tab is! PluginTab) return null;
    final spec = tab.manager.hostSpec;
    final descriptor = <String, dynamic>{};
    if (spec is SSHHostSpec) {
      descriptor.addAll({
        'type': tab.plugin is FileManagerPlugin ? 'sftp' : 'ssh',
        'hostId': spec.record.id,
      });
    } else if (spec is LocalHostSpec ||
        spec is AndroidHostSpec ||
        spec is IosHostSpec) {
      descriptor.addAll({'type': 'local', 'profileId': tab.shellProfileId});
    } else {
      return null;
    }
    final directory = tab.plugin is FileManagerPlugin
        ? (tab.plugin as FileManagerPlugin).currentPath.value ??
              _directories[tab]
        : _directories[tab] ?? tab.currentWorkingDirectory;
    if (directory != null) descriptor['workingDirectory'] = directory;
    if (tab.customTitle != null) descriptor['customTitle'] = tab.customTitle;
    return descriptor;
  }

  Map<String, dynamic> layout({bool groupOnly = false, String? groupId}) {
    final state = tabs.state;
    if (state is! TerminalTabLoaded) return {'tabs': [], 'activeIndex': 0};
    final grouping = state.grouping;
    final descriptors = <Map<String, dynamic>>[];
    var activeIndex = 0;
    for (final tab in state.allTabs) {
      if (groupOnly && grouping.groupIdOf(tab) != groupId) continue;
      final descriptor = _descriptor(tab);
      if (descriptor == null) continue;
      final memberGroupId = grouping.groupIdOf(tab);
      if (memberGroupId != null) descriptor['groupId'] = memberGroupId;
      if (identical(tab, state.activeTab)) activeIndex = descriptors.length;
      descriptors.add(descriptor);
    }
    final usedGroups = descriptors.map((tab) => tab['groupId']).toSet();
    final groups = [
      for (final group in grouping.groups)
        if (usedGroups.contains(group.id))
          {'id': group.id, 'name': group.name, 'collapsed': group.collapsed},
    ];
    return {
      'activeIndex': activeIndex,
      'tabs': descriptors,
      if (groups.isNotEmpty) 'groups': groups,
      if (grouping.ungroupedCollapsed) 'ungroupedCollapsed': true,
    };
  }

  Future<void> capture({bool force = false}) async {
    if (!_ready || _closing) return;
    final captured = layout();
    final encoded = jsonEncode(captured);
    if (!force && encoded == _lastLayout) return;
    _lastLayout = encoded;
    _hasChanges = true;
    try {
      await store.record(captured);
      if (persistenceError != null) {
        persistenceError = null;
        notifyListeners();
      }
    } catch (error) {
      persistenceError = error;
      notifyListeners();
    }
  }

  Future<SessionSnapshot> save(
    String name, {
    bool groupOnly = false,
    String? groupId,
  }) async {
    await refreshDirectories();
    await capture(force: true);
    final snapshot = await store.save(
      name,
      layout(groupOnly: groupOnly, groupId: groupId),
      group: groupOnly,
    );
    notifyListeners();
    return snapshot;
  }

  Future<void> deleteSaved(String id) async {
    await store.deleteSaved(id);
    notifyListeners();
  }

  Future<void> prepareExit() async {
    _closing = true;
    _directoryTimer?.cancel();
    if (persistenceError != null && _lastLayout != null) {
      await store.record(jsonDecode(_lastLayout!) as Map<String, dynamic>);
    }
    await store.flush();
  }

  Future<void> finishExit() => store.finishExit();

  @override
  void dispose() {
    _closing = true;
    _directoryTimer?.cancel();
    unawaited(_subscription.cancel());
    for (final entry in _titleListeners.entries) {
      entry.key.plugin.title.removeListener(entry.value);
      if (entry.key.plugin is FileManagerPlugin) {
        (entry.key.plugin as FileManagerPlugin).currentPath.removeListener(
          entry.value,
        );
      }
    }
    _titleListeners.clear();
    super.dispose();
  }
}
