import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_app/data/models/review.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReviewsSection extends StatelessWidget {
  final String eventSpaceId;

  const ReviewsSection({required this.eventSpaceId, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        FutureBuilder<List<Review>>(
          future: _fetchReviews(eventSpaceId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Erreur lors de la récupération des reviews : ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aucun avis disponible pour le moment.'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return FutureBuilder<String>(
                  future: _fetchUserEmail(review.userId),
                  builder: (context, emailSnapshot) {
                    final username = emailSnapshot.data != null
                        ? emailSnapshot.data!.split('@').first
                        : 'Utilisateur';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _formatDate(review.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _buildStarRating(review.rating),
                          const SizedBox(height: 4),
                          Text(
                            review.comment,
                            style: TextStyle(
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? CupertinoIcons.star_fill : CupertinoIcons.star,
          color: const Color(0xFF8773F8),
          size: 20,
        );
      }),
    );
  }

  Future<String> _fetchUserEmail(String userId) async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'Utilisateur';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<List<Review>> _fetchReviews(String eventSpaceId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('eventSpaceId', isEqualTo: eventSpaceId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Review.fromJson(data);
    }).toList();
  }
}
