import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/configs/global.config.dart';
import 'package:subtil_app/services/notifs_service.dart';
import 'package:subtil_app/providers/api_data_provider.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

final notifications = Notifications();

class HobbiesScreen extends StatefulWidget {
  final bool isRegistration;
  final List<String> selectedHobbies;
  final Function(List<String>) callback;

  const HobbiesScreen(
      {super.key,
      required this.isRegistration,
      required this.selectedHobbies,
      required this.callback});

  @override
  _HobbiesScreenState createState() => _HobbiesScreenState();
}

class _HobbiesScreenState extends State<HobbiesScreen> {
  late bool isRegistration;
  late List<String> selectedHobbies;
  late final Map<String, dynamic> hobbies;

  final TextEditingController _hobby1Controller = TextEditingController();
  final TextEditingController _hobby2Controller = TextEditingController();
  final TextEditingController _hobby3Controller = TextEditingController();

  final FocusNode _hobby1FocusNode = FocusNode();
  final FocusNode _hobby2FocusNode = FocusNode();
  final FocusNode _hobby3FocusNode = FocusNode();

  @override
  void initState() {
    isRegistration = widget.isRegistration;
    selectedHobbies = widget.selectedHobbies;

    hobbies = Provider.of<ApiProvider>(context, listen: false).apiResponse !=
            null
        ? Provider.of<ApiProvider>(context, listen: false).apiResponse!.hobbies
        : {};
    super.initState();
  }

  @override
  void dispose() {
    _hobby1Controller.dispose();
    _hobby2Controller.dispose();
    _hobby3Controller.dispose();
    _hobby1FocusNode.dispose();
    _hobby2FocusNode.dispose();
    _hobby3FocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: !isRegistration
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
      body: SingleChildScrollView(
          reverse: true,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HobbyField(
                  controller: _hobby1Controller..text = selectedHobbies[0],
                  focusNode: _hobby1FocusNode,
                  labelText: "Un truc que tu aimes",
                  hintText: 'Nature..',
                  hobbiesData: hobbies,
                  onSelected: (value) {
                    setState(() {
                      selectedHobbies[0] = value;
                    });
                    if (isRegistration) widget.callback(selectedHobbies);
                  },
                ),
                const SizedBox(height: 20),
                HobbyField(
                  controller: _hobby2Controller..text = selectedHobbies[1],
                  focusNode: _hobby2FocusNode,
                  labelText: "Un autre truc que tu aimes",
                  hintText: 'Sport..',
                  hobbiesData: hobbies,
                  onSelected: (value) {
                    setState(() {
                      selectedHobbies[1] = value;
                    });
                    if (isRegistration) widget.callback(selectedHobbies);
                  },
                ),
                const SizedBox(height: 20),
                HobbyField(
                  controller: _hobby3Controller..text = selectedHobbies[2],
                  focusNode: _hobby3FocusNode,
                  labelText: "Encore un petit dernier",
                  hintText: 'Peinture..',
                  hobbiesData: hobbies,
                  onSelected: (value) {
                    setState(() {
                      selectedHobbies[2] = value;
                    });
                    if (isRegistration) widget.callback(selectedHobbies);
                  },
                ),
                Padding(
                    padding: _hobby1FocusNode.hasFocus ||
                            _hobby2FocusNode.hasFocus ||
                            _hobby3FocusNode.hasFocus
                        ? EdgeInsets.only(
                            bottom: MediaQuery.sizeOf(context).height / 2)
                        : EdgeInsets.only(bottom: 0)),
              ],
            ),
          )),
      bottomNavigationBar: !isRegistration
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  widget.callback(selectedHobbies);
                },
                child: const Text('Valider'),
              ),
            )
          : null,
    );
  }
}

class HobbyField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final String hintText;
  final Map<String, dynamic> hobbiesData;
  final Function(String) onSelected;

  const HobbyField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    required this.hintText,
    required this.hobbiesData,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        onSelected(controller.text);
      }
    });

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            labelText,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
        TypeAheadField<String>(
          controller: controller,
          focusNode: focusNode,
          suggestionsCallback: (pattern) async {
            return hobbiesData.keys
                .where((item) =>
                    item.toLowerCase().contains(pattern.toLowerCase()))
                .toList();
          },
          builder: (context, suggestions, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: false,
              maxLength: hobbyNameMaxLength,
              maxLengthEnforcement:
                  MaxLengthEnforcement.truncateAfterCompositionEnds,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                labelText: hintText,
              ).copyWith(
                labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                border: Theme.of(context).inputDecorationTheme.border,
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
            );
          },
          itemBuilder: (context, value) {
            return ListTile(
              tileColor: Theme.of(context).colorScheme.onSurface,
              textColor: Theme.of(context).colorScheme.surface,
              title: Text("$value ${hobbiesData[value]["emoji"]}"),
            );
          },
          emptyBuilder: (context) {
            return ListTile(
              tileColor: Theme.of(context).colorScheme.onSurface,
              textColor: Theme.of(context).colorScheme.surface,
              title: const Text(
                  "Pas de ça en stock!\nMais tu peux mettre ton propre hobby"),
            );
          },
          onSelected: onSelected,
        ),
      ],
    );
  }
}
