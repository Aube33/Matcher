import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class User {
  final String uid;
  String name;
  int age;
  List<String> hobbies;
  int distance;
  bool liked;
  String note;
  String email;
  int searchDist;
  DateTime birthday;
  double ageMinSought;
  double ageMaxSought;
  int gender;
  List<int> attractions;
  int relationShip;
  LatLng location;
  bool hasClaimedDailyLikes;
  bool paused;

  Map<String, Image> images = {};

  int likes;

  User({
    required this.uid,
    required this.name,
    required this.age,
    required this.hobbies,
    required this.distance,
    required this.liked,
    required this.note,
    required this.email,
    required this.searchDist,
    required this.birthday,
    required this.ageMinSought,
    required this.ageMaxSought,
    required this.gender,
    required this.attractions,
    required this.relationShip,
    required this.location,
    required this.paused,

    this.likes = 0,
    this.hasClaimedDailyLikes = true
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'] as String,
      name: data['name'] as String,
      age: data['age'] as int,
      hobbies: List<String>.from(data['hobbies']),
      distance: data['distance'] as int,
      liked: data['liked'] as bool,
      note: data['bio'] as String,
      email: data['email'] as String,
      searchDist: data['searchDist'] as int,
      birthday: DateTime.parse(data['birthday'] as String),
      ageMinSought: (data['ageMinSought'] as int).toDouble(),
      ageMaxSought: (data['ageMaxSought'] as int).toDouble(),
      gender: data['gender'] as int,
      attractions: List<int>.from(data['attractions']),
      relationShip: data['relationShip'] as int,
      location: LatLng(
        (data['location']["coordinates"][0] as num).toDouble(),
        (data['location']["coordinates"][1] as num).toDouble(),
      ),
      paused: data['paused'] as bool,

      likes: data['likes'] != null ? data['likes'] as int : 0,
      hasClaimedDailyLikes: data['hasClaimedDailyLikes'] as bool//data['hasClaimedDailyLikes'] != null ? data['hasClaimedDailyLikes'] as bool : true
    );
  }
}
