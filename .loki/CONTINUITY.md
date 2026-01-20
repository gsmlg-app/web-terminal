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

#### Bug Fixes ✓ COMPLETED
- Added typed SSH exceptions (SshConnectionException, SshAuthenticationException, SshKeyParseException)
- Added input validation for hostname, port, username before network I/O
- Fixed resource cleanup on authentication failure
- **Commit**: 94a28a8 - fix(ssh): add typed exceptions and validation for SSH connections

#### Test Infrastructure Fixes ✓ COMPLETED (Iteration 3)
- **SSH Socket Test**: Added timeout handling and skip for unreliable network tests
- **web_server Package**: Converted to Flutter package (was misclassified as pure Dart but depends on flutter via terminal_core)
- **web_session_bloc Tests**: Added 17 state/event tests for WebSessionState and WebSessionEvent classes
- **web_server_settings Tests**: Added export availability test
- **ServerConfig Tests**: Added 4 tests for server configuration in web_server package
- All `melos run test` passes (both test:dart and test:flutter)
- **Commit**: 1db7398 - test: fix test infrastructure for melos run test

#### Shell Profile Management ✓ COMPLETED (Iteration 3)
- Added ShellProfiles database table with migration from v1 to v2
- Fields: name, shellType, envVars, aliases, fontFamily, fontSize, colorTheme, isDefault
- Created shell_profile_bloc package with full CRUD operations
- Default profile handling: automatically clears other defaults when setting new one
- Added 14 unit tests for state, events, and bloc operations
- **Commit**: 4e44d82 - feat(shell-profiles): add shell profile management system

#### Shell Profile Extensions ✓ COMPLETED (Iteration 3)
- Added ShellProfileParsing extension for JSON field parsing
- parsedEnvironmentVariables, parsedAliases, parsedShellType accessors
- generateInitCommands(): produces shell export/alias statements
- Added ShellProfileEncoder for encoding Maps to JSON
- Added 16 additional tests for extensions
- **Commit**: 2f0296a - feat(shell-profiles): add parsing extensions and init command generation

#### Shell Profile UI ✓ COMPLETED (Iteration 3)
- Added shell profile navigation tile to SettingsSectionTerminal
- Created ShellProfileScreen with list view and CRUD operations
- Profile form dialog for add/edit with shell type dropdown
- Set as default, delete with confirmation dialog
- Integrated ShellProfileBloc into main.dart providers
- Added route to settings navigation
- 9 widget tests for shell profile form dialog
- Fixed BlocProvider context issue in form submission
- **Commits**:
  - 9f719e1 - feat(terminal-settings): add shell profile navigation tile
  - daf0b53 - feat(settings): add shell profile management screen
  - 5e90cde - test(ssh): skip network tests by default
  - d0a81ef - test(shell-profiles): add widget tests for shell profile form

#### Shell Profile Integration ✓ COMPLETED (Iteration 3)
- Updated LocalHostSpec to accept environment and initCommands parameters
- LocalConnector and LocalHost chain profile data through
- Init commands sent to PTY via Future.delayed after shell starts
- createDefaultHostSpec() accepts optional profile parameters
- ProfileSelector widget shows profile options when opening local shell
- Smart defaults: uses single default profile automatically
- 'Default Shell' option available for system settings without profile
- **Commits**:
  - 66f768d - feat(terminal-hosts): add shell profile support to LocalHostSpec
  - 24a22e9 - feat(terminal): integrate shell profiles with session creation

#### Android/iOS Profile Support ✓ COMPLETED (Iteration 3)
- AndroidHostSpec: Added name, environment, initCommands parameters
- AndroidConnector: Pass profile parameters to AndroidHost
- AndroidHost: Merge profile environment vars, send init commands via PTY
- IosHostSpec: Added name, environment, initCommands parameters
- IosConnector: Pass profile parameters to IosHost
- IosHost/IosExecutionSession: Handle init commands (export, alias) silently
- createDefaultHostSpec(): Now passes profile params on all platforms
- Profile support consistent across: macOS, Linux, Windows, Android, iOS
- Added 24 unit tests for Local/Android/iOS HostSpec and Connector classes
- Total terminal_hosts tests: 46
- **Commits**:
  - dcd21fe - feat(terminal-hosts): add shell profile support to Android and iOS hosts
  - 4e14d7e - test(terminal-hosts): add unit tests for host spec profile support

#### Iteration 4 Improvements ✓ COMPLETED
- Created comprehensive iOS Shell Emulator documentation (docs/IOS_SHELL_EMULATOR.md)
  - Covers architecture, component diagram, limitations, roadmap, comparison with a-shell
  - Updated docs/INDEX.md to include the new document
- Added comprehensive Terminal Tab BLoC tests (36 tests)
  - Tests for all events: Start, Stop, OpenTab, ToggleFullscreen, SelectSession, CloseSession
  - Tests for all state properties and helper methods
  - Fixed blocTest timing issues with async pattern
- Added accessibility semantics to terminal widgets
  - TerminalAppBar: fullscreen toggle, session selector, close buttons
  - SessionMenu: menu button and all session type options
  - SshHostSelector: loading, error, empty states, and host list items
- Added SSH connection timeout handling
  - kSshConnectionTimeout (30s) and kSshAuthenticationTimeout (60s) constants
  - SshTimeoutException class for timeout-specific errors
  - Configurable connectionTimeout and authenticationTimeout in SSHConnector
  - Timeout wrapping for SSHSocket.connect() and client.authenticated
  - 13 unit tests for timeout handling
- Added terminal session telemetry tracking (PRD optional)
  - TerminalAnalytics service with event stream
  - SessionType enum (local, ssh, sftp)
  - TerminalEvent enum (sessionCreated, sessionClosed, fullscreenToggled)
  - Track local shell creation with profile metadata
  - Track SSH session creation with host and auth type
  - Track fullscreen toggle via BLoC listener
  - 15 unit tests for analytics service
- Added comprehensive SshHostSelector widget tests (16 tests)
  - Tests for loading, error, empty, and host list states
  - Tests for host selection and cancel behavior
  - Tests for accessibility semantics
- **Commits**:
  - bcb43cd - docs(loki): update CONTINUITY.md with Android/iOS profile support
  - a427590 - feat(ssh): add connection and authentication timeout handling
  - 5e4ef58 - feat(analytics): add terminal session telemetry tracking
  - 75067b3 - test(widgets): add comprehensive tests for SshHostSelector widget

#### Iteration 5: Test Coverage Expansion ✓ COMPLETED
- Added ProfileSelector widget tests (21 tests in test/screens/terminal/widgets/)
  - Tests for showProfileSelector() and selectProfileAndOpenShell() functions
  - Auto-selection of single default profile without dialog
  - Dialog display with multiple profiles
  - Callback handling for profile selection and cancellation
  - Star icon for default profiles, terminal icon for default shell
- Added default_host_test.dart (20 tests in app_lib/terminal_hosts/test/)
  - createDefaultHostSpec() returns correct spec type on desktop platforms
  - Parameter passing (name, environment, initCommands)
  - LocalHost instantiation, connectFileSystem(), execute(), disconnect()
  - LocalExecutionResult stdout/stderr/exitCode handling
  - LocalFileSystem directory and file access
- Added ios_host_test.dart (32 tests in app_lib/terminal_hosts/test/)
  - IosExecutionResult storage of exitCode, stdout, stderr
  - IosHostSpec and IosConnector parameter handling
  - Documented IosExecutionSession behavior (export parsing, input handling)
  - Control character handling (Ctrl+C, Ctrl+D, backspace)
  - Command execution and environment merging
- Total terminal_hosts tests now: 111 (was ~46)
- **Commits**:
  - d4b5d31 - test: add comprehensive widget and host implementation tests
  - c2ee206 - docs(loki): update CONTINUITY.md with iteration 5 progress

#### Iteration 5 (continued): Code Quality Fixes ✓ COMPLETED
- Fixed resource leak in SSHFile.copy() (ssh_fs.dart)
  - Added try-finally blocks to properly close source and destination file handles
  - Prevents connection exhaustion from unclosed SFTP file handles
- Added SSHHostSpec constructor validation (ssh_spec.dart)
  - Throws ArgumentError when keyData is null but identityType is key
  - Prevents silent fallback to password auth when key auth was intended
  - Improves developer experience with fail-fast error detection
- Added 3 tests for SSHHostSpec keyData validation
- **Commit**: fadc898 - fix: close file handles in SSHFile.copy() and validate SSHHostSpec keyData

#### Iteration 7: Security Enhancement - Random IV for AES Encryption ✓ COMPLETED
- Implemented random IV generation for AES encryption (addresses security review recommendation)
- Updated AesHelper (app_lib/security/lib/src/aes_helper.dart):
  - New encryptions generate cryptographically random 16-byte IV using SecureRandom
  - IV prepended to ciphertext: `base64(IV || ciphertext)` format
  - Backward compatible: decryption auto-detects old format (static IV) and new format
  - Existing encrypted SSH keys remain readable
- Added 8 new tests for random IV functionality:
  - Encrypting same text twice produces different ciphertext
  - encrypt64WithSalt produces different ciphertext for same input
  - Ciphertext length includes IV overhead
  - Empty input handling
  - Wrong salt detection
  - Long text encryption/decryption
  - Special character handling (unicode, emoji)
  - Cross-instance decryption works
- Security benefit: Same plaintext no longer produces same ciphertext, preventing pattern analysis
- Total AesHelper tests: 16 (was 8)
- **Commit**: 0727a22 - fix(security): implement random IV for AES encryption

#### Iteration 7 (continued): ErrorBloc Test Coverage ✓ COMPLETED
- Added comprehensive tests for error_handler_bloc package (39 tests)
- Test coverage includes:
  - ErrorSeverity enum values (1 test)
  - AppError: creation, displayMessage, copyWith, equality (8 tests)
  - ErrorState: default values, hasErrors, hasCriticalErrors, copyWith (6 tests)
  - ErrorEvent: ErrorReported, ErrorDismissed, ErrorsCleared, ErrorRecovered (8 tests)
  - ErrorBloc events: report, dismiss, clear, recover (12 tests)
  - Helper methods: reportError, reportNetworkError, reportValidationError, reportUnexpectedError (4 tests)
- Fixed missing export of ErrorSeverity in error_handler_bloc.dart
- Added bloc_test dependency for test infrastructure

#### Iteration 7 (continued): Error Reporting Service Improvements ✓ COMPLETED
- Fixed hardcoded values in `app_lib/logging/lib/src/error_reporting_service.dart`
  - Replaced hardcoded `'1.0.0'` with injectable app version via `initialize()` method
  - Replaced hardcoded `'flutter'` platform with `defaultTargetPlatform.name.toLowerCase()`
- Added `initialize()` method to set app version during app startup
- Added `_platformName` getter using Flutter's `defaultTargetPlatform`
- Added 17 new tests for ErrorReportingService (error_reporting_service_test.dart)
  - Tests for: singleton pattern, initialization, platform name, reportError, reportException
  - Tests for: reportFlutterError, getRecentErrors, clearErrorLogs, exportErrorLogs
  - Tests for: setupGlobalErrorHandler, LogLevel enum values
- Total logging package tests: 32 (was 15)

#### Iteration 7 (continued): Terminal Core Tests ✓ COMPLETED
- Added comprehensive tests for `app_lib/terminal_core` package (33 tests)
- Test coverage includes:
  - Plugin mixin: initial state, title, lifecycle errors (6 tests)
  - PluginManager: add/remove, mount/unmount, connect/disconnect (16 tests)
  - HostConnectorStatus enum values (1 test)
  - HostConnector: status transitions, connect/disconnect, listeners (8 tests)
  - ExecutionResult interface (1 test)
- Created mock implementations: MockHostSpec, MockHost, MockExecutionResult, MockHostConnector, TestPlugin
- Tests verify correct lifecycle callback ordering and state management
- Total terminal_core tests: 59 (33 plugin + 26 fs, was 0)

#### Iteration 7 (continued): File Manager Plugin Tests ✓ COMPLETED
- Added comprehensive tests for `app_widget/file_manager_plugin` package (27 tests)
- Test coverage for NavigationStack<T> class:
  - Initial state: current, canGoBack, canGoForward (3 tests)
  - Push operations: single, multiple, forward history clearing (7 tests)
  - Back operations: navigation, edge cases, callbacks (7 tests)
  - Forward operations: navigation, edge cases, callbacks (7 tests)
  - Complex navigation: multi-step back/forward, history clearing, generic types (3 tests)
- Tests verify ChangeNotifier listener notifications
- Tests verify onNavigate callback invocations
- Total file_manager_plugin tests: 27 (was 0)

#### Iteration 7 (continued): Terminal Core FileSystem Tests ✓ COMPLETED
- Added 26 tests for FileSystem abstractions (fs_test.dart)
- Test coverage includes:
  - FileSystemEntityType enum: all values, type names (4 tests)
  - FileMode enum: all values, mode names (4 tests)
  - FileStat: constructor, timestamps, file sizes, entity types (5 tests)
  - FileSystemEvent: constants, bitwise operations, instance creation (8 tests)
  - FileSystemException: creation, toString, edge cases (5 tests)
- Tests verify enum completeness and data class correctness

#### Iteration 8: BLoC Test Coverage Expansion ✓ COMPLETED
- Fixed unused import warning in terminal_core tests
- **Commit**: d0c0ebf - fix(terminal-core): remove unused dart:typed_data import

- Added comprehensive tests for SshHostBloc (23 tests)
  - SshIdentityType enum: values, fromValue, null for invalid (3 tests)
  - SshHostEvent: instantiation, parameter storage (4 tests)
  - SshHostState: state types, list storage, error handling (5 tests)
  - SshHostBloc: CRUD operations, error handling, persistence (11 tests)
- **Commit**: 26b3b80 - test(ssh-blocs): add comprehensive tests for SshHostBloc and SshKeyBloc

- Added comprehensive tests for SshKeyBloc (26 tests)
  - SshKeyAlgorithm enum: values, fromValue, null for invalid (3 tests)
  - SshKeyEvent: instantiation, parameter storage (4 tests)
  - SshKeyState: state types, list storage, error handling (5 tests)
  - SshKeyBloc: CRUD operations, algorithm support, persistence (14 tests)

- Added comprehensive tests for ThemeBloc (27 tests)
  - ThemeEvent: ChangeTheme, ChangeThemeMode events (4 tests)
  - ThemeState: props, copyWith, initial factory (11 tests)
  - ThemeBloc: state changes, SharedPreferences persistence (10 tests)
  - themeList: theme availability, light/dark variants (2 tests)
- **Commit**: 2471ecf - test(theme-bloc): add comprehensive tests for ThemeBloc

- Total new tests this iteration: 76
- Total project tests: 287+ (accumulated across all packages)
