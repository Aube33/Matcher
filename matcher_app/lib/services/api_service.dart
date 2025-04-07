import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/configs/api.configs.dart';
import 'package:subtil_app/services/jwt_service.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/providers/user_provider.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/widgets/match_animation_widget.dart';

Future<bool> getAPI() async {
  bool result = false;
  try {
    final response = await client.get(Uri.parse("$API_URL/check"));
    print(response.statusCode);
    if (response.statusCode == 200) {
      result = true;
    } else {
      print('API seems to be unavailble: ${response.statusCode}');
    }
  } catch (e) {
    print('ERROR when checking API availability !');
    print(e);
  }
  return result;
}

Future<Map<String, dynamic>>? getChatData(String cid, int length,
    {int index = 0}) async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/chat/$cid?m=$length${index > 0 ? '&i=$index' : ''}';

  try {
    final http.Response response =
        await client.get(Uri.parse(apiUrl), headers: <String, String>{
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  } catch (e) {
    print('Error: $e');
  }
  return {};
}

Future<Map<String, dynamic>> sendChatMessage(String cid, String message) async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/chat/$cid';

  final Map<String, String> requestData = {
    'content': message,
  };

  try {
    final http.Response response = await client.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  } catch (e) {
    print('Error: $e');
  }
  return {};
}

Future<Map<String, dynamic>> getUserData(String uid) async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/users/$uid';
  try {
    final http.Response response = await client.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
  } catch (e) {
    print('Error: $e');
  }
  return {};
}

void apiLogoutUser() async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/users/logout';
  try {
    final http.Response response = await client.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    }
  } catch (e) {
    print('Error: $e');
  }
  return;
}

Future<Map<String, dynamic>?> editUser(Map<dynamic, dynamic> newValues) async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/users/edit/';
  try {
    final http.Response response = await client.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(newValues),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      print("edit success");
      print(response.body);
      return json.decode(response.body);
    } else {
      print("edit failed");
    }
  } catch (e) {
    print('Error: $e');
  }
  return null;
}

Future<Map<String, dynamic>> fetchHobbiesAPI() async {
  try {
    final response = await client.get(Uri.parse('$API_URL/users/hobbies'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final Map<String, dynamic> hobbiesData = data['Hobbies'];
      return hobbiesData;
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('ERROR line here');
  }
  return {};
}

Future<Map<String, dynamic>> fetchHobbyAPI(String hobby) async {
  Map<String, dynamic> returnedData = {
    "color": "000000",
    "emoji": "",
  };

  try {
    final response =
        await client.get(Uri.parse('$API_URL/users/hobbies/$hobby'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data["hobby"] != null) {
        returnedData["color"] = data["hobby"]["color"];
        returnedData["emoji"] = data["hobby"]["emoji"];
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } on Exception catch (e) {
    print(e);
  }
  return returnedData;
}

Future<Map<int, String>> fetchGendersAPI() async {
  try {
    final response = await client.get(Uri.parse('$API_URL/users/genders'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final Map<String, dynamic> gendersData = data['Genders'];
      final Map<int, String> convertedGendersData =
          gendersData.map((key, value) {
        return MapEntry(int.parse(key), value as String);
      });

      return convertedGendersData;
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print("AUTRE RERROOR");
  }
  return {};
}

Future<Map<int, String>> fetchRelationsAPI() async {
  try {
    final response = await client.get(Uri.parse('$API_URL/users/relations'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final Map<String, dynamic> relationsData = data['RelationShips'];
      final Map<int, String> convertedrelationsData =
          relationsData.map((key, value) {
        return MapEntry(int.parse(key), value as String);
      });

      return convertedrelationsData;
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print("test tah l'erreur");
    print(e);
  }
  return {};
}

Future<int> changeEmail(String newEmail) async {
  const String apiUrl = '$API_URL/users/change-email/';
  final jwt = await getJWT();

  final Map<String, String> requestData = {
    'newEmail': newEmail,
  };

  try {
    final http.Response response = await client.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );
    print(response.body);

    return response.statusCode;
  } catch (e) {
    print('Error: $e');
  }
  return 0;
}

Future<void> saveNotifToken(String token) async {
  const String apiUrl = '$API_URL/tokens/notifications/';
  final jwt = await getJWT();

  final Map<String, String> requestData = {
    'token': token,
  };

  try {
    final http.Response response = await client.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );
    print(response.body);
  } catch (e) {
    print('Error: $e');
  }
}

Future<Map<String, Image>> fetchImages(String uid,
    {bool withProfilePicture = false, withImages = false}) async {
  final jwt = await getJWT();

  String query = "";
  if (withProfilePicture || withImages) {
    query += "?";
    if (withProfilePicture) {
      query += "pp=true";
    }
    if (withImages) {
      if (withProfilePicture) {
        query += "&";
      }
      query += "img=true";
    }
  }
  String apiUrl = '$API_URL/users/images/$uid${query != "" ? query : ''}';

  try {
    final http.Response response = await client.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final Map<String, Image> images = {};
      for (int i = 0; i < data.keys.length; i++) {
        final List<int> imgData =
            List<int>.from(data[data.keys.elementAt(i).toString()]["data"]);
        images[data.keys.elementAt(i).toString()] =
            Image.memory(Uint8List.fromList(imgData));
      }

      return images;
    } else {
      print("image get failed");
    }
  } catch (e) {
    print('Error: $e');
  }

  return {};
}

Future<int> postImages(List<int> indexs, List<File> images) async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/users/images';

  try {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers['Authorization'] = 'Bearer $jwt';
    request.headers['User-Agent'] = apiAgent;

    for (File img in images) {
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        img.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    request.fields['imagesIndex'] = json.encode(indexs);

    final response = await request.send();
    if (response.statusCode != 200) {
      print("Échec de l'envoi de l'image: ${response.reasonPhrase}");
    }
    return response.statusCode;
  } catch (e) {
    // Gérer les erreurs
    print('Erreur: $e');
  }

  return 0;
}

Future<bool> deleteImage(int index) async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/users/images';

  try {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers['Authorization'] = 'Bearer $jwt';
    request.headers['User-Agent'] = apiAgent;

    request.fields['imagesIndex'] = json.encode([index]);

    final response = await request.send();
    if (response.statusCode == 200) {
      //final dynamic data = json.decode(await response.stream.bytesToString());
      return true;
    } else {
      print("Échec de la suppression de l'image: ${response.reasonPhrase}");
    }
  } catch (e) {
    // Gérer les erreurs
    print('Erreur: $e');
  }

  return false;
}

Future<bool> deleteProfileImage() async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/users/images/profile';

  try {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers['Authorization'] = 'Bearer $jwt';
    request.headers['User-Agent'] = apiAgent;

    final response = await request.send();
    if (response.statusCode == 200) {
      //final dynamic data = json.decode(await response.stream.bytesToString());
      return true;
    } else {
      print("Échec de l'envoi de l'image: ${response.reasonPhrase}");
    }
  } catch (e) {
    // Gérer les erreurs
    print('Erreur: $e');
  }

  return false;
}

Future<int> postProfileImage(File image) async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/users/images/profile';

  try {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers['Authorization'] = 'Bearer $jwt';
    request.headers['User-Agent'] = apiAgent;

    request.files.add(await http.MultipartFile.fromPath(
      'images',
      image.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    final response = await request.send();
    if (response.statusCode != 200) {
      print(response.statusCode);
      print("Échec de l'envoi de l'image: ${response.reasonPhrase}");
    }
    return response.statusCode;
  } catch (e) {
    // Gérer les erreurs
    print('Erreur: $e');
  }

  return 0;
}

Future<Map<String, dynamic>>? deleteChat(String cid) async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/chat/$cid';
  try {
    final http.Response response = await client.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("test ok");
      return json.decode(response.body);
    }
  } catch (e) {
    print('Error: $e');
  }
  return {};
}

Future<Map<String, dynamic>>? deleteLikeReceived(String uid) async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/likes/reception/$uid';
  try {
    final http.Response response = await client.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("test ok");
      return json.decode(response.body);
    }
  } catch (e) {
    print('Error: $e');
  }
  return {};
}

Future<bool> deleteUser() async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/users';

  try {
    var request = http.MultipartRequest('DELETE', Uri.parse(apiUrl));
    request.headers['Authorization'] = 'Bearer $jwt';
    request.headers['User-Agent'] = apiAgent;

    final response = await request.send();
    if (response.statusCode == 200) {
      //json.decode(response.body);
      return true;
    } else {
      print(
          "Échec de la suppression de l'utilisateur: ${response.reasonPhrase}");
    }
  } catch (e) {
    // Gérer les erreurs
    print('Erreur: $e');
  }

  return false;
}

// ===== LIKES =====
Future<int> getLikes() async {
  const String apiUrl = '$API_URL/likes/';
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
      Map<String, dynamic> resData = json.decode(response.body);
      if (resData["likes"] != null) {
        return resData["likes"];
      }
    }
  } catch (e) {
    print('Error: $e');
  }

  return 0;
}

Future claimDailyLikes(context) async {
  final jwt = await getJWT();
  String apiUrl = '$API_URL/likes/daily';
  try {
    final http.Response response = await client.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = json.decode(response.body);
      if (responseJson["likes"] != null) {
        var currentUser =
            Provider.of<UserProvider>(context, listen: false).user!;
        currentUser.likes = responseJson["likes"];
        currentUser.hasClaimedDailyLikes = true;
        Provider.of<UserProvider>(context, listen: false)
            .updateUser(currentUser);

        return;
      }
    }
  } catch (e) {
    print('Error: $e');
  }

  showSnackBarBad(context);
}

Future<Map<String, dynamic>>? getUserChats(BuildContext context) async {
  const String apiUrl = '$API_URL/users/chats';
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
        List<Map<String, dynamic>> chats =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        Map<String, dynamic> chatsData = {};

        List<Future> futures = [];
        for (Map<String, dynamic> chat in chats) {
          final String cid = chat["cid"];
          futures.add(getChatData(cid, 1)!.then((data) async {
            if (data != {}) {
              List<String> otherUsers = [];
              otherUsers = List<String>.from(data["users"]);
              final currentUser = await getCurrentUserData(context);
              otherUsers.remove(currentUser["uid"] ?? "");
              data["currentUser"] = currentUser["uid"] ?? "";

              data["otherUser"] = [];
              for (String uid in otherUsers) {
                data["otherUser"].add(await getUserData(uid));
              }

              chatsData[cid] = data;
            }
          }));
        }

        await Future.wait(futures);

        for (var chatData in chatsData.values) {
          print(chatData);
          if (chatData["showMatchAnim"]) {
            showMatchAnimOverlay(chatData["otherUser"][0]["uid"]);
          }
        }
        return chatsData;
      }
    }
  } catch (e) {
    print('Error: $e');
  }
  return {};
}
