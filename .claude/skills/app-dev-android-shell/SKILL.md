---
name: Android Shell Development
description: Guide for developing and debugging the Android shell plugin using PRoot, Alpine Linux minirootfs, and flutter_pty. Use when working on app_plugin/android_shell, fixing Android terminal issues, dealing with noexec restrictions, managing rootfs, or troubleshooting PTY/shell initialization.
---

# Android Shell Development

Android uses PRoot and Alpine Linux minirootfs for a full Termux-like Linux userland without root, and flutter_pty for true PTY support. Supports interactive shell sessions, package management via `apk`, and Linux command execution.

## Project Structure

```
app_plugin/android_shell/android/src/main/
├── jniLibs/
│   ├── arm64-v8a/
│   │   ├── libproot.so                 # PRoot executable
│   │   ├── libloader.so                # 64-bit PRoot loader
│   │   ├── libloader32.so              # 32-bit PRoot loader
│   │   ├── libtalloc.so                # Talloc memory library
│   │   └── libandroid-shmem.so         # PRoot shared-memory dependency
│   └── x86_64/
│       └── ...                         # Same for x86_64, armeabi-v7a, x86
├── assets/shell/
│   ├── <arch>/rootfs.tar.gz            # Alpine Linux minirootfs (~3.8MB)
│   └── profile                         # Custom profile
└── kotlin/app/gsmlg/android_shell/
    ├── AndroidShellPlugin.kt           # Native plugin & setup coordinator
    └── TarExtractor.kt                 # Pure Kotlin tar.gz extractor
```

## Critical: noexec Workaround on Android 10+ (API 29+)

Android 10+ mounts `/data` with `noexec`. Executing binaries directly from app private directories fails with Permission Denied.

**Solution**:
1. Package `proot`, `loader`, `libtalloc`, and `libandroid-shmem` into `src/main/jniLibs/<arch>/lib*.so`.
2. Set the app's `packaging.jniLibs.useLegacyPackaging = true` so Android PackageManager extracts these to `applicationInfo.nativeLibraryDir` with executable permissions. Pass that directory as `LD_LIBRARY_PATH` so PRoot resolves its bundled dependencies, and set `PROOT_LOADER`/`PROOT_LOADER_32` to the packaged loaders.
3. PRoot virtualizes rootfs access (`-r $filesDir/rootfs`), handles system calls, and executes the guest binaries inside the Alpine Linux rootfs.

## Directory Structure (Runtime)

```
/data/data/<package>/files/
├── rootfs/                             # Complete Alpine Linux rootfs
│   ├── bin/                            # System binaries (sh, apk, etc.)
│   ├── etc/
│   │   ├── resolv.conf                 # DNS nameservers
│   │   ├── hosts                       # Localhost mappings
│   │   └── profile                     # Shell environment profile
│   ├── root/                           # Root home directory
│   │   └── .profile                    # User profile
│   └── .rootfs_version                 # Version marker for re-init
└── tmp/                                # Temp directory and dev/shm
```

## Initialization Flow

1. Detect architecture via `Build.SUPPORTED_ABIS` (`arm64-v8a`, `x86_64`, etc.).
2. Check if `.rootfs_version` matches `VERSION` and `libproot.so` exists in `nativeLibraryDir`.
3. If not initialized:
   - Extract `shell/<arch>/rootfs.tar.gz` from assets using `TarExtractor`.
   - Setup `/etc/resolv.conf` (DNS) and `/etc/hosts`.
   - Setup `/root/.profile` with colorful prompt and aliases.
   - Install custom profile into `/etc/profile.d/web_terminal.sh`.
   - Write version marker `.rootfs_version`.

## Shell Startup

PRoot starts with fake root (`-0`), essential kernel filesystems mounted (`/dev`, `/proc`, `/sys`), and current directory in `/root`:
```dart
proot [
  '-r', rootfsPath,
  '-0',
  '--link2symlink',
  '--sysvipc',
  '--kill-on-exit',
  '-b', '/dev',
  '-b', '/proc',
  '-b', '/sys',
  '-b', '/dev/urandom:/dev/random',
  '-b', '/proc/self/fd:/dev/fd',
  '-b', '/proc/self/fd/0:/dev/stdin',
  '-b', '/proc/self/fd/1:/dev/stdout',
  '-b', '/proc/self/fd/2:/dev/stderr',
  '-b', '$tmpPath:/tmp',
  '-b', '$tmpPath:/dev/shm',
  '-w', '/root',
  '/bin/sh',
  '-l',
]
```

## Dart API

```dart
await AndroidShellEnv.instance.initialize();
final env = AndroidShellEnv.instance.getEnvironment();
final (cmd, args) = AndroidShellEnv.instance.getShellCommand();

// Use with flutter_pty
final pty = Pty.start(cmd, arguments: args, environment: env);
```

## Package Management

Inside the terminal shell, users can install packages just like in Termux or Alpine Linux:
```bash
apk update
apk add bash curl git python3 neovim nodejs
exec bash
```

## Updating Artifacts

Run the Python helper script to refresh PRoot and Alpine rootfs:
```bash
python3 app_plugin/android_shell/scripts/setup_alpine_proot.py
```

The script checks every download against `scripts/android_artifacts.lock.json`.
Refresh those version and SHA-256 pins from the Termux package indexes and Alpine
release checksums when upgrading the bundled artifacts.
