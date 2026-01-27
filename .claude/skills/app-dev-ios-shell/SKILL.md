---
name: iOS Shell Development
description: Guide for developing and debugging the iOS shell plugin using ios_system framework. Use when working on app_plugin/ios_shell, fixing iOS terminal issues, adding iOS shell commands, or troubleshooting ios_system integration (exit code 127, no output, framework loading).
---

# iOS Shell Development

iOS uses `ios_system` framework (from a-shell project) for command execution. No PTY support—commands execute line-by-line with simulated shell session.

## Project Structure

```
app_plugin/ios_shell/ios/
├── Classes/
│   ├── IosShellPlugin.swift        # Plugin implementation
│   └── commandDictionary.plist     # Command definitions
├── Frameworks/                      # XCFrameworks: ios_system, shell, files, text, tar, awk
└── ios_shell.podspec
```

## Critical: Command Dictionary Location

The `commandDictionary.plist` **must** be at `Runner.app/` root (not in framework bundles).

The `ios/Podfile` post_install hook copies it:
```ruby
phase.shell_script = 'cp "${PODS_ROOT}/../.symlinks/plugins/ios_shell/ios/Classes/commandDictionary.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/"'
```

## Command Dictionary Format

```xml
<key>ls</key>
<array>
    <string>files.framework/files</string>  <!-- library path -->
    <string>ls_main</string>                 <!-- entry point -->
    <string>1RadfgsCFlors@:t:T:...</string>  <!-- getopt options -->
    <string>file</string>                    <!-- completion: file/directory/no -->
</array>
```

## Initialization Sequence

```swift
sideLoading = true                    // Read plist from main bundle
initializeEnvironment()               // Load command dictionary
ios_setMiniRoot(documentsPath)        // Set sandbox root
```

## Output Capture

`ios_system` runs commands in separate threads—`ios_setStreams()` won't work.

**Solution**: Use file redirection:
```swift
let redirectedCommand = "\(command) > \"\(stdoutPath)\" 2> \"\(stderrPath)\""
let exitCode = ios_system(redirectedCommand)
// Read temp files, then delete
```

## Framework Loading

Load frameworks globally before use:
```swift
let handle = dlopen(bundle.executablePath!, RTLD_NOW | RTLD_GLOBAL)
```

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Exit code 127 | Plist not in Runner.app/ | Check Podfile post_install hook |
| No output | Thread-local streams | Use file redirection |
| ios_executable returns 0 | sideLoading not set | Set `sideLoading = true` before `initializeEnvironment()` |

## Available Commands

- **files**: ls, cat, cp, mv, rm, mkdir, touch, chmod, ln, df, du, gzip, stat
- **shell**: pwd, echo, env, date, uname, id, find, xargs, sleep, tee
- **text**: head, tail, grep, wc, sort, uniq, tr, diff, sed
- **tar/awk**: tar, awk
- **Built-in**: cd, alias, export, setenv

## Dart API

```dart
final env = await IosShellPlugin.initialize();
final result = await env.execute('ls -la');
await IosShellPlugin.setCurrentDirectory('/path');
```
