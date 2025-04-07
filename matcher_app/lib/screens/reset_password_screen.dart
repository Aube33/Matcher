import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:subtil_app/configs/api.configs.dart';
import 'package:subtil_app/configs/global.config.dart';
import 'package:subtil_app/services/jwt_service.dart';
import 'package:subtil_app/services/user_service.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen(this.token, {super.key});

  @override
  _ResetPasswordScreenState createState() =>
      _ResetPasswordScreenState(token: token);
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String token;
  _ResetPasswordScreenState({
    required this.token,
  });

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordVerifController =
      TextEditingController();
  bool passwordVisible = false;
  bool passwordVerifVisible = false;
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_isLoading) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    String apiUrl = '$API_URL/users/reset-password/$token';

    final Map<String, String> requestData = {
      'newPassword': _passwordController.text,
    };

    try {
      final http.Response response = await client.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );
      print(response.body);

      if (response.statusCode == 200) {
        print("Modif ok");
        await deleteJWT();
        sendToLoginScreen(context);
        showSnackBarGood(
            context, AppLocalizations.of(context)!.passwordSuccessUpdated);
      } else if (response.statusCode == 403) {
        showSnackBarBad(context,
            content: AppLocalizations.of(context)!.delayExceededPleaseRestart);
      } else if (response.statusCode == 400) {
        showSnackBarBad(context,
            content: AppLocalizations.of(context)!.passwordDoesntRequirements);
      } else {
        showSnackBarBad(context);
      }
    } catch (e) {
      print('Error: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    passwordVerifVisible = true;
    print(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MATCHER',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context)!.newPassword,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    TextField(
                      textInputAction: TextInputAction.done,
                      maxLength: passwordMaxLength,
                      maxLengthEnforcement:
                          MaxLengthEnforcement.truncateAfterCompositionEnds,
                      style: Theme.of(context).inputDecorationTheme.labelStyle,
                      obscureText: passwordVisible,
                      autofillHints: const [
                        AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.newPassword,
                        labelText: AppLocalizations.of(context)!.newPassword,
                        helperText:
                            AppLocalizations.of(context)!.passwordRequirement,
                        suffixIcon: IconButton(
                          color: Theme.of(context).indicatorColor,
                          icon: Icon(passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(
                              () {
                                passwordVisible = !passwordVisible;
                              },
                            );
                          },
                        ),
                        alignLabelWithHint: false,
                      ).copyWith(
                        hintStyle:
                            Theme.of(context).inputDecorationTheme.hintStyle,
                        labelStyle:
                            Theme.of(context).inputDecorationTheme.labelStyle,
                        helperStyle:
                            Theme.of(context).inputDecorationTheme.helperStyle,
                        suffixStyle:
                            Theme.of(context).inputDecorationTheme.suffixStyle,
                      ),
                      controller: _passwordController,
                    ),
                    SizedBox(height: 12.0),
                    TextField(
                      textInputAction: TextInputAction.done,
                      maxLength: passwordMaxLength,
                      maxLengthEnforcement:
                          MaxLengthEnforcement.truncateAfterCompositionEnds,
                      style: Theme.of(context).inputDecorationTheme.labelStyle,
                      obscureText: passwordVisible,
                      autofillHints: const [
                        AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.reEnterPassword,
                        labelText:
                            AppLocalizations.of(context)!.reEnterPassword,
                        suffixIcon: IconButton(
                          color: Theme.of(context).indicatorColor,
                          icon: Icon(passwordVerifVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(
                              () {
                                passwordVerifVisible = !passwordVerifVisible;
                              },
                            );
                          },
                        ),
                        alignLabelWithHint: false,
                      ).copyWith(
                        hintStyle:
                            Theme.of(context).inputDecorationTheme.hintStyle,
                        labelStyle:
                            Theme.of(context).inputDecorationTheme.labelStyle,
                        helperStyle:
                            Theme.of(context).inputDecorationTheme.helperStyle,
                        suffixStyle:
                            Theme.of(context).inputDecorationTheme.suffixStyle,
                      ),
                      controller: _passwordVerifController,
                    ),
                    SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_passwordController.text != "" &&
                    _passwordController.text == _passwordVerifController.text) {
                  await _resetPassword();
                } else {
                  showSnackBarBad(context,
                      content: (_passwordController.text == "")
                          ? AppLocalizations.of(context)!.invalidPassword
                          : AppLocalizations.of(context)!.passwordsDoesntMatch);
                }
              },
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator()),
                    )
                  : Text(
                      AppLocalizations.of(context)!.resetPassword,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
