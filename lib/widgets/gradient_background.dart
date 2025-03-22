import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool useDarkMode;

  const GradientBackground({
    super.key,
    required this.child,
    this.useDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: useDarkMode
              ? [
                  const Color(0xFF2C3E50),
                  const Color(0xFF3498DB),
                ]
              : [
                  const Color(0xFF3455D8),
                  const Color(0xFF4C6EFF),
                ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: child,
    );
  }
} 