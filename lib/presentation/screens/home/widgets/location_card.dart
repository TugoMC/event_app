import 'package:event_app/data/models/recommendations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationCard extends StatelessWidget {
  final String id;
  final String title;
  final List<String> activities; // Change from subtitle to activities
  final String hours;
  final String? imageUrl;
  final EventSpaceOrder? eventSpaceOrder;

  const LocationCard({
    super.key,
    required this.id,
    required this.title,
    required this.activities, // Update constructor
    required this.hours,
    this.imageUrl,
    this.eventSpaceOrder,
  });

  String _formatActivities() {
    return activities.join(' - ');
  }

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

        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: imageUrl != null
                            ? ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                child: Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(color: Colors.grey[300]);
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(color: Colors.grey[300]);
                                  },
                                ),
                              )
                            : null,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(constraints.maxWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatActivities(), // Use the new activities formatting method
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
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
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    CupertinoIcons.clock,
                                    color: Color(0xFF8B5CF6),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      hours,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
