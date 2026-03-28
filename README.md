# Web Terminal

A Flutter-based terminal emulator with SSH/SFTP support, targeting Android, iOS, macOS, Linux, Windows, and Web. Features local shell sessions, remote SSH connections, and a web-based terminal server with session management.

## Features

- **Local Terminal** - PTY-based shell sessions on desktop and Android (busybox), ios_system on iOS
- **SSH Client** - Pure Dart SSH connections with secure key management
- **Web Terminal Server** - Host terminal sessions accessible via browser with WebSocket and approval-based authentication
- **Multi-Tab Interface** - Multiple terminal tabs with xterm.dart emulation
- **Cross-Platform** - Android, iOS, macOS, Linux, Windows, and Web
- **Theme System** - Multiple color schemes (fire, green, violet, wheat) with light/dark modes
- **Internationalization** - Full i18n support with ARB files

## Architecture

Monorepo managed by Melos with 50+ workspace packages:

- **app_bloc/** - BLoC state management (theme, SSH keys/hosts, terminal tabs, web sessions, shell profiles)
- **app_lib/** - Core libraries (database, terminal core, SSH, web server, logging, secure storage)
- **app_widget/** - UI components (xterm, terminal tabs, file manager, settings)
- **app_plugin/** - Native plugins (PTY, android_shell, ios_shell, client_info)
- **third_party/** - Modified packages (form_bloc, adaptive_scaffold, settings_ui, flex_tabs)

## Getting Started

### Prerequisites

- [Nix](https://nixos.org/) with [devenv](https://devenv.sh/) (recommended) or Flutter SDK manually
- Git

### Setup with devenv

```bash
git clone https://github.com/gsmlg-dev/web-terminal.git
cd web-terminal
direnv allow    # Auto-loads Nix environment with Flutter SDK
melos bootstrap
mason get
```

### Setup without devenv

```bash
dart pub global activate melos
dart pub global activate mason_cli
melos bootstrap
mason get
```

### Running the App

```bash
flutter run                # Default device
flutter run -d linux       # Linux (requires devenv shell for GTK3/libsecret deps)
flutter run -d macos       # macOS
flutter run -d chrome      # Web
flutter run -d android     # Android
flutter run -d ios         # iOS
```

## Development

### Common Commands

```bash
melos run prepare          # Full setup: bootstrap + gen-l10n + build-runner
melos run analyze          # Lint all packages
melos run format           # Format all packages
melos run test             # Run all tests
```

### Code Generation

Uses [Mason](https://github.com/felangel/mason) templates. See [BRICKS.md](./docs/BRICKS.md) for the complete guide.

```bash
mason make screen --name ScreenName --folder subfolder
mason make simple_bloc -o app_bloc/feature --name=feature
mason make native_plugin --name plugin_name --description "Description" --package_prefix app -o app_plugin
```

## Documentation

- [Mason Bricks Guide](./docs/BRICKS.md) - Code generation templates
- [Form BLoC Guide](./docs/FORM_BLOC.md) - Form validation and submission
- [Testing Guide](./docs/TESTING.md) - Test structure and strategy
- [Documentation Index](./docs/INDEX.md) - Full documentation index
- [CLAUDE.md](./CLAUDE.md) - AI assistant development guidance

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
