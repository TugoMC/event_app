import 'package:event_app/data/models/activity.dart';
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/review.dart';
import 'package:event_app/presentation/screens/communes/commune_detail_screen.dart';
import 'package:event_app/presentation/screens/profile/profile_screen.dart';
import 'package:event_app/presentation/screens/search/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // This function converts the list of activities into a string
  String _formatActivities(List<Activity> activities) {
    return activities.map((activity) => activity.type).join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/logos/logo.png',
                      width: 80,
                      height: 80,
                    ),
                    // Dans home_screen.dart, remplacez le Container du profile par:
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ProfileScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(-1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOutCubic;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.person,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Greeting
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Salut, ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextSpan(
                        text: '${user?.email?.split('@')[0] ?? "Invité"}!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 62,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: // Replace the existing TextField Container with this code
                      InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchScreen()),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.search,
                              color: Color(0xFFA0A5BA),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Rechercher',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Communes Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Communes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          const Text(
                            'Voir tout',
                            style: TextStyle(color: Colors.black),
                          ),
                          Icon(
                            CupertinoIcons.chevron_forward,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Communes Cards - Dynamic
                SizedBox(
                  height: 95,
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        firestore.collection('communes').limit(10).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Une erreur est survenue'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final communes = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Commune.fromJson(data);
                      }).toList();

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        scrollDirection: Axis.horizontal,
                        itemCount: communes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return CommuneCard(
                            name: communes[index].name,
                            imageUrl: communes[index].photoUrl,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Event Spaces Section
                const Text(
                  'Suggestions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Event Spaces Cards - Dynamic
                StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('event_spaces')
                      .where('isActive', isEqualTo: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Une erreur est survenue'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    try {
                      final eventSpaces = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        // Convert activities
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

                        // Create the commune
                        final communeData =
                            data['commune'] as Map<String, dynamic>;
                        final commune = Commune(
                          id: communeData['id'] as String,
                          name: communeData['name'] as String,
                          photoUrl: communeData['photoUrl'] as String,
                          cityId: communeData['cityId'] as String,
                        );

                        // Create the city
                        final cityData = data['city'] as Map<String, dynamic>;
                        final city = City(
                          id: cityData['id'] as String,
                          name: cityData['name'] as String,
                        );

                        // Convert reviews
                        final reviewsList = (data['reviews'] as List?)
                                ?.map((reviewData) {
                                  if (reviewData is Map<String, dynamic>) {
                                    return Review(
                                      id: reviewData['id'] as String,
                                      userId: reviewData['userId'] as String,
                                      eventSpaceId:
                                          reviewData['eventSpaceId'] as String,
                                      rating: reviewData['rating'] as int,
                                      comment: reviewData['comment'] as String,
                                      createdAt: DateTime.parse(
                                          reviewData['createdAt'] as String),
                                      isVerified:
                                          reviewData['isVerified'] as bool? ??
                                              false,
                                    );
                                  }
                                  return null;
                                })
                                .whereType<Review>()
                                .toList() ??
                            [];

                        // Create the EventSpace
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
                          createdAt:
                              DateTime.parse(data['createdAt'] as String),
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

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: eventSpaces.map((space) {
                          return LocationCard(
                            title: space.name,
                            subtitle: _formatActivities(space.activities),
                            rating: space.getAverageRating(),
                            hours: space.hours,
                            imageUrl: space.photos.isNotEmpty
                                ? space.photos[0]
                                : null,
                          );
                        }).toList(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommuneCard extends StatelessWidget {
  final String name;
  final String imageUrl;

  const CommuneCard({
    super.key,
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommuneDetailsScreen(communeName: name),
          ),
        );
      },
      child: SizedBox(
        width: 80,
        height: 95,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 70,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey[300]);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(color: Colors.grey[300]);
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 80,
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double rating;
  final String hours;
  final String? imageUrl;

  const LocationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.hours,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                      rating.toStringAsFixed(1),
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
  }
}
