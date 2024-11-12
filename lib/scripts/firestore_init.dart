// lib/scripts/firestore_init.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/activity.dart';
import '../data/models/city.dart';
import '../data/models/commune.dart';
import '../data/models/event_space.dart';

class FirestoreInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Référence des collections
  late CollectionReference _activitiesRef;
  late CollectionReference _citiesRef;
  late CollectionReference _communesRef;
  late CollectionReference _eventSpacesRef;
  late CollectionReference _reviewsRef;
  late CollectionReference _favoritesRef;

  // Compteurs pour le suivi
  int _activitiesCount = 0;
  int _citiesCount = 0;
  int _communesCount = 0;
  int _eventSpacesCount = 0;

  FirestoreInitializer() {
    _activitiesRef = _firestore.collection('activities');
    _citiesRef = _firestore.collection('cities');
    _communesRef = _firestore.collection('communes');
    _eventSpacesRef = _firestore.collection('event_spaces');
    _reviewsRef = _firestore.collection('reviews');
    _favoritesRef = _firestore.collection('favorites');
  }

  Future<void> initializeDatabase() async {
    try {
      print('🚀 Début de l\'initialisation de la base de données...\n');

      await _clearCollections();

      // Initialisation dans l'ordre avec vérification
      await _initializeActivities();
      await _initializeCities();
      await _initializeCommunes();
      await _createDemoEventSpaces();

      // Affichage du résumé
      _printSummary();
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation: $e');
      rethrow;
    }
  }

  Future<void> _clearCollections() async {
    print('🧹 Nettoyage des collections existantes...');

    final collections = [
      _activitiesRef,
      _citiesRef,
      _communesRef,
      _eventSpacesRef,
      _reviewsRef,
      _favoritesRef
    ];

    for (var collection in collections) {
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
    }
    print('✅ Collections existantes nettoyées\n');
  }

  Future<void> _initializeActivities() async {
    print('📝 Initialisation des activités...');
    print('Nombre d\'activités à créer: ${activities.length}');

    try {
      for (var activity in activities) {
        DocumentReference docRef = await _activitiesRef.add({
          'type': activity.type,
          'icon': activity.icon.codePoint,
        });

        if ((await docRef.get()).exists) {
          _activitiesCount++;
        }
      }

      print('✅ ${_activitiesCount}/${activities.length} activités créées\n');
    } catch (e) {
      print('❌ Erreur lors de la création des activités: $e\n');
      rethrow;
    }
  }

  Future<void> _initializeCities() async {
    print('🏙 Initialisation des villes...');
    print('Nombre de villes à créer: ${cities.length}');

    try {
      for (var city in cities) {
        await _citiesRef.doc(city.id).set({
          'id': city.id,
          'name': city.name,
        });

        if ((await _citiesRef.doc(city.id).get()).exists) {
          _citiesCount++;
        }
      }

      print('✅ ${_citiesCount}/${cities.length} villes créées\n');
    } catch (e) {
      print('❌ Erreur lors de la création des villes: $e\n');
      rethrow;
    }
  }

  Future<void> _initializeCommunes() async {
    print('🏘 Initialisation des communes...');
    print('Nombre de communes à créer: ${allCommunes.length}');

    try {
      for (var commune in allCommunes) {
        await _communesRef.doc(commune.id).set({
          'id': commune.id,
          'name': commune.name,
          'photoUrl': commune.photoUrl,
          'cityId': commune.cityId,
        });

        if ((await _communesRef.doc(commune.id).get()).exists) {
          _communesCount++;
        }
      }

      print('✅ ${_communesCount}/${allCommunes.length} communes créées\n');
    } catch (e) {
      print('❌ Erreur lors de la création des communes: $e\n');
      rethrow;
    }
  }

  Future<void> _createDemoEventSpaces() async {
    print('🏢 Création des espaces événementiels de démonstration...');

    final List<Map<String, dynamic>> demoSpaces = [
      {
        'name': 'Espace Cocody Events',
        'description':
            'Un espace moderne et élégant situé au cœur de Cocody, parfait pour vos événements haut de gamme. Grande capacité d\'accueil et équipements de dernière génération.',
        'communeId': '1', // Cocody
        'cityId': '1', // Abidjan
        'activities': ['Restaurant', 'Salle de concert'],
        'hours': 'Lu-Ve: 09:00-22:00, Sa-Di: 10:00-23:00',
        'price': 250000.0,
        'phoneNumber': '+225 07 07 07 07 07',
        'photos': [
          'https://example.com/cocody-events-1.jpg',
          'https://example.com/cocody-events-2.jpg'
        ],
        'location': '2 Boulevard de France, Cocody',
      },
      {
        'name': 'Plateau Business Center',
        'description':
            'Centre d\'affaires et espace événementiel au Plateau, équipé pour les conférences et séminaires professionnels. Vue panoramique sur la ville.',
        'communeId': '2', // Plateau
        'cityId': '1', // Abidjan
        'activities': ['Restaurant', 'Salle de concert', 'Café'],
        'hours': 'Lu-Ve: 08:00-20:00, Sa: 09:00-18:00',
        'price': 300000.0,
        'phoneNumber': '+225 07 08 09 10 11',
        'photos': [
          'https://example.com/plateau-center-1.jpg',
          'https://example.com/plateau-center-2.jpg'
        ],
        'location': '15 Avenue de la République, Plateau',
      }
    ];

    try {
      for (var spaceData in demoSpaces) {
        // Vérification que la commune et la ville existent
        var communeDoc = await _communesRef.doc(spaceData['communeId']).get();
        var cityDoc = await _citiesRef.doc(spaceData['cityId']).get();

        if (!communeDoc.exists || !cityDoc.exists) {
          print('⚠️ Commune ou ville non trouvée pour: ${spaceData['name']}');
          continue;
        }

        var commune =
            Commune.fromJson(communeDoc.data() as Map<String, dynamic>);
        var city = City.fromJson(cityDoc.data() as Map<String, dynamic>);

        var spaceActivities = activities
            .where(
                (activity) => spaceData['activities'].contains(activity.type))
            .toList();

        var eventSpace = EventSpace(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: spaceData['name'],
          description: spaceData['description'],
          commune: commune,
          city: city,
          activities: spaceActivities,
          reviews: [],
          hours: spaceData['hours'],
          price: spaceData['price'],
          phoneNumber: spaceData['phoneNumber'],
          photos: List<String>.from(spaceData['photos']),
          location: spaceData['location'],
          createdAt: DateTime.now(),
          createdBy: 'system',
        );

        await _eventSpacesRef.doc(eventSpace.id).set(eventSpace.toJson());

        if ((await _eventSpacesRef.doc(eventSpace.id).get()).exists) {
          _eventSpacesCount++;
          print('✅ Créé: ${eventSpace.name}');
        }
      }

      print(
          '✅ ${_eventSpacesCount}/${demoSpaces.length} espaces événementiels créés\n');
    } catch (e) {
      print('❌ Erreur lors de la création des espaces événementiels: $e\n');
      rethrow;
    }
  }

  void _printSummary() {
    print('''
📊 Résumé de l'initialisation:
-----------------------------
🎯 Activités: ${_activitiesCount}/${activities.length}
🏙 Villes: ${_citiesCount}/${cities.length}
🏘 Communes: ${_communesCount}/${allCommunes.length}
🏢 Espaces événementiels: $_eventSpacesCount

✨ Initialisation terminée!
    ''');
  }
}
