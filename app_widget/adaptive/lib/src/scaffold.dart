import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';

export 'package:duskmoon_ui/duskmoon_ui.dart';

class AppAdaptiveScaffold extends StatelessWidget {
  static const appSmallBreakpoint = Breakpoints.small;
  static const appMediumBreakpoint = Breakpoints.medium;
  static const appMediumLargeBreakpoint = Breakpoints.mediumLarge;
  static const appLargeBreakpoint = Breakpoints.large;
  static const appExtraLargeBreakpoint = Breakpoints.extraLarge;
  static const appDrawerBreakpoint = Breakpoints.smallDesktop;

  /// The destinations to be used in navigation items. These are converted to
  /// [NavigationRailDestination]s and [BottomNavigationBarItem]s and inserted
  /// into the appropriate places. If passing destinations, you must also pass a
  /// selected index to be used by the [NavigationRail].
  final List<NavigationDestination> destinations;

  /// The index to be used by the [NavigationRail].
  final int? selectedIndex;

  /// Option to display a leading widget at the top of the navigation rail
  /// at the middle breakpoint.
  final Widget? leadingUnextendedNavRail;

  /// Option to display a leading widget at the top of the navigation rail
  /// at the largest breakpoint.
  final Widget? leadingExtendedNavRail;

  /// Option to display a trailing widget below the destinations of the
  /// navigation rail at the largest breakpoint.
  final Widget? trailingNavRail;

  /// Option to apply custom padding to the navigation rail.
  final EdgeInsetsGeometry navigationRailPadding;

  /// The alignment of the destinations in the navigation rail.
  final double? groupAlignment;

  /// Widget to be displayed in the body slot at the smallest breakpoint.
  ///
  /// If nothing is entered for this property, then the default [body] is
  /// displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? smallBody;

  /// Widget to be displayed in the body slot at the medium breakpoint.
  ///
  /// The default displayed body.
  final WidgetBuilder? body;

  /// Widget to be displayed in the body slot at the mediumLarge breakpoint.
  ///
  /// If nothing is entered for this property, then the default [body] is
  /// displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? mediumLargeBody;

  /// Widget to be displayed in the body slot at the large breakpoint.
  ///
  /// If nothing is entered for this property, then the default [body] is
  /// displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? largeBody;

  /// Widget to be displayed in the body slot at the extraLarge breakpoint.
  ///
  /// If nothing is entered for this property, then the default [body] is
  /// displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? extraLargeBody;

  /// Widget to be displayed in the secondaryBody slot at the compact
  /// breakpoint.
  ///
  /// If nothing is entered for this property, then the default [secondaryBody]
  /// is displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? smallSecondaryBody;

  /// Widget to be displayed in the secondaryBody slot at the medium breakpoint.
  ///
  /// The default displayed secondaryBody.
  final WidgetBuilder? secondaryBody;

  /// Widget to be displayed in the secondaryBody slot at the mediumLarge
  /// breakpoint.
  ///
  /// If nothing is entered for this property, then the default [secondaryBody]
  /// is displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? mediumLargeSecondaryBody;

  /// Widget to be displayed in the secondaryBody slot at the large
  /// breakpoint.
  ///
  /// If nothing is entered for this property, then the default [secondaryBody]
  /// is displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? largeSecondaryBody;

  /// Widget to be displayed in the secondaryBody slot at the extraLarge
  /// breakpoint.
  ///
  /// If nothing is entered for this property, then the default [secondaryBody]
  /// is displayed in the slot. If null is entered for this slot, the slot stays
  /// empty.
  final WidgetBuilder? extraLargeSecondaryBody;

  /// Defines the fractional ratio of body to the secondaryBody.
  ///
  /// For example 0.3 would mean body takes up 30% of the available space and
  /// secondaryBody takes up the rest.
  ///
  /// If this value is null, the ratio is defined so that the split axis is in
  /// the center of the screen.
  final double? bodyRatio;

  /// The breakpoint defined for the compact size, associated with mobile-like
  /// features.
  ///
  /// Defaults to [Breakpoints.small].
  final Breakpoint smallBreakpoint;

  /// The breakpoint defined for the medium size, associated with tablet-like
  /// features.
  ///
  /// Defaults to [Breakpoints.medium].
  final Breakpoint mediumBreakpoint;

  /// The breakpoint defined for the mediumLarge size, associated with desktop-like
  /// features.
  ///
  /// Defaults to [Breakpoints.mediumLarge].
  final Breakpoint mediumLargeBreakpoint;

  /// The breakpoint defined for the large size, associated with desktop-like
  /// features.
  ///
  /// Defaults to [Breakpoints.large].
  final Breakpoint largeBreakpoint;

  /// The breakpoint defined for the extraLarge size, associated with ultra-wide
  /// features.
  ///
  /// Defaults to [Breakpoints.extraLarge].
  final Breakpoint extraLargeBreakpoint;

  /// Whether or not the developer wants the smooth entering slide transition on
  /// secondaryBody.
  ///
  /// Defaults to true.
  final bool internalAnimations;

  /// Defines the duration of transition between layouts.
  ///
  /// Defaults to [Duration(seconds: 1)].
  final Duration transitionDuration;

  /// The orientation of the body and secondaryBody. Either horizontal (side by
  /// side) or vertical (top to bottom).
  ///
  /// Defaults to Axis.horizontal.
  final Axis bodyOrientation;

  /// Whether to use a [Drawer] over a [BottomNavigationBar] when not on mobile
  /// and Breakpoint is small.
  ///
  /// Defaults to true.
  final bool useDrawer;

  /// Option to override the drawerBreakpoint for the usage of [Drawer] over the
  /// usual [BottomNavigationBar].
  ///
  /// Defaults to [Breakpoints.smallDesktop].
  final Breakpoint drawerBreakpoint;

  /// An optional [Breakpoint] which overrides the [appBar] breakpoint to display
  /// an [AppBar] without depending on the drawer visibility.
  ///
  /// By default, an [AppBar] will show on [Breakpoints.smallDesktop] if [useDrawer] is set
  /// to true.
  final Breakpoint? appBarBreakpoint;

  /// Option to override the default [AppBar] when using drawer in desktop
  /// small.
  final PreferredSizeWidget? appBar;

  /// Callback function for when the index of a [NavigationRail] changes.
  final void Function(int)? onSelectedIndexChange;

  /// The width used for the internal [NavigationRail] at the medium [Breakpoint].
  final double navigationRailWidth;

  /// The width used for the internal extended [NavigationRail] at the large
  /// [Breakpoint].
  final double extendedNavigationRailWidth;

  /// Shared across routes; null retains breakpoint-driven defaults.
  static final ValueNotifier<bool?> navigationRailExtendedNotifier =
      ValueNotifier<bool?>(null);

  /// Used to map NavigationDestination to NavigationRailDestination.
  final NavigationRailDestinationBuilder? navigationRailDestinationBuilder;

  /// When true, hides all navigation UI (NavigationRail, BottomNavigationBar)
  /// and displays only the body content in fullscreen mode.
  final bool hideNavigation;

  /// Whether the navigation rail shows its footer collapse/expand toggle button.
  final bool showCollapseToggle;

  /// Explicit rail extension preference; null uses the scaffold's preference
  /// or [navigationRailExtendedNotifier].
  final bool? isExtendedOverride;

  /// Called when the rail footer requests an extension change.
  final void Function(bool isExtended)? onExtendedChange;

  /// Icon displayed by the footer when the rail is extended.
  final IconData collapseIcon;

  /// Icon displayed by the footer when the rail is collapsed.
  final IconData expandIcon;

  /// Whether rail, drawer, and bottom navigation are visible.
  final bool navigationVisible;

  /// Adds reusable top-right hide controls to the rail/drawer.
  final bool showNavigationToggle;

  /// Requests a change to caller-controlled navigation visibility.
  final ValueChanged<bool>? onNavigationVisibleChange;

  /// Suppresses the overlay fallback when the page adopts header restoration.
  final bool navigationRestoreInHeader;

  /// How slots are distributed across a foldable or companion display.
  final DuoScreenPolicy duoScreenPolicy;

  /// View role after a companion display has connected successfully.
  final DuoScreenRole duoScreenRole;

  const AppAdaptiveScaffold({
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.leadingUnextendedNavRail,
    this.leadingExtendedNavRail,
    this.trailingNavRail,
    this.navigationRailPadding =
        const EdgeInsets.all(kNavigationRailDefaultPadding),
    this.smallBody,
    this.body,
    this.mediumLargeBody,
    this.largeBody,
    this.extraLargeBody,
    this.smallSecondaryBody,
    this.secondaryBody,
    this.mediumLargeSecondaryBody,
    this.largeSecondaryBody,
    this.extraLargeSecondaryBody,
    this.bodyRatio,
    this.smallBreakpoint = appSmallBreakpoint,
    this.mediumBreakpoint = appMediumBreakpoint,
    this.mediumLargeBreakpoint = appMediumLargeBreakpoint,
    this.largeBreakpoint = appLargeBreakpoint,
    this.extraLargeBreakpoint = appExtraLargeBreakpoint,
    this.drawerBreakpoint = appDrawerBreakpoint,
    this.internalAnimations = true,
    this.transitionDuration = const Duration(milliseconds: 0),
    this.bodyOrientation = Axis.horizontal,
    this.onSelectedIndexChange,
    this.useDrawer = false,
    this.appBar,
    this.navigationRailWidth = 72,
    this.extendedNavigationRailWidth = 192,
    this.appBarBreakpoint,
    this.navigationRailDestinationBuilder,
    this.groupAlignment,
    this.hideNavigation = false,
    this.showCollapseToggle = true,
    this.isExtendedOverride,
    this.onExtendedChange,
    this.collapseIcon = Icons.chevron_left,
    this.expandIcon = Icons.chevron_right,
    this.navigationVisible = true,
    this.showNavigationToggle = false,
    this.onNavigationVisibleChange,
    this.navigationRestoreInHeader = false,
    this.duoScreenPolicy = DuoScreenPolicy.splitBody,
    this.duoScreenRole = DuoScreenRole.single,
  });

  @override
  Widget build(BuildContext context) {
    // When hideNavigation is true, render only the body without navigation
    if (hideNavigation) {
      return body?.call(context) ?? const SizedBox.shrink();
    }

    final mediaQuery = MediaQuery.of(context);
    final secondaryBodies = <Breakpoint, WidgetBuilder?>{
      Breakpoints.standard: secondaryBody,
      if (smallSecondaryBody != null) smallBreakpoint: smallSecondaryBody,
      if (secondaryBody != null) mediumBreakpoint: secondaryBody,
      if (mediumLargeSecondaryBody != null)
        mediumLargeBreakpoint: mediumLargeSecondaryBody,
      if (largeSecondaryBody != null) largeBreakpoint: largeSecondaryBody,
      if (extraLargeSecondaryBody != null)
        extraLargeBreakpoint: extraLargeSecondaryBody,
    };
    final activeSecondaryBody = secondaryBodies[
        Breakpoint.activeBreakpointIn(context, secondaryBodies.keys.toList())];
    final hasSingleBody = duoScreenPolicy == DuoScreenPolicy.splitBody &&
        duoScreenRole == DuoScreenRole.single &&
        (activeSecondaryBody == null ||
            activeSecondaryBody == DmAdaptiveScaffold.emptyBuilder);
    // TODO(upstream): duskmoon-dev/flutter-duskmoon-ui#23
    // WORKAROUND(upstream): duskmoon-dev/flutter-duskmoon-ui#23
    final displayFeatures = hasSingleBody
        ? mediaQuery.displayFeatures
            .where(
              (feature) =>
                  feature.type != DisplayFeatureType.fold ||
                  (feature.bounds.width > 0 && feature.bounds.height > 0),
            )
            .toList()
        : mediaQuery.displayFeatures;
    final hasFilteredFold =
        displayFeatures.length != mediaQuery.displayFeatures.length;

    WidgetBuilder? preserveDisplayFeatures(WidgetBuilder? builder) {
      if (builder == null || !hasFilteredFold) return builder;
      return (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              displayFeatures: mediaQuery.displayFeatures,
            ),
            child: Builder(builder: builder),
          );
    }

    final scaffold = ValueListenableBuilder<bool?>(
      valueListenable: navigationRailExtendedNotifier,
      builder: (context, sharedExtended, _) {
        final effectiveExtended = isExtendedOverride ?? sharedExtended;
        void effectiveOnExtendedChange(bool val) {
          if (onExtendedChange != null) {
            onExtendedChange!(val);
          } else {
            navigationRailExtendedNotifier.value = val;
          }
        }

        return DmAdaptiveScaffold(
          destinations: destinations,
          selectedIndex: selectedIndex,
          leadingUnextendedNavRail: leadingUnextendedNavRail,
          leadingExtendedNavRail: leadingExtendedNavRail,
          trailingNavRail: trailingNavRail,
          navigationRailPadding: navigationRailPadding,
          smallBody: preserveDisplayFeatures(smallBody),
          body: preserveDisplayFeatures(body),
          mediumLargeBody: preserveDisplayFeatures(mediumLargeBody),
          largeBody: preserveDisplayFeatures(largeBody),
          extraLargeBody: preserveDisplayFeatures(extraLargeBody),
          smallSecondaryBody: smallSecondaryBody,
          secondaryBody: secondaryBody,
          mediumLargeSecondaryBody: mediumLargeSecondaryBody,
          largeSecondaryBody: largeSecondaryBody,
          extraLargeSecondaryBody: extraLargeSecondaryBody,
          bodyRatio: bodyRatio,
          smallBreakpoint: smallBreakpoint,
          mediumBreakpoint: mediumBreakpoint,
          mediumLargeBreakpoint: mediumLargeBreakpoint,
          largeBreakpoint: largeBreakpoint,
          extraLargeBreakpoint: extraLargeBreakpoint,
          drawerBreakpoint: drawerBreakpoint,
          internalAnimations: internalAnimations,
          transitionDuration: transitionDuration,
          bodyOrientation: bodyOrientation,
          onSelectedIndexChange: onSelectedIndexChange,
          useDrawer: useDrawer,
          appBar: appBar,
          navigationRailWidth: navigationRailWidth,
          extendedNavigationRailWidth: extendedNavigationRailWidth,
          appBarBreakpoint: appBarBreakpoint,
          navigationRailDestinationBuilder: navigationRailDestinationBuilder,
          groupAlignment: groupAlignment,
          showCollapseToggle: showCollapseToggle,
          isExtendedOverride: effectiveExtended,
          onExtendedChange: effectiveOnExtendedChange,
          collapseIcon: collapseIcon,
          expandIcon: expandIcon,
          navigationVisible: navigationVisible,
          showNavigationToggle: showNavigationToggle,
          onNavigationVisibleChange: onNavigationVisibleChange,
          navigationRestoreInHeader: navigationRestoreInHeader,
          duoScreenPolicy: duoScreenPolicy,
          duoScreenRole: duoScreenRole,
        );
      },
    );

    return hasFilteredFold
        ? MediaQuery(
            data: mediaQuery.copyWith(displayFeatures: displayFeatures),
            child: scaffold,
          )
        : scaffold;
  }
}
