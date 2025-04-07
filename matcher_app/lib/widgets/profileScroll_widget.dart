import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:subtil_app/configs/api.configs.dart';
import 'package:subtil_app/custom_icons_icons.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:subtil_app/services/jwt_service.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/providers/api_data_provider.dart';
import 'package:subtil_app/providers/user_provider.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/widgets/heartAnim_widget.dart';
import 'package:subtil_app/widgets/hobbyBubble_widget.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class ProfileScrollWidget extends StatefulWidget {
  final String name;
  final bool liked;
  final String uid;
  final int age;
  final List<dynamic> hobbies;
  final int distance;
  final String bio;

  final Future<Map<String, Image>>? images;
  final bool? arrowBack;
  final Function? callback;
  final bool? isCurrentUser;

  const ProfileScrollWidget(this.name, this.liked, this.uid, this.age,
      this.hobbies, this.distance, this.bio,
      {this.images,
      this.arrowBack,
      this.callback,
      this.isCurrentUser,
      Key? key})
      : super(key: key);

  @override
  _ProfileScrollWidgetState createState() => _ProfileScrollWidgetState(
      name: this.name,
      liked: this.liked,
      uid: this.uid,
      age: this.age,
      hobbies: this.hobbies,
      distance: this.distance,
      bio: this.bio,
      images: this.images,
      arrowBack: this.arrowBack,
      callback: this.callback,
      isCurrentUser: this.isCurrentUser ?? false);
}

class _ProfileScrollWidgetState extends State<ProfileScrollWidget>
    with TickerProviderStateMixin {
  String name;
  bool liked = false;
  String uid;
  int age;
  List<dynamic> hobbies;
  int distance;
  String bio;

  Future<Map<String, Image>>? images;
  bool? arrowBack;
  Function? callback;
  bool isCurrentUser;

  _ProfileScrollWidgetState({
    required this.name,
    required this.liked,
    required this.uid,
    required this.age,
    required this.hobbies,
    required this.distance,
    required this.bio,
    this.images,
    this.arrowBack,
    this.callback,
    required this.isCurrentUser,
  });

  final List<HobbybubbleWidget> _hobbiesBubbles = [];
  bool _showHeartAnimation = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _totalPage = 0;
  bool _isHolding = false;

  Future<bool> _like() async {
    final jwt = await getJWT();
    String apiUrl = '$API_URL/likes/send/$uid';
    try {
      final http.Response response = await client.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('like successfully sent');

        return true;
      } else {
        print(response.body);
        print('like failed');
        return false;
      }
    } catch (e) {
      print('Error: $e');
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> hobbiesData =
        Provider.of<ApiProvider>(context, listen: false).apiResponse != null
            ? Provider.of<ApiProvider>(context, listen: false)
                .apiResponse!
                .hobbies
            : {};
    for (int i = 0; i < hobbies.length; i++) {
      if (hobbies[i] == "" || hobbies[i] == null) continue;

      final Map<String, dynamic> hobbyData =
          hobbiesData[hobbies[i]] ?? {"color": null, "emoji": null};

      _hobbiesBubbles.add(HobbybubbleWidget(
        name: hobbies[i],
        colorStr: hobbyData["color"],
        emoji: hobbyData["emoji"],
      ));
    }

    if (mounted) {
      setState(() {
        _hobbiesBubbles;
      });
    }

    images?.then((userImages) {
      if (mounted) {
        setState(() {
          _totalPage = userImages.containsKey("profile")
              ? userImages.length - 1
              : userImages.length;
          if (bio != "") {
            _totalPage++;
          }
        });
      }
    });

    _pageController.addListener(() {
      int page = _pageController.page!.round();
      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: arrowBack == null
              ? null
              : AppBar(
                  title: Row(
                    children: [
                      FutureBuilder(
                        future: images,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.containsKey("profile")) {
                              return Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.onSurface,
                                    radius: 20,
                                    backgroundImage:
                                        snapshot.data!["profile"]!.image,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  )
                                ],
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      Text(
                        name.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  fontSize: 20,
                                ),
                      ),
                    ],
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_outlined),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  centerTitle: false,
                  actions: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: () async {
                          if (isCurrentUser) {
                            return;
                          }
                          if (await showConfirmationDialog(
                              context,
                              AppLocalizations.of(context)!.deleteThisLike,
                              AppLocalizations.of(context)!.confirmAction)) {
                            Navigator.pushReplacementNamed(context, "/inbox");
                            await deleteLikeReceived(uid);
                          }
                        },
                        child: isCurrentUser
                            ? const SizedBox.shrink()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Icon(
                                  Icons.delete,
                                  color: isCurrentUser
                                      ? AppColors.grey
                                      : AppColors.white,
                                )),
                      ),
                    )
                  ],
                ),
          body: Consumer<UserProvider>(builder: (context, userProvider, child) {
            final currentUser = userProvider.user!;
            return GestureDetector(
              onDoubleTap: () async {
                if (!currentUser.hasClaimedDailyLikes) {
                  if (mounted) {
                    showClaimLikesDialog(context);
                  }
                } else if (currentUser.likes <= 0) {
                  if (mounted) {
                    showNoMoreLikesDialog(context);
                  }
                } else if (!liked && !_showHeartAnimation) {
                  final likeSuccess = await _like();

                  if (mounted) {
                    setState(() {
                      _showHeartAnimation = true;
                    });

                    await Future.delayed(const Duration(seconds: 1));

                    setState(() {
                      _showHeartAnimation = false;
                    });

                    if (likeSuccess) {
                      currentUser.likes--;
                      Provider.of<UserProvider>(context, listen: false)
                          .updateUser(currentUser);

                      setState(() {
                        liked = true;
                      });

                      if (callback != null) {
                        callback!();
                      }
                    }
                  }
                }
              },
              onLongPressStart: (details) {
                setState(() {
                  _isHolding = true;
                });
              },
              onLongPressEnd: (details) {
                setState(() {
                  _isHolding = false;
                });
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<Map<String, Image>>(
                    future: images ??
                        fetchImages(uid,
                            withImages: true, withProfilePicture: true),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                        //return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                            decoration:
                                BoxDecoration(color: AppColors.darkBlue),
                            child: const Center(
                              child: Icon(Icons.hide_image_outlined),
                            ));
                      } else {
                        final Map<String, Image> userImages = snapshot.data!;
                        return Positioned.fill(
                          child: PageView(
                            controller: _pageController,
                            children: [
                              for (int i = 0; i < 3; i++)
                                if (userImages.containsKey(i.toString()))
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        image: DecorationImage(
                                          image:
                                              userImages[i.toString()]!.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                              if (bio != "")
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${AppLocalizations.of(context)!.note} :",
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          bio,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  AnimatedOpacity(
                    opacity: _isHolding ? 0 : 1,
                    duration: Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 15, left: 15),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            _totalPage,
                                            (index) => pageIndicator(
                                                index == _currentPage),
                                          ),
                                        ),
                                      ),
                                      if (liked)
                                        Transform.rotate(
                                          angle: -pi / 10,
                                          child: Icon(
                                            CustomIcons.heart,
                                            color: AppColors.pink,
                                            size: 35,
                                          ),
                                        ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 7),
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              WidgetSpan(
                                                alignment: PlaceholderAlignment
                                                    .baseline,
                                                baseline:
                                                    TextBaseline.alphabetic,
                                                child: Text(
                                                  name.toUpperCase(),
                                                  textAlign: TextAlign.left,
                                                  overflow:
                                                      TextOverflow.visible,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayMedium!
                                                      .copyWith(
                                                    fontSize: 33,
                                                    color: AppColors.white,
                                                    shadows: [
                                                      Shadow(
                                                        color: Color.fromARGB(
                                                            64, 0, 0, 0),
                                                        offset: Offset(0, 0),
                                                        blurRadius: 20.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const WidgetSpan(
                                                  child: SizedBox(width: 10)),
                                              WidgetSpan(
                                                alignment: PlaceholderAlignment
                                                    .baseline,
                                                baseline:
                                                    TextBaseline.alphabetic,
                                                child: Text(
                                                  '${age.toString()} ${AppLocalizations.of(context)!.years}',
                                                  style: const TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    shadows: [
                                                      Shadow(
                                                        color: Color.fromARGB(
                                                            128, 0, 0, 0),
                                                        offset: Offset(0, 0),
                                                        blurRadius: 10.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(children: [
                                        Container(
                                            height: 28,
                                            decoration: const BoxDecoration(
                                                color: AppColors.grey,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: Center(
                                                    child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      color: Colors.white,
                                                      size: 15,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      '$distance km',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15),
                                                    ),
                                                  ],
                                                )))),
                                      ]),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        runSpacing: 10,
                                        spacing: 10,
                                        alignment: WrapAlignment.start,
                                        children: _hobbiesBubbles,
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                        )
                      ],
                    ),
                  ),
                  if (_showHeartAnimation)
                    Positioned.fill(
                      child: HeartAnimWidget(),
                    ),
                ],
              ),
            );
          })),
    );
  }
}
