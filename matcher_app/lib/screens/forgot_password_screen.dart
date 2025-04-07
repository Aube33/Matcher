import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:subtil_app/configs/api.configs.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/l10n/app_localizations.dart';
import 'package:subtil_app/widgets/matcher_title_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String? email;
  _ForgotPasswordScreenState({this.email});

  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final Map<String, dynamic>? args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

        if (args != null) {
          _emailController.text = args["email"]!;
        } else {
          _emailController.text = "";
        }
      },
    );
  }

  Future<void> _forgotPassword() async {
    if (_isLoading == true) {
      return;
    }
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    const String apiUrl = '$API_URL/users/reset-password/';

    final Map<String, String> requestData = {
      'email': _emailController.text,
    };

    try {
      final http.Response response = await client.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print(response.body);

      if (response.statusCode == 200) {
        print('Reset successfully sent');
        Navigator.pop(context);
        showSnackBarGood(
            context, AppLocalizations.of(context)!.passwordResetEmailSent);
        return;
      } else {
        print('Reset password failed');
      }
    } catch (e) {
      print('Error: $e');
    }
    showSnackBarBad(context);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.resetPassword,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MatcherTitle(),
            const SizedBox(
              height: 50,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.emailAddress),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _forgotPassword,
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator()),
                    )
                  : Text(AppLocalizations.of(context)!.resetMyPassword),
            ),
          ],
        ),
      ),
    );
  }
}
