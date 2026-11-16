import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:web_terminal/destinations.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/terminal/terminal_screen.dart';
import 'package:web_terminal/services/session_controller.dart';
import 'package:web_terminal/services/session_store.dart';

class SessionSnapshotsScreen extends StatelessWidget {
  const SessionSnapshotsScreen({super.key});

  static const name = 'Session Snapshots';
  static const path = 'sessions';

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreenNames.settings),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (context) => _buildContent(context),
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
      largeBody: (context) =>
          const SafeArea(child: RootSettingList(config: rootSettingListConfig)),
      largeSecondaryBody: (context) =>
          _buildContent(context, showBackButton: false),
    );
  }

  Widget _buildContent(BuildContext context, {bool showBackButton = true}) {
    final sessions = context.read<SessionController>();
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: Text(context.l10n.sessionSnapshots),
            automaticallyImplyLeading: false,
            leading: showBackButton
                ? BackButton(
                    onPressed: () =>
                        context.goNamed(SettingsScreenNames.settings),
                  )
                : null,
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: sessions,
              builder: (context, _) {
                final store = sessions.store;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(context.l10n.sessionRestoreDescription),
                    if (store.latest == null && store.saved.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(context.l10n.sessionNoSnapshots),
                      ),
                    if (store.recovery case final SessionSnapshot recovery)
                      ..._section(
                        context,
                        sessions,
                        context.l10n.sessionRecovery,
                        [recovery],
                      ),
                    ..._section(
                      context,
                      sessions,
                      context.l10n.sessionExitHistory,
                      store.history,
                    ),
                    ..._section(
                      context,
                      sessions,
                      context.l10n.sessionManualSaved,
                      store.saved,
                      manual: true,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    SessionController sessions,
    String title,
    List<SessionSnapshot> snapshots, {
    bool manual = false,
  }) {
    if (snapshots.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      for (final snapshot in snapshots)
        Card(
          child: ListTile(
            title: Text(
              snapshot.name ??
                  MaterialLocalizations.of(context)
                      .formatFullDate(snapshot.createdAt.toLocal()),
            ),
            subtitle: Text(
              '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(snapshot.createdAt.toLocal()))} · ${context.l10n.sessionDetails((snapshot.layout['tabs'] as List).length, (snapshot.layout['groups'] as List? ?? []).length)}',
            ),
            onTap: () {
              sessions.requestRestore(snapshot);
              context.goNamed(TerminalScreen.name);
            },
            trailing: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    sessions.requestRestore(snapshot);
                    context.goNamed(TerminalScreen.name);
                  },
                  child: Text(context.l10n.sessionRestore),
                ),
                if (manual)
                  IconButton(
                    tooltip: context.l10n.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(context.l10n.sessionDeleteConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(context.l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(context.l10n.delete),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      try {
                        await sessions.deleteSaved(snapshot.id);
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${context.l10n.error}: $error'),
                            ),
                          );
                        }
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
    ];
  }
}
