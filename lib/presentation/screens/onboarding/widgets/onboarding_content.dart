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
          // Conteneur d'image responsive
          ConstrainedBox(
            constraints: BoxConstraints(
              // Largeur maximale de 80% de la largeur de l'écran
              maxWidth: screenWidth * 0.8,
              // Hauteur maximale de 80% de la largeur de l'écran pour garder un rapport hauteur/largeur proportionnel
              maxHeight: screenWidth * 0.8,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200], // Background gris par défaut
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // En cas d'erreur de chargement ou d'absence d'image
                    return Container(
                      color: Colors.grey[200],
                    );
                  },
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
