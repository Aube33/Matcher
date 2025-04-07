import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:subtil_app/configs/global.config.dart';
import 'package:subtil_app/custom_icons_icons.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:subtil_app/widgets/shakeButton_widget.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

String truncateString(String inputString) {
  if (inputString.length <= lastMessagePreviewLength) {
    return inputString;
  } else {
    return '${inputString.substring(0, lastMessagePreviewLength)}...';
  }
}

String formatDate(String dateString) {
  initializeDateFormatting('fr');
  DateTime date = DateTime.parse(dateString);
  return DateFormat('dd MMM yy', 'fr').format(date);
}

String colorToHex(Color color) {
  return color.value.toRadixString(16).toUpperCase().padLeft(8, '0');
}

bool isValidEmail(String email) {
  const emailPattern =
      r"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
  final regExp = RegExp(emailPattern);
  return regExp.hasMatch(email);
}

int calculateAge(DateTime birthday) {
  final today = DateTime.now();
  var age = today.year - birthday.year;
  final monthDiff = today.month - birthday.month;
  if (monthDiff < 0 || (monthDiff == 0 && today.day < birthday.day)) {
    age -= 1;
  }
  return age;
}

const double _snackBarMargin = 10.0;
void showSnackBarGood(BuildContext context, String text) {
  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "✓ $text",
        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500),
      ),
      backgroundColor: AppColors.green,
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.down,
      margin: const EdgeInsets.only(
        top: _snackBarMargin,
        left: _snackBarMargin,
        right: _snackBarMargin,
      ),
    ),
  );
}

void showSnackBarBad(context, {String? content}) {
  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "⚠️ ${content ?? AppLocalizations.of(context)!.errorOccured}",
        style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w500),
      ),
      backgroundColor: AppColors.red,
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.down,
      margin: const EdgeInsets.only(
        top: _snackBarMargin,
        left: _snackBarMargin,
        right: _snackBarMargin,
      ),
    ),
  );
}

// Slider location
double minSliderValue = 0;
double maxSliderValue = 1;
double minExpValue = 1;
double maxExpValue = 500;

double toExponential(double linearValue) {
  return minExpValue * pow((maxExpValue / minExpValue), linearValue);
}

double fromExponential(double expValue) {
  return log(expValue / minExpValue) / log(maxExpValue / minExpValue);
}

double calculInitalZoomMap(double mapWidth, double radiusInMeters) {
  const double equatorLength = 40075017;
  double initialResolution = equatorLength / mapWidth;

  double resolution = radiusInMeters * 2 / mapWidth + 100;

  double zoomLevel = log(initialResolution / resolution) / log(2);

  return zoomLevel;
}

Future<bool> showConfirmationDialog(
    BuildContext context, String title, String content,
    {String? btnTxt}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              btnTxt ?? AppLocalizations.of(context)!.confirm,
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

Future<void> showClaimLikesDialog(BuildContext context) async {
  final dialogContext = context;

  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.pinkLight,
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.dailyLikes,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: AppColors.pink,
                ),
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+50',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: AppColors.salmon, fontSize: 35, height: 0),
                  ),
                  Icon(
                    CustomIcons.heart,
                    color: AppColors.salmon,
                    size: 35,
                  )
                ],
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          ShakeAnimationButton(
            buttonText: AppLocalizations.of(context)!.claim,
            onPressed: () async {
              await claimDailyLikes(dialogContext);
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showNoMoreLikesDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.pinkLight,
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.oops,
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: AppColors.pink),
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(AppLocalizations.of(context)!.notEnoughLikes,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(height: 0, color: AppColors.salmon)),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pink,
            ),
            child: Text(
              AppLocalizations.of(context)!.okay,
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontSize: 22,
                  ),
            ),
          ),
        ],
      );
    },
  );
}
