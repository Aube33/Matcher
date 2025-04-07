import 'dart:math';

import 'package:flutter/material.dart';
import 'package:subtil_app/custom_icons_icons.dart';
import 'package:subtil_app/main.dart';

class MatcherTitle extends StatelessWidget {
  const MatcherTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -50,
          right: 0,
          child: Transform.rotate(
            angle: (pi/180) * 10,
            child: Icon(
              CustomIcons.heart,
              color: AppColors.pink,
              size: 50,
            ),
          ),
        ),
        Text(
          'MATCHER',
          style: Theme.of(context).textTheme.displayLarge,
        )
      ]
    );
  }
}