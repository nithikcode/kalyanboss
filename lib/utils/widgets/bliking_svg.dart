import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BlinkingSvg extends StatefulWidget {
  const BlinkingSvg({
    super.key,
    required this.assetName,
    this.height = 30.0,
    this.duration = const Duration(milliseconds: 700),
  });

  final String assetName;
  final double height;
  final Duration duration;

  @override
  BlinkingSvgState createState() => BlinkingSvgState();
}

class BlinkingSvgState extends State<BlinkingSvg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SvgPicture.asset(
        widget.assetName,
        height: widget.height,
        width: 30,
      ),
    );
  }
}