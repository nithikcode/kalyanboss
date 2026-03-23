import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _arcController;
  late Animation<double> _arcAnimation;

  late AnimationController _textController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _arcAnimation = CurvedAnimation(
      parent: _arcController,
      curve: Curves.easeOutExpo,
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _arcController.forward().then((_) => _textController.forward());

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _arcController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Warm premium glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 1.0,
                  colors: [

                    Colors.black,
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // Arcs
          Center(
            child: AnimatedBuilder(
              animation: _arcAnimation,
              builder: (_, __) {
                return CustomPaint(
                  painter: PremiumGoldSilverArcPainter(
                    progress: _arcAnimation.value,
                  ),
                  child: SizedBox.expand(),
                );
              },
            ),
          ),

          // Brand Name
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Icon(Icons.handshake),
                  // child: const Text(
                  //   "E-Comm",
                  //   style: TextStyle(
                  //     color: Color(0xFFD4AF37), // real gold
                  //     fontSize: 46,
                  //     fontWeight: FontWeight.w700,
                  //     letterSpacing: 1.5,
                  //     shadows: [
                  //       Shadow(
                  //         blurRadius: 40,
                  //         color: Color(0x80D4AF37), // gold glow
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// PREMIUM GOLD/SILVER ARC PAINTER
// ----------------------------------------------------------------------
class PremiumGoldSilverArcPainter extends CustomPainter {
  final double progress;
  PremiumGoldSilverArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 40);

    final radii = [110, 150, 190];
    const double openRatio = 0.82;
    const double startAngle = pi / 2;
    final sweep = pi * openRatio * progress;

    for (int i = 0; i < radii.length; i++) {
      final radius = radii[i];
      final rect = Rect.fromCircle(center: center, radius: radius.toDouble());

      // alternate: gold → silver → gold
      final Color strokeColor = (i % 2 == 0)
          ?  Colors.black // Gold
          : const Color(0xFFC0C0C0); // Silver

      // Glowing underlayer
      final glowPaint = Paint()
        ..color = strokeColor.withOpacity(0.18)
        ..strokeWidth = 16
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

      canvas.drawArc(rect, startAngle, sweep, false, glowPaint);
      canvas.drawArc(rect, startAngle, -sweep, false, glowPaint);

      // Clean main stroke
      final arcPaint = Paint()
        ..color = strokeColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweep, false, arcPaint);
      canvas.drawArc(rect, startAngle, -sweep, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PremiumGoldSilverArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
