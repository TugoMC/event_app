// lib/data/models/city.dart
import 'commune.dart';

class City {
  final String id;
  final String name;
  final List<Commune> communes;

  City({
    required this.id,
    required this.name,
    List<Commune>? communes,
  }) : this.communes = communes ?? [];

  // Factory constructor pour créer une City avec ses communes
  factory City.withCommunes({
    required String id,
    required String name,
    required List<Commune> communes,
  }) {
    return City(
      id: id,
      name: name,
      communes: communes.where((commune) => commune.cityId == id).toList(),
    );
  }

  // Méthodes de sérialisation
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'communes': communes.map((c) => c.toJson()).toList(),
      };

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json['id'],
        name: json['name'],
        communes:
            (json['communes'] as List).map((c) => Commune.fromJson(c)).toList(),
      );
}

// Liste des villes
final List<City> cities = [
  City(id: "1", name: "Abidjan"),
  City(id: "2", name: "Bouaké"),
  City(id: "3", name: "Daloa"),
  City(id: "4", name: "San-Pédro"),
  City(id: "5", name: "Yamoussoukro"),
  City(id: "6", name: "Korhogo"),
  City(id: "7", name: "Man"),
  City(id: "8", name: "Adzopé"),
  City(id: "9", name: "Sassandra"),
  City(id: "10", name: "Bondoukou"),
];
