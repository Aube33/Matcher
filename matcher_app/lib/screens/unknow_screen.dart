import 'package:flutter/material.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class UnknowScreen extends StatelessWidget {
  const UnknowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.pageNotFound,
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
