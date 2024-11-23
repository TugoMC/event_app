import 'package:event_app/data/filters/event_space_filter.dart';
import 'package:event_app/data/models/activity.dart';
import 'package:event_app/data/models/city.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/presentation/screens/search/activity_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';

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
  final List<Activity> _selectedActivities = [];

  List<City>? _filteredCities;
  List<Commune>? _filteredCommunes;
  List<EventSpace>? _filteredEventSpaces;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
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

  void _onSearchChanged() {
    final query = _searchController.text;

    setState(() {
      // Utiliser le nouveau filtre pour les espaces événementiels
      _filteredEventSpaces = EventSpaceFilter.filterEventSpaces(
        eventSpaces: widget.allEventSpaces ?? [],
        searchQuery: query,
        selectedActivities:
            _selectedActivities.isNotEmpty ? _selectedActivities : null,
      );

      // Filtrer les villes et communes uniquement si une recherche textuelle est active
      if (query.isNotEmpty) {
        _filteredCities = widget.allCities
            ?.where(
                (city) => city.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        _filteredCommunes = widget.allCommunes
            ?.where((commune) =>
                commune.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        _filteredCities = null;
        _filteredCommunes = null;
      }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Villes
        if (_filteredCities != null && _filteredCities!.isNotEmpty) ...[
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
                  // Navigation vers la ville
                },
              )),
        ],

        // Section Communes
        if (_filteredCommunes != null && _filteredCommunes!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 12),
            child: Text(
              'Communes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ..._filteredCommunes!.map((commune) => Container(
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
              )),
        ],

        // Section Espaces événementiels
        if (_filteredEventSpaces != null &&
            _filteredEventSpaces!.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 12),
            child: Text(
              'Espaces événementiels',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ..._filteredEventSpaces!.map((space) => Container(
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
                              Icon(Icons.star,
                                  size: 16, color: Colors.purple[400]),
                              const SizedBox(width: 4),
                              Text(
                                space.getAverageRating().toStringAsFixed(1),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
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
            top: _AppBarStyles.appBarTotalHeight + 20,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: _searchController.text.isEmpty
              ? Container() // Si la recherche est vide, on n'affiche rien
              : _buildSearchResults(),
        ),
      ),
    );
  }
}
