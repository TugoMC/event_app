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

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            'Donnez votre avis',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _selectedRating
                        ? CupertinoIcons.star_fill
                        : CupertinoIcons.star,
                    color: const Color(0xFF8773F8),
                    size: 32,
                  ),
                ),
              );
            }),
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
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 62,
              child: ElevatedButton(
                onPressed: () => _submitReview(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8773F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Soumettre mon avis',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
