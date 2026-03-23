import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class ShimmeringSvg extends StatelessWidget {
  const ShimmeringSvg({
    super.key,
    required this.assetName,
    this.height = 50.0,
    this.duration = const Duration(milliseconds: 2500), // A shine is usually slower
  });

  final String assetName;
  final double height;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. YOUR ORIGINAL SVG (at the bottom of the stack)
        // This will show its original colors.
        SvgPicture.asset(
          assetName,
          height: height,
        ),

        // 2. THE SHIMMER (on top of the stack)
        // This is your original gradient from your very first try.
        // It's mostly transparent, so the icon below shows through.
        Shimmer(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.0), // Start transparent
              Colors.white.withOpacity(0.5), // The "shine"
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.0), // End transparent
            ],
            // This makes the shine a narrow band
            stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
          ),
          period: duration,
          direction: ShimmerDirection.ltr,
          loop: 0,
          child: SvgPicture.asset(
            // This child acts as a MASK. The gradient above
            // will only be drawn inside the shape of this SVG.
            assetName,
            height: height,
          ),
        ),
      ],
    );
  }
}