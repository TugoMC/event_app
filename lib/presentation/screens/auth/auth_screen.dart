// auth_screen.dart
import 'package:event_app/data/services/auth_service.dart';
import 'package:event_app/presentation/screens/auth/login_screen.dart';
import 'package:event_app/presentation/screens/auth/otp_verification_screen.dart';
import 'package:event_app/presentation/screens/auth/phone_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:event_app/presentation/screens/home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _error;

  Widget _buildSocialButton({
    required String text,
    required String icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              height: 24,
              width: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePhoneSignIn(String phone) async {
    setState(() => _isLoading = true);
    await _authService.signInWithPhone(
      phone,
      (verificationId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              verificationId: verificationId,
            ),
          ),
        );
      },
      (error) => setState(() => _error = error),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenue',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 32),
              if (_error != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              _buildSocialButton(
                text: 'Continuer avec Google',
                icon: 'assets/icons/google.svg',
                onPressed: _handleGoogleSignIn,
              ),
              _buildSocialButton(
                text: 'Continuer avec Email',
                icon: 'assets/icons/email.svg',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                ),
              ),
              _buildSocialButton(
                text: 'Continuer avec Téléphone',
                icon: 'assets/icons/phone.svg',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PhoneVerificationScreen()),
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
