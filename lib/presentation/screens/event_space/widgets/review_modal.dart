import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModal extends StatefulWidget {
  final String eventSpaceId;

  const ReviewModal({Key? key, required this.eventSpaceId}) : super(key: key);

  @override
  _ReviewModalState createState() => _ReviewModalState();
}

class _ReviewModalState extends State<ReviewModal> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 3;

  void _submitReview(BuildContext context) async {
    // Validation de base
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un commentaire')),
      );
      return;
    }

    try {
      // Récupérer l'utilisateur actuellement connecté
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Vous devez être connecté pour laisser un avis')),
        );
        return;
      }

      // Vérifier si l'utilisateur a déjà laissé un avis pour cet espace
      final existingReviewQuery = await FirebaseFirestore.instance
          .collection('reviews')
          .where('userId', isEqualTo: currentUser.uid)
          .where('eventSpaceId', isEqualTo: widget.eventSpaceId)
          .get();

      if (existingReviewQuery.docs.isNotEmpty) {
        // L'utilisateur a déjà laissé un avis, proposer une mise à jour
        _showUpdateReviewDialog(context, existingReviewQuery.docs.first.id);
        return;
      }

      // Créer la nouvelle review
      await FirebaseFirestore.instance.collection('reviews').add({
        'userId': currentUser.uid,
        'eventSpaceId': widget.eventSpaceId,
        'rating': _selectedRating,
        'comment': _commentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false,
      });

      // Fermer le modal
      if (context.mounted) Navigator.of(context).pop();

      // Afficher un message de succès
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre avis a été soumis')),
        );
      }
    } catch (e) {
      // Gérer les erreurs potentielles
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la soumission : ${e.toString()}')),
        );
      }
    }
  }

  void _showUpdateReviewDialog(BuildContext context, String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avis existant'),
        content: const Text('Voulez-vous mettre à jour votre avis précédent ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateExistingReview(reviewId);
            },
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  void _updateExistingReview(String reviewId) async {
    try {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .update({
        'rating': _selectedRating,
        'comment': _commentController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre avis a été mis à jour')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la mise à jour : ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildRatingItem(int rating, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRating = rating;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? const Color(0xFF8773F8)
                  : const Color(0xFF8773F8).withOpacity(0.1),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFF8773F8) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.star_rounded,
                color: isSelected ? Colors.white : const Color(0xFF8773F8),
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rating.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? const Color(0xFF8773F8) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Ajout du fond blanc
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Donner un avis',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final rating = index + 1;
                  final isSelected = rating == _selectedRating;
                  return _buildRatingItem(rating, isSelected);
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Commentaire',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Partagez votre expérience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8773F8),
                      side: const BorderSide(color: Color(0xFF8773F8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Annuler'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _submitReview(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8773F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Soumettre',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
