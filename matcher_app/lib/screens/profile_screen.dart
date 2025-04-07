import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:subtil_app/services/jwt_service.dart';
import 'package:subtil_app/services/notifs_service.dart';
import 'package:subtil_app/services/user_service.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/models/user_model.dart';
import 'package:subtil_app/providers/api_data_provider.dart';
import 'package:subtil_app/providers/user_provider.dart';
import 'package:subtil_app/screens/parameters/ageSought_screen.dart';
import 'package:subtil_app/screens/parameters/attractions_screen.dart';
import 'package:subtil_app/screens/parameters/gender_screen.dart';
import 'package:subtil_app/screens/parameters/hobbies_screen.dart';
import 'package:subtil_app/screens/parameters/images_screen.dart';
import 'package:subtil_app/screens/parameters/map_screen.dart';
import 'package:subtil_app/screens/parameters/name&age_screen.dart';
import 'package:subtil_app/screens/parameters/note_screen.dart';
import 'package:subtil_app/screens/parameters/relation_screen.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/widgets/hobbyBubble_widget.dart';
import 'package:subtil_app/widgets/imageSelector_widget.dart';
import 'package:subtil_app/widgets/paramButton_widget.dart';
import 'package:subtil_app/widgets/profileScroll_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

final notifications = Notifications();

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late User currentUser;

  final List<Widget> _hobbiesBubbles = [];
  final MapController _mapController = MapController();
  bool _isProfilePictureLoading = false;

  late final Map<String, dynamic> hobbiesData;

  //===== FUNCTIONS =====
  void getUserHobbiesData() {
    _hobbiesBubbles.clear();
    print(currentUser.hobbies);
    for (int i = 0; i < currentUser.hobbies.length; i++) {
      if (currentUser.hobbies[i] == "") {
        _hobbiesBubbles.add(HobbybubbleWidget(
          name: AppLocalizations.of(context)!.addHobby,
          colorStr: colorToHex(Theme.of(context).colorScheme.onSurface),
        ));
      } else {
        final hobbyData = hobbiesData[currentUser.hobbies[i]] ??
            {"color": null, "emoji": null};

        if (hobbyData != null) {
          _hobbiesBubbles.add(HobbybubbleWidget(
            name: currentUser.hobbies[i],
            colorStr: hobbyData["color"],
            emoji: hobbyData["emoji"],
          ));
        }
      }
    }

    if (mounted) {
      setState(() {
        _hobbiesBubbles;
      });
    }
  }

  //===== GLOBALS =====
  @override
  void initState() {
    currentUser = Provider.of<UserProvider>(context, listen: false).user!;
    hobbiesData =
        Provider.of<ApiProvider>(context, listen: false).apiResponse != null
            ? Provider.of<ApiProvider>(context, listen: false)
                .apiResponse!
                .hobbies
            : {};

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserHobbiesData();
    });

    super.initState();
  }

  @override
  void dispose() {
    print("Dispose called for ProfileScreen");
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final currentUser = userProvider.user!;
      final bool userHasProfilePicture =
          currentUser.images.containsKey("profile");

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'PROFIL',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (contextTemp) => ProfileScrollWidget(
                                currentUser.name,
                                true,
                                currentUser.uid,
                                currentUser.age,
                                currentUser.hobbies,
                                currentUser.distance,
                                currentUser.note,
                                arrowBack: true,
                                images: Future.value(currentUser.images),
                                isCurrentUser: true,
                              )));
                },
                icon: Icon(Icons.remove_red_eye_outlined))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext tempContext) {
                                        return ImageSelector(
                                            callback: (file) async {
                                              if (file == null) {
                                                await deleteProfileImage();
                                                if (mounted) {
                                                  setState(() {
                                                    currentUser.images
                                                        .remove("profile");
                                                  });
                                                }
                                                Provider.of<UserProvider>(
                                                        context,
                                                        listen: false)
                                                    .updateUser(currentUser);
                                              } else {
                                                if (mounted) {
                                                  setState(() {
                                                    _isProfilePictureLoading =
                                                        true;
                                                  });
                                                }
                                                int response =
                                                    await postProfileImage(
                                                        file);
                                                if (response == 200) {
                                                  showSnackBarGood(
                                                      context,
                                                      AppLocalizations.of(
                                                              context)!
                                                          .imageEdited);
                                                  if (mounted) {
                                                    setState(() {
                                                      currentUser.images[
                                                              "profile"] =
                                                          Image.file(file);
                                                    });
                                                  }
                                                  Provider.of<UserProvider>(
                                                          context,
                                                          listen: false)
                                                      .updateUser(currentUser);
                                                } else if (response == 413) {
                                                  showSnackBarBad(context,
                                                      content:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .imageTooBig);
                                                } else {
                                                  showSnackBarBad(context);
                                                }

                                                if (mounted) {
                                                  setState(() {
                                                    _isProfilePictureLoading =
                                                        false;
                                                  });
                                                }
                                              }
                                            },
                                            canDelete: userHasProfilePicture);
                                      },
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.onSurface,
                                    radius: 50,
                                    backgroundImage: userHasProfilePicture
                                        ? currentUser.images["profile"]!.image
                                        : null,
                                    child: _isProfilePictureLoading
                                        ? CircularProgressIndicator()
                                        : userHasProfilePicture
                                            ? null
                                            : Icon(Icons.add_a_photo_outlined,
                                                size: 30),
                                  )),
                              const SizedBox(
                                height: 15,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (contextTemp) =>
                                              NameAgeScreen(
                                                  name: currentUser.name,
                                                  birthDate:
                                                      currentUser.birthday,
                                                  callback: (newName,
                                                      newBirthday) async {
                                                    if (currentUser.name ==
                                                            newName &&
                                                        currentUser.birthday ==
                                                            newBirthday) {
                                                      Navigator.pop(
                                                          contextTemp);
                                                      return;
                                                    }

                                                    final String nameSave =
                                                        currentUser.name;
                                                    final DateTime
                                                        birthdaySave =
                                                        currentUser.birthday;

                                                    var updatedUser = {};

                                                    if (currentUser.name !=
                                                        newName) {
                                                      currentUser.name =
                                                          newName;
                                                      updatedUser["name"] =
                                                          newName;
                                                    }
                                                    if (currentUser.birthday !=
                                                        newBirthday) {
                                                      currentUser.birthday =
                                                          newBirthday;
                                                      currentUser.age =
                                                          calculateAge(
                                                              newBirthday);
                                                      updatedUser["birthday"] =
                                                          DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(
                                                                  newBirthday);
                                                    }

                                                    Provider.of<UserProvider>(
                                                            context,
                                                            listen: false)
                                                        .updateUser(
                                                            currentUser);

                                                    final edit = await editUser(
                                                        updatedUser);
                                                    if (edit != null) {
                                                      Navigator.pop(
                                                          contextTemp);
                                                      showSnackBarGood(
                                                          context,
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .editSuccess);
                                                      getUserHobbiesData();
                                                    } else {
                                                      currentUser.name =
                                                          nameSave;
                                                      currentUser.birthday =
                                                          birthdaySave;
                                                      currentUser.age =
                                                          calculateAge(
                                                              birthdaySave);
                                                      Provider.of<UserProvider>(
                                                              context,
                                                              listen: false)
                                                          .updateUser(
                                                              currentUser);
                                                      showSnackBarBad(context);
                                                    }
                                                  })));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        currentUser.name.toUpperCase(),
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.visible,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25),
                                      ),
                                      Text(
                                        '${currentUser.age.toString()} ${AppLocalizations.of(context)!.years}',
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.visible,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 210,
                      height: 230,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (contextTemp) => ImagesScreen(
                                      images: currentUser.images,
                                      callback: (newImages) async {
                                        currentUser.images = newImages;
                                        Provider.of<UserProvider>(context,
                                                listen: false)
                                            .updateUser(currentUser);
                                      })));
                        },
                        child: Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            for (var i = 0; i < 3; i++)
                              Positioned(
                                width: 130,
                                height: 210,
                                left: i * 35,
                                top: i * 8,
                                child: RotationTransition(
                                  turns: i == 0
                                      ? const AlwaysStoppedAnimation(-10 / 360)
                                      : i == 2
                                          ? const AlwaysStoppedAnimation(
                                              10 / 360)
                                          : const AlwaysStoppedAnimation(
                                              0 / 360),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: const Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: 130,
                                        width: 80,
                                        decoration: BoxDecoration(
                                            image: currentUser.images
                                                    .containsKey(i.toString())
                                                ? DecorationImage(
                                                    image: currentUser
                                                        .images[i.toString()]!
                                                        .image,
                                                    fit: BoxFit.cover,
                                                  )
                                                : null),
                                        child: !currentUser.images
                                                .containsKey(i.toString())
                                            ? Card(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            color:
                                                                AppColors
                                                                    .salmon,
                                                            width: 0.1),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                child: const Icon(
                                                  Icons.add_a_photo_outlined,
                                                  color: AppColors.salmon,
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (contextTemp) => NoteScreen(
                                  note: currentUser.note,
                                  callback: (newNote) async {
                                    if (currentUser.note == newNote) {
                                      Navigator.pop(contextTemp);
                                      return;
                                    }

                                    final String noteSave = currentUser.note;

                                    currentUser.note = newNote;
                                    Provider.of<UserProvider>(context,
                                            listen: false)
                                        .updateUser(currentUser);

                                    final updatedUser = {
                                      "bio": currentUser.note,
                                    };

                                    final edit = await editUser(updatedUser);
                                    if (edit != null) {
                                      Navigator.pop(contextTemp);
                                      showSnackBarGood(
                                          context,
                                          AppLocalizations.of(context)!
                                              .editSuccess);
                                      getUserHobbiesData();
                                    } else {
                                      currentUser.note = noteSave;
                                      Provider.of<UserProvider>(context,
                                              listen: false)
                                          .updateUser(currentUser);
                                      showSnackBarBad(context);
                                    }
                                  })));
                    },
                    child: currentUser.note == ""
                        ? Row(
                            children: [
                              Text(
                                "${AppLocalizations.of(context)!.addANote} ",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.visible,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: AppColors.grey,
                                        fontWeight: FontWeight.w400),
                              ),
                              Icon(
                                Icons.edit,
                                size: 18,
                                color: AppColors.grey,
                              ),
                            ],
                          )
                        : Text(
                            currentUser.note.length > 64
                                ? '${currentUser.note.substring(0, 64)}...'
                                : currentUser.note,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.visible,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (contextTemp) => HobbiesScreen(
                                isRegistration: false,
                                selectedHobbies: currentUser.hobbies,
                                callback: (newHobbies) async {
                                  if (listEquals(
                                      currentUser.hobbies, newHobbies)) {
                                    Navigator.pop(contextTemp);
                                    return;
                                  }

                                  currentUser.hobbies = List.from(newHobbies);
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .updateUser(currentUser);

                                  final updatedUser = {
                                    "hobbies": currentUser.hobbies,
                                  };

                                  final edit = await editUser(updatedUser);
                                  if (edit != null) {
                                    Navigator.pop(contextTemp);
                                    showSnackBarGood(
                                        context,
                                        AppLocalizations.of(context)!
                                            .editSuccess);
                                    getUserHobbiesData();
                                  } else {
                                    showSnackBarBad(context);
                                  }
                                })));
                  },
                  child: Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    alignment: WrapAlignment.center,
                    children: _hobbiesBubbles,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.location,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .copyWith(height: 3)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 150,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (contextTemp) => MapScreen(
                                        isRegistration: false,
                                        location: currentUser.location,
                                        searchDist: currentUser.searchDist,
                                        callback:
                                            (newLoc, newSearchDist) async {
                                          if (currentUser.location == newLoc &&
                                              currentUser.searchDist ==
                                                  newSearchDist) {
                                            Navigator.pop(contextTemp);
                                            return;
                                          }

                                          var updatedUser = {};
                                          if (currentUser.location != newLoc) {
                                            currentUser.location = newLoc;
                                            updatedUser["location"] = {
                                              "type": "Point",
                                              "coordinates": [
                                                currentUser.location.latitude,
                                                currentUser.location.longitude
                                              ]
                                            };
                                          }
                                          if (currentUser.searchDist !=
                                              newSearchDist) {
                                            currentUser.searchDist =
                                                newSearchDist;
                                            updatedUser["searchDist"] =
                                                currentUser.searchDist;
                                          }

                                          if (await editUser(updatedUser) !=
                                              null) {
                                            Navigator.pop(contextTemp);
                                            showSnackBarGood(
                                                context,
                                                AppLocalizations.of(context)!
                                                    .editSuccess);

                                            Provider.of<UserProvider>(
                                                    contextTemp,
                                                    listen: false)
                                                .updateUser(currentUser);
                                            if (mounted) {
                                              setState(() {
                                                currentUser.location;
                                                currentUser.searchDist;
                                              });
                                            }
                                            _mapController.move(
                                                currentUser.location,
                                                calculInitalZoomMap(
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                    currentUser.searchDist *
                                                        1000));
                                          } else {
                                            showSnackBarBad(context);
                                          }
                                        })));
                          },
                          child: IgnorePointer(
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                  initialCenter: currentUser.location,
                                  initialZoom: calculInitalZoomMap(
                                      MediaQuery.of(context).size.width,
                                      currentUser.searchDist * 1000),
                                  minZoom: 1,
                                  maxZoom: 20),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'fr.aube33.matcher',
                                ),
                                CircleLayer(circles: [
                                  CircleMarker(
                                    point: currentUser.location,
                                    radius: currentUser.searchDist * 1000,
                                    useRadiusInMeter: true,
                                    color: AppColors.pink.withOpacity(0.3),
                                    borderColor: Colors.red.withOpacity(0.7),
                                    borderStrokeWidth: 2,
                                  )
                                ]),
                                MarkerLayer(markers: [
                                  Marker(
                                    width: 40.0,
                                    height: 40.0,
                                    point: currentUser.location,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: AppColors.darkBlue,
                                    ),
                                  )
                                ]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),

                //Gender
                ParamButton(
                    text: AppLocalizations.of(context)!.gender,
                    callback: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (contextTemp) => GenderScreen(
                                  isRegistration: false,
                                  gender: currentUser.gender,
                                  callback: (newGender) async {
                                    if (currentUser.gender == newGender) {
                                      Navigator.pop(contextTemp);
                                      return;
                                    }

                                    currentUser.gender = newGender;
                                    final updatedUser = {
                                      "gender": currentUser.gender,
                                    };

                                    if (await editUser(updatedUser) != null) {
                                      Navigator.pop(contextTemp);
                                      showSnackBarGood(
                                          context,
                                          AppLocalizations.of(context)!
                                              .editSuccess);
                                      Provider.of<UserProvider>(context,
                                              listen: false)
                                          .updateUser(currentUser);
                                    } else {
                                      showSnackBarBad(context);
                                    }
                                  })));
                    }),

                const SizedBox(
                  height: 20,
                ),
                const Divider(),

                Column(
                  children: [
                    Text(AppLocalizations.of(context)!.filters,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .copyWith(height: 3)),
                    ParamButton(
                        text: AppLocalizations.of(context)!.ageSearch,
                        callback: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (contextTemp) => ageSoughtScreen(
                                      isRegistration: false,
                                      minAgeSought: currentUser.ageMinSought,
                                      maxAgeSought: currentUser.ageMaxSought,
                                      callback: (newAgeMin, newAgeMax) async {
                                        if (currentUser.ageMinSought ==
                                                newAgeMin &&
                                            currentUser.ageMaxSought ==
                                                newAgeMax) {
                                          Navigator.pop(contextTemp);
                                          return;
                                        }

                                        var updatedUser = {};

                                        if (currentUser.ageMinSought !=
                                            newAgeMin) {
                                          currentUser.ageMinSought = newAgeMin;
                                          updatedUser["ageMinSought"] =
                                              newAgeMin.round();
                                        }
                                        if (currentUser.ageMaxSought !=
                                            newAgeMax) {
                                          currentUser.ageMaxSought = newAgeMax;
                                          updatedUser["ageMaxSought"] =
                                              newAgeMax.round();
                                        }

                                        if (await editUser(updatedUser) !=
                                            null) {
                                          Navigator.pop(contextTemp);
                                          showSnackBarGood(
                                              context,
                                              AppLocalizations.of(context)!
                                                  .editSuccess);
                                          Provider.of<UserProvider>(context,
                                                  listen: false)
                                              .updateUser(currentUser);
                                        } else {
                                          showSnackBarBad(context);
                                        }
                                      })));
                        }),

                    const SizedBox(
                      height: 15,
                    ),

                    ParamButton(
                        text: AppLocalizations.of(context)!.attractions,
                        callback: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (contextTemp) => AttractionsScreen(
                                      isRegistration: false,
                                      attractions:
                                          List.from(currentUser.attractions),
                                      callback: (newAttractions) async {
                                        if (listEquals(currentUser.attractions,
                                            newAttractions)) {
                                          Navigator.pop(context);
                                          return;
                                        }

                                        currentUser.attractions =
                                            List.from(newAttractions);
                                        final updatedUser = {
                                          "attractions":
                                              currentUser.attractions,
                                        };

                                        if (await editUser(updatedUser) !=
                                            null) {
                                          Navigator.pop(contextTemp);
                                          showSnackBarGood(
                                              context,
                                              AppLocalizations.of(context)!
                                                  .editSuccess);
                                          Provider.of<UserProvider>(context,
                                                  listen: false)
                                              .updateUser(currentUser);
                                        } else {
                                          showSnackBarBad(context);
                                        }
                                      })));
                        }),

                    const SizedBox(
                      height: 15,
                    ),

                    //RelationShip
                    ParamButton(
                        text: AppLocalizations.of(context)!.relationship,
                        callback: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (contextTemp) => RelationScreen(
                                      isRegistration: false,
                                      relationShip: currentUser.relationShip,
                                      callback: (newRelationShip) async {
                                        if (currentUser.relationShip ==
                                            newRelationShip) {
                                          Navigator.pop(contextTemp);
                                          return;
                                        }

                                        currentUser.relationShip =
                                            newRelationShip;
                                        final updatedUser = {
                                          "relationShip":
                                              currentUser.relationShip,
                                        };

                                        if (await editUser(updatedUser) !=
                                            null) {
                                          Navigator.pop(contextTemp);
                                          showSnackBarGood(
                                              context,
                                              AppLocalizations.of(context)!
                                                  .editSuccess);
                                          Provider.of<UserProvider>(context,
                                                  listen: false)
                                              .updateUser(currentUser);
                                        } else {
                                          showSnackBarBad(context);
                                        }
                                      })));
                        }),

                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),

                // Account
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.account,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(height: 3)),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "${AppLocalizations.of(context)!.profilePaused} :",
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(height: 2)),
                          Switch(
                            value: currentUser.paused,
                            onChanged: (isOn) async {
                              print(isOn);
                              final updatedUser = {"paused": isOn};
                              currentUser.paused = isOn;
                              Provider.of<UserProvider>(context, listen: false)
                                  .updateUser(currentUser);

                              final edit = await editUser(updatedUser);
                              if (edit != null) {
                                if (isOn) {
                                  showSnackBarBad(context,
                                      content: AppLocalizations.of(context)!
                                          .profileNowPaused);
                                } else {
                                  showSnackBarGood(
                                      context,
                                      AppLocalizations.of(context)!
                                          .profileNowVisible);
                                }
                              } else {
                                currentUser.paused = !isOn;
                                Provider.of<UserProvider>(context,
                                        listen: false)
                                    .updateUser(currentUser);
                                showSnackBarBad(context);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/changeEmail',
                                arguments: {'email': currentUser.email});
                          },
                          child:
                              Text(AppLocalizations.of(context)!.changeEmail)),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgotPassword',
                                arguments: {'email': currentUser.email});
                          },
                          child: Text(
                              AppLocalizations.of(context)!.resetPassword)),
                      const SizedBox(height: 60),
                      ElevatedButton(
                        onPressed: () async {
                          if (await showConfirmationDialog(
                              context,
                              AppLocalizations.of(context)!.logoutPopupTitle,
                              AppLocalizations.of(context)!
                                  .logoutPopupContent)) {
                            if (mounted) {
                              logoutUser(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(AppLocalizations.of(context)!.logout,
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          if (await showConfirmationDialog(
                              context,
                              AppLocalizations.of(context)!
                                  .accountDeletePopupTitle,
                              AppLocalizations.of(context)!
                                  .accountDeletePopupContent)) {
                            if (await deleteUser()) {
                              deleteJWT();
                              sendToLoginScreen(context, arguments: {
                                'message': AppLocalizations.of(context)!
                                    .accountDeleteReloginToCancel
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                            AppLocalizations.of(context)!.deleteMyAccount,
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: AppLocalizations.of(context)!.legalNotice,
                              style: TextStyle(
                                color: AppColors.grey,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.grey,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  await launchUrl(matcherUrlMentionLegale);
                                },
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: AppLocalizations.of(context)!.tos,
                              style: TextStyle(
                                color: AppColors.grey,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.grey,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  await launchUrl(matcherUrlCGU);
                                },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
