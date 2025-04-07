import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/providers/api_data_provider.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class GenderForm extends StatefulWidget {
  final bool isRegistration;
  final int gender;
  final Function(int) callback;
  final bool isError;

  const GenderForm(
      {super.key,
      required this.isRegistration,
      required this.gender,
      required this.callback,
      this.isError = false});

  @override
  _GenderFormState createState() => _GenderFormState();
}

class _GenderFormState extends State<GenderForm>
    with AutomaticKeepAliveClientMixin {
  late bool isRegistration;
  late int gender;
  late bool isError;
  late final Map<int, String> genders;

  @override
  void initState() {
    isRegistration = widget.isRegistration;
    gender = widget.gender;
    isError = widget.isError;

    genders = Provider.of<ApiProvider>(context, listen: false).apiResponse !=
            null
        ? Provider.of<ApiProvider>(context, listen: false).apiResponse!.genders
        : {};
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GenderForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isError != widget.isError) {
      setState(() {
        isError = widget.isError;
      });
      updateKeepAlive();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  genders.isNotEmpty
                      ? (isRegistration
                          ? "${AppLocalizations.of(context)!.whatsYourGender}.."
                          : AppLocalizations.of(context)!.whatsYourGender)
                      : AppLocalizations.of(context)!.noGenderAvailable,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontSize: 16),
                ),
                if (genders.isNotEmpty)
                  ...genders.keys.map((genderKey) {
                    final genderValue =
                        "${genders[genderKey]![0].toUpperCase()}${genders[genderKey]!.substring(1).toLowerCase()}";

                    return RadioListTile(
                      title: Text(
                        genderValue,
                        style: TextStyle(
                            color: isError ? AppColors.red : AppColors.white),
                      ),
                      value: genderKey,
                      groupValue: gender,
                      fillColor: isError == true
                          ? WidgetStateColor.resolveWith(
                              (states) => AppColors.red)
                          : Theme.of(context).radioTheme.fillColor,
                      onChanged: (value) {
                        setState(() {
                          gender = genderKey;
                        });

                        if (isRegistration) widget.callback(gender);
                      },
                    );
                  }),
              ],
            ),
            if (!isRegistration)
              ElevatedButton(
                onPressed: () {
                  widget.callback(gender);
                },
                child: Text(AppLocalizations.of(context)!.validate),
              ),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class GenderScreen extends StatefulWidget {
  final bool isRegistration;
  final int gender;
  final Function(int) callback;

  const GenderScreen(
      {super.key,
      required this.isRegistration,
      required this.gender,
      required this.callback});

  @override
  _GenderScreenState createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.edit,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: GenderForm(
            isRegistration: widget.isRegistration,
            gender: widget.gender,
            callback: widget.callback));
  }
}
