class Commune {
  final String name;
  final String photoUrl;

  Commune({
    required this.name,
    required this.photoUrl,
  });
}

List<Commune> communes = [
  Commune(
    name: "Abidjan",
    photoUrl: "https://example.com/photo1.jpg",
  ),
  Commune(
    name: "Bouaké",
    photoUrl: "https://example.com/photo2.jpg",
  ),
  Commune(
    name: "Korhogo",
    photoUrl: "https://example.com/photo3.jpg",
  ),
  Commune(
    name: "Daloa",
    photoUrl: "https://example.com/photo4.jpg",
  ),
  Commune(
    name: "San-Pédro",
    photoUrl: "https://example.com/photo5.jpg",
  ),
];

// ces communes seront affichée dans un dropdown menu lors de la créaton d'un event space