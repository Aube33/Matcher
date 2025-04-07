import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:subtil_app/configs/api.configs.dart';
import 'package:subtil_app/services/user_service.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

AndroidOptions _getAndroidOptions() =>
    const AndroidOptions(encryptedSharedPreferences: true);
final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

Future<void> saveJWT(String token) async {
  await storage.write(key: "jwt", value: token);
}

Future<void> deleteJWT() async {
  await storage.delete(key: 'jwt');
}

Future<String?> getJWT() async {
  return await storage.read(key: "jwt");
}

Map<String, dynamic> decodeJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('Invalid JWT. It should have 3 parts.');
  }

  var payload = parts[1];

  if (payload.length % 4 != 0) {
    int paddingLength = 4 - (payload.length % 4);
    payload = payload.padRight(payload.length + paddingLength, '=');
  }

  if (payload.length % 4 != 0) {
    throw Exception('Invalid Base64 length.');
  }

  final decodedPayload = base64Url.decode(payload);
  final payloadJson = utf8.decode(decodedPayload);

  return jsonDecode(payloadJson);
}

Future<bool> checkJWTAuth(String jwt) async {
  const String apiUrl = '$API_URL/users/authorize/';
  try {
    final http.Response response = await client.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    }
  } catch (e) {
    print('Error: $e');
  }
  return false;
}

Future<Map<String, dynamic>> getCurrentUserData(BuildContext context) async {
  final jwt = await getJWT();
  if (jwt == null) {
    sendToLoginScreen(context,
        arguments: {'message': AppLocalizations.of(context)!.pleaseReconnect});
    return {};
  }

  final authResponse = await checkJWTAuth(jwt);
  if (!authResponse) {
    sendToLoginScreen(context,
        arguments: {'message': AppLocalizations.of(context)!.pleaseReconnect});
    //throw 'JWT authentication failed';
  }
  return decodeJwt(jwt);
}
