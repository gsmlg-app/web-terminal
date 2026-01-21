# app_adaptive_widgets

Adaptive widgets that respond to different screen sizes and platforms. This package provides reusable components for building responsive Flutter applications.

## Features

- **AppAdaptiveActionList**: A list of actions that adapts its presentation based on available space:
  - `small`: Shows a popup menu button (compact for small screens)
  - `medium`: Shows icon buttons in a wrap layout
  - `large`: Shows text buttons with icons for spacious layouts

- **AppAdaptiveScaffold**: An adaptive scaffold wrapper around flutter_adaptive_scaffold

## Getting started

Add the package to your pubspec.yaml:

```yaml
dependencies:
  app_adaptive_widgets: any
```

## Usage

```dart
import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';

// Create adaptive actions
final actions = [
  AppAdaptiveAction(
    title: 'Save',
    icon: Icons.save,
    onPressed: () => saveDocument(),
  ),
  AppAdaptiveAction(
    title: 'Delete',
    icon: Icons.delete,
    onPressed: () => deleteDocument(),
    disabled: isReadOnly,
  ),
];

// Use in your widget tree
AppAdaptiveActionList(
  size: AppAdaptiveActionSize.medium,
  actions: actions,
  direction: Axis.horizontal,
  hideDisabled: true, // Hide disabled actions
)
```

## Additional information

This package is part of the web_terminal monorepo and designed for internal use.
