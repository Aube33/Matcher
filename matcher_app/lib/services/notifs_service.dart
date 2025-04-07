import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:subtil_app/l10n/app_localizations.dart';

class Notifications {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications(
      GlobalKey<NavigatorState> navigatorKey, BuildContext context) async {
    tz.initializeTimeZones();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings());
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (notificationResponse) async {
      onDidReceiveNotificationResponse(notificationResponse, navigatorKey);
    });

    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse,
      GlobalKey<NavigatorState> navigatorKey) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      if (notificationResponse.payload == "like") {
        navigatorKey.currentState!.pushNamed('/inbox');
        return;
      } else if (notificationResponse.payload == "match") {
        navigatorKey.currentState!.pushNamed('/chats');
        return;
      }
      print('notification payload: $payload');
    }
    navigatorKey.currentState!.pushNamed('/flow');
  }

  Future<void> showLikeNotification(String name) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final BuildContext context = navigatorKey.currentContext!;

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              'likes', AppLocalizations.of(context)!.likeReception,
              channelDescription:
                  AppLocalizations.of(context)!.likeReceptionDesc,
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');
      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      await _flutterLocalNotificationsPlugin.show(
          0,
          AppLocalizations.of(context)!
              .likeReceptionNotif(adapterDe(name, context)),
          AppLocalizations.of(context)!.clickToView,
          notificationDetails,
          payload: 'like');
    });
  }

  Future<void> showMatchNotification(String name) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final BuildContext context = navigatorKey.currentContext!;

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              'matches', AppLocalizations.of(context)!.matchReception,
              channelDescription:
                  AppLocalizations.of(context)!.matchReceptionDesc,
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');
      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      await _flutterLocalNotificationsPlugin.show(
          0,
          AppLocalizations.of(context)!.matchReceptionNotif(name),
          AppLocalizations.of(context)!.clickToView,
          notificationDetails,
          payload: 'match');
    });
  }

  Future<void> showMessageNotification(String name) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final BuildContext context = navigatorKey.currentContext!;

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              'messages', AppLocalizations.of(context)!.messageReception,
              channelDescription:
                  AppLocalizations.of(context)!.messageReceptionDesc,
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');
      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      await _flutterLocalNotificationsPlugin.show(
          0,
          AppLocalizations.of(context)!
              .messageReceptionNotif(adapterDe(name, context)),
          AppLocalizations.of(context)!.clickToView,
          notificationDetails,
          payload: 'message');
    });
  }

  Future<void> showDailyLikesNotification() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final BuildContext context = navigatorKey.currentContext!;

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              'notifs', AppLocalizations.of(context)!.dailyLikesNotif,
              channelDescription:
                  AppLocalizations.of(context)!.dailyLikesNotifDesc,
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');
      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      await _flutterLocalNotificationsPlugin.show(
          0,
          AppLocalizations.of(context)!.dailyLikesNotifTitle,
          AppLocalizations.of(context)!.dailyLikeNotifContent,
          notificationDetails,
          payload: 'dailyLikes');
    });
  }

  Future<void> showCustomNotification(data) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final BuildContext context = navigatorKey.currentContext!;
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
              'custom', AppLocalizations.of(context)!.customNotif,
              channelDescription: AppLocalizations.of(context)!.customNotifDesc,
              importance: Importance.max,
              icon: 'ic_notif',
              priority: Priority.high,
              ticker: 'ticker');
      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      await _flutterLocalNotificationsPlugin.show(
          0, data["title"], data["description"], notificationDetails,
          payload: 'custom');
    });
  }
}

String adapterDe(String name, BuildContext context) {
  List<String> voyelles = ['a', 'e', 'i', 'o', 'u', 'y'];
  String premiereLettre = name[0].toLowerCase();

  String locale = AppLocalizations.of(context)!.localeName;

  if (locale == 'fr') {
    if (voyelles.contains(premiereLettre)) {
      return "d'$name";
    } else {
      return "de $name";
    }
  } else if (locale == 'en') {
    return "from $name";
  }

  return name;
}

//===== FIREBASE =====
final notifications = Notifications();

Future<void> setupToken() async {
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print("Notification settings: ${settings.authorizationStatus}");

  print("======= SETUP FCM TOK =========");
  if (Platform.isIOS) {
    await Future.delayed(Duration(seconds: 1));
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print("APNs Token: $apnsToken");

    await Future.delayed(Duration(seconds: 1));
  }

  String? token = await FirebaseMessaging.instance.getToken();
  await saveNotifToken(token!);
  FirebaseMessaging.instance.onTokenRefresh.listen(saveNotifToken);
}

void handleMessage(RemoteMessage message) {
  Map<String, dynamic> data = message.data;

  if (data["type"] == "like") {
    notifications.showLikeNotification(data["userName"]);
    print('The user ${data["userName"]} liked you !');
  } else if (data["type"] == "match") {
    notifications.showMatchNotification(data["userName"]);
    print('Match with ${data["userName"]} !');
  } else if (data["type"] == "message") {
    notifications.showMessageNotification(data["senderName"]);
    print('Message from ${data["senderName"]}');
  } else if (data["type"] == "dailyLikes") {
    notifications.showDailyLikesNotification();
  } else if (data["type"] == "custom") {
    notifications.showCustomNotification(data);
  } else if (data["type"] == "test") {
    notifications.showMessageNotification("test notif");
  }
}
