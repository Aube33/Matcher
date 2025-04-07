import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subtil_app/configs/global.config.dart';
import 'package:subtil_app/services/notifs_service.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

final notifications = Notifications();

class NoteScreen extends StatefulWidget {
  final String note;
  final Function(String) callback;

  const NoteScreen({super.key, required this.callback, required this.note});

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final _textFieldController = TextEditingController();

  @override
  void initState() {
    _textFieldController.text = widget.note;

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  controller: _textFieldController,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.newNote),
                  style: const TextStyle(fontSize: 17.0),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: noteMaxLength,
                  maxLengthEnforcement:
                      MaxLengthEnforcement.truncateAfterCompositionEnds,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.callback(_textFieldController.text);
              },
              child: Text(AppLocalizations.of(context)!.validate),
            ),
          ],
        ),
      ),
    );
  }
}
