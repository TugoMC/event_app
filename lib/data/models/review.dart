// lib/data/models/review.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String eventSpaceId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Review({
    required this.id,
    required this.userId,
    required this.eventSpaceId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    List<Review>? existingReviews, // Nouveau paramètre optionnel
    String?
        currentReviewId, // Identifiant de la review en cours de modification
  }) {
    if (!isValidRating()) {
      throw ArgumentError('La note doit être comprise entre 1 et 5');
    }
    if (comment.trim().isEmpty) {
      throw ArgumentError('Le commentaire ne peut pas être vide');
    }

    // Validation modifiée pour permettre la mise à jour de sa propre review
    if (existingReviews != null) {
      final existingUserReviews = existingReviews
          .where((review) =>
              review.userId == userId && review.eventSpaceId == eventSpaceId)
          .toList();

      // Autoriser la mise à jour si la review existe déjà et correspond à l'ID en cours de modification
      if (existingUserReviews.isNotEmpty &&
          !existingUserReviews.any((review) => review.id == currentReviewId)) {
        throw ArgumentError(
            'Un utilisateur ne peut laisser qu\'une seule review par espace d\'événement');
      }
    }
  }

  bool isValidRating() {
    return rating >= 1 && rating <= 5;
  }

  Review copyWith({
    String? comment,
    int? rating,
    DateTime? updatedAt,
    bool? isVerified,
  }) {
    return Review(
      id: id,
      userId: userId,
      eventSpaceId: eventSpaceId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      updatedAt:
          updatedAt ?? DateTime.now(), // Mettre à jour la date de modification
    );
  }

  // Méthodes de sérialisation inchangées
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'eventSpaceId': eventSpaceId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        userId: json['userId'],
        eventSpaceId: json['eventSpaceId'],
        rating: json['rating'],
        comment: json['comment'],
        createdAt: (json['createdAt'] is Timestamp)
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] is Timestamp
            ? (json['updatedAt'] as Timestamp).toDate()
            : (json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'])
                : null),
      );
}
