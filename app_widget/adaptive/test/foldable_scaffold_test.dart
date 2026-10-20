import 'dart:ui';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _bodyKey = Key('foldable-primary-body');
const _secondaryBodyKey = Key('secondary-body');
const _destinations = [
  NavigationDestination(icon: Icon(Icons.terminal), label: 'Terminal'),
  NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
];

Future<void> _pumpScaffold(
  WidgetTester tester, {
  Size size = const Size(840, 700),
  List<DisplayFeature> displayFeatures = const [],
  WidgetBuilder? body,
  WidgetBuilder? smallSecondaryBody,
  WidgetBuilder? secondaryBody,
  WidgetBuilder? largeSecondaryBody,
  bool hideNavigation = false,
  DuoScreenPolicy duoScreenPolicy = DuoScreenPolicy.splitBody,
  DuoScreenRole duoScreenRole = DuoScreenRole.single,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size, displayFeatures: displayFeatures),
        child: AppAdaptiveScaffold(
          destinations: _destinations,
          internalAnimations: false,
          body: body ?? (_) => const SizedBox.expand(key: _bodyKey),
          smallSecondaryBody: smallSecondaryBody,
          secondaryBody: secondaryBody,
          largeSecondaryBody: largeSecondaryBody,
          hideNavigation: hideNavigation,
          duoScreenPolicy: duoScreenPolicy,
          duoScreenRole: duoScreenRole,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const fold = DisplayFeature(
    bounds: Rect.fromLTRB(420, 0, 420, 700),
    type: DisplayFeatureType.fold,
    state: DisplayFeatureState.postureHalfOpened,
  );

  testWidgets('single body fills the available width across a fold', (
    tester,
  ) async {
    await _pumpScaffold(tester, displayFeatures: const [fold]);

    final body = tester.getRect(find.byKey(_bodyKey));
    expect(body.right, 840);
    expect(body.width, greaterThan(420));
    expect(tester.takeException(), isNull);
  });

  testWidgets('explicit secondary body stays on the other side of a fold', (
    tester,
  ) async {
    await _pumpScaffold(
      tester,
      displayFeatures: const [fold],
      secondaryBody: (_) => const SizedBox.expand(key: _secondaryBodyKey),
    );

    final body = tester.getRect(find.byKey(_bodyKey));
    final secondaryBody = tester.getRect(find.byKey(_secondaryBodyKey));
    expect(body.right, 420);
    expect(secondaryBody.left, 420);
    expect(secondaryBody.right, 840);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone body fills the width without a fold', (tester) async {
    await _pumpScaffold(tester, size: const Size(400, 800));

    final body = tester.getRect(find.byKey(_bodyKey));
    expect(body.left, 0);
    expect(body.right, 400);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide body fills the available width without a fold', (
    tester,
  ) async {
    await _pumpScaffold(tester);

    final body = tester.getRect(find.byKey(_bodyKey));
    expect(body.right, 840);
    expect(body.width, greaterThan(420));
    expect(tester.takeException(), isNull);
  });

  testWidgets('fullscreen body fills the display across a fold',
      (tester) async {
    await _pumpScaffold(
      tester,
      displayFeatures: const [fold],
      hideNavigation: true,
    );

    expect(
      tester.getRect(find.byKey(_bodyKey)),
      const Rect.fromLTWH(0, 0, 840, 700),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('single body respects a physical hinge', (tester) async {
    await _pumpScaffold(
      tester,
      displayFeatures: const [
        DisplayFeature(
          bounds: Rect.fromLTRB(410, 0, 430, 700),
          type: DisplayFeatureType.hinge,
          state: DisplayFeatureState.unknown,
        ),
      ],
    );

    expect(tester.getRect(find.byKey(_bodyKey)).right, 410);
    expect(tester.takeException(), isNull);
  });

  testWidgets('single body fills the height across a horizontal fold', (
    tester,
  ) async {
    await _pumpScaffold(
      tester,
      displayFeatures: const [
        DisplayFeature(
          bounds: Rect.fromLTRB(0, 350, 840, 350),
          type: DisplayFeatureType.fold,
          state: DisplayFeatureState.postureHalfOpened,
        ),
      ],
    );

    expect(tester.getRect(find.byKey(_bodyKey)).bottom, 700);
    expect(tester.takeException(), isNull);
  });

  testWidgets('single body respects an occluding fold', (tester) async {
    await _pumpScaffold(
      tester,
      displayFeatures: const [
        DisplayFeature(
          bounds: Rect.fromLTRB(410, 0, 430, 700),
          type: DisplayFeatureType.fold,
          state: DisplayFeatureState.postureHalfOpened,
        ),
      ],
    );

    expect(tester.getRect(find.byKey(_bodyKey)).right, 410);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigation on secondary retains the fold layout', (
    tester,
  ) async {
    await _pumpScaffold(
      tester,
      displayFeatures: const [fold],
      duoScreenPolicy: DuoScreenPolicy.navigationOnSecondary,
    );

    expect(tester.getRect(find.byKey(_bodyKey)).right, 420);
    expect(tester.takeException(), isNull);
  });

  testWidgets('explicit display role retains the fold layout', (tester) async {
    await _pumpScaffold(
      tester,
      displayFeatures: const [fold],
      duoScreenRole: DuoScreenRole.primary,
    );

    expect(tester.getRect(find.byKey(_bodyKey)).right, 420);
    expect(tester.takeException(), isNull);
  });

  testWidgets('body descendants retain the original display features', (
    tester,
  ) async {
    List<DisplayFeature>? bodyFeatures;
    await _pumpScaffold(
      tester,
      displayFeatures: const [fold],
      body: (context) {
        bodyFeatures = MediaQuery.displayFeaturesOf(context);
        return const SizedBox.expand(key: _bodyKey);
      },
    );

    expect(bodyFeatures, const [fold]);
    expect(tester.getRect(find.byKey(_bodyKey)).right, 840);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inactive large secondary body does not reserve a fold pane', (
    tester,
  ) async {
    await _pumpScaffold(
      tester,
      size: const Size(841, 700),
      displayFeatures: const [fold],
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
      largeSecondaryBody: (_) => const SizedBox.expand(key: _secondaryBodyKey),
    );

    expect(tester.getRect(find.byKey(_bodyKey)).right, 841);
    expect(find.byKey(_secondaryBodyKey), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('active large secondary body retains the fold pane', (
    tester,
  ) async {
    await _pumpScaffold(
      tester,
      size: const Size(1280, 900),
      displayFeatures: const [
        DisplayFeature(
          bounds: Rect.fromLTRB(640, 0, 640, 900),
          type: DisplayFeatureType.fold,
          state: DisplayFeatureState.postureHalfOpened,
        ),
      ],
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
      largeSecondaryBody: (_) => const SizedBox.expand(key: _secondaryBodyKey),
    );

    expect(tester.getRect(find.byKey(_bodyKey)).right, 640);
    expect(tester.getRect(find.byKey(_secondaryBodyKey)).left, 640);
    expect(tester.takeException(), isNull);
  });

  testWidgets('emptyBuilder does not reserve a small secondary fold pane', (
    tester,
  ) async {
    await _pumpScaffold(
      tester,
      size: const Size(400, 800),
      displayFeatures: const [
        DisplayFeature(
          bounds: Rect.fromLTRB(200, 0, 200, 800),
          type: DisplayFeatureType.fold,
          state: DisplayFeatureState.postureHalfOpened,
        ),
      ],
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
      largeSecondaryBody: (_) => const SizedBox.expand(key: _secondaryBodyKey),
    );

    expect(tester.getRect(find.byKey(_bodyKey)).right, 400);
    expect(find.byKey(_secondaryBodyKey), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
