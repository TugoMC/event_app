import 'package:flutter/material.dart';
import 'package:event_app/data/services/auth_service.dart';
import 'package:event_app/presentation/screens/auth/otp_verification_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _error;

  Future<void> _handlePhoneSignIn(String phone) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authService.signInWithPhone(
        phone,
        (String verificationId) {
          // Succès - Navigation vers l'écran OTP
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                verificationId: verificationId,
              ),
            ),
          );
        },
        (String error) {
          // Erreur pendant la vérification
          if (mounted) {
            setState(() {
              _error = error;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro';
    }
    // Validation simple du format (peut être améliorée selon vos besoins)
    if (value.length < 8 || value.length > 12) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vérification du téléphone'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Entrez votre numéro de téléphone pour recevoir un code de vérification',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixText: '+225 ',
                  border: OutlineInputBorder(),
                  helperText: 'Example: 0123456789',
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                enabled: !_isLoading,
              ),
              if (_error != null)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          // Ajout du préfixe pays (+225) au numéro
                          _handlePhoneSignIn('+225${_phoneController.text}');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Envoyer le code'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
