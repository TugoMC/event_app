import 'package:event_app/data/models/activity.dart';
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/review.dart';
import 'package:event_app/presentation/screens/communes/all_commune.dart';
import 'package:event_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:event_app/presentation/screens/event_space/event_space_detail.dart';
import 'package:event_app/presentation/screens/home/widgets/app_bar_styles.dart';
import 'package:event_app/presentation/screens/home/widgets/city_card.dart';
import 'package:event_app/presentation/screens/home/widgets/commune_card.dart';
import 'package:event_app/presentation/screens/home/widgets/location_card.dart';
import 'package:event_app/presentation/screens/home/widgets/shimmer_loading.dart';
import 'package:event_app/presentation/screens/profile/profile_screen.dart';
import 'package:event_app/presentation/screens/search/search.dart';
import 'package:event_app/presentation/screens/villes/all_cities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  final Stream<QuerySnapshot> _citiesStream =
      FirebaseFirestore.instance.collection('cities').snapshots();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  bool get isAdmin => user?.email == 'ouattarajunior418@gmail.com';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > AppBarStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= AppBarStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: AppBarStyles.circularButtonSize,
      height: AppBarStyles.circularButtonSize,
      margin:
          EdgeInsets.symmetric(horizontal: AppBarStyles.circularButtonMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context,
      {required bool showBanner}) {
    final appBarHeight = showBanner
        ? AppBarStyles.appBarTotalHeight
        : AppBarStyles.appBarTotalHeight - AppBarStyles.bannerHeight;

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: _isScrolled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: appBarHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              if (showBanner)
                Container(
                  width: double.infinity,
                  height: AppBarStyles.bannerHeight,
                ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: AppBarStyles.buttonRowHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppBarStyles.horizontalPadding),
                        child: Row(
                          children: [
                            const Spacer(),
                            if (isAdmin)
                              _buildCircularButton(
                                icon: const Icon(CupertinoIcons.square_grid_2x2,
                                    color: Colors.black),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DashboardScreen()),
                                  );
                                },
                              ),
                            _buildCircularButton(
                              icon: const Icon(CupertinoIcons.search,
                                  color: Colors.black),
                              onPressed: () async {
                                // Récupérer les villes
                                final citiesSnapshot =
                                    await firestore.collection('cities').get();
                                final cities = citiesSnapshot.docs
                                    .map((doc) => City.fromJson(
                                        doc.data() as Map<String, dynamic>))
                                    .toList();

                                // Récupérer les communes
                                final communesSnapshot = await firestore
                                    .collection('communes')
                                    .get();
                                final communes = communesSnapshot.docs
                                    .map((doc) => Commune.fromJson(
                                        doc.data() as Map<String, dynamic>))
                                    .toList();

                                // Récupérer les espaces événementiels
                                final eventSpacesSnapshot = await firestore
                                    .collection('event_spaces')
                                    .where('isActive', isEqualTo: true)
                                    .get();
                                final eventSpaces =
                                    eventSpacesSnapshot.docs.map((doc) {
                                  final data = doc.data();
                                  return EventSpace(
                                    id: doc.id,
                                    name: data['name'] as String,
                                    description: data['description'] as String,
                                    commune: Commune.fromJson(data['commune']
                                        as Map<String, dynamic>),
                                    city: City.fromJson(
                                        data['city'] as Map<String, dynamic>),
                                    activities: (data['activities'] as List)
                                        .map((activity) => Activity.fromJson(
                                            activity as Map<String, dynamic>))
                                        .toList(),
                                    reviews: (data['reviews'] as List)
                                        .map((review) => Review.fromJson(
                                            review as Map<String, dynamic>))
                                        .toList(),
                                    hours: data['hours'] as String,
                                    price: (data['price'] as num).toDouble(),
                                    phoneNumber: data['phoneNumber'] as String,
                                    photoUrls:
                                        List<String>.from(data['photoUrls']),
                                    location: data['location'] as String,
                                    createdAt: DateTime.parse(
                                        data['createdAt'] as String),
                                    updatedAt: data['updatedAt'] != null
                                        ? DateTime.parse(
                                            data['updatedAt'] as String)
                                        : null,
                                    isActive: data['isActive'] as bool? ?? true,
                                    createdBy: data['createdBy'] as String,
                                  );
                                }).toList();

                                // Récupérer les activités
                                final activitiesSnapshot = await firestore
                                    .collection('activities')
                                    .get();
                                final activities = activitiesSnapshot.docs
                                    .map((doc) => Activity.fromJson(
                                        doc.data() as Map<String, dynamic>,
                                        doc.id))
                                    .toList();

                                // Afficher un indicateur de chargement pendant la récupération des données
                                if (!mounted) return;

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );

                                // Navigation vers l'écran de recherche
                                if (!mounted) return;

                                Navigator.pop(
                                    context); // Fermer le dialogue de chargement
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchScreen(
                                      allCities: cities,
                                      allCommunes: communes,
                                      allEventSpaces: eventSpaces,
                                      allActivities: activities,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildCircularButton(
                              icon: const Icon(CupertinoIcons.person,
                                  color: Colors.black),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppBarStyles.spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: AppBarStyles.titleContainerHeight,
                      margin: EdgeInsets.symmetric(
                          horizontal: AppBarStyles.horizontalPadding),
                      padding: AppBarStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppBarStyles.borderRadius),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Salut, ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${user?.email?.split('@')[0] ?? "Invité"}!',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatActivities(List<Activity> activities) {
    return activities.map((activity) => activity.type).join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, showBanner: true),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            top: AppBarStyles.appBarTotalHeight + 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cities Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Villes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AllCitiesScreen()),
                      );
                    },
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

              // Cities Cards
              SizedBox(
                height: 95,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _citiesStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                          child: Text('Une erreur est survenue'));
                    }

                    if (!snapshot.hasData) {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        scrollDirection: Axis.horizontal,
                        itemCount: 5, // Nombre d'éléments shimmer à afficher
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) =>
                            const CityCardShimmer(),
                      );
                    }

                    final cities = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return City.fromJson(data);
                    }).toList();

                    if (cities.isEmpty) {
                      return const Center(
                          child: Text('Aucune ville disponible'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      scrollDirection: Axis.horizontal,
                      itemCount: cities.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return CityCard(
                          id: city.id,
                          name: city.name,
                        );
                      },
                    );
                  },
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AllCommunesScreen()),
                      );
                    },
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
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        scrollDirection: Axis.horizontal,
                        itemCount: 5, // Nombre d'éléments shimmer à afficher
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) =>
                            const CommuneCardShimmer(),
                      );
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

              // Mise à jour du code dans le StreamBuilder des Event Spaces
              StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('event_spaces')
                    .where('isActive', isEqualTo: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Une erreur est survenue'));
                  }

                  if (!snapshot.hasData) {
                    return Column(
                      children: List.generate(
                        3, // Nombre d'éléments shimmer à afficher
                        (index) => const LocationCardShimmer(),
                      ),
                    );
                  }

                  try {
                    final eventSpaces = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return EventSpace(
                        id: doc.id,
                        name: data['name'] as String,
                        description: data['description'] as String,
                        commune: Commune.fromJson(
                            data['commune'] as Map<String, dynamic>),
                        city:
                            City.fromJson(data['city'] as Map<String, dynamic>),
                        activities: (data['activities'] as List)
                            .map((activity) => Activity.fromJson(
                                activity as Map<String, dynamic>))
                            .toList(),
                        reviews: (data['reviews'] as List)
                            .map((review) =>
                                Review.fromJson(review as Map<String, dynamic>))
                            .toList(),
                        hours: data['hours'] as String,
                        price: (data['price'] as num).toDouble(),
                        phoneNumber: data['phoneNumber'] as String,
                        photoUrls: List<String>.from(data['photoUrls']),
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

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: eventSpaces.map((space) {
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
                            id: space.id,
                            title: space.name,
                            subtitle: _formatActivities(space.activities),
                            hours: space.hours,
                            imageUrl: space.photoUrls.isNotEmpty
                                ? space.photoUrls.first
                                : null,
                          ),
                        );
                      }).toList(),
                    );
                  } catch (e, stackTrace) {
                    print('Error converting data: $e');
                    print(stackTrace);
                    return const Center(
                      child: Text('Erreur lors du chargement des données'),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
