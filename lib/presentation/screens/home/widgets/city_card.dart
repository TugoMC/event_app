// city_card.dart
import 'package:flutter/material.dart';
import 'package:event_app/presentation/screens/villes/city_detail.dart';

class CityCard extends StatelessWidget {
  final String id;
  final String name;

  const CityCard({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    // Utiliser MediaQuery pour obtenir les dimensions de l'écran
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculer les dimensions de façon responsive
    final cardWidth = screenWidth * 0.2; // 20% de la largeur de l'écran
    final minCardWidth = 70.0; // Largeur minimum
    final maxCardWidth = 100.0; // Largeur maximum

    // Clamp garantit que la largeur reste dans les limites définies
    final finalWidth = cardWidth.clamp(minCardWidth, maxCardWidth);

    // La hauteur du container sera 90% de sa largeur
    final containerHeight = finalWidth * 0.9;

    // Hauteur totale avec un peu d'espace pour le texte
    final totalHeight = containerHeight + 20;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CityDetailScreen(
              cityId: id,
              cityName: name,
            ),
          ),
        );
      },
      child: SizedBox(
        width: finalWidth,
        height: totalHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: finalWidth,
              height: containerHeight,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
