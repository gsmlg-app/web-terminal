import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terminal_tabs/src/shortcut/intents.dart';

// TODO: Import WindowService from terminal_core package when available
// import 'package:terminal_core/terminal_core.dart';

/// Provider for the window service.
///
/// TODO: This should be imported from the app's service layer.
/// For now, define a placeholder provider here.
final windowServiceProvider = Provider<WindowService>((ref) {
  throw UnimplementedError(
    'windowServiceProvider must be overridden by the host application',
  );
});

/// Abstract class representing a window service.
///
/// TODO: This should be imported from terminal_core package.
abstract class WindowService {
  Future<void> createWindow();
}

class GlobalActions extends ConsumerWidget {
  const GlobalActions({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Actions(
      actions: {
        NewWindowIntent: CallbackAction<NewWindowIntent>(
          onInvoke: (NewWindowIntent intent) async {
            await ref.read(windowServiceProvider).createWindow();
            return null;
          },
        ),
      },
      child: child,
    );
  }
}
