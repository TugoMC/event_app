// lib\data\services\auth_service.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // État courant de l'utilisateur
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Connexion avec Email/Mot de passe
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Inscription avec Email/Mot de passe
  Future<UserCredential> registerWithEmail(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Connexion avec Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Configuration explicite du GoogleSignIn pour différents appareils
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // Ajoutez des paramètres spécifiques pour améliorer la compatibilité
        signInOption: SignInOption.standard,
      );

      // Désactiver le rechargement automatique du compte précédent
      await googleSignIn.signOut();

      print('Début de la connexion Google');

      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Délai de connexion Google dépassé');
          throw 'La connexion a expiré. Veuillez réessayer.';
        },
      );

      print('GoogleSignInAccount: ${googleUser?.email}');

      if (googleUser == null) {
        print('Connexion annulée par l\'utilisateur');
        throw 'Connexion Google annulée';
      }

      print('Obtention des tokens d\'authentification');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Vérification supplémentaire des tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Tokens manquants');
        throw 'Impossible d\'obtenir les jetons d\'authentification';
      }

      print('Access Token obtenu: ${googleAuth.accessToken}');
      print('ID Token obtenu: ${googleAuth.idToken}');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Connexion à Firebase');
      final userCredential =
          await _auth.signInWithCredential(credential).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Délai de connexion Firebase dépassé');
          throw 'La connexion a expiré. Veuillez réessayer.';
        },
      );

      print('Connexion réussie pour: ${userCredential.user?.email}');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } on TimeoutException catch (e) {
      print('Timeout: $e');
      throw 'La connexion a pris trop de temps. Vérifiez votre connexion internet.';
    } catch (e) {
      print('Autre erreur: $e');
      throw 'Erreur de connexion Google : ${e.toString()}';
    }
  }

  // Connexion avec Téléphone
  Future<void> signInWithPhone(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onError,
  ) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_handleAuthException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: Duration(seconds: 60),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Vérification du code OTP
  Future<UserCredential> verifyOTP(
    String verificationId,
    String smsCode,
  ) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Gestion des erreurs Firebase
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'invalid-phone-number':
        return 'Le numéro de téléphone est invalide.';
      case 'invalid-verification-code':
        return 'Le code de vérification est invalide.';
      default:
        return 'Une erreur est survenue : ${e.message}';
    }
  }
}
