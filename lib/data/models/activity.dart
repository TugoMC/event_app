// lib/data/models/activity.dart
import 'package:flutter/material.dart';

class Activity {
  final String type;
  final IconData icon;

  Activity({
    required this.type,
    required this.icon,
  });

  // Ajout des méthodes de sérialisation
  Map<String, dynamic> toJson() => {
        'type': type,
        'icon': icon.codePoint,
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        type: json['type'],
        icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      );
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
