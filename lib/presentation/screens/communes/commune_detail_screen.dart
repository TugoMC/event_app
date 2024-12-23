import 'package:event_app/presentation/screens/communes/shimmer_load.dart';
import 'package:event_app/presentation/screens/home/widgets/location_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/activity.dart';
import 'package:event_app/presentation/screens/event_space/event_space_detail.dart';

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
}

class CommuneDetailsScreen extends StatefulWidget {
  final String communeName;

  const CommuneDetailsScreen({
    Key? key,
    required this.communeName,
  }) : super(key: key);

  @override
  State<CommuneDetailsScreen> createState() => _CommuneDetailsScreenState();
}

class _CommuneDetailsScreenState extends State<CommuneDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        color: Colors.transparent,
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

  Widget _buildSearchField() {
    return Container(
      height: _AppBarStyles.circularButtonSize,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_AppBarStyles.borderRadius),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(CupertinoIcons.xmark, size: 20),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _showSearch = false;
              });
            },
          ),
        ),
        onChanged: (value) {
          setState(() {}); // Trigger rebuild to filter results
        },
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
      child: AppBar(
        backgroundColor: Colors.white,
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
                          if (_showSearch) Expanded(child: _buildSearchField()),
                          if (!_showSearch) const Spacer(),
                          if (!_showSearch)
                            _buildCircularButton(
                              icon: const Icon(
                                CupertinoIcons.search,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showSearch = true;
                                });
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
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(_AppBarStyles.borderRadius),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      widget.communeName,
                      style: const TextStyle(
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
    );
  }

  String _formatActivities(List<Activity> activities) {
    return activities.map((activity) => activity.type).join(' - ');
  }

  Stream<List<EventSpace>> _getEventSpacesStream() {
    return _firestore
        .collection('event_spaces')
        .where('commune.name', isEqualTo: widget.communeName)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return EventSpace.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
    });
  }

  List<EventSpace> _filterEventSpaces(List<EventSpace> spaces) {
    if (_searchController.text.isEmpty) {
      return spaces;
    }
    final searchTerm = _searchController.text.toLowerCase();
    return spaces.where((space) {
      return space.name.toLowerCase().contains(searchTerm) ||
          space.activities.any(
              (activity) => activity.type.toLowerCase().contains(searchTerm));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, showBanner: true),
      body: StreamBuilder<List<EventSpace>>(
        stream: _getEventSpacesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Une erreur est survenue: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: 5, // nombre de shimmer items à afficher
              itemBuilder: (context, index) => const LocationCardShimmer(),
            );
          }

          final eventSpaces = _filterEventSpaces(snapshot.data ?? []);

          if (eventSpaces.isEmpty) {
            return const Center(
              child: Text(
                'Aucun espace événementiel disponible dans cette commune',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: eventSpaces.length,
            itemBuilder: (context, index) {
              final space = eventSpaces[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: GestureDetector(
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
                    activities: space.activities
                        .map((activity) => activity.type)
                        .toList(),
                    hours: space.hours,
                    imageUrl: space.photoUrls.isNotEmpty
                        ? space.photoUrls.first
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
