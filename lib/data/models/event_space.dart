import 'package:cloud_firestore/cloud_firestore.dart';

import 'activity.dart';
import 'city.dart';
import 'commune.dart';
import 'favorite.dart';
import 'review.dart';
import 'package:geolocator/geolocator.dart';

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
  final List<String> photoUrls;
  final String location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String createdBy;
  final int version;

  static const int maxDescriptionLength = 1500;
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
    required this.photoUrls,
    required this.location,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    required this.createdBy,
    this.version = 1,
  }) {
    if (price < 0) {
      throw ArgumentError('Le prix ne peut pas être négatif');
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
    if (photoUrls.isEmpty) {
      throw ArgumentError('Au moins une URL de photo est requise');
    }

    // Validation des URLs des photos
    for (final photoUrl in photoUrls) {
      final uri = Uri.tryParse(photoUrl);
      if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        throw ArgumentError(
            'Toutes les photos doivent être des URLs valides (http ou https): $photoUrl est invalide');
      }
    }

    final locationUri = Uri.tryParse(location);
    if (locationUri == null ||
        !locationUri.host.contains('google.com') ||
        !locationUri.path.contains('maps')) {
      throw ArgumentError(
          'La propriété "location" doit être un URL valide de Google Maps.');
    }
  }

  /// Vérifie si un utilisateur a déjà laissé une review pour cet espace d'événement
  bool hasUserAlreadyReviewed(String userId) {
    return reviews.any((review) => review.userId == userId);
  }

  /// Ajoute une nouvelle review en vérifiant qu'un utilisateur n'a pas déjà reviewé
  void addReview(Review newReview) {
    if (hasUserAlreadyReviewed(newReview.userId)) {
      throw ArgumentError(
          'Un utilisateur ne peut laisser qu\'une seule review par espace d\'événement');
    }
    reviews.add(newReview);
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

  /// Vérifie si cet EventSpace contient toutes les activités spécifiées
  bool hasAllActivities(List<Activity> selectedActivities) {
    return selectedActivities.every((selectedActivity) =>
        activities.any((activity) => activity.type == selectedActivity.type));
  }

  /// Récupère la liste unique des activités utilisées dans les EventSpaces
  static List<Activity> getUsedActivities(List<EventSpace> eventSpaces) {
    final Set<Activity> uniqueActivities = {};

    for (var eventSpace in eventSpaces) {
      uniqueActivities.addAll(eventSpace.activities);
    }

    return uniqueActivities.toList();
  }

  /// Filtre les EventSpaces en fonction des activités sélectionnées
  static List<EventSpace> filterByActivities(
    List<EventSpace> eventSpaces,
    List<Activity> selectedActivities,
  ) {
    if (selectedActivities.isEmpty) {
      return eventSpaces;
    }

    return eventSpaces
        .where((eventSpace) => eventSpace.hasAllActivities(selectedActivities))
        .toList();
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
    List<String>? photoUrls,
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
      photoUrls: photoUrls ?? this.photoUrls,
      location: location ?? this.location,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      createdBy: createdBy,
      version: version + 1,
    );
  }

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
        'photoUrls': photoUrls,
        'location': location,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'isActive': isActive,
        'createdBy': createdBy,
        'version': version,
      };

  factory EventSpace.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic price) {
      if (price is int) {
        return price.toDouble();
      } else if (price is double) {
        return price;
      } else if (price is String) {
        return double.parse(price);
      }
      throw FormatException('Prix invalide: $price');
    }

    return EventSpace(
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
      price: parsePrice(json['price']),
      phoneNumber: json['phoneNumber'],
      photoUrls: List<String>.from(json['photoUrls']),
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isActive: json['isActive'] ?? true,
      createdBy: json['createdBy'],
      version: json['version'] ?? 1,
    );
  }

  static Future<EventSpace> fetchEventSpaceDetails(String eventSpaceId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('event_spaces')
        .doc(eventSpaceId)
        .get();

    if (!docSnapshot.exists) {
      throw ArgumentError('EventSpace not found');
    }

    return EventSpace.fromJson(docSnapshot.data()!);
  }
}

extension EventSpaceGeolocation on EventSpace {
  // Méthode pour extraire les coordonnées à partir d'un lien Google Maps
  LatLng? extractCoordinatesFromLocation() {
    // Regex pour extraire les coordonnées du format Google Maps URL
    final RegExp coordPattern = RegExp(r'@([-\d.]+),([-\d.]+)');

    // Si les coordonnées ne sont pas dans le format @lat,lon, essayez le format alternatif
    final matchAtStyle = coordPattern.firstMatch(location);
    if (matchAtStyle != null) {
      final latitude = double.tryParse(matchAtStyle.group(1)!);
      final longitude = double.tryParse(matchAtStyle.group(2)!);

      if (latitude != null && longitude != null) {
        return LatLng(latitude, longitude);
      }
    }

    // Regex pour extraire les coordonnées à partir du format de lien que vous avez fourni
    final RegExp altCoordPattern = RegExp(r'@([-\d.]+),([-\d.]+),');
    final matchAltStyle = altCoordPattern.firstMatch(location);

    if (matchAltStyle != null) {
      final latitude = double.tryParse(matchAltStyle.group(1)!);
      final longitude = double.tryParse(matchAltStyle.group(2)!);

      if (latitude != null && longitude != null) {
        return LatLng(latitude, longitude);
      }
    }

    return null;
  }

  // Calcule la distance entre deux points géographiques
  double calculateDistance(LatLng userLocation) {
    final spaceCoords = extractCoordinatesFromLocation();

    if (spaceCoords == null) {
      return double.infinity; // Distance maximale si coordonnées non trouvées
    }

    return Geolocator.distanceBetween(userLocation.latitude,
        userLocation.longitude, spaceCoords.latitude, spaceCoords.longitude);
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}
