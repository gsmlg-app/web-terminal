import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_terminal/src/core/service/tabs_service.dart';
import 'package:web_terminal/src/hosts/local_spec.dart';

class DropdownContextMenu extends ConsumerStatefulWidget {
  const DropdownContextMenu(this.tabs, {super.key});

  final Tabs tabs;

  @override
  DropdownContextMenuState createState() => DropdownContextMenuState();
}

class DropdownContextMenuState extends ConsumerState<DropdownContextMenu>
    with ContextMenuStateMixin {
  Tabs get tabs => widget.tabs;

  @override
  Widget build(BuildContext context) {
    return cardBuilder(
      context,
      [
        buttonBuilder(
          context,
          ContextMenuButtonConfig(
            'Local',
            icon: const Icon(Icons.tablet),
            iconHover: const Icon(Icons.tablet_outlined),
            onPressed: () => handlePressed(context, () {
              final tabsService = ref.read(tabsServiceProvider);
              tabsService.openTerminal(LocalHostSpec());
            }),
          ),
        ),
      ],
    );
  }
}
