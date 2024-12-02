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
    final screenWidth = MediaQuery.of(context).size.width;

    final cardWidth = screenWidth * 0.2; // 20% de la largeur de l'écran
    final minCardWidth = 70.0; // Largeur minimum
    final maxCardWidth = 100.0; // Largeur maximum

    final finalWidth = cardWidth.clamp(minCardWidth, maxCardWidth);
    final containerHeight = finalWidth * 0.9;
    final totalHeight = containerHeight + 20; // Gardé comme avant

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
            // Suppression du Expanded et du Text
            const SizedBox(
                height: 20), // Espace vide pour conserver la hauteur totale
          ],
        ),
      ),
    );
  }
}
