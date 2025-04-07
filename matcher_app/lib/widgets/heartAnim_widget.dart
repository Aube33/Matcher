import 'dart:math';

import 'package:flutter/material.dart';
import 'package:subtil_app/main.dart';

class HeartAnimWidget extends StatefulWidget {
  @override
  _HeartAnimScreenState createState() => _HeartAnimScreenState();
}

class _HeartAnimScreenState extends State<HeartAnimWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.7, curve: Curves.easeInOut),
    );

    double randomAngle = (_random.nextDouble() - 0.5) * 0.2;
    _rotationAnimation = Tween<double>(begin: 0.0, end: randomAngle).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: RotationTransition(
              turns: _rotationAnimation,
              child: const Icon(
                Icons.favorite,
                color: AppColors.pink,
                size: 200.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}