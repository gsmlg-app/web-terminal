import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_terminal/src/core/conn.dart';
import 'package:web_terminal/src/core/host.dart';

final connectorProvider = Provider.family(
  name: 'connectorProvider',
  (ref, HostSpec config) => config.createConnector(),
);

final connectorStatusProvider =
    StateNotifierProvider.family<HostConnector, HostConnectorStatus, HostSpec>(
  name: 'connectorStatusProvider',
  (ref, HostSpec config) => ref.watch(connectorProvider(config)),
);

final hostProvider = Provider.family<Host?, HostSpec>(
  name: 'hostProvider',
  (ref, spec) {
    ref.watch(connectorStatusProvider(spec));
    return ref.watch(connectorProvider(spec)).host;
  },
);
