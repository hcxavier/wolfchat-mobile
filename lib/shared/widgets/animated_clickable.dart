import 'dart:async';

import 'package:flutter/material.dart';

/// A reusable widget that adds a scale-down click animation to any child.
/// Wraps the child with a GestureDetector that animates scale from 1.0 to
/// [pressedScale] on tap down, and back to 1.0 on tap up/cancel.
class AnimatedClickable extends StatefulWidget {
  const AnimatedClickable({
    required this.onTap,
    required this.child,
    this.duration,
    this.pressedScale = 0.95,
    this.borderRadius,
    super.key,
  });

  final VoidCallback onTap;
  final Widget child;
  final Duration? duration;
  final double pressedScale;
  final BorderRadiusGeometry? borderRadius;

  @override
  State<AnimatedClickable> createState() => _AnimatedClickableState();
}

class _AnimatedClickableState extends State<AnimatedClickable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 100),
    );
    _animation = Tween<double>(begin: 1, end: widget.pressedScale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!_isPressed) {
      _isPressed = true;
      unawaited(_controller.forward());
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isPressed) {
      _isPressed = false;
      unawaited(_controller.reverse());
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      _isPressed = false;
      unawaited(_controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
