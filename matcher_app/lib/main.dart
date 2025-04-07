import 'dart:async';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:subtil_app/l10n/app_localizations.dart';
import 'package:subtil_app/screens/change_email_screen.dart';
import 'package:subtil_app/services/jwt_service.dart';
import 'package:subtil_app/services/notifs_service.dart';
import 'package:subtil_app/navbar.dart';
import 'package:subtil_app/providers/api_data_provider.dart';
import 'package:subtil_app/providers/user_provider.dart';
import 'package:subtil_app/screens/auth_screen.dart';
import 'package:subtil_app/screens/forgot_password_screen.dart';
import 'package:subtil_app/screens/login_screen.dart';
import 'package:subtil_app/screens/register_screen.dart';
import 'package:subtil_app/screens/unknow_screen.dart';
import 'package:subtil_app/services/various_service.dart';
import 'screens/reset_password_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final notifications = Notifications();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  handleMessage(message);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    handleMessage(message);
  });

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    saveJWT(newToken);
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MainApp());
  FlutterNativeSplash.remove();
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();

    _appLinks.uriLinkStream.listen((uri) {
      handleIncomingUri(uri);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentState!.context;
      notifications.initializeNotifications(navigatorKey, context);
    });
  }

  void handleIncomingUri(Uri? uri) {
    print("Test URI incoming :");
    print(uri);
    if (uri != null) {
      if (uri.toString().startsWith('matcher://resetpassword') ||
          (uri.toString().contains('matcher-app.fr/validation') &&
              uri.queryParameters["resetpassword"] != null)) {
        final queryParameters = uri.queryParameters;
        final String? token = queryParameters['token'];
        if (token != null && token != "") {
          navigatorKey.currentState!.pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(token!),
            ),
          );
        }
      } else if (uri.toString().startsWith('matcher://goto')) {
        navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(
            builder: (context) => const NavBar(
              indexAsked: 1,
            ),
          ),
        );
      } else if (uri.toString().contains('matcher-app.fr/validation')) {
        showSnackBarGood(
            navigatorKey.currentContext!,
            AppLocalizations.of(navigatorKey.currentContext!)!
                .sucessConfirmEmail);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        theme: AppThemes.darkTheme,
        darkTheme: AppThemes.darkTheme,
        navigatorKey: navigatorKey,
        themeMode: ThemeMode.dark,
        routes: {
          '/': (context) => const AuthScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/forgotPassword': (context) => ForgotPasswordScreen(),
          '/changeEmail': (context) => ChangeEmailScreen(),
          '/flow': (context) => const NavBar(
                indexAsked: 1,
              ),
          '/inbox': (context) => const NavBar(
                indexAsked: 0,
              ),
          '/likesSent': (context) => const NavBar(
                indexAsked: 0,
                secondaryIndexAsked: 1,
              ),
          '/chats': (context) => const NavBar(
                indexAsked: 0,
                secondaryIndexAsked: 2,
              ),
          '/profile': (context) => const NavBar(
                indexAsked: 2,
              ),
          '/404': (context) => const UnknowScreen(),
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (BuildContext context) => const UnknowScreen(),
          );
        },
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}

class AppColors {
  static const black = Color(0xFF121212);
  static const white = Color(0xFFFFF7FA);
  static const white2 = Color.fromARGB(255, 245, 245, 245);

  //Palet 1
  static const shimmerMainColor = Color(0xFF9CA3AF);
  static const shimmerHighlightColor = Color(0xFFA9B0BD);

  static const darkBlue = Color(0xFF070E20);

  static const peach = Color(0XFFF8CBB4);
  static const salmon = Color(0XFFF88A9E);
  static const salmonLight = Color(0xFFFF9EAF);
  static const pink = Color(0XFFEB4994);
  static const pinkLight = Color.fromARGB(255, 255, 220, 226);
  static const yellow = Colors.yellow;

  static const lightGrey = Color.fromARGB(255, 196, 196, 196);
  static const grey = Colors.grey;
  static const darkGrey = Color.fromARGB(255, 105, 105, 105);

  static const red = Color(0xFFF44336);
  static const green = Color(0xFF4CAF50);

  static const purple = Color.fromRGBO(107, 71, 238, 1);

  static const Map<int, Color> colorSwatch = {
    50: Color.fromRGBO(235, 73, 148, .1),
    100: Color.fromRGBO(235, 73, 148, .2),
    200: Color.fromRGBO(235, 73, 148, .3),
    300: Color.fromRGBO(235, 73, 148, .4),
    400: Color.fromRGBO(235, 73, 148, .5),
    500: Color.fromRGBO(235, 73, 148, .6),
    600: Color.fromRGBO(235, 73, 148, .7),
    700: Color.fromRGBO(235, 73, 148, .8),
    800: Color.fromRGBO(235, 73, 148, .9),
    900: Color.fromRGBO(235, 73, 148, 1),
  };

  static const MaterialColor customSwatch =
      MaterialColor(0xFFEB4994, colorSwatch);
}

class AppThemes {
  //=== DARK THEME ===
  static final darkTheme = ThemeData(
      primarySwatch: AppColors.customSwatch,
      colorScheme: ColorScheme(
          primary: AppColors.salmon,
          onPrimary: AppColors.pink,
          secondary: AppColors.peach,
          onSecondary: AppColors.white,
          surface: AppColors.darkBlue,
          onSurface: AppColors.white,
          surfaceContainerHighest: AppColors.darkBlue.withOpacity(0.9),
          error: AppColors.red,
          onError: AppColors.white,
          brightness: Brightness.dark),
      scaffoldBackgroundColor: AppColors.darkBlue,
      brightness: Brightness.dark,
      canvasColor: AppColors.black,
      dialogTheme: const DialogThemeData(
          surfaceTintColor: AppColors.white,
          backgroundColor: AppColors.black,
          shadowColor: AppColors.black,
          titleTextStyle: TextStyle(
            fontSize: 15,
            color: AppColors.white,
            fontFamily: 'C800',
          )),
      textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.white,
            fontWeight: FontWeight.w400,
          ),
          bodySmall: TextStyle(
            fontSize: 15,
            color: AppColors.white,
            fontWeight: FontWeight.w300,
          ),
          displayLarge: TextStyle(
            fontSize: 55,
            fontWeight: FontWeight.normal,
            color: AppColors.white,
            fontFamily: 'C800',
            letterSpacing: 0,
          ),
          displayMedium: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.normal,
            color: AppColors.white,
            fontFamily: 'C800',
            letterSpacing: 0,
          ),
          displaySmall: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColors.white,
              fontFamily: 'C800',
              letterSpacing: 0,
              height: 4)),
      appBarTheme: const AppBarTheme(
        color: AppColors.darkBlue,
      ),
      dividerTheme:
          DividerThemeData(space: 50, color: AppColors.white.withOpacity(0.5)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            foregroundColor: AppColors.black,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            disabledBackgroundColor: AppColors.lightGrey,
            disabledForegroundColor: AppColors.darkGrey),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        foregroundColor: AppColors.salmon,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all<bool>(true),
        thumbColor: WidgetStateProperty.all<Color>(AppColors.salmon),
      ),
      textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
              splashFactory: NoSplash.splashFactory,
              foregroundColor: WidgetStatePropertyAll(AppColors.grey),
              textStyle: WidgetStatePropertyAll(
                  TextStyle(decoration: TextDecoration.underline)))),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateColor.resolveWith((states) => AppColors.salmon),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
        overlayColor: WidgetStateColor.resolveWith((states) => AppColors.white),
        checkColor: WidgetStateColor.resolveWith((states) => AppColors.pink),
        side: WidgetStateBorderSide.resolveWith(
          (states) => const BorderSide(width: 2.0, color: AppColors.salmon),
        ),
      ),
      sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.salmon,
          inactiveTrackColor: AppColors.white,
          thumbColor: AppColors.salmon,
          overlayColor: AppColors.white,
          overlayShape: RoundSliderOverlayShape(overlayRadius: 15.0),
          activeTickMarkColor: Colors.transparent,
          valueIndicatorColor: AppColors.white),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            minimumSize: const Size(double.infinity, 55),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            foregroundColor: AppColors.white,
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            )),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: AppColors.white),
        hintStyle: TextStyle(color: AppColors.white.withOpacity(0.5)),
        helperStyle:
            TextStyle(color: AppColors.white.withOpacity(0.7), fontSize: 12),
        suffixStyle: const TextStyle(color: AppColors.white),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.salmon),
            borderRadius: BorderRadius.circular(12.0)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.white),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBlue,
        selectedItemColor: AppColors.salmon,
        selectedIconTheme: IconThemeData(
          size: 32,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.darkBlue,
          indicatorColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          indicatorShape: null,
          elevation: 0,
          height: 52,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 0),
          ),
          iconTheme: const WidgetStatePropertyAll(
              IconThemeData(color: AppColors.grey, size: 23)),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide));
}
