import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String hours;
  final String? imageUrl;

  const LocationCard({
    super.key,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.hours,
    this.imageUrl,
  });

  Future<double> _calculateAverageRating() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('eventSpaceId', isEqualTo: id)
        .get();

    if (querySnapshot.docs.isEmpty) return 0.0;

    final ratings = querySnapshot.docs.map((doc) => doc['rating'] as int);
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _calculateAverageRating(),
      builder: (context, snapshot) {
        final rating = snapshot.data ?? 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: Colors.grey[300]);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(color: Colors.grey[300]);
                          },
                        ),
                      )
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.star,
                          color: Color(0xFF8B5CF6),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating == 0.0
                              ? 'Pas encore d\'avis'
                              : rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          CupertinoIcons.clock,
                          color: Color(0xFF8B5CF6),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hours,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
