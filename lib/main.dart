import 'package:event_app/presentation/screens/auth/auth_screen.dart';
import 'package:event_app/presentation/screens/profile/notif_navig.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

// Ajout du service
class UserCollectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUserToCollection(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'userId': user.uid,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur : $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs : $e');
      return [];
    }
  }

  Future<void> updateUserInfo(
      String userId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(userId).update(updatedData);
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'utilisateur : $e');
    }
  }

  Future<bool> userExists(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      return userDoc.exists;
    } catch (e) {
      print(
          'Erreur lors de la vérification de l\'existence de l\'utilisateur : $e');
      return false;
    }
  }
}

// Global instance du service
final userCollectionService = UserCollectionService();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC5m9Iu29cLJj-REdNpmNJ4zrhrk4m099k",
        appId: "1:782808634409:android:d43ff62177296db3997838",
        messagingSenderId: "782808634409",
        projectId: "event-app-14690",
        storageBucket: "event-app-14690.firebasestorage.app",
        authDomain: "event-app-14690.firebaseapp.com",
        measurementId: "G-XYZ1234567",
      ),
    );

    // Configurer l'écouteur d'authentification
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // Vérifier si l'utilisateur existe déjà dans Firestore
        userCollectionService.userExists(user.uid).then((exists) {
          if (!exists) {
            // Ajouter l'utilisateur à Firestore s'il n'existe pas
            userCollectionService.addUserToCollection(user);
          }
        });
      }
    });
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // Update background notification handler
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');

    final BuildContext? context = navigatorKey.currentContext;
    if (context != null) {
      NotificationNavigationService.handleNotificationTap(
          context, message.data);
    }
  });

  // Update terminated state notification handler
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      final BuildContext? context = navigatorKey.currentContext;
      if (context != null) {
        NotificationNavigationService.handleNotificationTap(
            context, message.data);
      }
    }
  });

  runApp(MyApp(navigatorKey: navigatorKey));
}

// Update the _handleNotificationNavigation function
void _handleNotificationNavigation(RemoteMessage message) {
  final BuildContext? context = navigatorKey.currentContext;
  if (context != null) {
    NotificationNavigationService.handleNotificationTap(context, message.data);
  }
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'anabe',
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Sen',
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
  // Ajout d'un flag pour suivre si l'initialisation est terminée
  bool _initialized = false;
  bool _isFirstTime = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkOnboardingAndAuthStatus();
  }

  Future<void> _checkOnboardingAndAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Ne mettre à jour l'état qu'une fois que toutes les vérifications sont terminées
    setState(() {
      _isFirstTime = isFirstTime;
      _currentUser = currentUser;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Afficher un écran de chargement pendant l'initialisation
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Une fois initialisé, retourner l'écran approprié
    if (_isFirstTime) {
      return const OnboardingScreen();
    } else if (_currentUser == null) {
      return AuthScreen();
    } else {
      return const HomeScreen();
    }
  }
}
