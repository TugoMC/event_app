// lib/presentation/screens/onboarding/widgets/onboarding_content.dart
import 'package:flutter/material.dart';

class OnboardingContent extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenir la largeur de l'écran
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF8773F8).withOpacity(1.0),
                    const Color(0xFF8773F8).withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Image.asset(
                    imagePath,
                    width: screenWidth * 0.5, // Contrôlez précisément la taille
                    height: screenWidth * 0.5,
                    fit: BoxFit.contain, // Gardez l'image entière visible
                    errorBuilder: (context, error, stackTrace) {
                      // En cas d'erreur de chargement ou d'absence d'image
                      return Container(
                        color: const Color(0xFF8773F8).withOpacity(0.5),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Sen',
            ),
          ),
          const SizedBox(height: 15),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'Sen',
            ),
          ),
        ],
      ),
    );
  }
}
