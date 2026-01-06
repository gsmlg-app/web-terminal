import 'package:web_terminal/src/core/conn.dart';
import 'package:web_terminal/src/hosts/local_host.dart';

class LocalConnector extends HostConnector<LocalHost> {
  LocalConnector();

  @override
  Future<LocalHost> createHost() async {
    return LocalHost();
  }
}
