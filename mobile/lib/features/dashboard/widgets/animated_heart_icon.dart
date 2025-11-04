import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'dart:math' as math;

class AnimatedHeartIcon extends StatefulWidget {
  final double percentage;
  final double size;
  final Color fillColor;
  final Color strokeColor;

  const AnimatedHeartIcon({
    super.key,
    required this.percentage,
    this.size = 60.0,
    this.fillColor = Colors.white,
    this.strokeColor = Colors.blue,
  });

  @override
  State<AnimatedHeartIcon> createState() => _AnimatedHeartIconState();
}

class _AnimatedHeartIconState extends State<AnimatedHeartIcon>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.percentage / 100.0)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedHeartIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _animation =
          Tween<double>(
            begin: _animation.value,
            end: widget.percentage / 100.0,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Heart shape with liquid progress
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return LiquidCustomProgressIndicator(
                value: _animation.value,
                direction: Axis.vertical,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(widget.fillColor),
                shapePath: _createHeartPath(widget.size),
              );
            },
          ),
        ],
      ),
    );
  }

  Path _createHeartPath(double size) {
    // Use a mathematically proven heart path formula for perfect heart shape
    final path = Path();
    final centerX = size / 2;
    final centerY = size / 2;
    final scale = size * 0.4; // Scale factor for the heart

    // Heart path based on mathematical heart equation
    // This creates a perfect, recognizable heart shape
    final step = 0.1;

    // Start from the bottom point
    path.moveTo(centerX, centerY + scale * 0.3);

    // Create heart using parametric equations
    for (double i = 0; i <= 2 * 3.14159; i += step) {
      final x = 16 * scale * math.pow(math.sin(i), 3) / 24;
      final y =
          -scale *
          (13 * math.cos(i) -
              5 * math.cos(2 * i) -
              2 * math.cos(3 * i) -
              math.cos(4 * i)) /
          24;

      if (i == 0) {
        path.moveTo(centerX + x, centerY + y);
      } else {
        path.lineTo(centerX + x, centerY + y);
      }
    }

    path.close();
    return path;
  }
}
