import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';

import 'paint_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  static const name = 'splash';
  static const path = '/splash';

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        context.goNamed(SettingsScreen.name);
      });
    });
    final size = MediaQuery.of(context).size;
    final width = size.width > size.height ? size.height : size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: width * 0.8,
            height: width * 0.8,
            child: Center(
              child: CustomPaint(
                size: Size(width * 0.7, width * 0.7 * 0.2),
                painter: LogoPainter(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
