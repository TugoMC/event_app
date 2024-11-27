import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/filters/event_space_filter.dart';
import 'package:event_app/data/models/activity.dart';
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/presentation/screens/communes/commune_detail_screen.dart';
import 'package:event_app/presentation/screens/event_space/event_space_detail.dart';
import 'package:event_app/presentation/screens/search/activity_filter.dart';
import 'package:event_app/presentation/screens/villes/city_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';

// Styles constants
class _AppBarStyles {
  static const double appBarTotalHeight = 52.0 + kToolbarHeight + 44.0;
  static const double buttonRowHeight = 52.0;
  static const double bannerHeight = 44.0;
  static const double circularButtonSize = 46.0;
  static const double circularButtonMargin = 5.0;
  static const double horizontalPadding = 24.0;
  static const double titleContainerHeight = 46.0;
  static const EdgeInsets titlePadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const double spaceBetweenButtonAndTitle = 8.0;
  static const double borderRadius = 20.0;
  static const double scrollThreshold = 80.0;
}

class SearchScreen extends StatefulWidget {
  final List<City>? allCities;
  final List<Commune>? allCommunes;
  final List<EventSpace>? allEventSpaces;
  final List<Activity>? allActivities;

  const SearchScreen({
    super.key,
    this.allCities,
    this.allCommunes,
    this.allEventSpaces,
    this.allActivities,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isLoading = false;
  final List<Activity> _selectedActivities = [];

  List<City>? _filteredCities;
  List<Commune>? _filteredCommunes;
  List<EventSpace>? _filteredEventSpaces;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    // Initialiser les EventSpaces dès le début
    _updateFilteredEventSpaces();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > _AppBarStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= _AppBarStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  // Nouvelle méthode pour mettre à jour les EventSpaces filtrés
  void _updateFilteredEventSpaces() {
    setState(() {
      _filteredEventSpaces = EventSpaceFilter.filterEventSpaces(
        eventSpaces: widget.allEventSpaces ?? [],
        searchQuery: _searchController.text,
        selectedActivities:
            _selectedActivities.isNotEmpty ? _selectedActivities : null,
      );
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text;

    setState(() {
      _isLoading = true;
    });

    // Simuler un délai de chargement
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      setState(() {
        _updateFilteredEventSpaces();

        if (query.isNotEmpty) {
          _filteredCities = widget.allCities
              ?.where((city) =>
                  city.name.toLowerCase().contains(query.toLowerCase()))
              .toList();

          _filteredCommunes = widget.allCommunes
              ?.where((commune) =>
                  commune.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
        } else {
          _filteredCities = null;
          _filteredCommunes = null;
        }
        _isLoading = false;
      });
    });
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: _AppBarStyles.circularButtonSize,
      height: _AppBarStyles.circularButtonSize,
      margin:
          EdgeInsets.symmetric(horizontal: _AppBarStyles.circularButtonMargin),
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
        ? _AppBarStyles.appBarTotalHeight
        : _AppBarStyles.appBarTotalHeight - _AppBarStyles.bannerHeight;

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
                  height: _AppBarStyles.bannerHeight,
                ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: _AppBarStyles.buttonRowHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: _AppBarStyles.horizontalPadding),
                        child: Row(
                          children: [
                            _buildCircularButton(
                              icon: const Icon(CupertinoIcons.back,
                                  color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            _buildCircularButton(
                              icon: const HugeIcon(
                                icon:
                                    HugeIcons.strokeRoundedPreferenceHorizontal,
                                color: Colors.black,
                                size: 24.0,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => ActivityFilterModal(
                                    initialSelectedActivities:
                                        _selectedActivities,
                                    eventSpaces: widget.allEventSpaces ??
                                        [], // Passer les EventSpaces
                                    onFilterChanged: (activities) {
                                      setState(() {
                                        _selectedActivities.clear();
                                        _selectedActivities.addAll(activities);
                                        // Mettre à jour les EventSpaces filtrés
                                        _filteredEventSpaces = widget
                                            .allEventSpaces
                                            ?.where((space) {
                                          return space
                                              .hasAllActivities(activities);
                                        }).toList();
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: _AppBarStyles.spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: _AppBarStyles.titleContainerHeight,
                      margin: EdgeInsets.symmetric(
                          horizontal: _AppBarStyles.horizontalPadding),
                      padding: _AppBarStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius:
                            BorderRadius.circular(_AppBarStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.search,
                                color: Color(0xFFA0A5BA), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                style: const TextStyle(height: 1.0),
                                decoration: const InputDecoration(
                                  hintText: 'Rechercher',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Color(0xFFA0A5BA)),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
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

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(5, (index) => const ShimmerItem()),
      );
    }

    final bool hasSearchResults = _searchController.text.isNotEmpty &&
        (_filteredCities?.isNotEmpty == true ||
            _filteredCommunes?.isNotEmpty == true ||
            _filteredEventSpaces?.isNotEmpty == true);

    final bool hasFilterResults = _selectedActivities.isNotEmpty &&
        _filteredEventSpaces?.isNotEmpty == true;

    if (!hasSearchResults && !hasFilterResults) {
      return const Center(
        child: Text(
          'Aucun résultat trouvé',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cities section
        if (_searchController.text.isNotEmpty &&
            _filteredCities != null &&
            _filteredCities!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 12),
            child: Text(
              'Villes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ..._filteredCities!.map((city) => ListTile(
                title: Text(city.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CityDetailScreen(
                        cityId: city.id,
                        cityName: city.name,
                      ),
                    ),
                  );
                },
              )),
        ],

        // Communes section
        if (_searchController.text.isNotEmpty &&
            _filteredCommunes != null &&
            _filteredCommunes!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 12),
            child: Text(
              'Communes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ..._filteredCommunes!.map((commune) => InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommuneDetailsScreen(
                        communeName: commune.name,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(commune.photoUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              commune.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              commune.city?.name ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],

        // Event spaces section
        if (_filteredEventSpaces != null &&
            _filteredEventSpaces!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 12),
            child: Text(
              'Espaces événementiels',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ..._filteredEventSpaces!.map((space) => FutureBuilder<double>(
                future: _calculateAverageRating(space.id),
                builder: (context, snapshot) {
                  final rating = snapshot.data ?? 0.0;

                  return InkWell(
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
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(space.photoUrls.first),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  space.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (rating > 0) ...[
                                      const Icon(CupertinoIcons.star,
                                          size: 16, color: Color(0xFF8B5CF6)),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ] else
                                      const Text(
                                        'Pas encore d\'avis',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
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
              )),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldShowResults =
        _searchController.text.isNotEmpty || _selectedActivities.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, showBanner: true),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            top: _AppBarStyles.appBarTotalHeight + 40,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: shouldShowResults ? _buildSearchResults() : Container(),
        ),
      ),
    );
  }

  Future<double> _calculateAverageRating(String eventSpaceId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('eventSpaceId', isEqualTo: eventSpaceId)
        .get();

    if (querySnapshot.docs.isEmpty) return 0.0;

    final ratings = querySnapshot.docs.map((doc) => doc['rating'] as int);
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }
}

// Ajout du widget Shimmer
class ShimmerItem extends StatelessWidget {
  const ShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
