// lib/data/models/commune.dart
import 'city.dart';

class Commune {
  final String id;
  final String name;
  final String photoUrl;
  final String cityId;

  Commune({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.cityId,
  });

  // Méthodes de sérialisation
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photoUrl': photoUrl,
        'cityId': cityId,
      };

  factory Commune.fromJson(Map<String, dynamic> json) => Commune(
        id: json['id'],
        name: json['name'],
        photoUrl: json['photoUrl'],
        cityId: json['cityId'],
      );
}

// Liste des communes pour Abidjan (cityId: "1")
final List<Commune> allCommunes = [
  // Abidjan (13 communes)
  Commune(
      id: "1",
      name: "Cocody",
      photoUrl: "https://example.com/cocody.jpg",
      cityId: "1"),
  Commune(
      id: "2",
      name: "Plateau",
      photoUrl: "https://example.com/plateau.jpg",
      cityId: "1"),
  Commune(
      id: "3",
      name: "Marcory",
      photoUrl: "https://example.com/marcory.jpg",
      cityId: "1"),
  Commune(
      id: "4",
      name: "Treichville",
      photoUrl: "https://example.com/treichville.jpg",
      cityId: "1"),
  Commune(
      id: "5",
      name: "Yopougon",
      photoUrl: "https://example.com/yopougon.jpg",
      cityId: "1"),
  Commune(
      id: "6",
      name: "Abobo",
      photoUrl: "https://example.com/abobo.jpg",
      cityId: "1"),
  Commune(
      id: "7",
      name: "Adjamé",
      photoUrl: "https://example.com/adjame.jpg",
      cityId: "1"),
  Commune(
      id: "8",
      name: "Attécoubé",
      photoUrl: "https://example.com/attecoube.jpg",
      cityId: "1"),
  Commune(
      id: "9",
      name: "Koumassi",
      photoUrl: "https://example.com/koumassi.jpg",
      cityId: "1"),
  Commune(
      id: "10",
      name: "Port-Bouët",
      photoUrl: "https://example.com/port-bouet.jpg",
      cityId: "1"),
  Commune(
      id: "11",
      name: "Songon",
      photoUrl: "https://example.com/songon.jpg",
      cityId: "1"),
  Commune(
      id: "12",
      name: "Bingerville",
      photoUrl: "https://example.com/bingerville.jpg",
      cityId: "1"),
  Commune(
      id: "13",
      name: "Anyama",
      photoUrl: "https://example.com/anyama.jpg",
      cityId: "1"),

  // Bouaké (cityId: "2")
  Commune(
      id: "14",
      name: "Bouaké-Centre",
      photoUrl: "https://example.com/bouake-centre.jpg",
      cityId: "2"),
  Commune(
      id: "15",
      name: "Nimbo",
      photoUrl: "https://example.com/nimbo.jpg",
      cityId: "2"),
  Commune(
      id: "16",
      name: "Dar-es-Salam",
      photoUrl: "https://example.com/dar-es-salam.jpg",
      cityId: "2"),
  Commune(
      id: "17",
      name: "Koko",
      photoUrl: "https://example.com/koko.jpg",
      cityId: "2"),
  Commune(
      id: "18",
      name: "Belleville",
      photoUrl: "https://example.com/belleville.jpg",
      cityId: "2"),

  // Daloa (cityId: "3")
  Commune(
      id: "19",
      name: "Daloa-Centre",
      photoUrl: "https://example.com/daloa-centre.jpg",
      cityId: "3"),
  Commune(
      id: "20",
      name: "Tazibouo",
      photoUrl: "https://example.com/tazibouo.jpg",
      cityId: "3"),
  Commune(
      id: "21",
      name: "Gbokora",
      photoUrl: "https://example.com/gbokora.jpg",
      cityId: "3"),
  Commune(
      id: "22",
      name: "Lobia",
      photoUrl: "https://example.com/lobia.jpg",
      cityId: "3"),
  Commune(
      id: "23",
      name: "Marais",
      photoUrl: "https://example.com/marais.jpg",
      cityId: "3"),

  // San-Pédro (cityId: "4")
  Commune(
      id: "24",
      name: "San-Pédro-Centre",
      photoUrl: "https://example.com/san-pedro-centre.jpg",
      cityId: "4"),
  Commune(
      id: "25",
      name: "Séwéké",
      photoUrl: "https://example.com/seweke.jpg",
      cityId: "4"),
  Commune(
      id: "26",
      name: "Bardo",
      photoUrl: "https://example.com/bardo.jpg",
      cityId: "4"),
  Commune(
      id: "27",
      name: "Zone Industrielle",
      photoUrl: "https://example.com/zone-industrielle.jpg",
      cityId: "4"),
  Commune(
      id: "28",
      name: "Port",
      photoUrl: "https://example.com/port.jpg",
      cityId: "4"),

  // Yamoussoukro (cityId: "5")
  Commune(
      id: "29",
      name: "Yamoussoukro-Centre",
      photoUrl: "https://example.com/yamoussoukro-centre.jpg",
      cityId: "5"),
  Commune(
      id: "30",
      name: "Dioulakro",
      photoUrl: "https://example.com/dioulakro.jpg",
      cityId: "5"),
  Commune(
      id: "31",
      name: "N'Zuessi",
      photoUrl: "https://example.com/nzuessi.jpg",
      cityId: "5"),
  Commune(
      id: "32",
      name: "Quartier Millionnaire",
      photoUrl: "https://example.com/millionnaire.jpg",
      cityId: "5"),
  Commune(
      id: "33",
      name: "Habitat",
      photoUrl: "https://example.com/habitat.jpg",
      cityId: "5"),

  // Korhogo (cityId: "6")
  Commune(
      id: "34",
      name: "Korhogo-Centre",
      photoUrl: "https://example.com/korhogo-centre.jpg",
      cityId: "6"),
  Commune(
      id: "35",
      name: "Petit Paris",
      photoUrl: "https://example.com/petit-paris.jpg",
      cityId: "6"),
  Commune(
      id: "36",
      name: "Sonzoribougou",
      photoUrl: "https://example.com/sonzoribougou.jpg",
      cityId: "6"),
  Commune(
      id: "37",
      name: "Delafosse",
      photoUrl: "https://example.com/delafosse.jpg",
      cityId: "6"),
  Commune(
      id: "38",
      name: "Tchekelezo",
      photoUrl: "https://example.com/tchekelezo.jpg",
      cityId: "6"),

  // Man (cityId: "7")
  Commune(
      id: "39",
      name: "Man-Centre",
      photoUrl: "https://example.com/man-centre.jpg",
      cityId: "7"),
  Commune(
      id: "40",
      name: "Domoraud",
      photoUrl: "https://example.com/domoraud.jpg",
      cityId: "7"),
  Commune(
      id: "41",
      name: "Gbêpleu",
      photoUrl: "https://example.com/gbepleu.jpg",
      cityId: "7"),
  Commune(
      id: "42",
      name: "Doyagouiné",
      photoUrl: "https://example.com/doyagouine.jpg",
      cityId: "7"),
  Commune(
      id: "43",
      name: "Grand Gbapleu",
      photoUrl: "https://example.com/grand-gbapleu.jpg",
      cityId: "7"),

  // Adzopé (cityId: "8")
  Commune(
      id: "44",
      name: "Adzopé-Centre",
      photoUrl: "https://example.com/adzope-centre.jpg",
      cityId: "8"),
  Commune(
      id: "45",
      name: "Agnissankoi",
      photoUrl: "https://example.com/agnissankoi.jpg",
      cityId: "8"),
  Commune(
      id: "46",
      name: "Téléphone-Sans-Fil",
      photoUrl: "https://example.com/tsf.jpg",
      cityId: "8"),
  Commune(
      id: "47",
      name: "Commerce",
      photoUrl: "https://example.com/commerce.jpg",
      cityId: "8"),
  Commune(
      id: "48",
      name: "Diasson",
      photoUrl: "https://example.com/diasson.jpg",
      cityId: "8"),

  // Sassandra (cityId: "9")
  Commune(
      id: "49",
      name: "Sassandra-Centre",
      photoUrl: "https://example.com/sassandra-centre.jpg",
      cityId: "9"),
  Commune(
      id: "50",
      name: "Sassandra-Plage",
      photoUrl: "https://example.com/sassandra-plage.jpg",
      cityId: "9"),
  Commune(
      id: "51",
      name: "Phare",
      photoUrl: "https://example.com/phare.jpg",
      cityId: "9"),
  Commune(
      id: "52",
      name: "Port-Gauthier",
      photoUrl: "https://example.com/port-gauthier.jpg",
      cityId: "9"),
  Commune(
      id: "53",
      name: "Beyo",
      photoUrl: "https://example.com/beyo.jpg",
      cityId: "9"),

  // Bondoukou (cityId: "10")
  Commune(
      id: "54",
      name: "Bondoukou-Centre",
      photoUrl: "https://example.com/bondoukou-centre.jpg",
      cityId: "10"),
  Commune(
      id: "55",
      name: "Zanzan",
      photoUrl: "https://example.com/zanzan.jpg",
      cityId: "10"),
  Commune(
      id: "56",
      name: "Lycée",
      photoUrl: "https://example.com/lycee.jpg",
      cityId: "10"),
  Commune(
      id: "57",
      name: "Kamagaya",
      photoUrl: "https://example.com/kamagaya.jpg",
      cityId: "10"),
  Commune(
      id: "58",
      name: "Donzosso",
      photoUrl: "https://example.com/donzosso.jpg",
      cityId: "10"),
];

// Fonction d'initialisation des villes avec leurs communes
List<City> initializeCities() {
  return cities.map((city) {
    return City.withCommunes(
      id: city.id,
      name: city.name,
      communes: allCommunes,
    );
  }).toList();
}
