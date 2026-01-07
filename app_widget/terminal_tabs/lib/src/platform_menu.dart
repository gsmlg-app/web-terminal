import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:terminal_tabs/src/shortcuts.dart' as shortcuts;
import 'package:terminal_tabs/src/devtools_tab.dart';

// TODO: Import from terminal_core package when available
// import 'package:terminal_core/terminal_core.dart';

/// Provider for the active tab service.
///
/// TODO: This should be imported from the app's service layer.
final activeTabServiceProvider = Provider<ActiveTabService>((ref) {
  throw UnimplementedError(
    'activeTabServiceProvider must be overridden by the host application',
  );
});

/// Abstract class representing an active tab service.
///
/// TODO: This should be imported from terminal_core package.
abstract class ActiveTabService {
  dynamic getActiveTab();
}

/// Extension on WidgetRef to open a new tab.
///
/// TODO: This should be imported from the app's service layer.
extension TabsExtension on WidgetRef {
  void openTab(dynamic tab) {
    // TODO: Implement tab opening logic
    // This should be integrated with the app's tab management system
  }
}

class GlobalPlatformMenu extends ConsumerStatefulWidget {
  const GlobalPlatformMenu({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GlobalPlatformMenu> createState() => _GlobalPlatformMenuState();
}

class _GlobalPlatformMenuState extends ConsumerState<GlobalPlatformMenu> {
  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: <PlatformMenuItem>[
        PlatformMenu(
          label: 'Web Terminal',
          menus: [
            if (PlatformProvidedMenuItem.hasMenu(
              PlatformProvidedMenuItemType.about,
            ))
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.about,
              ),
            PlatformMenuItemGroup(
              members: [
                if (PlatformProvidedMenuItem.hasMenu(
                  PlatformProvidedMenuItemType.servicesSubmenu,
                ))
                  const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.servicesSubmenu,
                  ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                if (PlatformProvidedMenuItem.hasMenu(
                  PlatformProvidedMenuItemType.hide,
                ))
                  const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.hide,
                  ),
                if (PlatformProvidedMenuItem.hasMenu(
                  PlatformProvidedMenuItemType.hideOtherApplications,
                ))
                  const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.hideOtherApplications,
                  ),
              ],
            ),
            if (PlatformProvidedMenuItem.hasMenu(
              PlatformProvidedMenuItemType.quit,
            ))
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.quit,
              ),
          ],
        ),
        PlatformMenu(
          label: 'Edit',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Copy',
                  shortcut: shortcuts.terminalCopy,
                  onSelected: () {
                    final primaryContext = primaryFocus?.context;
                    if (primaryContext == null) {
                      return;
                    }
                    Actions.invoke(
                      primaryContext,
                      CopySelectionTextIntent.copy,
                    );
                  },
                ),
                PlatformMenuItem(
                  label: 'Paste',
                  shortcut: shortcuts.terminalPaste,
                  onSelected: () {
                    final primaryContext = primaryFocus?.context;
                    if (primaryContext == null) {
                      return;
                    }
                    Actions.invoke(
                      primaryContext,
                      const PasteTextIntent(SelectionChangedCause.keyboard),
                    );
                  },
                ),
                PlatformMenuItem(
                  label: 'Select All',
                  shortcut: shortcuts.terminalSelectAll,
                  onSelected: () {
                    final primaryContext = primaryFocus?.context;
                    if (primaryContext == null) {
                      return;
                    }
                    try {
                      Actions.maybeFind<Intent>(
                        primaryContext,
                        intent: const SelectAllTextIntent(
                          SelectionChangedCause.keyboard,
                        ),
                      );
                    } catch (e, st) {
                      debugPrint('$e');
                      debugPrint('$st');
                    }
                    Actions.invoke<Intent>(
                      primaryContext,
                      const SelectAllTextIntent(SelectionChangedCause.keyboard),
                    );
                  },
                ),
              ],
            ),
            if (PlatformProvidedMenuItem.hasMenu(
              PlatformProvidedMenuItemType.quit,
            ))
              const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.quit,
              ),
          ],
        ),
        PlatformMenu(
          label: 'View',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Close Tab',
                  shortcut: shortcuts.tabClose,
                  onSelected: () {
                    // TODO: Integrate with app's active tab service
                    // return ref
                    //     .read(activeTabServiceProvider)
                    //     .getActiveTab()
                    //     ?.detach();
                  },
                ),
                if (PlatformProvidedMenuItem.hasMenu(
                  PlatformProvidedMenuItemType.toggleFullScreen,
                ))
                  const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.toggleFullScreen,
                  ),
              ],
            ),
            PlatformMenuItem(
              label: 'DevTools',
              shortcut: shortcuts.openDevTools,
              onSelected: () => ref.openTab(DevToolsTab()),
            ),
          ],
        ),
      ],
      child: widget.child,
    );
  }
}
