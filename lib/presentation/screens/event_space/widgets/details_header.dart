import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsHeader extends StatelessWidget {
  final EventSpace eventSpace;

  const DetailsHeader({Key? key, required this.eventSpace}) : super(key: key);

  Future<double> _calculateAverageRating() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('eventSpaceId', isEqualTo: eventSpace.id)
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
        final averageRating = snapshot.data ?? 0.0;
        final hasReviews = averageRating > 0;

        return Container(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (hasReviews) ...[
                    const Icon(
                      CupertinoIcons.star,
                      color: Color(0xFF8773F8),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  const Icon(
                    CupertinoIcons.clock,
                    size: 16,
                    color: Color(0xFF8773F8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    eventSpace.hours,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8773F8).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${eventSpace.price.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8773F8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                eventSpace.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Téléphone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(CupertinoIcons.phone, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    eventSpace.phoneNumber,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
