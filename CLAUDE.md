# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter-based terminal emulator with SSH/SFTP support, targeting mobile (Android + iOS) and desktop (macOS, Linux, Windows). Uses modular monorepo architecture with BLoC state management.

- **Android**: Busybox + flutter_pty for real PTY shell sessions
- **iOS**: ios_system framework for simulated shell (no PTY support on iOS)
- **Desktop**: flutter_pty with native system shell
- **SSH**: Pure Dart SSH client for remote connections

## Architecture Structure

```
├── lib/                    # Main app entry point + screens
├── app_bloc/               # BLoC state management packages
├── app_lib/                # Core utilities and abstractions
├── app_widget/             # Reusable UI components
├── app_plugin/             # Native platform plugins
├── bricks/                 # Mason templates for code generation
├── test_bricks/            # Brick tests (one folder per brick)
└── third_party/            # Modified third-party packages (flex_tabs, etc.)
```

## Terminal Architecture

The terminal system uses a Host abstraction with platform-specific implementations:

```
Host interface (app_lib/terminal_core)
  ├─ LocalHost  (flutter_pty)               → Desktop PTY shell
  ├─ AndroidHost (flutter_pty + android_shell) → Busybox PTY shell
  ├─ IosHost    (ios_shell)                 → ios_system line-by-line shell
  └─ SSHHost    (app_lib/ssh)              → Remote SSH connections
```

Key packages:
- `app_lib/terminal_core` - `Host`, `ExecutionSession`, `FileSystem` interfaces
- `app_lib/terminal_hosts` - Platform-specific host implementations
- `app_plugin/ios_shell` - iOS shell via ios_system XCFrameworks
- `app_plugin/android_shell` - Android shell via busybox
- `app_plugin/pty` - Vendored flutter_pty for PTY support
- `app_widget/xterm` - Vendored xterm.dart terminal emulator widget

## Platform Build Requirements

### iOS
- **XCFrameworks** in `app_plugin/ios_shell/ios/Frameworks/`: ios_system, shell, files, text, tar, awk
- **Critical**: `ios/Podfile` post_install hook copies `commandDictionary.plist` to `Runner.app/` root — without this, all commands return exit code 127
- See `.claude/skills/app-dev-ios-shell/SKILL.md` for full details

### Android
- **Busybox binaries** in `app_plugin/android_shell/android/src/main/assets/shell/{arch}/`
- Wrapper scripts generated at runtime to work around Android 10+ noexec restrictions on `/data`
- See `.claude/skills/app-dev-android-shell/SKILL.md` for full details

## Workspace Packages

Defined in root `pubspec.yaml` workspace section. Use `<package_name>: any` for internal dependencies (never use path dependencies).

- `app_lib/`: database, theme, locale, provider, logging, terminal_core, terminal_hosts, ssh, secure_storage, security, utils, web_server
- `app_bloc/`: theme, connection, ssh_key, ssh_host, terminal_tab, terminal_settings, shell_profile, web_session
- `app_widget/`: adaptive, artwork, feedback, web_view, xterm, terminal_settings, terminal_tabs, terminal_plugin, file_manager_plugin
- `app_plugin/`: client_info (federated), android_shell, ios_shell, pty
- `third_party/`: flex_tabs

## Custom Skills (Claude Code)

Project-specific skills in `.claude/skills/`:
- `/project-bloc` - Create BLoC packages
- `/project-screen` - Create screens with routing
- `/project-widget` - Create reusable widgets
- `/project-plugin` - Create native plugins
- `/app-dev-ios-shell` - iOS shell development guide
- `/app-dev-android-shell` - Android shell development guide
- `/project-database`, `/project-locale`, `/project-form`, `/project-api`, `/project-feedback`, `/project-secure-storage`, `/project-metadata`

## Development Commands

### Setup
```bash
dart pub global activate melos
dart pub global activate mason_cli
melos bootstrap
mason get
```

### Common Workflows
```bash
melos run prepare          # Bootstrap + gen-l10n + build-runner (full setup)
melos run analyze          # Lint all packages (--fatal-warnings)
melos run format           # Format all packages
melos run format-check     # Check formatting (CI uses this, exits non-zero if changes needed)
melos run fix              # Apply dart fix --apply
melos run test             # Run all tests (flutter + dart)
melos run test:dart        # Non-Flutter packages only
melos run test:flutter     # Flutter packages only
```

### Individual Package Operations
```bash
# Test single file
flutter test test/screens/splash_screen_test.dart

# Package-specific commands
cd app_lib/theme && flutter test
cd app_lib/theme && dart run build_runner build --delete-conflicting-outputs
```

### Code Generation with Mason
```bash
# Screens and widgets
mason make screen --name ScreenName --folder subfolder
mason make widget --name WidgetName --type stateless --folder components

# BLoC patterns
mason make simple_bloc -o app_bloc/feature_name --name=feature_name
mason make list_bloc -o app_bloc/feature_name --name=feature_name
mason make form_bloc --name Login --field_names "email,password"

# Other generators
mason make repository -o app_lib/feature_name --name=feature_name
mason make api_client -o app_api/app_api --package_name=app_api

# Native plugins (prefer native_plugin for simplicity)
mason make native_plugin --name plugin_name --description "Description" --package_prefix app -o app_plugin
# Use native_federation_plugin only when publishing separate platform packages
mason make native_federation_plugin --name plugin_name --description "Description" --package_prefix app -o app_plugin
```

See [BRICKS.md](./docs/BRICKS.md) for complete brick documentation.

### Template Scripts
```bash
# Rename template to your project name (run once after cloning)
dart run bin/setup_project.dart my_project_name

# Update bricks from upstream template (only works after renaming)
dart run bin/update_bricks.dart
dart run bin/update_bricks.dart --force  # Force update all bricks
```

## Key Entry Points

- `lib/main.dart` - App initialization: MainProvider, AppLogger, AppDatabase, SharedPreferences
- `lib/app.dart` - Root widget with ThemeBloc and MaterialApp.router
- `lib/router.dart` - GoRouter configuration with NoTransitionPage
- `lib/screens/` - Feature screens (app/, home/, settings/)

## Architecture Patterns

### App Initialization (lib/main.dart)
```dart
MainProvider(
  sharedPrefs: sharedPrefs,
  database: database,
  child: MaterialApp(...),
)
```

### Routing Pattern
Screens define static `name` and `path` constants for GoRouter integration:
```dart
class HomeScreen extends StatelessWidget {
  static const name = 'home';
  static const path = '/home';
}
```

### Logging
Use `AppLogger` from `app_logging` package with configurable levels (debug, info, warning, error). Logs to file in application support directory.

### Theme
`ThemeBloc` manages theme state. Available color schemes: fire, green, violet, wheat. Supports light/dark modes.

## Running the App

```bash
flutter run                # Default device
flutter run -d chrome      # Web
flutter run -d macos       # macOS
flutter run -d linux       # Linux
```

## Development Environment

Uses Nix/Devenv for reproducible environment. Auto-loads via direnv (`.envrc`). Flutter SDK version managed through `devenv.nix`.

## Code Style

- flutter_lints rules from analysis_options.yaml
- BLoC pattern for state management
- Repository pattern for data layer
- Prefer const constructors
- Use AppLogger for error handling with logging

## CI Workflows

- `ci.yml` - Format check, analyze, test, and build (skips for docs/config changes)
- `brick-test.yml` - Tests Mason bricks (only runs when brick files change)
- `release.yml` - Manual workflow for creating releases with platform builds
