// lib/presentation/screens/onboarding/onboarding_screen.dart
import 'package:event_app/presentation/screens/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/onboarding_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Trouvez l'espace idéal",
      "description":
          "Découvrez des lieux uniques et adaptés à tous vos événements, des réunions intimes aux grandes célébrations.",
      "imagePath": "assets/images/onboarding_event.png",
    },
    {
      "title": "Réservation simplifiée",
      "description":
          "Recherchez, filtrez et réservez en quelques clics. Notre plateforme vous guide à chaque étape.",
      "imagePath": "assets/images/onboarding_reservation.png",
    },
    {
      "title": "Des souvenirs spéciaux",
      "description":
          "Des espaces vérifiés et des avis authentiques pour faire de chaque événement une réussite.",
      "imagePath": "assets/images/onboarding_memories.png",
    },
    {
      "title": "Localisation",
      "description":
          "Voulez-vous que nous vous suggérions des espaces événementiels près de chez vous ?",
      "imagePath": "assets/images/onboarding_location.png",
    },
  ];

  Future<bool> _requestLocationPermission() async {
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  void _nextPage() async {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      // Dernière page (localisation)
      bool permissionGranted = await _requestLocationPermission();

      if (permissionGranted) {
        // Marquer l'onboarding comme terminé et passer à l'écran principal
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstTime', false);

        // Naviguer vers l'écran de connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
      } else {
        // Afficher un message si la permission est refusée
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'La localisation est recommandée pour une meilleure expérience'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: onboardingData.length,
              itemBuilder: (context, index) => OnboardingContent(
                title: onboardingData[index]['title']!,
                description: onboardingData[index]['description']!,
                imagePath: onboardingData[index]['imagePath']!,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
              (index) => _buildDot(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8773F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      _currentPage == onboardingData.length - 1
                          ? "COMMENCER"
                          : "SUIVANT",
                      style: const TextStyle(
                        fontFamily: 'Sen',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // Mettre à jour la préférence
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool('isFirstTime', false);

                    // Naviguer vers la page de login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreen()),
                    );
                  },
                  child: const Text(
                    "Passer",
                    style: TextStyle(
                      fontFamily: 'Sen',
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF8773F8)
            : const Color(0xFFC3B9FB),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
