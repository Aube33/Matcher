import 'package:flutter/material.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class HobbybubbleWidget extends StatelessWidget {
  final String name;
  final String? colorStr;
  final String? emoji;
  final bool? deletable;

  const HobbybubbleWidget({
    Key? key,
    required this.name,
    this.colorStr,
    this.emoji,
    this.deletable,
  }) : super(key: key);

  Color _getContrastingFontColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? AppColors.darkBlue
        : AppColors.white;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = colorStr != null
        ? Color(int.parse(colorStr!, radix: 16) + 0xFF000000)
        : Theme.of(context).colorScheme.onSurface;

    final effectiveFontColor = _getContrastingFontColor(backgroundColor);

    return IntrinsicWidth(
      child: Container(
        height: 28,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Center(
            child: Row(
              children: [
                Text(
                  '${name == "" ? AppLocalizations.of(context)!.addHobby : name}${emoji == null ? '' : ' $emoji'}',
                  style: TextStyle(
                    color: effectiveFontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (deletable == true && name != "")
                  Icon(
                    Icons.close,
                    color: effectiveFontColor,
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedHobbyBubble extends StatefulWidget {
  final String name;
  final String? colorStr;
  final String? emoji;
  final bool? deletable;
  final bool isEditable;
  final Duration delay;
  final VoidCallback onTap;

  const AnimatedHobbyBubble({
    Key? key,
    required this.name,
    this.colorStr,
    this.emoji,
    this.deletable,
    required this.isEditable,
    required this.delay,
    required this.onTap,
  }) : super(key: key);

  @override
  _AnimatedHobbyBubbleState createState() => _AnimatedHobbyBubbleState();
}

class _AnimatedHobbyBubbleState extends State<AnimatedHobbyBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEditable ? widget.onTap : null,
      child: AnimatedOpacity(
        opacity: widget.isEditable ? 1 : 0.5,
        duration: const Duration(milliseconds: 300),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: HobbybubbleWidget(
            name: widget.name,
            colorStr: widget.colorStr,
            emoji: widget.emoji,
            deletable: widget.deletable,
          ),
        ),
      ),
    );
  }
}
