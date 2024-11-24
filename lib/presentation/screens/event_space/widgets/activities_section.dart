import 'package:event_app/data/models/activity.dart';
import 'package:flutter/material.dart';

class ActivitiesSection extends StatelessWidget {
  final List<Activity> activities;

  const ActivitiesSection({Key? key, required this.activities})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Activités',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculer combien d'éléments peuvent tenir dans la largeur
            double itemWidth =
                80; // Largeur de base pour chaque élément (avatar + texte)
            double spacing = 16; // Espacement uniforme entre les éléments

            int itemsPerRow =
                (constraints.maxWidth / (itemWidth + spacing)).floor();
            // Assurer au moins 2 éléments par ligne
            itemsPerRow = itemsPerRow < 2 ? 2 : itemsPerRow;

            // Calculer le padding horizontal pour centrer les éléments
            double totalItemsWidth = itemsPerRow * itemWidth;
            double totalSpacingWidth = (itemsPerRow - 1) * spacing;
            double remainingWidth =
                constraints.maxWidth - (totalItemsWidth + totalSpacingWidth);
            double horizontalPadding = remainingWidth / 2;

            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding.clamp(16, double.infinity)),
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.start,
                children: activities.map((activity) {
                  return SizedBox(
                    width: itemWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              const Color(0xFF8773F8).withOpacity(0.2),
                          child: Icon(activity.icon,
                              color: const Color(0xFF8773F8)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activity.type,
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
