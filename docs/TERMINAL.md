# Terminal Feature Documentation

This document describes the terminal feature of the web-terminal application, including the shell screen, session management, and remote connections.

## Overview

The terminal provides a native-like shell experience with support for:
- Local shell sessions on Android (Termux-style with busybox)
- Local shell sessions on iOS (a-shell style with ios_system)
- Remote SSH sessions with password and key-based authentication
- Multiple concurrent sessions with tab-style management
- Configurable terminal settings (font, max shells, environment variables)

## Architecture

### Core Components

| Component | Location | Purpose |
|-----------|----------|---------|
| TerminalScreen | `lib/screens/terminal/` | Main terminal screen with AppBar |
| TerminalAppBar | `lib/screens/terminal/widgets/` | Session selector and actions |
| TerminalTabBloc | `app_bloc/terminal_tab/` | Tab/session state management |
| TerminalSettingsBloc | `app_bloc/terminal_settings/` | Terminal configuration |
| AndroidShellPlugin | `app_plugin/android_shell/` | Android shell integration |
| IosShellPlugin | `app_plugin/ios_shell/` | iOS shell integration |
| SSH Library | `app_lib/ssh/` | Pure Dart SSH implementation |
| Terminal Hosts | `app_lib/terminal_hosts/` | Host abstraction layer |

### Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        TerminalScreen                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    TerminalAppBar                        │   │
│  │  ┌──────────┐ ┌─────────────┐ ┌──────────────────────┐  │   │
│  │  │Fullscreen│ │Session Title│ │    + Menu            │  │   │
│  │  │ Toggle   │ │  (Selector) │ │ • Local Shell        │  │   │
│  │  └──────────┘ └─────────────┘ │ • SSH Shell          │  │   │
│  │                               │ • SFTP (planned)     │  │   │
│  │                               └──────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   Terminal View (xterm)                  │   │
│  │                                                          │   │
│  │    Renders active session's terminal output              │   │
│  │                                                          │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      TerminalTabBloc                            │
│  • Manages tab state (Tabs, TabItem, TabsDocument)              │
│  • Handles session selection/closing                            │
│  • Tracks fullscreen state                                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Terminal Host Layer                         │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐            │
│  │ LocalHost    │ │  SSHHost     │ │  SFTPHost    │            │
│  │ (PTY-based)  │ │ (dartssh2)   │ │  (planned)   │            │
│  └──────────────┘ └──────────────┘ └──────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

## User Interface

### AppBar Layout

The terminal screen uses a custom AppBar instead of the previous flex-tabs layout:

- **Left Action**: Fullscreen toggle (hides app navigation)
- **Title**: Current session name with dropdown arrow (tap to switch sessions)
- **Right Action**: Plus menu for creating new sessions

### Session Selector

Tap the AppBar title to open the session selector popup:
- Shows all active sessions
- Checkmark indicates current session
- Close button (X) for each session
- Tap a session to switch to it

### Creating Sessions

Tap the plus (+) button to open the session menu:
- **Local Shell**: Opens a new local shell session
- **SSH Shell**: Opens host selector dialog, then connects
- **SFTP** (planned): Will open file manager for remote host

## Local Shell

### Android

The Android shell uses busybox with a sandboxed root filesystem:

```
$APP_DATA/files/
├── busybox           # Static ARM64 busybox binary
├── rootfs/           # Root filesystem
│   ├── bin/          # Busybox symlinks
│   ├── usr/etc/profile  # Shell profile
│   └── ...
└── home/             # User home directory
```

**Shell initialization**:
```sh
cd $HOME; . $ENV; exec sh -i
```

The shell:
- Starts in the home directory
- Sources the environment profile
- Provides common Unix utilities via busybox

### iOS

The iOS shell uses the ios_system framework:

- Commands execute in a sandboxed Documents directory
- Uses dash shell (not bash)
- Limited command set provided by ios_system
- No PTY support (expected limitation)

Available commands can be queried via:
```dart
IosShellPlugin.listCommands()
```

## Remote SSH Sessions

### Connection Flow

1. User taps plus (+) → "SSH Shell"
2. SshHostSelector dialog shows configured SSH hosts
3. User selects a host
4. SSHConnector establishes connection based on identity type:
   - **Password**: Prompts for password authentication
   - **Key-based**: Loads and decrypts stored SSH key

### SSH Key Authentication

SSH keys are stored encrypted in the database and decrypted at connection time:

```dart
// Key storage structure
class SshKey {
  final int id;
  final String name;
  final String publicKey;     // Stored as plain text
  final String privateKey;    // Stored AES-encrypted
  final String? passphrase;   // Stored AES-encrypted (optional)
}
```

The `SSHConnector` class handles authentication:

```dart
// In SSHConnector.connect()
if (spec.identityType == SSHIdentityType.key) {
  // Load key from database
  final key = await db.sshKeyDao.findById(spec.identityKeyId);

  // Decrypt private key
  final keyData = await key.decryptKey();

  // Use SSHKeyPair.fromPem() for authentication
  await ssh.authenticate(keyPair: SSHKeyPair.fromPem(keyData.content));
}
```

### Configuring SSH Hosts

SSH hosts are managed through the settings screen:

1. Navigate to Settings → SSH Hosts
2. Add new host with:
   - Hostname/IP
   - Port (default: 22)
   - Username
   - Identity type (password or key)
   - SSH key selection (for key-based auth)

## Terminal Settings

### Configuration Options

| Setting | Default | Range | Description |
|---------|---------|-------|-------------|
| Font Size | 13.0 | 8-32 | Terminal font size in logical pixels |
| Font Family | monospace | preset list | Terminal font family |
| Max Open Shells | 10 | 1-50 | Maximum concurrent sessions |
| Environment Variables | {} | - | Custom environment variables |

### Settings Bloc

The `TerminalSettingsBloc` manages terminal configuration:

```dart
// Load settings
bloc.add(TerminalSettingsLoad());

// Update font size
bloc.add(TerminalSettingsUpdateFontSize(fontSize: 16.0));

// Update max shells
bloc.add(TerminalSettingsUpdateMaxOpenShells(maxOpenShells: 20));

// Add environment variable
bloc.add(TerminalSettingsUpdateEnvVar(key: 'MY_VAR', value: 'my_value'));
```

Settings are persisted to secure storage and loaded on app start.

## Fullscreen Mode

Toggle fullscreen mode to maximize terminal real estate:

1. Tap the fullscreen icon in the AppBar (left action)
2. App navigation shell is hidden
3. Terminal fills the entire screen
4. Tap again to restore navigation

Fullscreen state is managed by `TerminalTabBloc`:

```dart
bloc.add(TerminalTabToggleFullscreen());
```

## Performance

The terminal rendering uses several optimizations:

- **Repaint boundary**: Terminal is isolated from ancestor repaints
- **Visible line culling**: Only renders lines in the viewport
- **Paragraph caching**: LRU cache (10,240 entries) for text layouts
- **VM inlining hints**: Hot paths use `@pragma('vm:prefer-inline')`
- **Circular buffer**: O(1) line operations with bounded memory

See `.loki/logs/performance-review-terminal-rendering.md` for detailed analysis.

## Security

### SSH Key Storage

- Private keys encrypted with AES before storage
- Per-key salt for encryption
- Keys decrypted only when needed for connection
- Passphrase support for additional protection

See `.loki/logs/security-review-ssh-keys.md` for detailed analysis.

### Sandboxing

- Android: Shell runs in app sandbox with scoped filesystem
- iOS: Commands execute in sandboxed Documents directory
- No root/jailbreak capabilities

## Testing

Tests are located in:

- `test/screens/terminal/` - Widget tests for terminal screen
- `test/screens/terminal/widgets/` - Widget tests for AppBar, menus
- `app_bloc/terminal_tab/test/` - BLoC tests for tab management
- `app_bloc/terminal_settings/test/` - BLoC tests for settings
- `app_lib/terminal_hosts/test/` - Unit tests for SSH components

Run tests with:
```bash
melos run test
```

## Known Limitations

### iOS Shell
- No PTY support (uses ios_system)
- Limited to dash shell
- Sandboxed to Documents directory
- Some interactive applications may not work

### SFTP
- Not yet implemented
- Planned for future release

### Android Rootfs
- Initial extraction required on first launch
- Filesystem scoped to app sandbox

## See Also

- [PRD.md](../PRD.md) - Product requirements
- [CLAUDE.md](../CLAUDE.md) - AI assistant guidance
- [USAGE.md](USAGE.md) - Error handling guide
