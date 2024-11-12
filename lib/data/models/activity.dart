import 'package:flutter/material.dart';

class Activity {
  final String type; // Type d'activité (par exemple, restaurant, piscine, etc.)
  final IconData icon; // Icône associée à l'activité

  Activity({
    required this.type,
    required this.icon,
  });
}

// Liste des activités avec icônes associées
List<Activity> activities = [
  Activity(type: "Restaurant", icon: Icons.restaurant),
  Activity(type: "Piscine", icon: Icons.pool),
  Activity(type: "Salle de sport", icon: Icons.fitness_center),
  Activity(type: "Cinéma", icon: Icons.movie),
  Activity(type: "Théâtre", icon: Icons.theater_comedy),
  Activity(type: "Salle de concert", icon: Icons.music_note),
  Activity(type: "Café", icon: Icons.local_cafe),
  Activity(type: "Bibliothèque", icon: Icons.local_library),
  Activity(type: "Terrain de sport", icon: Icons.sports_soccer),
  Activity(type: "Spa", icon: Icons.spa),
];


// ces activités seront affichées dans un dropdown menu lors de la création d'un event space