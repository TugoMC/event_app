import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/home/home_screen.dart'; // Remplacez par l'écran principal réel
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase avec les options manuellement définies
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC5m9Iu29cLJj-REdNpmNJ4zrhrk4m099k", // Clé API
      appId:
          "1:782808634409:android:d43ff62177296db3997838", // ID de l'application
      messagingSenderId: "782808634409", // ID du destinataire de message
      projectId: "event-app-14690", // ID du projet
      storageBucket: "event-app-14690.firebasestorage.app", // Storage bucket
      authDomain: "event-app-14690.firebaseapp.com", // Auth domain
      measurementId: "G-XYZ1234567", // ID de mesure (optionnel)
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Onboarding Example',
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Sen', // Définir Sen comme police par défaut
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Sen'),
          displayMedium: TextStyle(fontFamily: 'Sen'),
          displaySmall: TextStyle(fontFamily: 'Sen'),
          headlineLarge: TextStyle(fontFamily: 'Sen'),
          headlineMedium: TextStyle(fontFamily: 'Sen'),
          headlineSmall: TextStyle(fontFamily: 'Sen'),
          titleLarge: TextStyle(fontFamily: 'Sen'),
          titleMedium: TextStyle(fontFamily: 'Sen'),
          titleSmall: TextStyle(fontFamily: 'Sen'),
          bodyLarge: TextStyle(fontFamily: 'Sen'),
          bodyMedium: TextStyle(fontFamily: 'Sen'),
          bodySmall: TextStyle(fontFamily: 'Sen'),
          labelLarge: TextStyle(fontFamily: 'Sen'),
          labelMedium: TextStyle(fontFamily: 'Sen'),
          labelSmall: TextStyle(fontFamily: 'Sen'),
        ),
      ),
      home: const EntryPoint(),
    );
  }
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  _EntryPointState createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTime') ?? true;

    setState(() {
      _isFirstTime = isFirstTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isFirstTime ? const OnboardingScreen() : HomeScreen();
  }
}
