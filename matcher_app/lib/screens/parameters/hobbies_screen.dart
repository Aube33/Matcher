import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/configs/global.config.dart';
import 'package:subtil_app/services/notifs_service.dart';
import 'package:subtil_app/providers/api_data_provider.dart';
import 'package:subtil_app/widgets/hobbyBubble_widget.dart';
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

class _HobbiesScreenState extends State<HobbiesScreen>
    with AutomaticKeepAliveClientMixin {
  late bool isRegistration;
  late List<String> initialSelectedHobbies;
  late final Map<String, dynamic> hobbies;

  final TextEditingController _hobbiesSearchController =
      TextEditingController();
  late Map<String, dynamic> filteredHobbies;

  final _random = Random();
  int initialMaxhobbies = 3;

  late List<String> selectedHobbies;
  late List<Map<String, dynamic>> selectedHobbiesData;

  List<Map<String, dynamic>> getSelectedHobbiesData(
      List<String> selectedHobbies) {
    return selectedHobbies
        //.where((hobby) => hobby.isNotEmpty)
        .map((hobby) {
      return {
        "name": hobby,
        "data": hobbies[hobby] ?? {"color": null, "emoji": null},
      };
    }).toList();
  }

  void _filterHobbies(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredHobbies = Map.of(hobbies);
      } else {
        filteredHobbies = hobbies.entries
            .where((entry) =>
                entry.key.toLowerCase().contains(query.toLowerCase()))
            .fold({}, (map, entry) {
          map[entry.key] = entry.value;
          return map;
        });
        filteredHobbies[query] = {"color": null, "emoji": null};
      }
    });
  }

  @override
  void initState() {
    isRegistration = widget.isRegistration;
    initialSelectedHobbies = widget.selectedHobbies;

    selectedHobbies = List.from(widget.selectedHobbies);
    //selectedHobbies.removeWhere((e) => e=="");

    hobbies = Provider.of<ApiProvider>(context, listen: false).apiResponse !=
            null
        ? Provider.of<ApiProvider>(context, listen: false).apiResponse!.hobbies
        : {};

    filteredHobbies = Map.of(hobbies);
    selectedHobbiesData = getSelectedHobbiesData(selectedHobbies);

    super.initState();
  }

  @override
  void dispose() {
    _hobbiesSearchController.dispose();
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
          child: Padding(
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 20, bottom: isRegistration ? 100 : 0),
        child: Column(
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ...selectedHobbiesData.map((hobby) {
                  return GestureDetector(
                    onTap: () {
                      if (hobby["name"] == "") {
                        return;
                      }
                      setState(() {
                        selectedHobbies[
                            selectedHobbies.indexOf(hobby["name"])] = "";
                        selectedHobbiesData =
                            getSelectedHobbiesData(selectedHobbies);
                      });
                      if (isRegistration) widget.callback(selectedHobbies);
                    },
                    child: HobbybubbleWidget(
                      name: hobby["name"],
                      colorStr: hobby["data"]["color"],
                      emoji: hobby["data"]["emoji"],
                      deletable: true,
                    ),
                  );
                }),

                /* ...List.generate(
                    initialMaxhobbies - selectedHobbies.length,
                    (_) => HobbybubbleWidget(
                      name: "",
                    ),
                  ), */
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _hobbiesSearchController,
              maxLength: hobbyNameMaxLength,
              maxLines: 1,
              keyboardType: TextInputType.name,
              maxLengthEnforcement:
                  MaxLengthEnforcement.truncateAfterCompositionEnds,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText:
                    "${hobbies.keys.toList()[_random.nextInt(hobbies.keys.toList().length)]}..",
              ).copyWith(
                labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                border: Theme.of(context).inputDecorationTheme.border,
              ),
              onChanged: _filterHobbies,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              runSpacing: 8.0,
              children: filteredHobbies.entries.map((entry) {
                final hobbyName = entry.key;
                final hobbyData = entry.value;

                final hobbiesWithoutEmpty = selectedHobbiesData
                    .where((hobby) => hobby["name"].isNotEmpty)
                    .toList();

                print(hobbiesWithoutEmpty);
                final isEditable =
                    hobbiesWithoutEmpty.length < selectedHobbiesData.length;

                final index = filteredHobbies.keys.toList().indexOf(hobbyName);
                final delay = Duration(milliseconds: index % 6 * 180);

                return AnimatedHobbyBubble(
                  name: hobbyName,
                  colorStr: hobbyData["color"],
                  emoji: hobbyData["emoji"],
                  isEditable: isEditable,
                  delay: delay,
                  deletable: false,
                  onTap: () {
                    if (isEditable) {
                      setState(() {
                        for (int i = 0; i < selectedHobbies.length; i++) {
                          if (selectedHobbies[i] == "") {
                            selectedHobbies[i] = hobbyName;
                            break;
                          }
                        }
                        selectedHobbiesData =
                            getSelectedHobbiesData(selectedHobbies);
                      });
                      if (isRegistration) widget.callback(selectedHobbies);
                    }
                  },
                );
              }).toList(),
            )
          ],
        ),
      )),
      bottomNavigationBar: !isRegistration
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  initialSelectedHobbies = List.from(selectedHobbies);

                  while (initialSelectedHobbies.length < initialMaxhobbies) {
                    initialSelectedHobbies.add("");
                  }

                  widget.callback(initialSelectedHobbies);
                },
                child: Text(AppLocalizations.of(context)!.validate),
              ),
            )
          : null,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
