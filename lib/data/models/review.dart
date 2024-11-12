// lib/data/models/review.dart
class Review {
  final String id;
  final String userId;
  final String eventSpaceId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;

  Review({
    required this.id,
    required this.userId,
    required this.eventSpaceId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
  }) {
    if (!isValidRating()) {
      throw ArgumentError('La note doit être comprise entre 1 et 5');
    }
    if (comment.trim().isEmpty) {
      throw ArgumentError('Le commentaire ne peut pas être vide');
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
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  // Méthodes de sérialisation
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'eventSpaceId': eventSpaceId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'isVerified': isVerified,
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        userId: json['userId'],
        eventSpaceId: json['eventSpaceId'],
        rating: json['rating'],
        comment: json['comment'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        isVerified: json['isVerified'],
      );
}
