import 'package:event_app/data/models/event_space.dart';

class Recommendations {
  final String id;
  final List<EventSpace> eventSpaces;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String userId;
  final int version;
  final bool isActive; // Nouveau champ

  Recommendations({
    String? id,
    required this.eventSpaces,
    DateTime? createdAt,
    this.updatedAt,
    required this.userId,
    this.version = 1,
    this.isActive = false, // Valeur par défaut
  })  : id = id ?? DateTime.now().toIso8601String(),
        createdAt = createdAt ?? DateTime.now();

  // Mettre à jour toJson et fromJson pour inclure isActive
  Map<String, dynamic> toJson() => {
        'id': id,
        'eventSpaces': eventSpaces.map((es) => es.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'userId': userId,
        'version': version,
        'isActive': isActive, // Nouveau champ
      };

  factory Recommendations.fromJson(Map<String, dynamic> json) {
    return Recommendations(
      id: json['id'],
      eventSpaces: (json['eventSpaces'] as List)
          .map((esJson) => EventSpace.fromJson(esJson))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      userId: json['userId'],
      version: json['version'] ?? 1,
      isActive: json['isActive'] ?? false, // Nouveau champ
    );
  }

  // Modifier copyWith pour inclure isActive
  Recommendations copyWith({
    List<EventSpace>? eventSpaces,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Recommendations(
      id: id,
      eventSpaces: eventSpaces ?? this.eventSpaces,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      userId: userId,
      version: version + 1,
      isActive: isActive ?? this.isActive,
    );
  }
}
