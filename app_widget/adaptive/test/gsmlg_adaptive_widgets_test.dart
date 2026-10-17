import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';

void main() {
  group('AppAdaptiveActionSize', () {
    test('has all expected values', () {
      expect(AppAdaptiveActionSize.values, hasLength(3));
      expect(
          AppAdaptiveActionSize.values, contains(AppAdaptiveActionSize.small));
      expect(
          AppAdaptiveActionSize.values, contains(AppAdaptiveActionSize.medium));
      expect(
          AppAdaptiveActionSize.values, contains(AppAdaptiveActionSize.large));
    });

    test('enum index values are correct', () {
      expect(AppAdaptiveActionSize.small.index, 0);
      expect(AppAdaptiveActionSize.medium.index, 1);
      expect(AppAdaptiveActionSize.large.index, 2);
    });
  });

  group('AppAdaptiveAction', () {
    test('creates action with required properties', () {
      var pressed = false;
      final action = AppAdaptiveAction(
        title: 'Test Action',
        icon: Icons.add,
        onPressed: () => pressed = true,
      );

      expect(action.title, 'Test Action');
      expect(action.icon, Icons.add);
      expect(action.disabled, false);

      action.onPressed();
      expect(pressed, true);
    });

    test('creates disabled action', () {
      final action = AppAdaptiveAction(
        title: 'Disabled Action',
        icon: Icons.remove,
        onPressed: () {},
        disabled: true,
      );

      expect(action.disabled, true);
    });

    test('creates action with different icons', () {
      final actions = [
        AppAdaptiveAction(title: 'Add', icon: Icons.add, onPressed: () {}),
        AppAdaptiveAction(title: 'Edit', icon: Icons.edit, onPressed: () {}),
        AppAdaptiveAction(
            title: 'Delete', icon: Icons.delete, onPressed: () {}),
      ];

      expect(actions[0].icon, Icons.add);
      expect(actions[1].icon, Icons.edit);
      expect(actions[2].icon, Icons.delete);
    });
  });

  group('AppAdaptiveActionList', () {
    late List<AppAdaptiveAction> testActions;
    late int pressedIndex;

    setUp(() {
      pressedIndex = -1;
      testActions = [
        AppAdaptiveAction(
          title: 'Action 1',
          icon: Icons.home,
          onPressed: () => pressedIndex = 0,
        ),
        AppAdaptiveAction(
          title: 'Action 2',
          icon: Icons.settings,
          onPressed: () => pressedIndex = 1,
        ),
        AppAdaptiveAction(
          title: 'Action 3',
          icon: Icons.info,
          onPressed: () => pressedIndex = 2,
        ),
      ];
    });

    group('small size (PopupMenuButton)', () {
      testWidgets('renders PopupMenuButton', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.small,
                actions: testActions,
              ),
            ),
          ),
        );

        expect(find.byType(PopupMenuButton<int>), findsOneWidget);
      });

      testWidgets('shows menu items when tapped', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.small,
                actions: testActions,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PopupMenuButton<int>));
        await tester.pumpAndSettle();

        // PopupMenuItem widgets should appear
        expect(find.byType(PopupMenuItem<int>), findsNWidgets(3));

        // Text is inside Text.rich with TextSpan, use textContaining
        expect(find.textContaining('Action 1'), findsOneWidget);
        expect(find.textContaining('Action 2'), findsOneWidget);
        expect(find.textContaining('Action 3'), findsOneWidget);
      });

      testWidgets('calls onPressed when menu item selected', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.small,
                actions: testActions,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PopupMenuButton<int>));
        await tester.pumpAndSettle();

        // Tap on second popup menu item
        await tester.tap(find.byType(PopupMenuItem<int>).at(1));
        await tester.pumpAndSettle();

        expect(pressedIndex, 1);
      });

      testWidgets('does not call onPressed for disabled action',
          (tester) async {
        final disabledActions = [
          AppAdaptiveAction(
            title: 'Disabled',
            icon: Icons.block,
            onPressed: () => pressedIndex = 99,
            disabled: true,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.small,
                actions: disabledActions,
                hideDisabled: false,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PopupMenuButton<int>));
        await tester.pumpAndSettle();

        // Tap on the disabled popup menu item
        await tester.tap(find.byType(PopupMenuItem<int>).first);
        await tester.pumpAndSettle();

        expect(pressedIndex, -1);
      });

      testWidgets('shows icon with disabled color for disabled action',
          (tester) async {
        final disabledActions = [
          AppAdaptiveAction(
            title: 'Disabled',
            icon: Icons.block,
            onPressed: () {},
            disabled: true,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.small,
                actions: disabledActions,
                hideDisabled: false,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(PopupMenuButton<int>));
        await tester.pumpAndSettle();

        final icon = tester.widget<Icon>(find.byIcon(Icons.block));
        final theme = Theme.of(tester.element(find.byType(PopupMenuItem<int>)));
        expect(icon.color, theme.disabledColor);
      });
    });

    group('medium size (IconButtons)', () {
      testWidgets('renders IconButtons', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.medium,
                actions: testActions,
              ),
            ),
          ),
        );

        expect(find.byType(IconButton), findsNWidgets(3));
        expect(find.byType(Wrap), findsOneWidget);
      });

      testWidgets('calls onPressed when IconButton tapped', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.medium,
                actions: testActions,
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        expect(pressedIndex, 1);
      });

      testWidgets('disabled IconButton does not respond to tap',
          (tester) async {
        final mixedActions = [
          AppAdaptiveAction(
            title: 'Enabled',
            icon: Icons.check,
            onPressed: () => pressedIndex = 0,
          ),
          AppAdaptiveAction(
            title: 'Disabled',
            icon: Icons.block,
            onPressed: () => pressedIndex = 1,
            disabled: true,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.medium,
                actions: mixedActions,
                hideDisabled: false,
              ),
            ),
          ),
        );

        // The IconButton for disabled action should have null onPressed
        final iconButtons =
            tester.widgetList<IconButton>(find.byType(IconButton));
        final disabledButton = iconButtons.elementAt(1);
        expect(disabledButton.onPressed, isNull);
      });

      testWidgets('respects vertical direction', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.medium,
                actions: testActions,
                direction: Axis.vertical,
              ),
            ),
          ),
        );

        final wrap = tester.widget<Wrap>(find.byType(Wrap));
        expect(wrap.direction, Axis.vertical);
      });
    });

    group('large size (TextButton.icon)', () {
      testWidgets('renders TextButtons with icons and labels', (tester) async {
        // Verify testActions is populated
        expect(testActions.length, 3);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.large,
                actions: testActions,
              ),
            ),
          ),
        );

        // First verify Wrap is rendered
        expect(find.byType(Wrap), findsOneWidget);

        // Then check for text content
        expect(find.text('Action 1'), findsOneWidget);
        expect(find.text('Action 2'), findsOneWidget);
        expect(find.text('Action 3'), findsOneWidget);
      });

      testWidgets('calls onPressed when TextButton tapped', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.large,
                actions: testActions,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Action 3'));
        await tester.pumpAndSettle();

        expect(pressedIndex, 2);
      });

      testWidgets('disabled TextButton does not respond to tap',
          (tester) async {
        final mixedActions = [
          AppAdaptiveAction(
            title: 'Enabled',
            icon: Icons.check,
            onPressed: () => pressedIndex = 0,
          ),
          AppAdaptiveAction(
            title: 'Disabled',
            icon: Icons.block,
            onPressed: () => pressedIndex = 1,
            disabled: true,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.large,
                actions: mixedActions,
                hideDisabled: false,
              ),
            ),
          ),
        );

        // Verify both actions are rendered
        expect(find.text('Enabled'), findsOneWidget);
        expect(find.text('Disabled'), findsOneWidget);

        // Tap the disabled action - should not trigger callback
        await tester.tap(find.text('Disabled'));
        await tester.pumpAndSettle();

        // pressedIndex should remain -1 since disabled action shouldn't trigger
        expect(pressedIndex, -1);
      });

      testWidgets('respects horizontal direction by default', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.large,
                actions: testActions,
              ),
            ),
          ),
        );

        final wrap = tester.widget<Wrap>(find.byType(Wrap));
        expect(wrap.direction, Axis.horizontal);
      });
    });

    group('hideDisabled behavior', () {
      testWidgets('hides disabled actions by default', (tester) async {
        final mixedActions = [
          AppAdaptiveAction(
            title: 'Enabled',
            icon: Icons.check,
            onPressed: () {},
          ),
          AppAdaptiveAction(
            title: 'Disabled',
            icon: Icons.block,
            onPressed: () {},
            disabled: true,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.large,
                actions: mixedActions,
              ),
            ),
          ),
        );

        expect(find.text('Enabled'), findsOneWidget);
        expect(find.text('Disabled'), findsNothing);
      });

      testWidgets('shows disabled actions when hideDisabled is false',
          (tester) async {
        final mixedActions = [
          AppAdaptiveAction(
            title: 'Enabled',
            icon: Icons.check,
            onPressed: () {},
          ),
          AppAdaptiveAction(
            title: 'Disabled',
            icon: Icons.block,
            onPressed: () {},
            disabled: true,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppAdaptiveActionList(
                size: AppAdaptiveActionSize.large,
                actions: mixedActions,
                hideDisabled: false,
              ),
            ),
          ),
        );

        expect(find.text('Enabled'), findsOneWidget);
        expect(find.text('Disabled'), findsOneWidget);
      });

      testWidgets('filters disabled actions in actions list', (tester) async {
        final mixedActions = [
          AppAdaptiveAction(title: 'A', icon: Icons.star, onPressed: () {}),
          AppAdaptiveAction(
              title: 'B',
              icon: Icons.star_border,
              onPressed: () {},
              disabled: true),
          AppAdaptiveAction(
              title: 'C', icon: Icons.star_half, onPressed: () {}),
        ];

        final list = AppAdaptiveActionList(
          size: AppAdaptiveActionSize.large,
          actions: mixedActions,
        );

        expect(list.actions.length, 2);
        expect(list.actions.map((a) => a.title), ['A', 'C']);
      });
    });

    group('default values', () {
      test('size defaults to medium', () {
        final list = AppAdaptiveActionList(actions: []);
        expect(list.size, AppAdaptiveActionSize.medium);
      });

      test('hideDisabled defaults to true', () {
        final list = AppAdaptiveActionList(actions: []);
        expect(list.hideDisabled, true);
      });

      test('direction defaults to horizontal', () {
        final list = AppAdaptiveActionList(actions: []);
        expect(list.direction, Axis.horizontal);
      });
    });
  });

  group('AppAdaptiveScaffold', () {
    final testDestinations = [
      const NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
      const NavigationDestination(
          icon: Icon(Icons.settings), label: 'Settings'),
    ];

    testWidgets('renders body content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            body: (context) => const Text('Body Content'),
          ),
        ),
      );

      expect(find.text('Body Content'), findsOneWidget);
    });

    testWidgets('renders only body when hideNavigation is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            body: (context) => const Text('Fullscreen Body'),
            hideNavigation: true,
          ),
        ),
      );

      expect(find.text('Fullscreen Body'), findsOneWidget);
      // Should not find AdaptiveScaffold when hideNavigation is true
      expect(find.byType(DmAdaptiveScaffold), findsNothing);
    });

    testWidgets('renders SizedBox.shrink when hideNavigation true and no body',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            hideNavigation: true,
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('renders AdaptiveScaffold when hideNavigation is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            body: (context) => const Text('Body'),
            hideNavigation: false,
          ),
        ),
      );

      expect(find.byType(DmAdaptiveScaffold), findsOneWidget);
    });

    test('has correct static breakpoint constants', () {
      expect(AppAdaptiveScaffold.appSmallBreakpoint, Breakpoints.small);
      expect(AppAdaptiveScaffold.appMediumBreakpoint, Breakpoints.medium);
      expect(AppAdaptiveScaffold.appMediumLargeBreakpoint,
          Breakpoints.mediumLarge);
      expect(AppAdaptiveScaffold.appLargeBreakpoint, Breakpoints.large);
      expect(
          AppAdaptiveScaffold.appExtraLargeBreakpoint, Breakpoints.extraLarge);
      expect(AppAdaptiveScaffold.appDrawerBreakpoint, Breakpoints.smallDesktop);
    });

    group('default values', () {
      test('selectedIndex defaults to 0', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.selectedIndex, 0);
      });

      test('hideNavigation defaults to false', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.hideNavigation, false);
      });

      test('useDrawer defaults to false', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.useDrawer, false);
      });

      test('internalAnimations defaults to true', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.internalAnimations, true);
      });

      test('transitionDuration defaults to 0ms', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.transitionDuration, const Duration(milliseconds: 0));
      });

      test('bodyOrientation defaults to horizontal', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.bodyOrientation, Axis.horizontal);
      });

      test('navigationRailWidth defaults to 72', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.navigationRailWidth, 72);
      });

      test('extendedNavigationRailWidth defaults to 192', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.extendedNavigationRailWidth, 192);
      });

      test('navigationRailPadding defaults correctly', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        // kNavigationRailDefaultPadding is 8.0
        expect(
          scaffold.navigationRailPadding,
          const EdgeInsets.all(8.0),
        );
      });

      test('breakpoints use app defaults', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(
            scaffold.smallBreakpoint, AppAdaptiveScaffold.appSmallBreakpoint);
        expect(
            scaffold.mediumBreakpoint, AppAdaptiveScaffold.appMediumBreakpoint);
        expect(scaffold.mediumLargeBreakpoint,
            AppAdaptiveScaffold.appMediumLargeBreakpoint);
        expect(
            scaffold.largeBreakpoint, AppAdaptiveScaffold.appLargeBreakpoint);
        expect(scaffold.extraLargeBreakpoint,
            AppAdaptiveScaffold.appExtraLargeBreakpoint);
        expect(
            scaffold.drawerBreakpoint, AppAdaptiveScaffold.appDrawerBreakpoint);
      });
      test('showCollapseToggle defaults to true', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.showCollapseToggle, true);
      });

      test('isExtendedOverride defaults to null', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.isExtendedOverride, isNull);
      });

      test('collapseIcon and expandIcon default to chevron icons', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.collapseIcon, Icons.chevron_left);
        expect(scaffold.expandIcon, Icons.chevron_right);
      });

      test('navigationVisible defaults to true', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.navigationVisible, true);
      });

      test('showNavigationToggle defaults to false', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.showNavigationToggle, false);
      });

      test('navigationRestoreInHeader defaults to false', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.navigationRestoreInHeader, false);
      });

      test('duoScreenPolicy defaults to DuoScreenPolicy.splitBody', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.duoScreenPolicy, DuoScreenPolicy.splitBody);
      });

      test('duoScreenRole defaults to DuoScreenRole.single', () {
        final scaffold = AppAdaptiveScaffold(destinations: testDestinations);
        expect(scaffold.duoScreenRole, DuoScreenRole.single);
      });
    });

    testWidgets('passes selectedIndex to AdaptiveScaffold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            selectedIndex: 1,
            body: (context) => const Text('Body'),
          ),
        ),
      );

      final adaptiveScaffold =
          tester.widget<DmAdaptiveScaffold>(find.byType(DmAdaptiveScaffold));
      expect(adaptiveScaffold.selectedIndex, 1);
    });

    testWidgets('passes destinations to AdaptiveScaffold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            body: (context) => const Text('Body'),
          ),
        ),
      );

      final adaptiveScaffold =
          tester.widget<DmAdaptiveScaffold>(find.byType(DmAdaptiveScaffold));
      expect(adaptiveScaffold.destinations, testDestinations);
    });

    testWidgets('calls onSelectedIndexChange callback', (tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            onSelectedIndexChange: (index) => selectedIndex = index,
            body: (context) => const Text('Body'),
          ),
        ),
      );

      final adaptiveScaffold =
          tester.widget<DmAdaptiveScaffold>(find.byType(DmAdaptiveScaffold));

      // Simulate callback
      adaptiveScaffold.onSelectedIndexChange?.call(1);
      expect(selectedIndex, 1);
    });

    testWidgets('renders with leading widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            leadingUnextendedNavRail: const Icon(Icons.menu),
            leadingExtendedNavRail: const Text('App Name'),
            body: (context) => const Text('Body'),
          ),
        ),
      );

      final adaptiveScaffold =
          tester.widget<DmAdaptiveScaffold>(find.byType(DmAdaptiveScaffold));
      expect(adaptiveScaffold.leadingUnextendedNavRail, isNotNull);
      expect(adaptiveScaffold.leadingExtendedNavRail, isNotNull);
    });

    testWidgets('renders with trailing widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            trailingNavRail: const Text('Trailing'),
            body: (context) => const Text('Body'),
          ),
        ),
      );

      final adaptiveScaffold =
          tester.widget<DmAdaptiveScaffold>(find.byType(DmAdaptiveScaffold));
      expect(adaptiveScaffold.trailingNavRail, isNotNull);
    });

    testWidgets('renders with secondaryBody', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            body: (context) => const Text('Primary'),
            secondaryBody: (context) => const Text('Secondary'),
          ),
        ),
      );

      final adaptiveScaffold =
          tester.widget<DmAdaptiveScaffold>(find.byType(DmAdaptiveScaffold));
      expect(adaptiveScaffold.secondaryBody, isNotNull);
    });

    testWidgets('passes bodyRatio to AdaptiveScaffold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            body: (context) => const Text('Body'),
            bodyRatio: 0.3,
          ),
        ),
      );

      final adaptiveScaffold =
          tester.widget<DmAdaptiveScaffold>(find.byType(DmAdaptiveScaffold));
      expect(adaptiveScaffold.bodyRatio, 0.3);
    });

    testWidgets('passes showCollapseToggle and icons to AdaptiveScaffold',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            showCollapseToggle: true,
            collapseIcon: Icons.arrow_back,
            expandIcon: Icons.arrow_forward,
            body: (context) => const Text('Body'),
          ),
        ),
      );

      final adaptiveScaffold =
          tester.widget<DmAdaptiveScaffold>(find.byType(DmAdaptiveScaffold));
      expect(adaptiveScaffold.showCollapseToggle, isTrue);
      expect(adaptiveScaffold.collapseIcon, Icons.arrow_back);
      expect(adaptiveScaffold.expandIcon, Icons.arrow_forward);
    });

    testWidgets('passes explicit isExtendedOverride to AdaptiveScaffold',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            isExtendedOverride: false,
            body: (context) => const Text('Body'),
          ),
        ),
      );

      final adaptiveScaffold =
          tester.widget<DmAdaptiveScaffold>(find.byType(DmAdaptiveScaffold));
      expect(adaptiveScaffold.isExtendedOverride, isFalse);
    });

    testWidgets('synchronizes with navigationRailExtendedNotifier by default',
        (tester) async {
      AppAdaptiveScaffold.navigationRailExtendedNotifier.value = true;
      addTearDown(() {
        AppAdaptiveScaffold.navigationRailExtendedNotifier.value = null;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            body: (context) => const Text('Body'),
          ),
        ),
      );

      var adaptiveScaffold =
          tester.widget<DmAdaptiveScaffold>(find.byType(DmAdaptiveScaffold));
      expect(adaptiveScaffold.isExtendedOverride, isTrue);

      // Simulate extension change callback without custom onExtendedChange
      adaptiveScaffold.onExtendedChange?.call(false);
      await tester.pump();

      expect(AppAdaptiveScaffold.navigationRailExtendedNotifier.value, isFalse);
      adaptiveScaffold =
          tester.widget<DmAdaptiveScaffold>(find.byType(DmAdaptiveScaffold));
      expect(adaptiveScaffold.isExtendedOverride, isFalse);
    });

    testWidgets('passes navigation visibility parameters to AdaptiveScaffold',
        (tester) async {
      bool? requestedVisibility;

      await tester.pumpWidget(
        MaterialApp(
          home: AppAdaptiveScaffold(
            destinations: testDestinations,
            navigationVisible: false,
            showNavigationToggle: true,
            navigationRestoreInHeader: true,
            onNavigationVisibleChange: (val) => requestedVisibility = val,
            body: (context) => const Text('Body'),
          ),
        ),
      );

      final adaptiveScaffold =
          tester.widget<DmAdaptiveScaffold>(find.byType(DmAdaptiveScaffold));
      expect(adaptiveScaffold.navigationVisible, isFalse);
      expect(adaptiveScaffold.showNavigationToggle, isTrue);
      expect(adaptiveScaffold.navigationRestoreInHeader, isTrue);

      adaptiveScaffold.onNavigationVisibleChange?.call(true);
      expect(requestedVisibility, isTrue);
    });
  });
}
