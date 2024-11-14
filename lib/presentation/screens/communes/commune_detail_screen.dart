import 'package:event_app/presentation/screens/communes/appbar/appbar.dart';
import 'package:event_app/presentation/screens/event_space/event_space_detail.dart';
import 'package:event_app/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/activity.dart';
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/review.dart';

class CommuneDetailsScreen extends StatelessWidget {
  final String communeName;

  const CommuneDetailsScreen({
    Key? key,
    required this.communeName,
  }) : super(key: key);

  String _formatActivities(List<Activity> activities) {
    return activities.map((activity) => activity.type).join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight = 52.0 + kToolbarHeight;

    return Scaffold(
      appBar: CustomAppBar(
        communeName: communeName,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('event_spaces')
            .where('commune.name', isEqualTo: communeName)
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            final eventSpaces = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final activitiesList = (data['activities'] as List?)
                      ?.take(3)
                      .map((activityData) {
                        if (activityData is Map<String, dynamic>) {
                          return Activity(
                            type: activityData['type'] as String,
                            icon: IconData(
                              activityData['icon'],
                              fontFamily: 'MaterialIcons',
                            ),
                          );
                        }
                        return null;
                      })
                      .whereType<Activity>()
                      .toList() ??
                  [];

              final communeData = data['commune'] as Map<String, dynamic>;
              final commune = Commune(
                id: communeData['id'] as String,
                name: communeData['name'] as String,
                photoUrl: communeData['photoUrl'] as String,
                cityId: communeData['cityId'] as String,
              );

              final cityData = data['city'] as Map<String, dynamic>;
              final city = City(
                id: cityData['id'] as String,
                name: cityData['name'] as String,
              );

              final reviewsList = (data['reviews'] as List?)
                      ?.map((reviewData) {
                        if (reviewData is Map<String, dynamic>) {
                          return Review(
                            id: reviewData['id'] as String,
                            userId: reviewData['userId'] as String,
                            eventSpaceId: reviewData['eventSpaceId'] as String,
                            rating: reviewData['rating'] as int,
                            comment: reviewData['comment'] as String,
                            createdAt: DateTime.parse(
                                reviewData['createdAt'] as String),
                            isVerified:
                                reviewData['isVerified'] as bool? ?? false,
                          );
                        }
                        return null;
                      })
                      .whereType<Review>()
                      .toList() ??
                  [];

              return EventSpace(
                id: doc.id,
                name: data['name'] as String,
                description: data['description'] as String,
                commune: commune,
                city: city,
                activities: activitiesList,
                reviews: reviewsList,
                hours: data['hours'] as String,
                price: (data['price'] as num).toDouble(),
                phoneNumber: data['phoneNumber'] as String,
                photos: List<String>.from(data['photos'] ?? []),
                location: data['location'] as String,
                createdAt: DateTime.parse(data['createdAt'] as String),
                updatedAt: data['updatedAt'] != null
                    ? DateTime.parse(data['updatedAt'] as String)
                    : null,
                isActive: data['isActive'] as bool? ?? true,
                createdBy: data['createdBy'] as String,
              );
            }).toList();

            if (eventSpaces.isEmpty) {
              return const Center(
                child: Text('Aucun espace événementiel disponible'),
              );
            }

            return Padding(
              padding: EdgeInsets.only(top: 44),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: eventSpaces.length,
                itemBuilder: (context, index) {
                  final space = eventSpaces[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventSpaceDetailScreen(
                            eventSpace: space,
                          ),
                        ),
                      );
                    },
                    child: LocationCard(
                      title: space.name,
                      subtitle: _formatActivities(space.activities),
                      rating: space.getAverageRating(),
                      hours: space.hours,
                      imageUrl:
                          space.photos.isNotEmpty ? space.photos[0] : null,
                    ),
                  );
                },
              ),
            );
          } catch (e, stackTrace) {
            print('Error converting data: $e');
            print(stackTrace);
            return const Center(
              child: Text('Error loading data'),
            );
          }
        },
      ),
    );
  }
}
