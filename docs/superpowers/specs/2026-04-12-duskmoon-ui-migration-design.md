# Migrate Third-Party Packages to DuskMoon UI

**Date:** 2026-04-12
**Status:** Approved

## Goal

Replace four vendored third-party packages with the `duskmoon_ui` umbrella package:
- `third_party/form_bloc` -> `duskmoon_form` (via `duskmoon_ui`)
- `third_party/flutter_form_bloc` -> `duskmoon_form` (via `duskmoon_ui`)
- `third_party/settings_ui` -> `duskmoon_settings` (via `duskmoon_ui`)
- `third_party/flutter_adaptive_scaffold` -> `duskmoon_adaptive_scaffold` (via `duskmoon_ui`)

## Approach: Direct API Swap

The duskmoon packages are designed as compatible replacements. Changes are:
1. Import path changes
2. `Dm` prefix on form widget builders
3. `DmAdaptiveScaffold` replaces `AdaptiveScaffold`
4. Remove third_party directories and workspace entries

## Affected Files

### Dependencies (pubspec.yaml)
- Root `pubspec.yaml` - remove 4 third_party deps, add duskmoon_ui
- `app_widget/terminal_settings/pubspec.yaml` - replace settings_ui + flutter_form_bloc
- `app_widget/web_server_settings/pubspec.yaml` - replace settings_ui
- `app_widget/adaptive/pubspec.yaml` - replace flutter_adaptive_scaffold
- `app_bloc/ssh_host/pubspec.yaml` - replace form_bloc
- `app_bloc/ssh_key/pubspec.yaml` - replace form_bloc

### Settings UI (19 files) - import change only
- `lib/screens/settings/select_brightness.dart`
- `lib/screens/settings/ssh_key_management.dart`
- `lib/screens/settings/shell_profile_screen.dart`
- `lib/screens/settings/host_management.dart`
- `lib/screens/settings/select_theme.dart`
- `lib/screens/settings/device/device_info_screen.dart`
- `lib/screens/settings/device/wifi_info_screen.dart`
- `lib/screens/settings/web_server/web_server_screen.dart`
- `app_widget/terminal_settings/lib/src/root_setting_list.dart`
- `app_widget/terminal_settings/lib/src/env_settings_list.dart`
- `app_widget/terminal_settings/lib/src/settings_section_device_info.dart`
- `app_widget/terminal_settings/lib/src/settings_section_wifi_info.dart`
- `app_widget/terminal_settings/lib/src/settings_section_terminal.dart`
- `app_widget/terminal_settings/lib/src/bloc_settings_section_accent_color.dart`
- `app_widget/terminal_settings/lib/src/bloc_settings_section_appearance.dart`
- `app_widget/web_server_settings/lib/src/settings_section_web_server.dart`
- `app_widget/terminal_settings/test/terminal_settings_test.dart`
- `app_widget/terminal_settings/test/settings_section_terminal_test.dart`
- `app_widget/terminal_settings/test/settings_section_wifi_info_test.dart`

### Form BLoC (5 files) - import change + Dm prefix on widgets
- `app_bloc/ssh_host/lib/src/form.dart` - import only (uses FormBloc, TextFieldBloc, SelectFieldBloc)
- `app_bloc/ssh_key/lib/src/form.dart` - import only (uses FormBloc, TextFieldBloc)
- `app_widget/terminal_settings/lib/src/ssh_host_form.dart` - import + Dm prefix widgets
- `app_widget/terminal_settings/lib/src/ssh_key_form.dart` - import + Dm prefix widgets

### Adaptive Scaffold (1 file) - import + class rename
- `app_widget/adaptive/lib/src/scaffold.dart` - AdaptiveScaffold -> DmAdaptiveScaffold

### Mason Brick (3 files)
- `bricks/form_bloc/__brick__/pubspec.yaml`
- `bricks/form_bloc/__brick__/lib/src/bloc.dart`
- `bricks/form_bloc/__brick__/lib/src/state.dart`
- `bricks/form_bloc/__brick__/test/{{name.snakeCase()}}_form_bloc_test.dart`

## API Mapping

| Old | New | Notes |
|-----|-----|-------|
| `SettingsList` | `SettingsList` | Same |
| `SettingsSection` | `SettingsSection` | Same |
| `SettingsTile` | `SettingsTile` | Same |
| `SettingsTile.navigation` | `SettingsTile.navigation` | Same |
| `SettingsTile.switchTile` | `SettingsTile.switchTile` | Same |
| `FormBloc` | `FormBloc` | Same |
| `TextFieldBloc` | `TextFieldBloc` | Same |
| `SelectFieldBloc` | `SelectFieldBloc` | Same |
| `FieldBlocValidators` | `FieldBlocValidators` | Same |
| `TextFieldBlocBuilder` | `DmTextFieldBlocBuilder` | Added Dm prefix |
| `DropdownFieldBlocBuilder` | `DmDropdownFieldBlocBuilder` | Added Dm prefix |
| `FormBlocListener` | `DmFormBlocListener` | Added Dm prefix |
| `SuffixButton` | `SuffixButton` | Same |
| `FieldItem` | `FieldItem` | Same |
| `AdaptiveScaffold` | `DmAdaptiveScaffold` | Added Dm prefix |
| `Breakpoints` | `Breakpoints` | Same |

## Removals

Delete directories:
- `third_party/form_bloc/`
- `third_party/flutter_form_bloc/`
- `third_party/settings_ui/`
- `third_party/flutter_adaptive_scaffold/`

Remove from root `pubspec.yaml` workspace section:
- `third_party/form_bloc`
- `third_party/flutter_form_bloc`
- `third_party/flutter_adaptive_scaffold`
- `third_party/settings_ui`

## Verification

- `melos run analyze` passes
- `melos run test` passes
- No remaining imports of old packages
