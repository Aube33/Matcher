import 'dart:convert';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/models/user_model.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/providers/user_provider.dart';
import 'package:subtil_app/screens/message_screen.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/widgets/likesCounter_widget.dart';
import 'package:subtil_app/widgets/profileScroll_widget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:subtil_app/configs/api.configs.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:subtil_app/services/jwt_service.dart';
import 'package:subtil_app/services/notifs_service.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

final notifications = Notifications();

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  _LikesScreenState createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  ValueNotifier<Map<String, dynamic>> usersLikesData = ValueNotifier({});
  ValueNotifier<Map<String, dynamic>> usersChatsData = ValueNotifier({});

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  void _removeChat(String chatID) {
    usersChatsData.value.remove(chatID);
  }

  Future<void> _getLikeReceived() async {
    const String apiUrl = '$API_URL/likes/reception/';
    final jwt = await getJWT();
    try {
      final http.Response response = await client.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          Map<String, dynamic> resData = json.decode(response.body);
          Map<String, dynamic> usersData = {};

          List<Future> futures = [];
          resData.forEach(
            (uid, likeData) => futures.add(getUserData(uid).then((data) {
              if (data != null) {
                data["date"] = likeData;
                usersData[uid] = data;
              }
            })),
          );
          await Future.wait(futures);
          usersLikesData.value = usersData;
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this)
          ..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: -pi / 6,
      end: pi / 6,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOutCubicEmphasized));

    _getLikeReceived();

    getUserChats(context)?.then(
      (value) {
        usersChatsData.value = value;
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Map<String, dynamic> messageData = message.data;
      if (mounted) {
        if (messageData["type"] == "like") {
          if (messageData["userID"] != null) {
            getUserData(messageData["userID"]).then((data) async {
              if (data != null) {
                final DateTime now = DateTime.now();
                final formattedDate =
                    DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').format(now);
                data["date"] = formattedDate;

                usersLikesData.value = {
                  ...usersLikesData.value,
                  messageData["userID"]: data,
                };
              }
            });
          }
        } else if (messageData["type"] == "match") {
          getUserChats(context)?.then(
            (value) {
              usersChatsData.value = value;
            },
          );
        } else if (messageData["type"] == "deleteMatch") {
          if (messageData["chatID"] != null &&
              usersChatsData.value.containsKey(messageData["chatID"])) {
            _removeChat(messageData["chatID"]);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    print("Dispose called for LikesScreen");
    _animationController.dispose();
    usersLikesData.dispose();
    usersChatsData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'MATCHER',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        centerTitle: false,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        actions: [
          LikeCounterWidget(),
        ],
      ),
      body: Stack(children: [
        backGround(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 15, top: 0),
                    child: Text(
                      AppLocalizations.of(context)!.receivedLikes,
                      textAlign: TextAlign.left,
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall!
                          .copyWith(fontSize: 20, height: 0),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: usersLikesData,
                  builder: (BuildContext context,
                      Map<String, dynamic> likesData, Widget? child) {
                    if (likesData.isEmpty) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)!.emptyLikesReception,
                          style: TextStyle(color: AppColors.grey),
                        ),
                      );
                    }

                    List<MapEntry<String, dynamic>> sortedEntries =
                        likesData.entries.toList()
                          ..sort((a, b) => DateTime.parse(b.value["date"])
                              .compareTo(DateTime.parse(a.value["date"])));

                    likesData = Map.fromEntries(sortedEntries);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: likesData.length,
                            itemBuilder: (BuildContext context, int index) {
                              String uid = likesData.keys.elementAt(index);
                              String name = likesData[uid]["name"];
                              List<dynamic> hobbies = likesData[uid]["hobbies"];
                              int age = likesData[uid]["age"];
                              String date = likesData[uid]["date"];
                              String bio = likesData[uid]["bio"];
                              int distance = likesData[uid]["distance"];
                              bool liked = likesData[uid]["liked"];

                              Future<Map<String, Image>> userImages =
                                  fetchImages(uid,
                                      withImages: true,
                                      withProfilePicture: true);

                              DateTime dateFormated = DateTime.parse(date);

                              timeago.setLocaleMessages(
                                  'fr', timeago.FrMessages());
                              String timeAgo =
                                  timeago.format(dateFormated, locale: 'fr');

                              return Container(
                                width: 150,
                                height: 300,
                                margin: index == (likesData.keys.length) - 1
                                    ? const EdgeInsets.only(right: 25, left: 15)
                                    : const EdgeInsets.only(left: 15),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 210,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileScrollWidget(
                                                          name,
                                                          liked,
                                                          uid,
                                                          age,
                                                          hobbies,
                                                          distance,
                                                          bio,
                                                          images: userImages,
                                                          arrowBack: true,
                                                          callback: () async {
                                                            Navigator.pop(
                                                                context);
                                                            Map<String,
                                                                    dynamic>?
                                                                newValue =
                                                                await getUserChats(
                                                                    context);
                                                            if (newValue !=
                                                                null) {
                                                              usersChatsData
                                                                      .value =
                                                                  newValue;
                                                            }
                                                            await _getLikeReceived();
                                                          },
                                                        )));
                                          },
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: FutureBuilder<
                                                Map<String, Image>>(
                                              future: userImages,
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return ShimmerProfileScrollLoadingImage();
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                      'Error: ${snapshot.error}');
                                                } else {
                                                  Map<String, Image>?
                                                      userImages =
                                                      snapshot.data;
                                                  if (userImages!.isEmpty) {
                                                    return Container(
                                                        decoration: BoxDecoration(
                                                            color: AppColors
                                                                .darkBlue,
                                                            border: Border.all(
                                                                color: AppColors
                                                                    .white),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: const Center(
                                                          child: Icon(Icons
                                                              .hide_image_outlined),
                                                        ));
                                                  } else {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: userImages[
                                                                  userImages
                                                                      .keys
                                                                      .first]!
                                                              .image,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  name,
                                                  style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  timeAgo,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 15),
                          child: Text(
                            AppLocalizations.of(context)!.matches,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(fontSize: 20, height: 0),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ValueListenableBuilder<Map<String, dynamic>>(
                          valueListenable: usersChatsData,
                          builder: (BuildContext context,
                              Map<String, dynamic> chatsData, Widget? child) {
                            if (chatsData.isEmpty) {
                              return Center(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .emptyMatchesReception,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount: chatsData.length,
                              itemBuilder: (BuildContext context, int index) {
                                String cid = chatsData.keys.elementAt(index);

                                String chatName = "";
                                for (dynamic user in chatsData[cid]
                                    ["otherUser"]) {
                                  chatName += user["name"];
                                }

                                Future<Map<String, Image>>
                                    otherUserProfilePicture = Future.value({});
                                if (chatsData[cid]["otherUser"].length > 0) {
                                  otherUserProfilePicture = fetchImages(
                                      chatsData[cid]["otherUser"][0]["uid"],
                                      withProfilePicture: true);
                                }

                                String dateFormated =
                                    formatDate(chatsData[cid]["updatedAt"]);

                                String lastChatMessage =
                                    chatsData[cid]["messages"].length == 0
                                        ? AppLocalizations.of(context)!
                                            .takeFirstStep
                                        : chatsData[cid]["messages"][
                                            (chatsData[cid]["messages"])
                                                    .length -
                                                1]["content"];

                                List<String> chatSeenBy =
                                    chatsData[cid]["messages"].length == 0
                                        ? []
                                        : (chatsData[cid]["seen"]
                                                as List<dynamic>)
                                            .cast<String>();

                                return ChatTile(
                                  key: ValueKey(cid),
                                  chatName: chatName,
                                  dateFormated: dateFormated,
                                  lastChatMessage: lastChatMessage,
                                  otherUserProfilePicture:
                                      otherUserProfilePicture,
                                  chatData: chatsData[cid],
                                  seenBy: chatSeenBy,
                                );
                              },
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class ChatTile extends StatefulWidget {
  final String chatName;
  final String dateFormated;
  final String lastChatMessage;
  final Future<Map<String, Image>> otherUserProfilePicture;
  final Map<String, dynamic> chatData;
  final List<String> seenBy;

  ChatTile({
    super.key,
    required this.chatName,
    required this.dateFormated,
    required this.lastChatMessage,
    required this.otherUserProfilePicture,
    required this.chatData,
    this.seenBy = const [],
  });

  @override
  _ChatTileState createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  late ValueNotifier<String> _lastMessageNotifier;
  late ValueNotifier<List<String>> _seenByNotifier;

  late User currentUser;

  @override
  void initState() {
    super.initState();

    currentUser = Provider.of<UserProvider>(context, listen: false).user!;

    _lastMessageNotifier = ValueNotifier(widget.lastChatMessage);
    _seenByNotifier = ValueNotifier(widget.seenBy);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Map<String, dynamic> messageData = message.data;
      if (mounted && messageData["type"] == "message") {
        _lastMessageNotifier.value = truncateString(messageData["content"]);
        _seenByNotifier.value = const [];
      }
    });
  }

  @override
  void dispose() {
    _lastMessageNotifier.dispose();
    _seenByNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
        valueListenable: _seenByNotifier,
        builder: (context, seenBy, child) {
          bool isSeenByCurrentUser = seenBy.contains(currentUser.uid);

          return SizedBox(
            width: 200,
            child: ListTile(
              leading: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.pink,
                    border: isSeenByCurrentUser
                        ? null
                        : Border.all(color: AppColors.pink, width: 2),
                  ),
                  child: FutureBuilder(
                    future: widget.otherUserProfilePicture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.containsKey("profile")) {
                          return CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.onSurface,
                            backgroundImage: snapshot.data!["profile"]!.image,
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.favorite,
                              color: AppColors.white,
                            ),
                          );
                        }
                      }
                      return CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onSurface,
                        strokeWidth: 2,
                      );
                    },
                  ),
                ),
                if (!isSeenByCurrentUser)
                  Positioned(bottom: 0, right: 0, child: UnreadBubble()),
              ]),
              title: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 19),
                  children: [
                    TextSpan(
                      text: widget.chatName,
                    ),
                    const TextSpan(
                      text: '  ',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    TextSpan(
                      text: widget.dateFormated,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: _lastMessageNotifier,
                    builder: (context, lastMessage, child) {
                      return Text(
                        truncateString(lastMessage),
                        style: TextStyle(
                          fontWeight: isSeenByCurrentUser
                              ? FontWeight.normal
                              : FontWeight.w900,
                        ),
                      );
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MessageScreen(
                              callback: (newLastMessage) {
                                _lastMessageNotifier.value =
                                    truncateString(newLastMessage);
                              },
                              profileImage: widget.otherUserProfilePicture,
                              chatData: widget.chatData,
                            )));
                _seenByNotifier.value = List.from(_seenByNotifier.value)
                  ..add(currentUser.uid);
              },
            ),
          );
        });
  }
}

class UnreadBubble extends StatelessWidget {
  const UnreadBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        height: 13,
        padding: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            color: AppColors.pink, borderRadius: BorderRadius.circular(20)),
        child: Text(AppLocalizations.of(context)!.newLabel.toLowerCase(),
            style: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(height: 0, fontSize: 10)),
      ),
    );
  }
}
