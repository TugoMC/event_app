// auth_state.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:event_app/data/services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
}

class AuthState extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;
  bool _isLoading = false;
  late StreamSubscription<User?> _authStateSubscription;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthState() {
    _init();
  }

  void _init() {
    _authStateSubscription = _authService.authStateChanges.listen(
      (User? user) {
        _user = user;
        _status = user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      },
    );
  }

  // Connexion avec email
  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmail(email, password);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Inscription avec email
  Future<void> registerWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.registerWithEmail(email, password);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Connexion avec Google
  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();
      _clearError();
    } catch (e) {
      // Message d'erreur plus explicite pour l'utilisateur
      _setError(e.toString().contains('expiré')
          ? 'La connexion a pris trop de temps. Vérifiez votre connexion internet.'
          : 'Erreur de connexion Google. Veuillez réessayer.');
    } finally {
      _setLoading(false);
    }
  }

  // Connexion avec téléphone - Étape 1: Envoi du code
  Future<void> signInWithPhone(
    String phoneNumber,
    Function(String) onCodeSent,
  ) async {
    _setLoading(true);
    try {
      await _authService.signInWithPhone(
        phoneNumber,
        onCodeSent,
        _setError,
      );
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Connexion avec téléphone - Étape 2: Vérification du code
  Future<void> verifyPhoneCode(
    String verificationId,
    String smsCode,
  ) async {
    _setLoading(true);
    try {
      await _authService.verifyOTP(verificationId, smsCode);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _clearError();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Méthodes utilitaires privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _status = AuthStatus.authenticating;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
