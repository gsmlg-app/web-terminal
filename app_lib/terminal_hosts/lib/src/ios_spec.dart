import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/src/ios_conn.dart';

/// Host specification for iOS devices using ios_system shell.
class IosHostSpec implements HostSpec {
  @override
  final name = 'iOS';

  @override
  HostConnector createConnector() => IosConnector();
}
