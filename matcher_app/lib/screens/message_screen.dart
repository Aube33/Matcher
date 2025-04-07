import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/widgets/profileScroll_widget.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class MessageScreen extends StatefulWidget {
  final Future<Map<String, Image>>? profileImage;
  final Map<String, dynamic>? chatData;
  final Function(String) callback;

  const MessageScreen(
      {super.key,
      required this.callback,
      required this.chatData,
      this.profileImage});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class ChatMessage {
  String author;
  DateTime createdAt;
  String content;
  bool timeDisplay = false;
  ChatMessage(
      {required this.author, required this.createdAt, required this.content});
}

class _MessageScreenState extends State<MessageScreen> {
  Future<Map<String, Image>>? profileImage;
  dynamic data;

  List<ChatMessage> messages = [];
  final TextEditingController _textFieldController = TextEditingController();

  bool _loadMoreMessageIsLoading = false;

  void loadMoreMessages() async {
    if (_loadMoreMessageIsLoading == true) {
      return;
    }
    setState(() {
      _loadMoreMessageIsLoading = true;
    });
    Map<String, dynamic>? newChatData =
        await getChatData(data["cid"], 10, index: messages.length);
    if (newChatData != null) {
      if (newChatData["messages"] != null) {
        List<ChatMessage> newMessage = [];
        for (dynamic mes in newChatData["messages"]) {
          newMessage.add(ChatMessage(
              author: mes["uid"],
              createdAt: DateTime.parse(mes["created_at"]),
              content: mes["content"]));
        }

        if (mounted) {
          setState(() {
            messages = [...newMessage, ...messages];
          });
        }
      }
    }
    if (mounted) {
      setState(() {
        _loadMoreMessageIsLoading = false;
      });
    }
  }

  @override
  void initState() {
    data = widget.chatData;
    if (data != null) {
      getChatData(data["cid"], 10)?.then((chatData) async {
        messages.clear();
        if (chatData["messages"] != null) {
          for (dynamic mes in chatData["messages"]) {
            messages.add(ChatMessage(
                author: mes["uid"],
                createdAt: DateTime.parse(mes["created_at"]),
                content: mes["content"]));
          }
        }
        if (mounted) {
          setState(() {
            messages;
          });
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        Map<String, dynamic> messageData = message.data;
        if (mounted) {
          if (messageData["type"] == "deleteMatch") {
            if (messageData["chatID"] != null &&
                data["cid"] == messageData["chatID"]) {
              if (await showConfirmationDialog(
                      context,
                      AppLocalizations.of(context)!.matchUnavailblePopupTitle,
                      AppLocalizations.of(context)!
                          .matchUnavailablePopupContent,
                      btnTxt: "OK") ||
                  true) {
                Navigator.pushReplacementNamed(context, "/inbox");
              }
            }
          }
        }
      });
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Map<String, dynamic> messageData = message.data;
      if (mounted &&
          messageData["type"] == "message" &&
          messageData["cid"] == data["cid"]) {
        setState(() {
          messages.add(ChatMessage(
              author: messageData["sender"],
              createdAt: DateTime.parse(messageData["time"]),
              content: messageData["content"]));
        });
        widget.callback(messageData["content"]);
      }
    });

    profileImage = widget.profileImage;
    super.initState();
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.flag),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (await showConfirmationDialog(
                          context,
                          AppLocalizations.of(context)!.deleteThisMatch,
                          AppLocalizations.of(context)!.confirmAction)) {
                        await deleteChat(data["cid"]);
                        Navigator.pushReplacementNamed(context, "/inbox");
                      }
                    },
                    child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.delete)),
                  )
                ],
              ),
            ),
          ],
          title: InkWell(
              onTap: () {
                final otherUser = data["otherUser"][0];

                Future<Map<String, Image>> userImages = fetchImages(
                    otherUser["uid"],
                    withImages: true,
                    withProfilePicture: true);

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileScrollWidget(
                              otherUser["name"],
                              true,
                              otherUser["uid"],
                              otherUser["age"],
                              otherUser["hobbies"],
                              otherUser["distance"],
                              otherUser["bio"],
                              arrowBack: true,
                              images: userImages,
                            )));
              },
              child: Row(
                children: [
                  FutureBuilder(
                    future: profileImage,
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
                    data["otherUser"][0]["name"].toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(fontSize: 20),
                  ),
                ],
              )),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: <Widget>[
            backGround(),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      reverse: true,
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                        children: [
                          Center(
                            child: TextButton(
                                onPressed: () {
                                  loadMoreMessages();
                                },
                                child: _loadMoreMessageIsLoading
                                    ? const SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                          color: AppColors.grey,
                                          strokeWidth: 3,
                                        ))
                                    : Text(
                                        AppLocalizations.of(context)!
                                            .loadMoreMessages,
                                        textAlign: TextAlign.center,
                                      )),
                          ),
                          Column(
                            children: messages.map((message) {
                              String formattedDate =
                                  DateFormat('dd/MM/yyyy hh:mm')
                                      .format(message.createdAt);

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    message.timeDisplay = !message.timeDisplay;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 14),
                                      alignment:
                                          message.author != data["currentUser"]
                                              ? Alignment.topLeft
                                              : Alignment.topRight,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment: message.author !=
                                                data["currentUser"]
                                            ? CrossAxisAlignment.start
                                            : CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: message.author !=
                                                      data["currentUser"]
                                                  ? AppColors.salmon
                                                  : Colors.grey[300],
                                              gradient: message.author !=
                                                      data["currentUser"]
                                                  ? const LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        AppColors.salmon,
                                                        AppColors.pink,
                                                      ],
                                                      stops: [0, 1.0],
                                                    )
                                                  : null,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 10),
                                            child: Text(
                                              message.content,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w400,
                                                color: message.author !=
                                                        data["currentUser"]
                                                    ? AppColors.white
                                                    : AppColors.black,
                                              ),
                                            ),
                                          ),
                                          if (message.timeDisplay)
                                            const SizedBox(height: 5),
                                          if (message.timeDisplay)
                                            Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.white),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.only(left: 15),
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          style: TextStyle(color: Colors.black),
                          controller: _textFieldController,
                          decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(context)!.typeAMessage,
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none)),
                    ),
                    const SizedBox(width: 15),
                    FloatingActionButton(
                      highlightElevation: 0,
                      splashColor: Colors.transparent,
                      onPressed: () {
                        String message = _textFieldController.text;
                        if (message.isEmpty) return;

                        sendChatMessage(data["cid"], message).then((value) {
                          if (value != {}) {
                            try {
                              if (mounted) {
                                setState(() {
                                  messages.add(ChatMessage(
                                      author: value["uid"],
                                      createdAt:
                                          DateTime.parse(value["created_at"]),
                                      content: value["content"]));
                                });
                              }
                              _textFieldController.clear();
                              widget.callback(value["content"]);
                            } catch (e) {
                              print("test ====");
                              print(value);
                              print('Error sending message: $e');
                            }
                          }
                        });
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      child:
                          const Icon(Icons.send, color: Colors.black, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
