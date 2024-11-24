import 'package:event_app/presentation/screens/villes/city_detail.dart';
import 'package:event_app/presentation/screens/villes/shimmer_load.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/models/city.dart';

// Constantes de style
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
  static const double listItemSpacing = 16.0;
  static const double listTopPadding = 40.0;
  static const double listBottomPadding = 20.0;
}

class AllCitiesScreen extends StatefulWidget {
  const AllCitiesScreen({super.key});

  @override
  State<AllCitiesScreen> createState() => _AllCitiesScreenState();
}

class _AllCitiesScreenState extends State<AllCitiesScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

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
    if (_scrollController.offset > _AppBarStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= _AppBarStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
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
                              icon: const Icon(
                                CupertinoIcons.back,
                                color: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
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
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(_AppBarStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Toutes les villes',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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

  @override
  Widget build(BuildContext context) {
    final appBarHeight = _AppBarStyles.appBarTotalHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, showBanner: true),
      body: Column(
        children: [
          SizedBox(height: appBarHeight + 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('cities').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Une erreur est survenue'));
                }

                if (!snapshot.hasData) {
                  return ListView.separated(
                    padding: const EdgeInsets.only(
                      top: _AppBarStyles.listTopPadding,
                      left: 20,
                      right: 20,
                      bottom: _AppBarStyles.listBottomPadding,
                    ),
                    itemCount: 10, // Nombre d'items de shimmer à afficher
                    separatorBuilder: (context, index) => const SizedBox(
                      height: _AppBarStyles.listItemSpacing,
                    ),
                    itemBuilder: (context, index) =>
                        const ShimmerListItem(isCity: true),
                  );
                }

                final cities = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return City(
                    id: doc.id,
                    name: data['name'] as String,
                  );
                }).toList();

                if (cities.isEmpty) {
                  return const Center(
                    child: Text('Aucune ville trouvée'),
                  );
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(
                    top: _AppBarStyles.listTopPadding,
                    left: 20,
                    right: 20,
                    bottom: _AppBarStyles.listBottomPadding,
                  ),
                  itemCount: cities.length,
                  separatorBuilder: (context, index) => const SizedBox(
                    height: _AppBarStyles.listItemSpacing,
                  ),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return CityListItem(
                      name: city.name,
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CityListItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const CityListItem({
    super.key,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
