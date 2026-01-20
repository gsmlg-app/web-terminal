# Loki Mode Continuity Document

## Project: Mobile Shell Experience (Android + iOS)

### Current State
- **Phase**: SDLC COMPLETE
- **Started**: 2026-01-20T14:19:29Z
- **Last Updated**: 2026-01-20

### PRD Summary
Building a native-like shell experience on Android and iOS with:
1. Local shell on Android (Termux-style with rootfs)
2. Local shell on iOS (a-shell style with ios_system)
3. Remote SSH/SFTP sessions
4. New AppBar-based UI replacing flex-tabs

### Architecture Understanding

**Key Components Identified:**
- `lib/screens/terminal/terminal_screen.dart` - Main shell screen (now uses AppBar)
- `lib/screens/terminal/widgets/` - New widgets (TerminalAppBar, SessionMenu, SshHostSelector)
- `app_bloc/terminal_tab/` - Terminal tab state management
- `app_bloc/terminal_settings/` - Terminal settings (font, max shells, env vars)
- `app_plugin/android_shell/` - Android shell plugin with busybox
- `app_plugin/ios_shell/` - iOS shell plugin with ios_system
- `app_plugin/pty/` - Cross-platform PTY implementation
- `app_lib/ssh/` - Pure Dart SSH implementation
- `app_lib/terminal_hosts/` - Host abstraction layer (with SSH key auth)

### Milestones & Tasks

#### Milestone 1: Shell Screen AppBar Refactor ✓ COMPLETED
- [x] Create new AppBar-based terminal screen layout
- [x] Replace flex_tabs with custom tab management in UI
- [x] Add session selector in AppBar title (popup menu)
- [x] Add fullscreen toggle as AppBar left action
- [x] Add plus dropdown menu as AppBar right action
- [x] Implement session types: Local Shell, SSH, SFTP

**Commit**: dae816b - feat(terminal): replace flex-tabs with AppBar-based session UI

#### Milestone 2: Android Local Shell Integration ✓ COMPLETED
- [x] Verify busybox extraction works correctly
- [x] Test rootfs shell environment setup
- [x] Ensure home directory starts correctly (via profile sourcing)
- [x] Shell profile configuration exists at usr/etc/profile
- [x] Multiple shell sessions supported via tab management

**Verification**: Reviewed AndroidShellEnv.getShellCommand() which chains:
`cd $HOME; . $ENV; exec sh -i` to ensure proper home directory and profile.

#### Milestone 3: iOS Local Shell Integration ✓ COMPLETED
- [x] Verify ios_system command execution
- [x] Test Documents-based filesystem (homePath = documentsPath)
- [x] Document shell limitations (uses dash shell via ios_system)
- [x] Available commands provided via IosShellPlugin.listCommands()
- [x] Directory navigation supported via ios_system

**Note**: iOS shell uses ios_system framework which provides sandboxed command execution.

#### Milestone 4: Remote SSH Session Flow ✓ COMPLETED
- [x] Complete SSH connection workflow
- [x] Implement password authentication
- [x] Implement key-based authentication (unencrypted keys)
- [x] Add SshKeyData class for decrypted key content
- [x] Update SSHConnector to check identityType and use key auth
- [x] Update SSHHostSpec to accept keyData parameter
- [x] Load and decrypt keys from database via SshKeyEncryption extension

**Commit**: d57036d - feat(ssh): add SSH key authentication support

#### Milestone 5: Settings & Configuration ✓ COMPLETED
- [x] Add terminal profile settings (font size, font family)
- [x] Implement max open shells limit (1-50, default 10)
- [x] Add settings to TerminalSettingsBloc state
- [x] Update settings UI with font slider and dropdowns
- [x] Apply font settings in terminal plugin via BlocBuilder
- [x] Enforce max shells limit with user feedback

**Commit**: dfdd32f - feat(settings): add terminal profile settings

### Progress Log

**2026-01-20 - Session Start:**
- Bootstrapped Loki Mode
- Explored codebase architecture comprehensively
- Identified all key components and their relationships
- Created task breakdown from PRD

**2026-01-20 - Milestone 1 Completed:**
- Created TerminalAppBar widget with session selector
- Created SessionMenu for new session creation
- Created SshHostSelector dialog for SSH host selection
- Updated TerminalTabBloc with SelectSession/CloseSession events
- Refactored terminal_screen.dart to use AppBar instead of flex-tabs
- All analysis passes, tests pass

**2026-01-20 - Milestones 2-3 Verified:**
- Android shell uses busybox with proper profile sourcing
- iOS shell uses ios_system with dash for sandboxed execution
- Both plugins properly initialize their environments

**2026-01-20 - Milestone 4 Completed:**
- Added SshKeyData class to hold decrypted SSH key content
- Updated SSHConnector to support key-based authentication
- Keys are loaded from database and decrypted before use
- SSHKeyPair.fromPem() parses the decrypted PEM content

**2026-01-20 - Milestone 5 Completed:**
- Added fontSize, fontFamily, maxOpenShells to TerminalSettingsLoaded
- Added events: UpdateMaxOpenShells, UpdateFontSize, UpdateFontFamily
- Updated settings UI with interactive controls
- Terminal plugin reads settings via BlocBuilder
- Max shells limit enforced before opening new sessions

### Mistakes & Learnings

1. **Type Check Warnings**: Initially used `child is TabItem` in a loop where `Tabs.children` already returns `List<TabItem>`. Fixed by removing unnecessary type check.

2. **SshHostLoading State**: Assumed SshHostBloc had a Loading state, but it only has Initial, Loaded, and Error states. Fixed by only checking for SshHostInitial.

3. **TabItem.close() vs dispose()**: Used `close()` method that doesn't exist on TabItem. The correct method is `dispose()` which removes the tab and triggers cleanup.

4. **Constant Naming Conflicts**: Used `kDefaultFontSize` which conflicted with Flutter's constant. Renamed to `kTerminalDefaultFontSize`.

5. **BuildContext Across Async Gap**: Updated context_menu.dart to capture context references before async operations to fix analyzer warning.

### Dependencies
- xterm package for terminal emulation
- flex_tabs (still used internally for tab state, removed from UI)
- ios_system framework (iOS)
- busybox (Android)
- Drift database for settings storage
- terminal_settings_bloc for font/session settings

### Notes
- The codebase follows clean architecture with BLoC pattern
- Plugin system abstracts different host types effectively
- SSH implementation is pure Dart (no native dependencies)
- Android uses busybox symlinks for shell commands
- iOS uses ios_system which is sandboxed to Documents
- flex_tabs is still used internally for managing tab state (Tabs, TabItem, TabsDocument) but the UI no longer uses TabsView
- SSH key authentication decrypts stored keys using AesHelper
- Font settings are applied at runtime via BlocBuilder

### SDLC Phase (Quality Assurance)

#### Code Analysis ✓ COMPLETED
- Fixed `unnecessary_underscores` warnings in flutter_form_bloc
- All packages pass `melos run analyze`

#### Unit Tests ✓ COMPLETED
- Added terminal widget tests (27 tests in test/screens/terminal/widgets/)
- Added SSH key authentication tests (14 tests in app_lib/terminal_hosts/test/)
- Added terminal settings tests (22 tests in app_bloc/terminal_settings/test/)
- Total: 63 new tests added

#### Security Review ✓ COMPLETED
- Reviewed SSH key handling in SshKeyBloc, SshKeyEncryption, AesHelper
- Documented findings in `.loki/logs/security-review-ssh-keys.md`
- Status: PASS with recommendations (static IV is medium priority)

#### Performance Review ✓ COMPLETED
- Reviewed terminal rendering in xterm widget
- Documented findings in `.loki/logs/performance-review-terminal-rendering.md`
- Found: repaint boundary, paragraph caching, visible line culling, VM inlining
- Status: PASS

#### Documentation ✓ COMPLETED
- Created comprehensive terminal feature documentation: `docs/TERMINAL.md`
- Updated documentation index: `docs/INDEX.md`
- Covers: shell sessions, SSH, settings, architecture, limitations
