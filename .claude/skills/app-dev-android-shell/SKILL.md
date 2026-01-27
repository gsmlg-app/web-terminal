---
name: Android Shell Development
description: Guide for developing and debugging the Android shell plugin using busybox and flutter_pty. Use when working on app_plugin/android_shell, fixing Android terminal issues, dealing with noexec restrictions, adding busybox support, or troubleshooting PTY/shell initialization.
---

# Android Shell Development

Android uses busybox for Unix commands and flutter_pty for true PTY support. Supports interactive shell sessions with fork/exec.

## Project Structure

```
app_plugin/android_shell/android/src/main/
├── kotlin/app/gsmlg/android_shell/
│   └── AndroidShellPlugin.kt           # Native plugin
└── assets/shell/
    ├── arm64-v8a/busybox                # Static binary (add other archs as needed)
    └── profile                          # Shell profile
```

## Critical: noexec Workaround

Android 10+ mounts `/data` with `noexec`. Direct execution of extracted binaries fails.

**Solution**: Create wrapper scripts using `/system/bin/sh`:
```kotlin
appletFile.writeText("#!/system/bin/sh\nexec $busyboxPath $applet \"\$@\"\n")
appletFile.setExecutable(true, false)
```

## Directory Structure (Runtime)

```
/data/data/<package>/files/
├── usr/
│   ├── bin/              # Wrapper scripts for busybox applets
│   ├── etc/profile       # Shell profile
│   └── .shell_version    # Version marker for re-init
├── home/                 # User home
└── tmp/                  # Temp files
```

## Initialization Flow

1. Detect architecture via `Build.SUPPORTED_ABIS`
2. Extract busybox to `usr/bin/`
3. Run `busybox --list` to get applets
4. Create wrapper script for each applet
5. Extract profile to `usr/etc/`
6. Write version marker

## Shell Startup

PTY `workingDirectory` is unreliable on Android. Use shell command to cd:
```dart
(shellPath, ['-c', 'cd "\$HOME"; . "\$ENV"; exec sh -i'])
```

Set `ENV` variable for busybox to find profile:
```dart
'ENV': profilePath,  // usr/etc/profile
```

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Permission denied | noexec on /data | Use wrapper scripts |
| Wrong directory | PTY workingDirectory | Use shell -c with cd |
| Profile not loaded | Missing ENV | Set `ENV` env variable |
| Arch mismatch | Wrong binary | Check `Build.SUPPORTED_ABIS` |

## Version Management

Bump `VERSION` in AndroidShellPlugin.kt when:
- Busybox binary updated
- Directory structure changes
- Profile format changes

```kotlin
private const val VERSION = "1.0.1"
```

## Adding Architectures

1. Get static busybox for arch from busybox.net/downloads/binaries/
2. Place at `assets/shell/<arch>/busybox`
3. Architecture detection is automatic via `Build.SUPPORTED_ABIS`

## Dart API

```dart
await AndroidShellEnv.instance.initialize();
final env = AndroidShellEnv.instance.getEnvironment();
final (cmd, args) = AndroidShellEnv.instance.getShellCommand();

// Use with flutter_pty
final pty = Pty.start(cmd, arguments: args, environment: env);
```
