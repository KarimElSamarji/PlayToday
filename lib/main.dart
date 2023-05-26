// ignore_for_file: prefer_const_constructors
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:playtoday/provider/dark_theme_provider.dart';
import 'package:playtoday/screen/auth_screen.dart';
import 'package:playtoday/screen/home_screen.dart';
import 'package:playtoday/screen/search_screen.dart';
import 'package:playtoday/screen/login_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:playtoday/theme/theme_constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final navigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          return themeChangeProvider;
        })
      ],
      child:
          Consumer<DarkThemeProvider>(builder: (contex, themeProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: Styles.themeData(themeProvider.getDarkTheme, context),
          home: AnimatedSplash(),
        );
      }),
    );
  }
}

class AnimatedSplash extends StatelessWidget {
  const AnimatedSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(children: [
        Expanded(child: Image.asset('assets/PTLogo.png')),
      ]),
      backgroundColor: Colors.black,
      nextScreen: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Something went wrong!'));
            } else if (snapshot.hasData) {
              return SearchSreen();
            } else {
              return AuthScreen();
            }
          }),
      splashIconSize: 800,
      duration: 3000,
      splashTransition: SplashTransition.slideTransition,
      pageTransitionType: PageTransitionType.leftToRight,
    );
  }
}
