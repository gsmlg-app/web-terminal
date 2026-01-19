import 'dart:io';

import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/android_spec.dart';
import 'package:terminal_hosts/src/local_spec.dart';

/// Creates the default host specification for the current platform.
///
/// Returns [AndroidHostSpec] on Android devices (which uses a sandboxed
/// shell environment with bundled busybox), and [LocalHostSpec] on all
/// other platforms.
HostSpec createDefaultHostSpec() {
  if (Platform.isAndroid) {
    return AndroidHostSpec();
  }
  return LocalHostSpec();
}
