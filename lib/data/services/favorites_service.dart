// lib/services/favorites_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/models/favorite.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir tous les favoris d'un utilisateur
  Stream<List<Favorite>> getUserFavorites(String userId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Favorite.fromJson(doc.data())).toList());
  }

  // Vérifier si un espace est déjà en favori
  Future<bool> isEventSpaceFavorited(String userId, String eventSpaceId) async {
    final querySnapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('eventSpaceId', isEqualTo: eventSpaceId)
        .where('isActive', isEqualTo: true)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Ajouter ou mettre à jour un favori
  Future<void> toggleFavorite(String userId, String eventSpaceId) async {
    final querySnapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('eventSpaceId', isEqualTo: eventSpaceId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Créer un nouveau favori
      final favorite = Favorite(
        id: _firestore.collection('favorites').doc().id,
        userId: userId,
        eventSpaceId: eventSpaceId,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _firestore
          .collection('favorites')
          .doc(favorite.id)
          .set(favorite.toJson());
    } else {
      // Inverser l'état du favori existant
      final doc = querySnapshot.docs.first;
      final favorite = Favorite.fromJson(doc.data());
      final updatedFavorite = favorite.copyWith(
        isActive: !favorite.isActive,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('favorites')
          .doc(doc.id)
          .update(updatedFavorite.toJson());
    }
  }
}
