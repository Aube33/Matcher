import 'dart:math';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:subtil_app/custom_icons_icons.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:subtil_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/providers/user_provider.dart';
import 'package:subtil_app/widgets/shakeButton_widget.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class LikeCounterWidget extends StatefulWidget {
  const LikeCounterWidget({Key? key}) : super(key: key);

  @override
  _LikeCounterWidgetState createState() => _LikeCounterWidgetState();
}

class _LikeCounterWidgetState extends State<LikeCounterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final user = userProvider.user;
      return GestureDetector(
        onTap: () async {
          if (!user.hasClaimedDailyLikes) {
            await claimDailyLikes(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              (user != null && !user.hasClaimedDailyLikes)
                  ? AbsorbPointer(
                      absorbing: true,
                      child: SizedBox(
                        height: 20,
                        width: 90,
                        child: ShakeAnimationButton(
                          buttonText:
                              AppLocalizations.of(context)!.freeDailyLike,
                          fontSize: 13,
                          onPressed: () async {},
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 50,
                      child: AnimatedFlipCounter(
                        duration: Duration(milliseconds: 500),
                        value: user!.likes,
                        textStyle:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                          fontSize: 22,
                          height: 0,
                          shadows: [
                            Shadow(
                              color: Color.fromARGB(64, 0, 0, 0),
                              offset: Offset(0, 0),
                              blurRadius: 20.0,
                            ),
                          ],
                        ),
                      ),
                    ),
              Transform.rotate(
                  angle: (pi / 180) * 35,
                  child: Icon(
                    CustomIcons.heart,
                    color: AppColors.pink,
                    size: 25,
                  ))
            ],
          ),
        ),
      );
    });
  }
}
