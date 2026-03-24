import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kalyanboss/config/routes/route_names.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/services/session_manager.dart';

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
  final SessionManager sessionManager = SessionManager.instance;

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

    _navigateToNext();
  }
  void _navigateToNext() async {
    // Wait for the splash animation to finish (e.g., 3 seconds)
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Trigger the AuthBloc to check the current session status
    // This will update the AuthState, which GoRouter is listening to.
    context.read<AuthBloc>().add(CheckAuthStatusEvent());

    // If for some reason GoRouter doesn't redirect automatically (e.g. initial state was already correct),
    // we do a manual fallback check:
    final state = context.read<AuthBloc>().state;
    if (state.isAuthenticated) {
      context.go(RouteNames.home);
    } else {
      context.go(RouteNames.register);
    }
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
