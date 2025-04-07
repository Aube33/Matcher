import 'package:flutter/material.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:subtil_app/services/jwt_service.dart';

void logoutUser(BuildContext context) async {
  apiLogoutUser();
  await deleteJWT();
  sendToLoginScreen(context);
}

void sendToLoginScreen(BuildContext context, {Map<String, dynamic>? arguments}) {
  if (context.mounted) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
      (Route<dynamic> route) => false,
      arguments: arguments
    );
  }
}
