import 'package:flutter/material.dart';
import 'package:subtil_app/main.dart';

class ShakeAnimationButton extends StatefulWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final double? fontSize;

  const ShakeAnimationButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.fontSize,
  }) : super(key: key);

  @override
  _ShakeAnimationButtonState createState() => _ShakeAnimationButtonState();
}

class _ShakeAnimationButtonState extends State<ShakeAnimationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.1).chain(
      CurveTween(curve: Curves.elasticIn),
    ).animate(_controller);

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pink,
            ),
            onPressed: widget.onPressed,
            child: Text(
              widget.buttonText,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontSize: widget.fontSize ?? 22,
              ),
            ),
          ),
        );
      },
    );
  }
}
