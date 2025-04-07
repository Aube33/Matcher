import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/services/notifs_service.dart';
import 'package:subtil_app/providers/api_data_provider.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

final notifications = Notifications();

class AttractionsForm extends StatefulWidget {
  final bool isRegistration;
  final List<int> attractions;
  final Function(List<int>) callback;
  final bool isError;

  const AttractionsForm(
      {super.key,
      required this.isRegistration,
      required this.attractions,
      required this.callback,
      this.isError = false});

  @override
  _AttractionsFormState createState() => _AttractionsFormState();
}

class _AttractionsFormState extends State<AttractionsForm>
    with AutomaticKeepAliveClientMixin {
  late bool isRegistration;
  late List<int> attractions;
  late bool isError;

  late final Map<int, String> genders;

  @override
  void initState() {
    super.initState();
    isRegistration = widget.isRegistration;
    attractions = widget.attractions;
    isError = widget.isError;

    genders = Provider.of<ApiProvider>(context, listen: false).apiResponse !=
            null
        ? Provider.of<ApiProvider>(context, listen: false).apiResponse!.genders
        : {};
  }

  @override
  void didUpdateWidget(covariant AttractionsForm oldWidget) {
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
                        ? "... ${AppLocalizations.of(context)!.andYourAttractions}"
                        : AppLocalizations.of(context)!.whatsYourAttractions)
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
                  return CheckboxListTile(
                    title: Text(
                      genderValue,
                      style: TextStyle(
                          color: isError ? AppColors.red : AppColors.white),
                    ),
                    value: attractions.contains(genderKey),
                    side: isError
                        ? BorderSide(color: AppColors.red, width: 2)
                        : Theme.of(context).checkboxTheme.side,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          attractions
                              .removeWhere((element) => element == genderKey);
                          attractions.add(genderKey);
                        } else {
                          attractions
                              .removeWhere((element) => element == genderKey);
                        }
                      });

                      if (isRegistration) widget.callback(attractions);
                    },
                  );
                }),
            ],
          ),
          if (!isRegistration)
            ElevatedButton(
              onPressed: () {
                widget.callback(attractions);
              },
              child: Text(AppLocalizations.of(context)!.validate),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class AttractionsScreen extends StatefulWidget {
  final bool isRegistration;
  final List<int> attractions;
  final Function(List<int>) callback;

  const AttractionsScreen({
    super.key,
    required this.isRegistration,
    required this.attractions,
    required this.callback,
  });

  @override
  _AttractionsScreenState createState() => _AttractionsScreenState();
}

class _AttractionsScreenState extends State<AttractionsScreen> {
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
      body: AttractionsForm(
          isRegistration: widget.isRegistration,
          attractions: widget.attractions,
          callback: widget.callback),
    );
  }
}
