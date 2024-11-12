// lib/data/models/event_space.dart
import 'package:event_app/data/models/activity.dart';

import 'city.dart';
import 'commune.dart';
import 'favorite.dart';
import 'review.dart';

class EventSpace {
  final String id;
  final String name;
  final String description;
  final Commune commune;
  final City city;
  final List<Activity> activities;
  final List<Review> reviews;
  final String hours;
  final double price;
  final String phoneNumber;
  final List<String> photos;
  final String location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String createdBy;
  final int version; // Pour le versioning

  static const int maxDescriptionLength = 1000;
  static const int minDescriptionLength = 50;

  EventSpace({
    required this.id,
    required this.name,
    required this.description,
    required this.commune,
    required this.city,
    required this.activities,
    required this.reviews,
    required this.hours,
    required this.price,
    required this.phoneNumber,
    required this.photos,
    required this.location,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    required this.createdBy,
    this.version = 1,
  }) {
    // Validations
    if (price < 0) {
      throw ArgumentError('Le prix ne peut pas être négatif');
    }
    if (!isValidPhoneNumber(phoneNumber)) {
      throw ArgumentError('Format de numéro de téléphone invalide');
    }
    if (!isValidHours(hours)) {
      throw ArgumentError('Format des heures invalide');
    }
    if (!commune.cityId.contains(city.id)) {
      throw ArgumentError('La commune doit appartenir à la ville spécifiée');
    }
    if (description.length < minDescriptionLength ||
        description.length > maxDescriptionLength) {
      throw ArgumentError(
          'La description doit contenir entre $minDescriptionLength et '
          '$maxDescriptionLength caractères');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError('Le nom ne peut pas être vide');
    }
    if (photos.isEmpty) {
      throw ArgumentError('Au moins une photo est requise');
    }
  }

  bool isValidPhoneNumber(String phone) {
    // Format attendu: +225 XX XX XX XX XX ou 07 XX XX XX XX
    final RegExp phoneRegex = RegExp(
        r'^\+225\s\d{2}\s\d{2}\s\d{2}\s\d{2}\s\d{2}$|^0[1-9]\s\d{2}\s\d{2}\s\d{2}\s\d{2}$');
    return phoneRegex.hasMatch(phone);
  }

  bool isValidHours(String hours) {
    // Format attendu: "Lu-Ve: 08:00-18:00, Sa: 09:00-15:00"
    final RegExp hoursRegex = RegExp(
        r'^([A-Za-z]{2}(-[A-Za-z]{2})?: \d{2}:\d{2}-\d{2}:\d{2}(, )?)+$');
    return hoursRegex.hasMatch(hours);
  }

  double getAverageRating() {
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
  }

  bool isFavoritedBy(String userId, List<Favorite> favorites) {
    return favorites
        .any((f) => f.eventSpaceId == id && f.userId == userId && f.isActive);
  }

  EventSpace copyWith({
    String? name,
    String? description,
    Commune? commune,
    City? city,
    List<Activity>? activities,
    List<Review>? reviews,
    String? hours,
    double? price,
    String? phoneNumber,
    List<String>? photos,
    String? location,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return EventSpace(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      commune: commune ?? this.commune,
      city: city ?? this.city,
      activities: activities ?? this.activities,
      reviews: reviews ?? this.reviews,
      hours: hours ?? this.hours,
      price: price ?? this.price,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photos: photos ?? this.photos,
      location: location ?? this.location,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      createdBy: createdBy,
      version: version + 1,
    );
  }

  // Méthodes de sérialisation
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'commune': commune.toJson(),
        'city': city.toJson(),
        'activities': activities.map((a) => a.toJson()).toList(),
        'reviews': reviews.map((r) => r.toJson()).toList(),
        'hours': hours,
        'price': price,
        'phoneNumber': phoneNumber,
        'photos': photos,
        'location': location,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'isActive': isActive,
        'createdBy': createdBy,
        'version': version,
      };

  factory EventSpace.fromJson(Map<String, dynamic> json) => EventSpace(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        commune: Commune.fromJson(json['commune']),
        city: City.fromJson(json['city']),
        activities: (json['activities'] as List)
            .map((a) => Activity.fromJson(a))
            .toList(),
        reviews:
            (json['reviews'] as List).map((r) => Review.fromJson(r)).toList(),
        hours: json['hours'],
        price: json['price'],
        phoneNumber: json['phoneNumber'],
        photos: List<String>.from(json['photos']),
        location: json['location'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        isActive: json['isActive'],
        createdBy: json['createdBy'],
        version: json['version'] ?? 1,
      );
}
