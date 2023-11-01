import 'package:eventos_partenaires/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_config/flutter_config.dart';
import 'package:eventos_partenaires/config/config.dart';
import 'package:eventos_partenaires/pages/HomePage.dart';
import 'package:eventos_partenaires/pages/loginui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:connectivity_checker/connectivity_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? login = prefs.getBool('login');
  await FlutterConfig.loadEnvVariables();

  final connected = await checkInternetConnection();
  if (!connected) {
    runApp(MyApp2());
  } else {
    runApp(login == null
        ? MyApp1()
        : login
            ? MyApp()
            : MyApp1());
  }
}

Future<bool> checkInternetConnection() async {
  final isConnected = await ConnectivityWrapper.instance.isConnected;
  if (isConnected) {
    return true;
  } else {
    return false;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventOs Partenaires',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: AppColors.secondary),
      ),
      home: HomePage(),
      routes: {
        'login': (context) => Login(),
        'homepage': (context) => HomePage()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventOs Patenaires',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: AppColors.secondary),
      ),
      home: Login(),
      routes: {
        'login': (context) => Login(),
        'homepage': (context) => HomePage()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventos',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        hintColor: AppColors.secondary,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NotConnectedScreen(),
      routes: {
        'login': (context) => Login(),
        'homepage': (context) => HomePage()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotConnectedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/Connection_Lost.png',
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          const Positioned(
            bottom: 200,
            left: 30,
            child: Text('Pas de Connexion',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                )),
          ),
          const Positioned(
            bottom: 150,
            left: 30,
            child: Text(
              'S\'il vous plaît, vérifiez votre connexion internet \net réessayer.',
              style: TextStyle(
                color: Colors.black38,
                fontSize: 16,
                letterSpacing: 1,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Positioned(
              bottom: 50,
              left: 40,
              right: 40,
              child: InkWell(
                onTap: () {
                  main();
                },
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.blue[800]!,
                  ),
                  child: Center(
                      child: Text(
                    'Réessayer'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                ),
              )),
        ],
      ),
    );
  }
}
