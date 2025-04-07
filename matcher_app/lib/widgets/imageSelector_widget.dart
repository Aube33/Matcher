import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class ImageSelector extends StatefulWidget {
  final Function(File?) callback;
  final bool canDelete;

  const ImageSelector(
      {super.key, required this.callback, required this.canDelete});

  @override
  _ImageSelectorState createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  Future<File?> _getImageFromSource(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        final image = File(pickedFile.path);
        widget.callback(image);
      } else {
        print('Aucune image sélectionnée.');
      }
    } on Exception catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectImage),
      content: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              GestureDetector(
                child: Row(
                  children: [
                    const Icon(Icons.photo_library),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.gallery),
                  ],
                ),
                onTap: () {
                  _getImageFromSource(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                child: Row(
                  children: [
                    const Icon(Icons.photo_camera_outlined),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.takePicture),
                  ],
                ),
                onTap: () {
                  _getImageFromSource(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              if (widget.canDelete) const SizedBox(height: 30),
              if (widget.canDelete)
                GestureDetector(
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.delete,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  onTap: () {
                    widget.callback(null);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
