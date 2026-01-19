import 'dart:io';

import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/android_spec.dart';
import 'package:terminal_hosts/src/ios_spec.dart';
import 'package:terminal_hosts/src/local_spec.dart';

/// Creates the default host specification for the current platform.
///
/// Returns:
/// - [AndroidHostSpec] on Android (sandboxed shell with bundled busybox)
/// - [IosHostSpec] on iOS (ios_system framework from a-shell)
/// - [LocalHostSpec] on all other platforms (macOS, Linux, Windows)
HostSpec createDefaultHostSpec() {
  if (Platform.isAndroid) {
    return AndroidHostSpec();
  }
  if (Platform.isIOS) {
    return IosHostSpec();
  }
  return LocalHostSpec();
}
