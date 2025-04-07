import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:subtil_app/configs/global.config.dart';
import 'package:subtil_app/services/jwt_service.dart';
import 'package:subtil_app/configs/api.configs.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:subtil_app/widgets/matcher_title_widget.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _isLoginLoading = false;
  String? externalMessage;
  Color? externalMessageColor;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool passwordVisible = false;
  bool _accountNeedToLogin = false;

  final GlobalKey _emailKey = GlobalKey();
  final GlobalKey _passwordKey = GlobalKey();

  final double _buttonSize = 50;
  final double _buttonPaddingFromTextField = 10;
  final Duration _textFieldAnimationDuration = Duration(milliseconds: 150);
  FocusNode? _lastFocusNode;

  @override
  void initState() {
    super.initState();
    _lastFocusNode = _emailFocusNode;

    passwordVisible = true;

    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus && _lastFocusNode != _emailFocusNode) {
        setState(() {
          _lastFocusNode = _emailFocusNode;
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus && _lastFocusNode != _passwordFocusNode) {
        setState(() {
          _lastFocusNode = _passwordFocusNode;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final Map<String, dynamic>? args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

        if (args != null) {
          externalMessage = args['message'] ?? "";
          externalMessageColor =
              (args["type"] != null && args["type"] == "good")
                  ? Colors.red
                  : Colors.green;
        }
      },
    );
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool?> _checkEmailExist() async {
    bool? result;

    if (_emailController.text.isNotEmpty &&
        isValidEmail(_emailController.text)) {
      result = null;

      setState(() {
        _isLoginLoading = true;
      });

      String apiUrl = '$API_URL/users/exist/${_emailController.text}';

      try {
        final http.Response response = await client.get(
          Uri.parse(apiUrl),
        );

        if (mounted) {
          if (response.statusCode == 200) {
            if (mounted) {
              setState(() {
                externalMessage = null;
              });
            }
            final Map<String, dynamic> responseBody =
                json.decode(response.body);
            result = responseBody['exists'] ?? false;
          } else {
            if (mounted) {
              setState(() {
                externalMessage = AppLocalizations.of(context)!.errorOccured;
              });
            }
          }
        }
      } catch (e) {
        print(e);
        if (mounted) {
          setState(() {
            externalMessage = AppLocalizations.of(context)!.errorOccured;
          });
        }
      }
      if (mounted) {
        setState(() {
          _isLoginLoading = false;
        });
      }
    } else if (_emailController.text.isNotEmpty &&
        !isValidEmail(_emailController.text)) {
      if (mounted) {
        setState(() {
          externalMessage = AppLocalizations.of(context)!.pleaseEnterValidEmail;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          externalMessage = "";
        });
      }
    }

    return Future.value(result);
  }

  Future<void> _login() async {
    if (_isLoginLoading ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        !isValidEmail(_emailController.text)) {
      return;
    }

    setState(() {
      _isLoginLoading = true;
    });

    const String apiUrl = '$API_URL/users/login/';

    final Map<String, String> requestData = {
      'email': _emailController.text,
      'password': _passwordController.text,
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
        if (response.statusCode == 200) {
          saveJWT(response.body);

          if (context.mounted) Navigator.pushReplacementNamed(context, "/");
        } else if (response.statusCode == 201) {
          if (mounted) {
            setState(() {
              externalMessage =
                  AppLocalizations.of(context)!.pleaseConfirmEmail;
            });
          }
        } /* else if(response.statusCode == 404) {
          if (context.mounted) {
            Navigator.pushNamed(context, "/register", arguments: {'email': _emailController.text, 'password': _passwordController.text});
          }
        }  */
        else if (response.statusCode == 401) {
          if (mounted) {
            setState(() {
              externalMessage = AppLocalizations.of(context)!.wrongCredentials;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              externalMessage = AppLocalizations.of(context)!.wrongCredentials;
            });
          }
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() {
          externalMessage = AppLocalizations.of(context)!.errorOccured;
        });
      }
    }
    if (mounted) {
      setState(() {
        _isLoginLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                      child: Image.asset(
                          fit: BoxFit.fitWidth,
                          _accountNeedToLogin
                              ? 'assets/images/coeur-fil-large.png'
                              : 'assets/images/coeur-fil.png')),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const MatcherTitle(),
                        const SizedBox(height: 30),
                        Column(
                          children: [
                            (externalMessage != null &&
                                    externalMessage!.isNotEmpty)
                                ? Row(
                                    children: [
                                      const Icon(
                                        Icons.dangerous,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        externalMessage!,
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 20.0),

                            // Email TextField
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double availableWidth = constraints.maxWidth;
                                double textFieldWidth = availableWidth -
                                    (_buttonSize + _buttonPaddingFromTextField);

                                return Row(
                                  children: [
                                    AnimatedContainer(
                                      width: (!_accountNeedToLogin &&
                                              (_emailFocusNode.hasFocus ||
                                                  _emailFocusNode ==
                                                      _lastFocusNode))
                                          ? textFieldWidth
                                          : availableWidth,
                                      duration: _textFieldAnimationDuration,
                                      curve: Curves.easeInCubic,
                                      child: TextField(
                                        focusNode: _emailFocusNode,
                                        key: _emailKey,
                                        textInputAction: TextInputAction.next,
                                        style: Theme.of(context)
                                            .inputDecorationTheme
                                            .labelStyle,
                                        controller: _emailController,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        decoration: InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)!
                                                  .emailAddress,
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .emailAddress,
                                        ).copyWith(
                                          labelStyle: Theme.of(context)
                                              .inputDecorationTheme
                                              .labelStyle,
                                          hintStyle: Theme.of(context)
                                              .inputDecorationTheme
                                              .hintStyle,
                                        ),
                                        onEditingComplete: () {
                                          _passwordFocusNode.requestFocus();
                                        },
                                      ),
                                    ),
                                    if (!_accountNeedToLogin)
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          ForwardButton(
                                            isLoading: _isLoginLoading,
                                            onPressed: () async {
                                              if (_isLoginLoading) {
                                                return;
                                              }

                                              if (_passwordController
                                                  .text.isEmpty) {
                                                bool? exist =
                                                    await _checkEmailExist();
                                                if (exist == false) {
                                                  if (context.mounted) {
                                                    Navigator.pushNamed(
                                                        context, "/register",
                                                        arguments: {
                                                          'email':
                                                              _emailController
                                                                  .text,
                                                          'password':
                                                              _passwordController
                                                                  .text
                                                        });
                                                  }
                                                } else if (exist == true) {
                                                  if (mounted) {
                                                    setState(() {
                                                      _accountNeedToLogin =
                                                          exist!;
                                                    });
                                                  }
                                                  _passwordFocusNode
                                                      .requestFocus();
                                                }
                                              } else {
                                                await _login();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 25.0),

                            // Password TextField
                            if (_accountNeedToLogin)
                              TextField(
                                focusNode: _passwordFocusNode,
                                key: _passwordKey,
                                textInputAction: TextInputAction.go,
                                maxLength: passwordMaxLength,
                                maxLengthEnforcement: MaxLengthEnforcement
                                    .truncateAfterCompositionEnds,
                                style: Theme.of(context)
                                    .inputDecorationTheme
                                    .labelStyle,
                                obscureText: passwordVisible,
                                autofillHints: const [
                                  AutofillHints.password,
                                ],
                                decoration: InputDecoration(
                                  hintText:
                                      AppLocalizations.of(context)!.password,
                                  labelText:
                                      AppLocalizations.of(context)!.password,
                                  helperText: AppLocalizations.of(context)!
                                      .passwordRequirement,
                                  suffixIcon: IconButton(
                                    color: Theme.of(context).indicatorColor,
                                    icon: Icon(passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        passwordVisible = !passwordVisible;
                                      });
                                    },
                                  ),
                                  alignLabelWithHint: false,
                                ).copyWith(
                                  hintStyle: Theme.of(context)
                                      .inputDecorationTheme
                                      .hintStyle,
                                  labelStyle: Theme.of(context)
                                      .inputDecorationTheme
                                      .labelStyle,
                                  helperStyle: Theme.of(context)
                                      .inputDecorationTheme
                                      .helperStyle,
                                  suffixStyle: Theme.of(context)
                                      .inputDecorationTheme
                                      .suffixStyle,
                                ),
                                onSubmitted: (String value) async {
                                  await _login();
                                },
                                controller: _passwordController,
                              ),

                            if (_accountNeedToLogin)
                              Column(
                                children: [
                                  const SizedBox(height: 40.0),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_isLoginLoading) {
                                        return;
                                      }

                                      bool? exist = await _checkEmailExist();
                                      if (exist == false) {
                                        if (context.mounted) {
                                          Navigator.pushNamed(
                                              context, "/register", arguments: {
                                            'email': _emailController.text,
                                            'password': _passwordController.text
                                          });
                                        }
                                      } else if (exist == true) {
                                        _login();
                                      }
                                    },
                                    style: Theme.of(context)
                                        .elevatedButtonTheme
                                        .style,
                                    child: _isLoginLoading
                                        ? const Center(
                                            child: SizedBox(
                                                height: 15,
                                                width: 15,
                                                child:
                                                    CircularProgressIndicator()),
                                          )
                                        : const Text(
                                            'Continuer',
                                          ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 45.0),

                            // Forgot password link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/forgotPassword', arguments: {
                                      'email': _emailController.text
                                    });
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .passwordForgot,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          decoration: TextDecoration.underline,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForwardButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isBackward;

  const ForwardButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.isBackward = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: Theme.of(context).elevatedButtonTheme.style,
        child: isLoading
            ? const Center(
                child: SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(),
                ),
              )
            : Center(
                child: Icon(
                  isBackward
                      ? Icons.arrow_back_ios_sharp
                      : Icons.arrow_forward_ios_sharp,
                ),
              ),
      ),
    );
  }
}
