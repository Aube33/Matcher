import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:subtil_app/services/notifs_service.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/providers/user_provider.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/widgets/imageSelector_widget.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

final notifications = Notifications();

class ImagesScreen extends StatefulWidget {
  final Map<String, Image> images;
  final Function(Map<String, Image>) callback;

  const ImagesScreen({super.key, required this.callback, required this.images});

  @override
  _ImagesScreenState createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  Map<String, Image> images = {};

  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPage = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    images = widget.images;

    _pageController.addListener(() {
      int page = _pageController.page!.round();
      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  void _onImageSelected(File? image, int index) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    if (image == null) {
      await deleteImage(index);
      if (mounted) {
        setState(() {
          _isLoading = false;
          images.remove(index.toString());
        });
      }
    } else {
      int response = await postImages([index], [image]);
      if (response == 200) {
        showSnackBarGood(context, AppLocalizations.of(context)!.imageEdited);
        if (mounted) {
          setState(() {
            images[index.toString()] = Image.file(image);
          });
        }
      } else if (response == 413) {
        showSnackBarBad(context,
            content: AppLocalizations.of(context)!.imageTooBig);
      } else {
        showSnackBarBad(context);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    widget.callback(images);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(images);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.pictures,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _totalPage,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 40.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Consumer<UserProvider>(
                                    builder: (context, userProvider, child) {
                                      return ImageSelector(
                                        callback: (file) {
                                          _onImageSelected(file, index);
                                        },
                                        canDelete: images
                                            .containsKey(index.toString()),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: !images.containsKey(index.toString())
                                ? Container(
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: AppColors.white),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _isLoading
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            : Column(
                                                children: [
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .addPicture,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall!
                                                        .copyWith(),
                                                  ),
                                                  const Icon(
                                                      Icons
                                                          .add_a_photo_outlined,
                                                      size: 30),
                                                ],
                                              ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: images[index.toString()]!.image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        // Edit Icon
                        if (images.containsKey(index.toString()))
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Icon(
                              Icons.edit,
                              color: AppColors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalPage,
                (index) => pageIndicator(index == _currentPage),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
