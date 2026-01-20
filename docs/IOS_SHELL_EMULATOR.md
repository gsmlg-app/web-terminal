# iOS Shell Emulator Documentation

This document describes the iOS shell emulator implementation, its architecture, limitations, and development roadmap.

## Overview

The iOS shell emulator provides a terminal experience on iOS devices using the `ios_system` framework. Unlike traditional Unix shells, iOS does not support PTY (pseudo-terminal) or process forking, requiring a fundamentally different approach.

## Architecture

### Components

| Component | Location | Purpose |
|-----------|----------|---------|
| IosShellPlugin | `app_plugin/ios_shell/lib/` | Flutter/Dart interface to native shell |
| IosShellPlugin.swift | `app_plugin/ios_shell/ios/` | Native Swift implementation |
| IosShellEnv | `app_plugin/ios_shell/lib/src/` | Singleton managing shell environment |
| IosHost | `app_lib/terminal_hosts/lib/src/` | Host abstraction for iOS |
| IosExecutionSession | `app_lib/terminal_hosts/lib/src/` | Interactive shell session |

### Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter App                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    TerminalScreen                        │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │              xterm terminal view                 │    │   │
│  │  │  (renders IosExecutionSession output)            │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                              ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  IosExecutionSession                     │   │
│  │  • Processes keyboard input character-by-character       │   │
│  │  • Simulates shell prompt and line editing               │   │
│  │  • Handles built-in commands (cd, exit, export)          │   │
│  │  • Delegates to ios_system for other commands            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                              ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    IosShellPlugin                        │   │
│  │  • Flutter MethodChannel interface                       │   │
│  │  • Methods: initialize, execute, listCommands            │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                   Method Channel
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Native iOS                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │               IosShellPlugin.swift                       │   │
│  │  • Initializes ios_system environment                    │   │
│  │  • Sets up sandbox (miniRoot = Documents)                │   │
│  │  • Executes commands via ios_system()                    │   │
│  │  • Captures stdout/stderr via pipe redirection           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│                              ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    ios_system                            │   │
│  │  (from a-shell project)                                  │   │
│  │  • Provides Unix-like commands in sandboxed environment  │   │
│  │  • No fork/exec, runs commands in-process                │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## How It Works

### Initialization

1. `IosShellPlugin.initialize()` is called at app startup
2. Native code sets up the ios_system environment:
   - Sets `miniRoot` to Documents directory (sandboxing)
   - Creates `bin` directory for user scripts
   - Configures environment variables (HOME, PATH, TERM, etc.)
3. Dart singleton `IosShellEnv` stores paths and state

### Shell Session Flow

1. User opens a local shell session on iOS
2. `IosConnector` creates an `IosHost` with optional profile settings
3. `IosHost.shell()` creates an `IosExecutionSession`
4. Session displays prompt and processes input:

```
User types: ls -la
┌─────────────────────────┐
│  IosExecutionSession    │
│  _inputBuffer = "ls -la"│
│  (user presses Enter)   │
│         │               │
│         ▼               │
│  _executeCommand()      │
│         │               │
│         ▼               │
│  IosShellEnv.execute()  │
│         │               │
│         ▼               │
│  IosShellPlugin.execute │
│  (MethodChannel)        │
│         │               │
│         ▼               │
│  ios_system("ls -la")   │
│         │               │
│         ▼               │
│  (output captured)      │
│         │               │
│         ▼               │
│  output → terminal view │
└─────────────────────────┘
```

### Output Capture

Since ios_system runs commands in-process, output is captured via file descriptor redirection:

```swift
// In IosShellPlugin.swift
let stdoutPipe = Pipe()
let stderrPipe = Pipe()

// Redirect stdout/stderr
dup2(stdoutPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
dup2(stderrPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)

// Execute command
let exitCode = ios_system(command)

// Restore and read output
// ...
```

## Available Commands

The ios_system framework provides many common Unix commands. Query available commands with:

```dart
final commands = await IosShellPlugin.listCommands();
```

Typical commands include:
- File operations: `ls`, `cp`, `mv`, `rm`, `mkdir`, `cat`, `head`, `tail`
- Text processing: `grep`, `sed`, `awk`, `sort`, `uniq`
- Compression: `tar`, `gzip`, `gunzip`
- Development: `python`, `lua`, `bc`
- Networking: `curl` (limited)
- And more...

## Built-in Commands

`IosExecutionSession` handles these commands directly:

| Command | Behavior |
|---------|----------|
| `cd <path>` | Changes current directory |
| `cd` | Changes to home directory |
| `exit` | Closes the shell session |
| `logout` | Same as exit |
| `export VAR=value` | Sets environment variable for session |

## Limitations

### No PTY Support

iOS does not support pseudo-terminals. Consequences:

1. **No job control**: Cannot suspend (Ctrl+Z) or background processes
2. **No interactive programs**: Programs expecting PTY (vi, less, top) will not work correctly
3. **No terminal resize**: Window size changes don't affect running programs
4. **Simple line editing**: Only basic backspace, no arrow keys or history

### Sandboxed Filesystem

- Home directory is the app's Documents folder
- Cannot access files outside the app sandbox
- No root access or system directories
- File permissions are limited by iOS

### Single-threaded Execution

- Commands run synchronously in the main process
- Long-running commands block the session
- Cannot run multiple commands in parallel within one session

### No Shell Features

- No shell scripting (no if/then/else, loops)
- No pipes between commands (limited)
- No background processes (&)
- No aliases (ignored silently)
- No command history navigation

### Networking Restrictions

- Outbound connections subject to App Transport Security
- No listening sockets (no servers)
- curl works for basic HTTPS requests

## Shell Profiles

Shell profiles can customize the iOS shell session:

1. **Environment Variables**: Applied to all commands in session
2. **Aliases**: Silently ignored (ios_system doesn't support them)
3. **Init Commands**: Run when session starts

Profile settings are stored in the database and applied via `IosHostSpec`:

```dart
final spec = IosHostSpec(
  name: 'My Profile',
  environment: {'MY_VAR': 'value'},
  initCommands: 'export PATH=$PATH:~/scripts',
);
```

## Development Roadmap

### Phase 1: Current Implementation ✓
- [x] Basic command execution via ios_system
- [x] Shell prompt and line input
- [x] cd command for directory navigation
- [x] Environment variable support (export)
- [x] Shell profile integration
- [x] Documentation

### Phase 2: Enhanced Input (Future)
- [ ] Arrow key support for line editing
- [ ] Command history with up/down arrows
- [ ] Tab completion for files and commands
- [ ] Ctrl+A/E for line navigation

### Phase 3: Output Improvements (Future)
- [ ] ANSI color support improvements
- [ ] Better terminal size handling
- [ ] Scrollback buffer management
- [ ] Copy/paste integration

### Phase 4: Advanced Features (Future)
- [ ] Simple pipe support (cmd1 | cmd2)
- [ ] Output redirection (> and >>)
- [ ] Basic wildcards (*.txt)
- [ ] Environment variable expansion ($HOME)

### Phase 5: Integration (Future)
- [ ] File manager integration
- [ ] Syntax highlighting for output
- [ ] Custom command scripts
- [ ] SSH tunnel support

## Comparison with a-shell

This implementation is inspired by [a-shell](https://github.com/holzschu/a-shell), but differs:

| Feature | a-shell | web-terminal |
|---------|---------|--------------|
| Base framework | ios_system | ios_system |
| Shell | Customized shell | Simulated via Dart |
| PTY emulation | Partial | None |
| Full vim | Yes (custom build) | No |
| Python | Full support | Via ios_system |
| Lua | Yes | Via ios_system |
| Package manager | Yes (luarocks, pip) | No |
| File browser | Integrated | Separate (planned) |

## Testing

### Unit Tests

Test files are in `app_lib/terminal_hosts/test/`:
- `ios_spec_test.dart` - Tests for IosHostSpec
- `ios_conn_test.dart` - Tests for IosConnector

Run with:
```bash
cd app_lib/terminal_hosts && flutter test
```

### Manual Testing

1. Build and run on iOS simulator or device
2. Open local shell session
3. Test commands: `ls`, `pwd`, `echo`, `cd`
4. Verify prompt displays correctly
5. Test Ctrl+C interrupt
6. Test Ctrl+D exit

## Troubleshooting

### "Shell not initialized" Error

The shell environment wasn't initialized before use:
```dart
await IosShellEnv.instance.initialize();
```

### Commands Not Found

Check if command is available:
```dart
final available = await IosShellPlugin.isCommandAvailable('mycommand');
```

### Permission Denied

iOS sandbox restrictions. Can only access files in:
- Documents directory (app's sandbox)
- Temporary directory
- Cannot access other app's files or system directories

### Slow Command Execution

ios_system runs commands synchronously. Long operations block the UI.
Consider running in background or breaking into smaller operations.

## References

- [ios_system framework](https://github.com/holzschu/ios_system)
- [a-shell project](https://github.com/holzschu/a-shell)
- [Apple App Sandbox](https://developer.apple.com/documentation/security/app_sandbox)
- [Terminal Hosts Documentation](./TERMINAL.md)
