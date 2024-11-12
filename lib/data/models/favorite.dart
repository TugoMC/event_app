// lib/data/models/favorite.dart
class Favorite {
  final String id;
  final String userId;
  final String eventSpaceId;
  final DateTime createdAt;
  final bool isActive;

  Favorite({
    required this.id,
    required this.userId,
    required this.eventSpaceId,
    required this.createdAt,
    this.isActive = true,
  });

  Favorite copyWith({
    bool? isActive,
  }) {
    return Favorite(
      id: id,
      userId: userId,
      eventSpaceId: eventSpaceId,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Méthodes de sérialisation
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'eventSpaceId': eventSpaceId,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
      };

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json['id'],
        userId: json['userId'],
        eventSpaceId: json['eventSpaceId'],
        createdAt: DateTime.parse(json['createdAt']),
        isActive: json['isActive'],
      );
}
