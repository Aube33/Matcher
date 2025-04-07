import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subtil_app/configs/global.config.dart';
import 'package:subtil_app/services/notifs_service.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

final notifications = Notifications();

class NameAgeScreen extends StatefulWidget {
  final String name;
  final DateTime birthDate;
  final Function(String, DateTime) callback;

  const NameAgeScreen(
      {super.key,
      required this.callback,
      required this.name,
      required this.birthDate});

  @override
  _NameAgeScreenState createState() => _NameAgeScreenState();
}

class _NameAgeScreenState extends State<NameAgeScreen> {
  final _textFieldNameController = TextEditingController();
  late DateTime birthDate;

  @override
  void initState() {
    _textFieldNameController.text = widget.name;
    birthDate = widget.birthDate;

    super.initState();
  }

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.firstName,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    TextField(
                      controller: _textFieldNameController,
                      maxLength: nameMaxLength,
                      maxLines: 1,
                      keyboardType: TextInputType.name,
                      maxLengthEnforcement:
                          MaxLengthEnforcement.truncateAfterCompositionEnds,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.firstName,
                      ).copyWith(
                        labelStyle:
                            Theme.of(context).inputDecorationTheme.labelStyle,
                        border: Theme.of(context).inputDecorationTheme.border,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.birthDate,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall!
                          .copyWith(height: 0),
                    ),
                    SizedBox(
                      height: 300,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: birthDate,
                        maximumDate: DateTime.utc(DateTime.now().year - 18,
                            DateTime.now().month, DateTime.now().day),
                        minimumDate: DateTime(1900, 1),
                        dateOrder: DatePickerDateOrder.dmy,
                        onDateTimeChanged: (DateTime newDateTime) {
                          setState(() {
                            birthDate = newDateTime;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.callback(_textFieldNameController.text, birthDate);
              },
              child: Text(AppLocalizations.of(context)!.validate),
            ),
          ],
        ),
      ),
    );
  }
}
