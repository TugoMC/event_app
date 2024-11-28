import 'package:event_app/data/models/activity.dart';
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/recommendations.dart';
import 'package:event_app/data/models/review.dart';
import 'package:event_app/presentation/screens/communes/all_commune.dart';
import 'package:event_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:event_app/presentation/screens/event_space/event_space_detail.dart';
import 'package:event_app/presentation/screens/home/widgets/app_bar_styles.dart';
import 'package:event_app/presentation/screens/home/widgets/commune_card.dart';
import 'package:event_app/presentation/screens/home/widgets/location_card.dart';
import 'package:event_app/presentation/screens/home/widgets/shimmer_loading.dart';
import 'package:event_app/presentation/screens/profile/profile_screen.dart';
import 'package:event_app/presentation/screens/search/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<EventSpace> _nearbyEventSpaces = [];
  Position? _currentPosition;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isLocationEnabled = false;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  bool get isAdmin => user?.email == 'ouattarajunior418@gmail.com';

  // Ajout des clés pour les différentes sections
  final GlobalKey _communesKey = GlobalKey();
  final GlobalKey _suggestionsKey = GlobalKey();
  final GlobalKey _nearbyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Gestion de l'animation de l'AppBar
    if (_scrollController.offset > AppBarStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= AppBarStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }

    // Nouvelle logique pour détecter la section visible
    final communesRenderBox =
        _communesKey.currentContext?.findRenderObject() as RenderBox?;
    final suggestionsRenderBox =
        _suggestionsKey.currentContext?.findRenderObject() as RenderBox?;
    final nearbyRenderBox =
        _nearbyKey.currentContext?.findRenderObject() as RenderBox?;

    if (communesRenderBox == null ||
        suggestionsRenderBox == null ||
        nearbyRenderBox == null) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final scrollOffset =
        _scrollController.offset + AppBarStyles.appBarTotalHeight;

    final communesPosition = communesRenderBox.localToGlobal(Offset.zero).dy;
    final suggestionsPosition =
        suggestionsRenderBox.localToGlobal(Offset.zero).dy;
    final nearbyPosition = nearbyRenderBox.localToGlobal(Offset.zero).dy;

    String newSelectedSection;

    if (scrollOffset >= communesPosition &&
        scrollOffset < suggestionsPosition) {
      newSelectedSection = 'Communes';
    } else if (scrollOffset >= suggestionsPosition &&
        scrollOffset < nearbyPosition) {
      newSelectedSection = 'Suggestions';
    } else if (scrollOffset >= nearbyPosition) {
      newSelectedSection = 'Nearby';
    } else {
      return; // Si aucune section n'est clairement sélectionnée
    }

    if (newSelectedSection != _selectedSection) {
      setState(() {
        _selectedSection = newSelectedSection;
      });
    }
  }

  Future<void> _checkLocationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Vérifier le statut réel de la permission de localisation
    PermissionStatus status = await Permission.location.status;

    setState(() {
      // La localisation est activée uniquement si la permission est accordée
      _isLocationEnabled = status == PermissionStatus.granted;
    });

    if (_isLocationEnabled) {
      await _getCurrentPosition();
    }
  }

  Future<void> _getCurrentPosition() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition();

      // Récupérer tous les espaces événementiels
      final eventSpacesSnapshot = await firestore
          .collection('event_spaces')
          .where('isActive', isEqualTo: true)
          .get();

      final allEventSpaces = eventSpacesSnapshot.docs.map((doc) {
        final data = doc.data();
        return EventSpace.fromJson(data);
      }).toList();

      // Filtrer les espaces proches (dans un rayon de 5 km)
      final userLocation =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      setState(() {
        _nearbyEventSpaces = allEventSpaces.where((space) {
          final distance = space.calculateDistance(userLocation);
          return distance <= 5000; // 5 km
        }).toList()
          ..sort((a, b) => a
              .calculateDistance(userLocation)
              .compareTo(b.calculateDistance(userLocation)));
      });
    } catch (e) {
      print('Erreur lors de la récupération de la position: $e');
    }
  }

  Future<void> _checkLocationPermissionAndGetLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool locationEnabled = prefs.getBool('locationEnabled') ?? false;

    if (!locationEnabled) {
      setState(() {
        _currentPosition = null;
        _nearbyEventSpaces = [];
        return;
      });
    }

    bool serviceEnabled;
    LocationPermission permission;

    // Test si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Les services de localisation sont désactivés
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Les permissions sont refusées
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Les permissions sont définitivement refusées
      return;
    }

    // Obtenir la position actuelle
    _currentPosition = await Geolocator.getCurrentPosition();

    // Récupérer tous les espaces événementiels
    final eventSpacesSnapshot = await firestore
        .collection('event_spaces')
        .where('isActive', isEqualTo: true)
        .get();

    final allEventSpaces = eventSpacesSnapshot.docs.map((doc) {
      final data = doc.data();
      return EventSpace.fromJson(data);
    }).toList();

    // Filtrer les espaces proches (par exemple, dans un rayon de 5 km)
    final userLocation =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    setState(() {
      _nearbyEventSpaces = allEventSpaces.where((space) {
        final distance = space.calculateDistance(userLocation);
        return distance <= 5000; // 5 km
      }).toList()
        ..sort((a, b) => a
            .calculateDistance(userLocation)
            .compareTo(b.calculateDistance(userLocation)));
    });
  }

  Future<void> _toggleLocationPermission() async {
    final status = await Permission.location.request();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (status == PermissionStatus.granted) {
      await prefs.setBool('locationEnabled', true);
      await _checkLocationPermissionAndGetLocation();

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localisation activée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (status == PermissionStatus.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autorisation de localisation refusée'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (status == PermissionStatus.permanentlyDenied) {
      // Guide l'utilisateur vers les paramètres de l'application
      await openAppSettings();
    }
  }

  Widget _buildNearbySection() {
    if (!_isLocationEnabled) {
      return Center(
        child: Column(
          children: [
            const Text(
              'Activez la localisation pour voir les espaces évenementiels proches de chez vous.',
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: _checkLocationStatus,
              child: const Text('Actualiser'),
            ),
          ],
        ),
      );
    }

    if (_currentPosition == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_nearbyEventSpaces.isEmpty) {
      return const Center(
        child: Text('Aucun espace événementiel trouvé.'),
      );
    }

    return Column(
      children: _nearbyEventSpaces.map((space) {
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
            imageUrl: space.photoUrls.isNotEmpty ? space.photoUrls.first : null,
          ),
        );
      }).toList(),
    );
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
      child: Container(
        decoration: BoxDecoration(
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
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: appBarHeight,
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First row: User greeting and action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
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
                          text: (user?.displayName?.length ?? 0) > 12
                              ? '${user?.displayName?.substring(0, 12)}...' // Tronque le displayName
                              : (user?.email?.split('@')[0].length ?? 0) > 12
                                  ? '${user?.email?.split('@')[0].substring(0, 12)}...' // Tronque la partie avant @ de l'email
                                  : user?.email?.split('@')[0] ??
                                      'User', // Affiche sans troncature ou "User" par défaut
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
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
                          final communesSnapshot =
                              await firestore.collection('communes').get();
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
                              commune: Commune.fromJson(
                                  data['commune'] as Map<String, dynamic>),
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
                              photoUrls: List<String>.from(data['photoUrls']),
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

                          // Récupérer les activités
                          final activitiesSnapshot =
                              await firestore.collection('activities').get();
                          final activities = activitiesSnapshot.docs
                              .map((doc) => Activity.fromJson(
                                  doc.data() as Map<String, dynamic>, doc.id))
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
                                builder: (context) => const ProfileScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Second row: Navigation buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildNavButton(
                        text: 'Communes',
                        section: 'Communes',
                        onPressed: () => _navigateToSection(_communesKey)),
                    const SizedBox(width: 10),
                    _buildNavButton(
                        text: 'Suggestions',
                        section: 'Suggestions',
                        onPressed: () => _navigateToSection(_suggestionsKey)),
                    const SizedBox(width: 10),
                    _buildNavButton(
                        text: 'Proche de chez moi',
                        section: 'Nearby',
                        onPressed: () => _navigateToSection(_nearbyKey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(
      {required String text,
      required String section,
      required VoidCallback onPressed}) {
    final isSelected = _selectedSection == section;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFC3B9FB) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          onPressed();
          setState(() {
            _selectedSection = section;
          });
        },
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(text),
      ),
    );
  }

  void _navigateToSection(GlobalKey key) {
    final RenderObject? renderObject = key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final offset = renderObject.localToGlobal(Offset.zero).dy -
          AppBarStyles.appBarTotalHeight;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatActivities(List<Activity> activities) {
    return activities.map((activity) => activity.type).join(' - ');
  }

  String _selectedSection = 'Communes';
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
              const SizedBox(height: 16),

              // Communes Section
              Container(
                key: _communesKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                  builder: (context) =>
                                      const AllCommunesScreen()),
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
                        stream: firestore
                            .collection('communes')
                            .limit(10)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Une erreur est survenue'));
                          }

                          if (!snapshot.hasData) {
                            return ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  5, // Nombre d'éléments shimmer à afficher
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
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Event Spaces Section
              Container(
                key: _suggestionsKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          .collection('recommendations')
                          .where('isActive', isEqualTo: true)
                          .snapshots(),
                      builder: (context, recommendationSnapshot) {
                        if (recommendationSnapshot.hasError) {
                          return const Center(
                              child: Text('Une erreur est survenue'));
                        }

                        if (!recommendationSnapshot.hasData) {
                          return const LocationCardShimmer();
                        }

                        final activeRecommendations = recommendationSnapshot
                            .data!.docs
                            .map((doc) => Recommendations.fromJson(
                                doc.data() as Map<String, dynamic>))
                            .toList();

                        if (activeRecommendations.isEmpty) {
                          return const Center(
                            child: Text('Aucune recommandation active'),
                          );
                        }

                        final activeRecommendation =
                            activeRecommendations.first;
                        final recommendedEventSpaces =
                            activeRecommendation.eventSpaces;

                        if (recommendedEventSpaces.isEmpty) {
                          return const Center(
                            child: Text('Aucun espace événementiel recommandé'),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: recommendedEventSpaces.map((space) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventSpaceDetailScreen(
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
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30), // Nearby Section
              Container(
                key: _nearbyKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Proche de chez moi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildNearbySection(), // Utilisez cette méthode
                    const SizedBox(height: 30),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToSection(GlobalKey key) {
    final RenderObject? renderObject = key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final offset = renderObject.localToGlobal(Offset.zero).dy -
          AppBarStyles.appBarTotalHeight;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
