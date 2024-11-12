// lib/models/favorite.dart

class Favorite {
  final String userId;
  final String eventSpaceId;

  Favorite({
    required this.userId,
    required this.eventSpaceId,
  });
}

// ici lorsque l'utilisateur clique sur l'icône de favoris, on ajoute un favori au tableau favorites
