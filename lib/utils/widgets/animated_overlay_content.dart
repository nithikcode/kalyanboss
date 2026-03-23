import 'package:flutter/material.dart';

class AnimatedOverlayContent extends StatefulWidget {
  final Widget child;
  final VoidCallback onClose;
  final Duration duration;
  final Color backgroundColor;

  const AnimatedOverlayContent({
    super.key,
    required this.child,
    required this.onClose,
    this.duration = const Duration(milliseconds: 300),
    this.backgroundColor = const Color.fromRGBO(0, 0, 0, 0.9),
  });

  @override
  State<AnimatedOverlayContent> createState() => _AnimatedOverlayContentState();
}

class _AnimatedOverlayContentState extends State<AnimatedOverlayContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  /// Expose an optional reverse before closing
  Future<void> _reverseThenClose() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Material(
          color: widget.backgroundColor,
          child: widget.child,
        ),
      ),
    );
  }
}


