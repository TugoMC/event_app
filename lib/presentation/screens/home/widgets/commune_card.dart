// commune_card.dart
import 'package:flutter/material.dart';
import 'package:event_app/presentation/screens/communes/commune_detail_screen.dart';

class CommuneCard extends StatelessWidget {
  final String name;
  final String imageUrl;

  const CommuneCard({
    super.key,
    required this.name,
    required this.imageUrl,
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
            builder: (context) => CommuneDetailsScreen(communeName: name),
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey[300]);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(color: Colors.grey[300]);
                  },
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
