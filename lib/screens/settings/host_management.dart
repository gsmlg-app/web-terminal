import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_feedback/app_feedback.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:web_terminal/src/components/destinations.dart';
import 'package:web_terminal/src/components/setting/root_setting_list.dart';
import 'package:web_terminal/src/components/setting/ssh_host_form.dart';
import 'package:web_terminal/src/extensions/buildcontext/l10n.dart';

class SettingsHost extends StatelessWidget {
  static const name = 'SSH Host Management';
  static const path = 'ssh_host_management';

  static const String fullPath = '${SettingsScreen.path}/$path';

  const SettingsHost({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SshHostBloc>().add(SshHostLoad());
    });

    return AppAdaptiveScaffold(
      selectedIndex:
          Destinations.indexOf(const Key(SettingsScreen.name), context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(
        idx,
        context,
      ),
      destinations: Destinations.navs(context),
      body: (context) => SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              title: Text(context.l10n.titleSSHHost),
              actions: getActions(context),
            ),
            BlocBuilder<SshHostBloc, SshHostState>(
              builder: (context, state) {
                return SliverFillRemaining(
                  child: SettingsList(
                    sections: [
                      buildSection(context, state),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      largeBody: (context) => SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              title: Text(context.l10n.settingsTitle),
              automaticallyImplyLeading: false,
            ),
            const SliverFillRemaining(
              child: RootSettingList(),
            ),
          ],
        ),
      ),
      largeSecondaryBody: (_) => SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              title: Text(context.l10n.titleSSHHost),
              automaticallyImplyLeading: false,
              actions: getActions(context),
            ),
            BlocBuilder<SshHostBloc, SshHostState>(
              builder: (context, state) {
                return SliverFillRemaining(
                  child: SettingsList(
                    sections: [
                      buildSection(context, state),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SettingsSection buildSection(BuildContext context, SshHostState state) {
    if (state is SshHostInitial) {
      return SettingsSection(
        title: Text(context.l10n.sshHost),
        tiles: <SettingsTile>[
          SettingsTile(
            title: const Text('...'),
            leading: const FaIcon(FontAwesomeIcons.server),
          ),
        ],
      );
    }
    if (state is SshHostError) {
      return SettingsSection(
        title: Text(context.l10n.sshHost),
        tiles: <SettingsTile>[
          SettingsTile(
            title: Text('Error',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    )),
            leading: const Icon(Icons.error),
            description: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.errorContainer,
              ),
              child: Column(
                children: [
                  Text(
                    state.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                  ElevatedButton(
                    child: Text(context.l10n.reload),
                    onPressed: () {
                      context.read<SshHostBloc>().add(SshHostLoad());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    final sshHosts = (state as SshHostLoaded).sshHosts;
    return sshHosts.isNotEmpty
        ? SettingsSection(
            title: Text(context.l10n.sshHost),
            tiles: <SettingsTile>[
              for (final sshHost in sshHosts)
                SettingsTile(
                  title: Text(sshHost.host ?? 'N/A'),
                  leading: const FaIcon(FontAwesomeIcons.server),
                  onPressed: (c) {
                    showBottomSheetActionList(
                      showBackdrop: false,
                      context: c,
                      actions: [
                        BottomSheetAction(
                          title: Text(context.l10n.edit),
                          onTap: () {
                            showSshHostForm(context: context, sshHost: sshHost);
                          },
                        ),
                        BottomSheetAction(
                          title: Text(context.l10n.delete),
                          onTap: () {
                            showAdaptiveDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog.adaptive(
                                  title: Text(context.l10n.delete),
                                  content:
                                      Text(context.l10n.deleteSshHostMessage),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(context.l10n.cancel),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.read<SshHostBloc>().add(
                                              SshHostDelete(sshHost),
                                            );
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(context.l10n.delete),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        BottomSheetAction(
                          title: Text(context.l10n.cancel),
                          onTap: () {},
                        ),
                      ],
                    );
                  },
                ),
            ],
          )
        : SettingsSection(
            title: Text(context.l10n.sshHost),
            tiles: <SettingsTile>[
              SettingsTile(
                title: Text(context.l10n.add),
                leading: const Icon(Icons.add),
                onPressed: (context) {
                  showSshHostForm(context: context);
                },
              ),
            ],
          );
  }

  List<Widget> getActions(BuildContext context) {
    return [
      AppAdaptiveActionList(
        actions: [
          AppAdaptiveAction(
            icon: Icons.add,
            title: context.l10n.add,
            onPressed: () {
              showSshHostForm(context: context);
            },
          ),
        ],
      ),
    ];
  }
}
