import 'commune.dart';
import 'activity.dart';
import 'review.dart';

class EventSpace {
  final String id;
  final String name;
  final String description;
  final Commune commune; // Référence à la Commune
  final String city;
  final List<Activity>
      activities; // liste des activités (piscine, restaurant, bar...)
  final List<Review> reviews;
  final String hours;
  final double price;
  final String phoneNumber;
  final List<String> photos; // Liste des photos supplémentaires
  final String location; // url google maps

  EventSpace({
    required this.id,
    required this.name,
    required this.description,
    required this.commune,
    required this.city,
    required this.activities,
    required this.reviews,
    required this.location,
    required this.hours,
    required this.price,
    required this.phoneNumber,
    required this.photos,
  });
}

// pour créer une instance de EventSpace il faut un nom, une description, une commune, une ville, une liste d'activités, un lieu, des heures, un prix, un numéro de téléphone, et une liste de photos.
// les avis sont liés à l'espace evénement et seront affichés sur la page de l'espace	evénement.