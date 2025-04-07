import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:subtil_app/configs/global.config.dart';
import 'package:subtil_app/configs/api.configs.dart';
import 'package:subtil_app/main.dart';
import 'package:subtil_app/screens/login_screen.dart';
import 'package:subtil_app/services/user_service.dart';
import 'package:subtil_app/services/various_service.dart';
import 'package:subtil_app/providers/api_data_provider.dart';
import 'package:subtil_app/screens/parameters/ageSought_screen.dart';
import 'package:subtil_app/screens/parameters/attractions_screen.dart';
import 'package:subtil_app/screens/parameters/gender_screen.dart';
import 'package:subtil_app/screens/parameters/hobbies_screen.dart';
import 'package:subtil_app/screens/parameters/map_screen.dart';
import 'package:subtil_app/screens/parameters/relation_screen.dart';
import 'package:subtil_app/widgets/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:subtil_app/l10n/app_localizations.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class RegistrationData {
  String email = "";
  String password = "";
  String name = "";
  LatLng location = const LatLng(48.864716, 2.349014);
  int searchDist = 1;
  DateTime birthDate = DateTime.utc(
      DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);
  double minAge = 18;
  double maxAge = 99;
  int? gender;
  List<int> attractions = [];
  int? relationShip;
  List<String> hobbies = ["", "", ""];

  @override
  String toString() {
    return 'RegistrationData{\n'
        '  email: $email,\n'
        '  password: $password,\n'
        '  name: $name,\n'
        '  location: $location,\n'
        '  searchDist: $searchDist,\n'
        '  birthdate: ${birthDate.toString()},\n'
        '  minAge: $minAge,\n'
        '  maxAge: $maxAge,\n'
        '  gender: $gender,\n'
        '  attractions: $attractions,\n'
        '  relationShip: $relationShip,\n'
        '  hobbies: $hobbies,\n'
        '}';
  }
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  final _maxPageIndex = 4;
  int _currentPageIndex = 0;

  bool _isRegisterLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String? _emailErrorText;
  String? _passwordErrorText;
  String? _nameErrorText;
  bool _relationError = false;
  bool _genderError = false;
  bool _attractionError = false;

  RegistrationData registrationData = RegistrationData();

  final ScrollController _scrollControllerInfos = ScrollController();
  final ScrollController _scrollControllerGendersAttractions =
      ScrollController();

  bool passwordVisible = false;
  bool? _cguChecked;

  // Registration Data
  late final Map<String, dynamic> hobbies;
  late final Map<int, String> genders;
  late final Map<int, String> relations;

  @override
  void initState() {
    super.initState();

    passwordVisible = true;

    _emailController.addListener(
      () {
        setState(() {
          _emailErrorText = null;
        });
      },
    );
    _passwordController.addListener(
      () {
        setState(() {
          _passwordErrorText = null;
        });
      },
    );
    _nameController.addListener(
      () {
        setState(() {
          _nameErrorText = null;
        });
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic>? args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        registrationData.email = args['email'] ?? "";
        _emailController.text = args['email'] ?? "";

        registrationData.password = args['password'] ?? "";
        _passwordController.text = args['password'] ?? "";
      }
    });

    _pageViewController = PageController();
    _tabController = TabController(length: _maxPageIndex + 1, vsync: this);

    hobbies = Provider.of<ApiProvider>(context, listen: false).apiResponse !=
            null
        ? Provider.of<ApiProvider>(context, listen: false).apiResponse!.hobbies
        : {};
    genders = Provider.of<ApiProvider>(context, listen: false).apiResponse !=
            null
        ? Provider.of<ApiProvider>(context, listen: false).apiResponse!.genders
        : {};
    relations =
        Provider.of<ApiProvider>(context, listen: false).apiResponse != null
            ? Provider.of<ApiProvider>(context, listen: false)
                .apiResponse!
                .relationShip
            : {};
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();

    _pageViewController.dispose();
    _tabController.dispose();
    _scrollControllerInfos.dispose();
    _scrollControllerGendersAttractions.dispose();
  }

  Map<String, dynamic> sexualitiesAPI = {};
  Map<String, dynamic> relationsAPI = {};

  //===== FUNCTIONS API =====
  int? isFormValid(RegistrationData r) {
    if (r.email == "" ||
        !isValidEmail(r.email) ||
        r.password == "" ||
        !passwordRegex.hasMatch(r.password) ||
        r.name == "" ||
        !nameRegex.hasMatch(r.name)) {
      setState(() {
        if (r.email == "" || !isValidEmail(r.email)) {
          _emailErrorText = AppLocalizations.of(context)!.emailInvalid;
        }
        if (r.password == "" || !passwordRegex.hasMatch(r.password)) {
          _passwordErrorText = AppLocalizations.of(context)!.passwordInvalid;
        }
        if (r.name == "" || !nameRegex.hasMatch(r.name)) {
          _nameErrorText = AppLocalizations.of(context)!.firstNameInvalid;
        }
      });
      return 0;
    }
    if (r.attractions.isEmpty || r.gender == null) {
      setState(() {
        if (r.gender == null) {
          _genderError = true;
        }
        if (r.attractions.isEmpty) {
          _attractionError = true;
        }
      });
      return 3;
    }
    if (r.relationShip == null) {
      setState(() {
        _relationError = true;
      });
      return 4;
    }
    if (_cguChecked == null || !_cguChecked!) {
      setState(() {
        _cguChecked = false;
      });
      return 4;
    }
    return null;
  }

  Future<void> _register() async {
    if (_isRegisterLoading == true) {
      return;
    }

    int? problemIndex = isFormValid(registrationData);
    if (problemIndex != null) {
      _updateCurrentPageIndex(problemIndex);
      return;
    }

    setState(() {
      _isRegisterLoading = true;
    });

    const String apiUrl = '$API_URL/users/signup';

    final Map<String, dynamic> requestData = {
      'name': registrationData.name,
      'email': registrationData.email,
      'password': registrationData.password,
      'location': {
        "type": "Point",
        "coordinates": [
          registrationData.location.latitude,
          registrationData.location.longitude
        ]
      },
      'searchDist': registrationData.searchDist.round(),
      'birthday': DateFormat('yyyy-MM-dd').format(registrationData.birthDate),
      'ageMinSought': registrationData.minAge.round(),
      'ageMaxSought': registrationData.maxAge.round(),
      'gender': registrationData.gender,
      'attractions': registrationData.attractions,
      'relationShip': registrationData.relationShip,
      'hobbies': registrationData.hobbies,
      'images': [null, null, null],
    };

    try {
      final http.Response response = await client.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print(response);

      if (response.statusCode == 201) {
        print('Register successful please confirm email');
        sendToLoginScreen(context);
        showSnackBarGood(
            context, AppLocalizations.of(context)!.validateAccountWithEmail);
      } else {
        print('Registration failed');
        print(response.statusCode);
        print(response.body);
        showSnackBarBad(context);
      }
    } catch (e) {
      print('Error: $e');
    }

    if (mounted) {
      setState(() {
        _isRegisterLoading = false;
      });
    }
  }
  //==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MATCHER',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _maxPageIndex + 1,
                  (index) => pageIndicator(index == _currentPageIndex),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageViewController,
                  onPageChanged: (index) => _handlePageViewChanged(index),
                  children: <Widget>[
                    Scrollbar(
                      controller: _scrollControllerInfos,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: SingleChildScrollView(
                          controller: _scrollControllerInfos,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .yourLoginInfo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                    ),
                                  ),
                                  TextField(
                                    controller: _emailController,
                                    maxLength: emailMaxLength,
                                    maxLengthEnforcement: MaxLengthEnforcement
                                        .truncateAfterCompositionEnds,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)!
                                          .emailAddress,
                                    ).copyWith(
                                        labelStyle: Theme.of(context)
                                            .inputDecorationTheme
                                            .labelStyle,
                                        hintStyle: Theme.of(context)
                                            .inputDecorationTheme
                                            .hintStyle,
                                        border: Theme.of(context)
                                            .inputDecorationTheme
                                            .border,
                                        errorText: _emailErrorText),
                                    onChanged: (value) {
                                      registrationData.email = value;
                                    },
                                  ),
                                  TextField(
                                    maxLength: passwordMaxLength,
                                    maxLengthEnforcement: MaxLengthEnforcement
                                        .truncateAfterCompositionEnds,
                                    obscureText: passwordVisible,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      hintText: AppLocalizations.of(context)!
                                          .password,
                                      labelText: AppLocalizations.of(context)!
                                          .password,
                                      helperText: AppLocalizations.of(context)!
                                          .passwordRequirement,
                                      errorText: _passwordErrorText,
                                      suffixIcon: IconButton(
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
                                      border: Theme.of(context)
                                          .inputDecorationTheme
                                          .border,
                                    ),
                                    controller: _passwordController,
                                    onChanged: (value) {
                                      registrationData.password = value;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .whatsYourName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall!
                                            .copyWith(
                                              height: 0,
                                            ),
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: _nameController,
                                    maxLength: nameMaxLength,
                                    maxLines: 1,
                                    keyboardType: TextInputType.name,
                                    maxLengthEnforcement: MaxLengthEnforcement
                                        .truncateAfterCompositionEnds,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      errorText: _nameErrorText,
                                      labelText: AppLocalizations.of(context)!
                                          .firstName,
                                    ).copyWith(
                                      labelStyle: Theme.of(context)
                                          .inputDecorationTheme
                                          .labelStyle,
                                      border: Theme.of(context)
                                          .inputDecorationTheme
                                          .border,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        registrationData.name = value;
                                      });
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .whenWereBorn,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 100,
                                    child: CupertinoDatePicker(
                                      mode: CupertinoDatePickerMode.date,
                                      initialDateTime:
                                          registrationData.birthDate,
                                      maximumDate: DateTime.utc(
                                          DateTime.now().year - 18,
                                          DateTime.now().month,
                                          DateTime.now().day),
                                      minimumDate: DateTime(1900, 1),
                                      dateOrder: DatePickerDateOrder.dmy,
                                      onDateTimeChanged:
                                          (DateTime newDateTime) {
                                        setState(() {
                                          registrationData.birthDate =
                                              newDateTime;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              ageSoughtForm(
                                isRegistration: true,
                                minAgeSought: registrationData.minAge,
                                maxAgeSought: registrationData.maxAge,
                                callback: (newAgeMin, newAgeMax) {
                                  setState(() {
                                    registrationData.minAge = newAgeMin;
                                    registrationData.maxAge = newAgeMax;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    MapScreen(
                        isRegistration: true,
                        location: registrationData.location,
                        searchDist: registrationData.searchDist,
                        callback: (newLoc, newSearchDist) {
                          setState(() {
                            registrationData.location = newLoc;
                            registrationData.searchDist = newSearchDist;
                          });
                        }),
                    HobbiesScreen(
                      isRegistration: true,
                      selectedHobbies: registrationData.hobbies,
                      callback: (newHobbies) {
                        registrationData.hobbies = List.from(newHobbies);
                      },
                    ),
                    Scrollbar(
                      controller: _scrollControllerGendersAttractions,
                      child: SingleChildScrollView(
                        controller: _scrollControllerGendersAttractions,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GenderForm(
                                isError: _genderError,
                                isRegistration: true,
                                gender: registrationData.gender ?? 0,
                                callback: (newGender) {
                                  setState(() {
                                    _genderError = false;
                                    registrationData.gender = newGender;
                                  });
                                },
                              ),
                              AttractionsForm(
                                isError: _attractionError,
                                isRegistration: true,
                                attractions: registrationData.attractions,
                                callback: (newAttractions) {
                                  setState(() {
                                    _attractionError = false;
                                    registrationData.attractions =
                                        newAttractions;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox.expand(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RelationForm(
                          isRegistration: true,
                          isError: _relationError,
                          relationShip: registrationData.relationShip ?? 0,
                          callback: (newRelationShip) {
                            setState(() {
                              _relationError = false;
                              registrationData.relationShip = newRelationShip;
                            });
                          },
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: CheckboxListTile(
                              tristate: true,
                              title: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "${AppLocalizations.of(context)!.agreeWith} "),
                                    RichText(
                                      text: TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .termsOfService,
                                        style: TextStyle(
                                          color: AppColors.grey,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.grey,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            await launchUrl(matcherUrlCGU);
                                          },
                                      ),
                                    ),
                                  ]),
                              value: _cguChecked,
                              side: _cguChecked == false
                                  ? BorderSide(color: AppColors.red, width: 2)
                                  : Theme.of(context).checkboxTheme.side,
                              onChanged: (value) {
                                if (mounted) {
                                  setState(() {
                                    _cguChecked = value ?? false;
                                  });
                                }
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
                                onPressed: () {
                                  _register();
                                },
                                child: _isRegisterLoading
                                    ? const SizedBox(
                                        height: 15,
                                        width: 15,
                                        child: CircularProgressIndicator())
                                    : Text(AppLocalizations.of(context)!
                                        .finalize)),
                          ),
                        )
                      ],
                    ))
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: PageNavigator(
              tabController: _tabController,
              currentPageIndex: _currentPageIndex,
              maxPageIndex: _maxPageIndex,
              onUpdateCurrentPageIndex: _updateCurrentPageIndex,
            ),
          ),
        ]),
      ),
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    // if(!_hasAskedLocation && currentPageIndex==1){
    //   _getCurrentPosition();
    // }
    _tabController.index = currentPageIndex;
    if (mounted) {
      setState(() {
        _currentPageIndex = currentPageIndex;
      });
    }
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _updateCurrentPageIndex(int index) async {
    _tabController.index = index;
    _pageViewController.jumpToPage(index);
  }
}

class PageNavigator extends StatelessWidget {
  const PageNavigator(
      {super.key,
      required this.tabController,
      required this.currentPageIndex,
      required this.onUpdateCurrentPageIndex,
      required this.maxPageIndex});

  final int currentPageIndex;
  final int maxPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: (currentPageIndex > 0)
                  ? ForwardButton(
                      isLoading: false,
                      onPressed: () {
                        if (currentPageIndex > 0) {
                          onUpdateCurrentPageIndex(currentPageIndex - 1);
                        }
                      },
                      isBackward: true,
                    )
                  : SizedBox(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: (currentPageIndex < maxPageIndex)
                  ? SizedBox(
                      width: 150,
                      child: IntrinsicHeight(
                        child: ElevatedButton(
                          child: Text(
                            "Suivant",
                          ),
                          onPressed: () {
                            if (currentPageIndex < maxPageIndex) {
                              onUpdateCurrentPageIndex(currentPageIndex + 1);
                            }
                          },
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
          ],
        ));
  }
}
