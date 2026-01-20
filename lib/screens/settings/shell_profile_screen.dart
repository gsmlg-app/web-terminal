import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_feedback/app_feedback.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:web_terminal/destinations.dart';

/// Screen for managing shell profiles.
class ShellProfileScreen extends StatelessWidget {
  static const name = SettingsScreenNames.shellProfiles;
  static const path = 'shell_profiles';

  static const String fullPath = '${SettingsScreen.path}/$path';

  const ShellProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShellProfileBloc>().add(const LoadShellProfiles());
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
              title: const Text('Shell Profiles'),
              actions: _getActions(context),
            ),
            BlocBuilder<ShellProfileBloc, ShellProfileState>(
              builder: (context, state) {
                return SliverFillRemaining(
                  child: SettingsList(
                    sections: [
                      _buildSection(context, state),
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
            const SliverAppBar(
              title: Text('Settings'),
              automaticallyImplyLeading: false,
            ),
            SliverFillRemaining(
              child: RootSettingList(config: rootSettingListConfig),
            ),
          ],
        ),
      ),
      largeSecondaryBody: (_) => SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              title: const Text('Shell Profiles'),
              automaticallyImplyLeading: false,
              actions: _getActions(context),
            ),
            BlocBuilder<ShellProfileBloc, ShellProfileState>(
              builder: (context, state) {
                return SliverFillRemaining(
                  child: SettingsList(
                    sections: [
                      _buildSection(context, state),
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

  SettingsSection _buildSection(BuildContext context, ShellProfileState state) {
    if (state is ShellProfileInitial || state is ShellProfileLoading) {
      return SettingsSection(
        title: const Text('Shell Profiles'),
        tiles: <SettingsTile>[
          SettingsTile(
            title: const Text('Loading...'),
            leading: const CircularProgressIndicator.adaptive(),
          ),
        ],
      );
    }
    if (state is ShellProfileError) {
      return SettingsSection(
        title: const Text('Shell Profiles'),
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
                    child: const Text('Reload'),
                    onPressed: () {
                      context
                          .read<ShellProfileBloc>()
                          .add(const LoadShellProfiles());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    final profiles = (state as ShellProfileLoaded).profiles;
    return profiles.isNotEmpty
        ? SettingsSection(
            title: const Text('Shell Profiles'),
            tiles: <SettingsTile>[
              for (final profile in profiles)
                SettingsTile(
                  title: Text(profile.name),
                  leading: profile.isDefault
                      ? const Icon(Icons.star, color: Colors.amber)
                      : const Icon(Icons.person),
                  description: Text(_getProfileDescription(profile)),
                  onPressed: (c) {
                    _showProfileActions(c, profile);
                  },
                ),
            ],
          )
        : SettingsSection(
            title: const Text('Shell Profiles'),
            tiles: <SettingsTile>[
              SettingsTile(
                title: const Text('Add Profile'),
                leading: const Icon(Icons.add),
                onPressed: (context) {
                  _showProfileForm(context: context);
                },
              ),
            ],
          );
  }

  String _getProfileDescription(ShellProfile profile) {
    final shellType = ShellType.fromValue(profile.shellType)?.name ?? 'sh';
    final parts = <String>[shellType];
    if (profile.isDefault) {
      parts.add('default');
    }
    return parts.join(' • ');
  }

  void _showProfileActions(BuildContext context, ShellProfile profile) {
    showBottomSheetActionList(
      showBackdrop: false,
      context: context,
      actions: [
        BottomSheetAction(
          title: const Text('Edit'),
          onTap: () {
            _showProfileForm(context: context, profile: profile);
          },
        ),
        if (!profile.isDefault)
          BottomSheetAction(
            title: const Text('Set as Default'),
            onTap: () {
              context.read<ShellProfileBloc>().add(SetDefaultProfile(profile));
            },
          ),
        BottomSheetAction(
          title: const Text('Delete'),
          onTap: () {
            _confirmDelete(context, profile);
          },
        ),
        BottomSheetAction(
          title: const Text('Cancel'),
          onTap: () {},
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, ShellProfile profile) {
    showAdaptiveDialog(
      context: context,
      builder: (_) {
        return AlertDialog.adaptive(
          title: const Text('Delete Profile'),
          content: Text('Delete "${profile.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<ShellProfileBloc>().add(
                      DeleteShellProfile(profile),
                    );
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showProfileForm({
    required BuildContext context,
    ShellProfile? profile,
  }) {
    showShellProfileForm(context: context, profile: profile);
  }

  List<Widget> _getActions(BuildContext context) {
    return [
      AppAdaptiveActionList(
        actions: [
          AppAdaptiveAction(
            icon: Icons.add,
            title: 'Add',
            onPressed: () {
              _showProfileForm(context: context);
            },
          ),
        ],
      ),
    ];
  }
}

/// Shows a form dialog for creating or editing a shell profile.
void showShellProfileForm({
  required BuildContext context,
  ShellProfile? profile,
}) {
  final isEditing = profile != null;
  final nameController = TextEditingController(text: profile?.name ?? '');
  var selectedShellType =
      ShellType.fromValue(profile?.shellType) ?? ShellType.sh;
  var isDefault = profile?.isDefault ?? false;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Profile' : 'New Profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter profile name',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ShellType>(
                    initialValue: selectedShellType,
                    decoration: const InputDecoration(
                      labelText: 'Shell Type',
                    ),
                    items: ShellType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedShellType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Default Profile'),
                    value: isDefault,
                    onChanged: (value) {
                      setState(() {
                        isDefault = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    return;
                  }

                  final bloc = context.read<ShellProfileBloc>();
                  if (isEditing) {
                    bloc.add(UpdateShellProfile(
                      id: profile.id,
                      name: name,
                      shellType: selectedShellType,
                      isDefault: isDefault,
                    ));
                  } else {
                    bloc.add(AddShellProfile(
                      name: name,
                      shellType: selectedShellType,
                      isDefault: isDefault,
                    ));
                  }
                  Navigator.of(dialogContext).pop();
                },
                child: Text(isEditing ? 'Save' : 'Add'),
              ),
            ],
          );
        },
      );
    },
  );
}
