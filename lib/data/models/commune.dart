import 'city.dart';

class Commune {
  final String id;
  final String name;
  final String photoUrl;
  final String cityId; // Toujours lier la commune à une city via cityId
  City? city; // Propriété optionnelle pour stocker l'objet City associé

  Commune({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.cityId,
    this.city,
  });

  // Méthodes de sérialisation
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photoUrl': photoUrl,
        'cityId': cityId,
        'city': city
            ?.toJson(), // Inclure les informations de la city si elles sont disponibles
      };

  factory Commune.fromJson(Map<String, dynamic> json, {City? city}) {
    return Commune(
      id: json['id'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      cityId: json['cityId'],
      city:
          city, // Vous pouvez passer la city complète ici si elle est déjà en mémoire
    );
  }

  // Méthode pour récupérer la City associée à cette commune (si nécessaire)
  City getCity(List<City> allCities) {
    // Throws an error if no matching city is found
    return allCities.firstWhere((city) => city.id == cityId, orElse: () {
      throw Exception("City with id $cityId not found");
    });
  }
}
