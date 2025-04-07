import 'package:flutter/material.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:subtil_app/services/jwt_service.dart';
import 'package:subtil_app/services/user_service.dart';
import 'package:subtil_app/models/user_model.dart';
import 'package:subtil_app/providers/api_data_provider.dart';
import 'package:subtil_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/widgets/matcher_title_widget.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  bool isAPIAvailable = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        isAPIAvailable = await getAPI();
        print("===== API Available =====");
        print(isAPIAvailable);
        if (isAPIAvailable == true) {
          final apiProvider = Provider.of<ApiProvider>(context, listen: false);
          apiProvider.fetchApiData();

          final data = await getCurrentUserData(context);
          if (data.isNotEmpty) {
            final userDatas = await getUserData(data["uid"]);
            if (userDatas.isNotEmpty) {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              userProvider.updateUser(User.fromMap(userDatas));

              final images = await fetchImages(data["uid"],
                  withProfilePicture: true, withImages: true);
              var currentUser = userProvider.user!;
              currentUser.images = images;
              userProvider.updateUser(currentUser);

              await Future.microtask(
                  () => Navigator.pushReplacementNamed(context, "/flow"));
            } else {
              throw Exception("User data not found");
            }
          } else {
            throw Exception("No user data");
          }
        } else {
          if (mounted) {
            setState(() {
              isAPIAvailable;
            });
          }
        }
      } catch (e) {
        print("Error in AuthScreen: $e");
        await deleteJWT();
        if (mounted) {
          sendToLoginScreen(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          backGround(),
          Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MatcherTitle(),
              const SizedBox(
                height: 30,
              ),
              isAPIAvailable == false
                  ? const Icon(
                      Icons.dangerous,
                      color: Colors.red,
                      size: 60,
                    )
                  : CircularProgressIndicator(),
              if (!isAPIAvailable)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        AppLocalizations.of(context)!.apiUnavailable,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )
            ],
          )),
        ]));
  }
}
