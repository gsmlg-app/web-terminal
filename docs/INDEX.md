# Documentation Index

This directory contains detailed documentation for the Flutter App Template project.

## Quick Links

| Document | Description |
|----------|-------------|
| [BRICKS.md](BRICKS.md) | Mason bricks guide - code generation templates for screens, BLoCs, repositories, and more |
| [BRICK_TESTING.md](BRICK_TESTING.md) | Guide for testing Mason bricks and validation |
| [DOCUMENTATION.md](DOCUMENTATION.md) | Error handling and logging system architecture |
| [FORM_BLOC.md](FORM_BLOC.md) | Comprehensive guide for form management with BLoC pattern |
| [TERMINAL.md](TERMINAL.md) | Terminal feature documentation - shell sessions, SSH, settings |
| [REMOTE_CLIPBOARD.md](REMOTE_CLIPBOARD.md) | Native terminal OSC 52 remote clipboard integration, security policy, and tmux configuration |
| [IOS_SHELL_EMULATOR.md](IOS_SHELL_EMULATOR.md) | iOS shell emulator architecture, limitations, and roadmap |
| [TESTING.md](TESTING.md) | Testing guide for running tests across the monorepo |
| [USAGE.md](USAGE.md) | Error handling system usage and setup guide |

## Document Summaries

### BRICKS.md
Complete guide for using Mason bricks in this project. Covers all available bricks:
- **screen** - Create new screens with adaptive scaffold support
- **simple_bloc** - Generate BLoC pattern boilerplate
- **list_bloc** - BLoC for list/pagination scenarios
- **form_bloc** - Form validation and submission BLoC
- **repository** - Data layer repository pattern
- **api_client** - OpenAPI client generation
- **widget** - Reusable widget components
- **native_federation_plugin** - Cross-platform native plugins

### BRICK_TESTING.md
Documentation for the brick testing infrastructure located in `tool/brick_tests/`. Explains how to validate brick structure, test code generation, and run integration tests.

### DOCUMENTATION.md
Technical documentation for the error handling and logging system:
- `app_lib/logging` - Core logging functionality with AppLogger
- `app_bloc/error_handler` - Error state management
- Integration with feedback widgets

### FORM_BLOC.md
In-depth guide for the `form_bloc` and `flutter_form_bloc` packages:
- Core concepts and architecture
- Available field types and validation
- Form submission handling
- UI integration examples
- Best practices

### TESTING.md
Guide for running tests across the Flutter monorepo using Melos:
- Melos test commands (`melos run test`, `melos run brick-test`)
- CI/CD integration with GitHub Actions
- Screen test coverage details
- Writing widget and BLoC tests

### TERMINAL.md
Complete documentation for the terminal feature:
- Shell screen architecture and components
- Local shell on Android (busybox/Termux-style) and iOS (ios_system)
- Remote SSH sessions with password and key-based authentication
- Terminal settings (font, max shells, environment variables)
- Performance and security considerations

### IOS_SHELL_EMULATOR.md
Detailed documentation for iOS shell emulator development:
- Architecture overview and component diagram
- How ios_system framework works without PTY support
- Available commands and built-in shell commands
- Known limitations (no job control, no interactive programs)
- Development roadmap for future enhancements
- Comparison with a-shell project

### USAGE.md
Practical guide for setting up and using the error handling system:
- Initialization in main.dart
- Crash reporting widget setup
- Error handling patterns

## See Also

- [README.md](../README.md) - Project overview and quick start
- [CLAUDE.md](../CLAUDE.md) - AI assistant guidance for this codebase
