import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    // Create an animation controller for the text fade-in.
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );
    // Delay the text fade-in so that it appears after 4 seconds.
    Future.delayed(const Duration(seconds: 4), () {
      _textController.forward();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a clean dark background.
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The logo image with a shimmer (glowing) effect.
            Shimmer(
              child: Image.asset(
                'assets/logo.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 1),
            // The "narratra" text using the custom font, fading in.
            FadeTransition(
              opacity: _textFadeAnimation,
              child: Text(
                'narratra',
                style: const TextStyle(
                  fontFamily: 'NarratraFont',
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A simple Shimmer widget that creates a horizontal moving gradient overlay.
class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({Key? key, required this.child}) : super(key: key);

  @override
  _ShimmerState createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            // Use lower opacities to reduce the glow intensity.
            return LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.2),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1 - _shimmerController.value * 2, 0),
              end: Alignment(1 - _shimmerController.value * 2, 0),
            ).createShader(bounds);
          },
          child: widget.child,
          blendMode: BlendMode.srcATop,
        );
      },
    );
  }
}
