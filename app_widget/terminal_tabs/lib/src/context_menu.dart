import 'package:context_menus/context_menus.dart';
import 'package:flex_tabs/flex_tabs.dart';
import 'package:flutter/material.dart';

class DropdownContextMenu extends StatefulWidget {
  const DropdownContextMenu(this.tabs, {super.key});

  final Tabs tabs;

  @override
  DropdownContextMenuState createState() => DropdownContextMenuState();
}

class DropdownContextMenuState extends State<DropdownContextMenu>
    with ContextMenuStateMixin {
  Tabs get tabs => widget.tabs;

  @override
  Widget build(BuildContext context) {
    return cardBuilder(context, [
      buttonBuilder(
        context,
        ContextMenuButtonConfig(
          'Local',
          icon: const Icon(Icons.tablet),
          iconHover: const Icon(Icons.tablet_outlined),
          onPressed: () => handlePressed(context, () {
            // TODO: Integrate with app's tabs service
            // final tabsService = context.read<TabsService>();
            // tabsService.openTerminal(LocalHostSpec());
          }),
        ),
      ),
    ]);
  }
}
