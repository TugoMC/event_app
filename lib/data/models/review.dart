class Review {
  final String userId; // ID unique de l'utilisateur
  final int rating; // Note de 1 à 5
  final String comment;

  Review({
    required this.userId,
    required this.rating,
    required this.comment,
  });
}


// ici on va pouvoir ajouter des avis à un espace evénement