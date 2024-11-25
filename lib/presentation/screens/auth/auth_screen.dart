import 'package:flutter/material.dart';
import 'package:event_app/data/services/auth_service.dart';
import 'package:event_app/presentation/screens/auth/login_screen.dart';
import 'package:event_app/presentation/screens/auth/register_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _error;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String iconPath,
    required String text,
    required double height,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Stack(
          children: [
            // SVG Icon with fixed position
            Positioned(
              left: 32, // Position fixe pour tous les icônes
              top: 0,
              bottom: 0,
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  height: 20,
                  width: 20,
                ),
              ),
            ),
            // Centered text
            Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: const Color(0xFFF5F5F5),
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            // Top Image Container
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: size.height * 0.45,
                width: size.width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  color: Color(0xFF6C63FF),
                  image: DecorationImage(
                    image: AssetImage("images/image.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Content Container
            Positioned(
              top: size.height * 0.48,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Discover your\nDream job Here",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Explore all the most exciting jobs roles\nbased on your interest And study major",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      _buildButton(
                        height: size.height * 0.06,
                        onPressed: _handleGoogleSignIn,
                        iconPath: 'assets/icons/google.svg',
                        text: "Continue with Google",
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        height: size.height * 0.06,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()),
                          );
                        },
                        iconPath: 'assets/icons/email.svg',
                        text: "S'inscrire",
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        height: size.height * 0.06,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        iconPath: 'assets/icons/email.svg',
                        text: "Se connecter",
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
