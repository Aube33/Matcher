import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/providers/api_data_provider.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class RelationForm extends StatefulWidget {
  final bool isRegistration;
  final int relationShip;
  final Function(int) callback;
  final bool isError;

  const RelationForm(
      {super.key,
      required this.isRegistration,
      required this.relationShip,
      required this.callback,
      this.isError = false});

  @override
  _RelationFormState createState() => _RelationFormState();
}

class _RelationFormState extends State<RelationForm>
    with AutomaticKeepAliveClientMixin {
  late bool isRegistration;
  late int relationShip;
  late final Map<int, String> relationShips;
  late bool isError;

  @override
  void initState() {
    isRegistration = widget.isRegistration;
    relationShip = widget.relationShip;
    isError = widget.isError;

    relationShips =
        Provider.of<ApiProvider>(context, listen: false).apiResponse != null
            ? Provider.of<ApiProvider>(context, listen: false)
                .apiResponse!
                .relationShip
            : {};
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RelationForm oldWidget) {
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
                  relationShips.isNotEmpty
                      ? (isRegistration
                          ? "${AppLocalizations.of(context)!.andOtherwise}...\n ${AppLocalizations.of(context)!.whyAreYouHere}"
                          : AppLocalizations.of(context)!.relationshipSearched)
                      : AppLocalizations.of(context)!.noRelationshipAvailable,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontSize: isRegistration ? 20 : 16, height: 2),
                ),
                if (relationShips.isNotEmpty)
                  ...relationShips.keys.map((relationKey) {
                    final genderValue =
                        "${relationShips[relationKey]![0].toUpperCase()}${relationShips[relationKey]!.substring(1).toLowerCase()}";

                    return RadioListTile(
                      title: Text(
                        genderValue,
                        style: TextStyle(
                            color: isError ? AppColors.red : AppColors.white),
                      ),
                      value: relationKey,
                      groupValue: relationShip,
                      fillColor: isError == true
                          ? WidgetStateColor.resolveWith(
                              (states) => AppColors.red)
                          : Theme.of(context).radioTheme.fillColor,
                      onChanged: (value) {
                        setState(() {
                          relationShip = relationKey;
                        });

                        if (isRegistration) widget.callback(relationShip);
                      },
                    );
                  }),
              ],
            ),
            if (!isRegistration)
              ElevatedButton(
                onPressed: () {
                  widget.callback(relationShip);
                },
                child: Text(AppLocalizations.of(context)!.validate),
              ),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class RelationScreen extends StatefulWidget {
  final bool isRegistration;
  final int relationShip;
  final Function(int) callback;

  const RelationScreen(
      {super.key,
      required this.isRegistration,
      required this.relationShip,
      required this.callback});

  @override
  _RelationScreenState createState() => _RelationScreenState();
}

class _RelationScreenState extends State<RelationScreen> {
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
        body: RelationForm(
            isRegistration: widget.isRegistration,
            relationShip: widget.relationShip,
            callback: widget.callback));
  }
}
