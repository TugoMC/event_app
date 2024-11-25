import 'package:event_app/presentation/screens/auth/login_screen.dart';
import 'package:event_app/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    bool isConfirmPassword = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 10,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword
            ? !_isPasswordVisible
            : isConfirmPassword
                ? !_isConfirmPasswordVisible
                : false,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 22,
          ),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(15),
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black45,
            fontSize: 19,
          ),
          suffixIcon: (isPassword || isConfirmPassword)
              ? IconButton(
                  icon: Icon(
                    (isPassword
                            ? _isPasswordVisible
                            : _isConfirmPasswordVisible)
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.black26,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isPassword) {
                        _isPasswordVisible = !_isPasswordVisible;
                      } else {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      }
                    });
                  },
                )
              : null,
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            if (isPassword) return 'Entrez votre mot de passe';
            if (isConfirmPassword) return 'Confirmez votre mot de passe';
            return 'Entrez votre email';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF8983FF),
              Color(0xFFA5A0FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: size.height * 0.03),
                const Text(
                  "Créer un compte",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 37,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Rejoignez-nous !",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    color: Colors.white70,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                _buildTextField("Email", _emailController),
                _buildTextField("Mot de passe", _passwordController,
                    isPassword: true),
                _buildTextField(
                  "Confirmer le mot de passe",
                  _confirmPasswordController,
                  isConfirmPassword: true,
                ),
                SizedBox(height: size.height * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    width: size.width,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextButton(
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6C63FF),
                              ),
                            )
                          : const Text(
                              "S'inscrire",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C63FF),
                                fontSize: 22,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.07),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: "Déjà un compte ? ",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        children: const [
                          TextSpan(
                            text: "Se connecter",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
