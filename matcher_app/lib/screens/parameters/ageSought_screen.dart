import 'package:flutter/material.dart';
import 'package:subtil_app/services/notifs_service.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

final notifications = Notifications();

class ageSoughtForm extends StatefulWidget {
  final bool isRegistration;
  final double minAgeSought;
  final double maxAgeSought;
  final Function(double, double) callback;

  const ageSoughtForm(
      {super.key,
      required this.isRegistration,
      required this.minAgeSought,
      required this.maxAgeSought,
      required this.callback});

  @override
  _ageSoughtFormState createState() => _ageSoughtFormState();
}

class _ageSoughtFormState extends State<ageSoughtForm> {
  late bool isRegistration;
  late double minAgeSought;
  late double maxAgeSought;
  late final Future<Map<String, dynamic>> genders;

  @override
  void initState() {
    isRegistration = widget.isRegistration;
    minAgeSought = widget.minAgeSought;
    maxAgeSought = widget.maxAgeSought;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: isRegistration
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.anAgePreference,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: RangeSlider(
                  values: RangeValues(minAgeSought, maxAgeSought),
                  min: 18,
                  max: 99,
                  divisions: 99,
                  labels: RangeLabels(
                    "${minAgeSought.round()} ${AppLocalizations.of(context)!.years}",
                    "${maxAgeSought.round()} ${AppLocalizations.of(context)!.years}",
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      minAgeSought = values.start;
                      maxAgeSought = values.end;
                    });

                    if (isRegistration)
                      widget.callback(minAgeSought, maxAgeSought);
                  },
                ),
              ),
            ],
          ),
          if (!isRegistration)
            ElevatedButton(
              onPressed: () {
                widget.callback(minAgeSought, maxAgeSought);
              },
              child: Text(AppLocalizations.of(context)!.validate),
            ),
        ],
      ),
    );
  }
}

class ageSoughtScreen extends StatefulWidget {
  final bool isRegistration;
  final double minAgeSought;
  final double maxAgeSought;
  final Function(double, double) callback;

  const ageSoughtScreen(
      {super.key,
      required this.isRegistration,
      required this.minAgeSought,
      required this.maxAgeSought,
      required this.callback});

  @override
  _ageSoughtScreenState createState() => _ageSoughtScreenState();
}

class _ageSoughtScreenState extends State<ageSoughtScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: !widget.isRegistration
            ? AppBar(
                title: Text(
                  AppLocalizations.of(context)!.edit,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_outlined),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
            : null,
        body: ageSoughtForm(
            isRegistration: widget.isRegistration,
            minAgeSought: widget.minAgeSought,
            maxAgeSought: widget.maxAgeSought,
            callback: widget.callback));
  }
}
