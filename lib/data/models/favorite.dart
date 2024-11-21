// lib/data/models/favorite.dart

class Favorite {
  final String id;
  final String userId;
  final String eventSpaceId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final int version;

  Favorite({
    required this.id,
    required this.userId,
    required this.eventSpaceId,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.version = 1,
  }) {
    if (userId.trim().isEmpty) {
      throw ArgumentError('L\'ID de l\'utilisateur ne peut pas être vide');
    }
    if (eventSpaceId.trim().isEmpty) {
      throw ArgumentError(
          'L\'ID de l\'espace d\'événement ne peut pas être vide');
    }
  }

  /// Vérifie si le favori est actif et correspond à l'utilisateur spécifié
  bool isActiveForUser(String userId) {
    return this.userId == userId && isActive;
  }

  /// Vérifie si le favori correspond à l'espace d'événement spécifié
  bool isForEventSpace(String eventSpaceId) {
    return this.eventSpaceId == eventSpaceId && isActive;
  }

  Favorite copyWith({
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return Favorite(
      id: id,
      userId: userId,
      eventSpaceId: eventSpaceId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      version: version + 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'eventSpaceId': eventSpaceId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'isActive': isActive,
        'version': version,
      };

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      userId: json['userId'],
      eventSpaceId: json['eventSpaceId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isActive: json['isActive'] ?? true,
      version: json['version'] ?? 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Favorite &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          eventSpaceId == other.eventSpaceId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode ^ eventSpaceId.hashCode;

  @override
  String toString() {
    return 'Favorite{id: $id, userId: $userId, eventSpaceId: $eventSpaceId, '
        'isActive: $isActive, version: $version}';
  }
}

extension FavoriteListExtension on List<Favorite> {
  /// Obtenir tous les favoris actifs pour un utilisateur
  List<Favorite> getActiveFavoritesForUser(String userId) {
    return where((favorite) => favorite.isActiveForUser(userId)).toList();
  }

  /// Obtenir tous les favoris pour un espace d'événement
  List<Favorite> getFavoritesForEventSpace(String eventSpaceId) {
    return where((favorite) => favorite.isForEventSpace(eventSpaceId)).toList();
  }

  /// Vérifier si un espace d'événement est en favori pour un utilisateur
  bool isEventSpaceFavorited(String eventSpaceId, String userId) {
    return any((favorite) =>
        favorite.eventSpaceId == eventSpaceId &&
        favorite.isActiveForUser(userId));
  }

  /// Obtenir le nombre total de favoris actifs pour un espace d'événement
  int getFavoriteCountForEventSpace(String eventSpaceId) {
    return where((favorite) => favorite.isForEventSpace(eventSpaceId)).length;
  }
}
