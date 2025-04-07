import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subtil_app/l10n/app_localizations.dart';
import 'package:subtil_app/models/user_model.dart';
import 'package:subtil_app/providers/user_provider.dart';
import 'package:subtil_app/services/api_service.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/widgets/matcher_title_widget.dart';

class ChangeEmailScreen extends StatefulWidget {
  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  String? email;
  _ChangeEmailScreenState({this.email});

  late User currentUser;
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = Provider.of<UserProvider>(context, listen: false).user!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic>? args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        _emailController.text = args["email"]!;
      } else {
        _emailController.text = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.changeEmail,
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
              onPressed: () async {
                if (_isLoading == true) {
                  return;
                }
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }

                final newValue = _emailController.text;

                if (newValue.toUpperCase() ==
                    (currentUser.email).toUpperCase()) {
                  return Navigator.pop(context);
                }

                final response = await changeEmail(newValue);
                if (response == 200) {
                  showSnackBarGood(context,
                      AppLocalizations.of(context)!.verifEmailSent(newValue));
                } else if (response == 403) {
                  showSnackBarBad(context,
                      content: AppLocalizations.of(context)!.emailUnvailable);
                } else if (response == 401) {
                  showSnackBarBad(context,
                      content:
                          AppLocalizations.of(context)!.pleaseConfirmEmail);
                } else {
                  showSnackBarBad(context);
                }
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator()),
                    )
                  : Text(AppLocalizations.of(context)!.changeMyEmail),
            ),
          ],
        ),
      ),
    );
  }
}
