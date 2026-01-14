import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

class MacosFormRow extends StatelessWidget {
  static const labelWidth = 100.0;

  final Widget? label;

  final Widget child;

  final double spaceBetween;

  const MacosFormRow({
    super.key,
    this.label,
    required this.child,
    this.spaceBetween = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          if (label != null)
            Container(
              width: labelWidth,
              alignment: Alignment.centerRight,
              child: label,
            ),
          if (label != null) SizedBox(width: spaceBetween),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class MacosTextFormRow extends StatelessWidget {
  final Widget? label;

  final String? placeholder;

  final bool obscureText;

  final void Function(String)? onChanged;

  final TextEditingController? controller;

  const MacosTextFormRow({
    super.key,
    this.label,
    this.placeholder,
    this.obscureText = false,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return MacosFormRow(
      label: label,
      spaceBetween: 6.0,
      child: MacosTextField(
        placeholder: placeholder,
        obscureText: obscureText,
        decoration: kDefaultRoundedBorderDecoration.copyWith(
          borderRadius: BorderRadius.circular(2),
        ),
        focusedDecoration: kDefaultFocusedBorderDecoration.copyWith(
          borderRadius: BorderRadius.circular(5),
        ),
        onChanged: onChanged,
        controller: controller,
      ),
    );
  }
}
