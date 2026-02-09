import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_terminal/screens/terminal/terminal_screen.dart';

import 'paint_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const name = 'splash';
  static const path = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.goNamed(TerminalScreen.name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
