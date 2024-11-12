import 'package:event_app/data/models/activity.dart';
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC5m9Iu29cLJj-REdNpmNJ4zrhrk4m099k",
      appId: "1:782808634409:android:d43ff62177296db3997838",
      messagingSenderId: "782808634409",
      projectId: "event-app-14690",
      storageBucket: "event-app-14690.appspot.com",
      authDomain: "event-app-14690.firebaseapp.com",
    ),
  );

  try {
    print(
        '🔄 Démarrage du script de correction des espaces événementiels...\n');
    final fixer = EventSpaceFixer();
    await fixer.fixEventSpaces();
  } catch (e) {
    print('❌ Erreur fatale: $e');
  } finally {
    print('👋 Fin du script\n');
  }
}

class EventSpaceFixer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _eventSpacesCount = 0;

  // Liste des espaces événementiels de démonstration
  final List<Map<String, dynamic>> demoSpaces = [
    {
      'name': 'Espace Cocody Events',
      'description':
          'Un espace moderne et élégant situé au cœur de Cocody, parfait pour vos événements haut de gamme.',
      'communeId': '1',
      'cityId': '1',
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
          'Centre d\'affaires et espace événementiel au Plateau, équipé pour les conférences et séminaires professionnels.',
      'communeId': '2',
      'cityId': '1',
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

  Future<void> fixEventSpaces() async {
    print('🔍 Vérification des collections existantes...');

    // Vérifier si des espaces événementiels existent déjà
    final existingSpaces = await _firestore.collection('event_spaces').get();
    if (existingSpaces.docs.isNotEmpty) {
      print('⚠️ Suppression des espaces événementiels existants...');
      for (var doc in existingSpaces.docs) {
        await doc.reference.delete();
      }
      print('✅ Nettoyage terminé');
    }

    print('\n🏢 Création des espaces événementiels...');

    for (var spaceData in demoSpaces) {
      try {
        // Récupérer la commune et la ville
        final communeDoc = await _firestore
            .collection('communes')
            .doc(spaceData['communeId'])
            .get();
        final cityDoc = await _firestore
            .collection('cities')
            .doc(spaceData['cityId'])
            .get();

        if (!communeDoc.exists || !cityDoc.exists) {
          print('⚠️ Commune ou ville non trouvée pour: ${spaceData['name']}');
          continue;
        }

        // Créer les objets Commune et City sans la liste des communes
        final commune = Commune(
          id: communeDoc.id,
          name: communeDoc.data()!['name'],
          photoUrl: communeDoc.data()!['photoUrl'],
          cityId: communeDoc.data()!['cityId'],
        );

        final city = City(
          id: cityDoc.id,
          name: cityDoc.data()!['name'],
        );

        // Récupérer les activités
        final activitiesSnapshot =
            await _firestore.collection('activities').get();
        final availableActivities = activitiesSnapshot.docs
            .map((doc) => Activity(
                  type: doc.data()['type'] as String,
                  icon: IconData(doc.data()['icon'] as int,
                      fontFamily: 'MaterialIcons'),
                ))
            .toList();

        final selectedActivities = availableActivities
            .where(
                (activity) => spaceData['activities'].contains(activity.type))
            .toList();

        // Créer l'espace événementiel
        final eventSpace = EventSpace(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: spaceData['name'],
          description: spaceData['description'],
          commune: commune,
          city: city,
          activities: selectedActivities,
          reviews: [], // Liste vide pour les nouveaux espaces
          hours: spaceData['hours'],
          price: spaceData['price'],
          phoneNumber: spaceData['phoneNumber'],
          photos: List<String>.from(spaceData['photos']),
          location: spaceData['location'],
          createdAt: DateTime.now(),
          createdBy: 'system',
        );

        // Sauvegarder dans Firestore
        await _firestore
            .collection('event_spaces')
            .doc(eventSpace.id)
            .set(eventSpace.toJson());

        _eventSpacesCount++;
        print('✅ Créé: ${eventSpace.name}');
      } catch (e) {
        print('❌ Erreur lors de la création de ${spaceData['name']}: $e');
      }
    }

    print('\n📊 Résumé:');
    print('-----------------------------');
    print(
        '🏢 Espaces événementiels créés: $_eventSpacesCount/${demoSpaces.length}');
    print('\n✨ Correction terminée!');
  }
}
