import 'package:flutter/material.dart';
import 'package:subtil_app/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void updateUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }
}
