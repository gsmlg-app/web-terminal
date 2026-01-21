# app_feedback

A collection of user feedback widgets for Flutter applications. Provides consistent toast, snackbar, dialog, and bottom sheet components.

## Features

- **Toast**: Lightweight overlay messages for quick notifications
- **Snackbar**: Material Design snackbars with action support
- **Dialog**: Standard dialogs for confirmations and forms
- **Fullscreen Dialog**: Modal dialogs that cover the entire screen
- **Bottom Sheet Actions**: Action sheets presented from the bottom

## Getting started

Add the package to your pubspec.yaml:

```yaml
dependencies:
  app_feedback: any
```

## Usage

```dart
import 'package:app_feedback/app_feedback.dart';

// Show a toast message
AppToast.show(context, 'Operation completed');

// Show a snackbar
AppSnackbar.show(
  context,
  message: 'Item deleted',
  action: SnackBarAction(
    label: 'Undo',
    onPressed: () => undoDelete(),
  ),
);

// Show a confirmation dialog
final confirmed = await AppDialog.confirm(
  context,
  title: 'Delete item?',
  message: 'This action cannot be undone.',
);

// Show a bottom sheet with actions
AppBottomSheet.showActions(
  context,
  actions: [
    BottomSheetAction(
      title: 'Share',
      icon: Icons.share,
      onPressed: () => share(),
    ),
    BottomSheetAction(
      title: 'Delete',
      icon: Icons.delete,
      onPressed: () => delete(),
      isDestructive: true,
    ),
  ],
);
```

## Additional information

This package is part of the web_terminal monorepo and designed for internal use.
