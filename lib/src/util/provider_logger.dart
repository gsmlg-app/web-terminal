import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_terminal/src/util/logging.dart';

class ProviderLogger implements ProviderObserver {
  const ProviderLogger();

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    log.info('Provider+: ${provider.describe}');
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    log.info('Provider-: ${provider.describe}');
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    log.info('Provider*: ${provider.describe}');
  }

  @override
  void providerDidFail(
    ProviderBase provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    log.info('Provider!: ${provider.describe}');
  }
}

extension _ProviderName on ProviderBase {
  String get describe => name ?? toString();
}
