import 'package:event_app/presentation/screens/event_space/event_space_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/favorite.dart';
import 'package:event_app/data/services/favorites_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class _FavoritesStyles {
  static const double appBarTotalHeight = 52.0 + kToolbarHeight + 44.0;
  static const double buttonRowHeight = 52.0;
  static const double circularButtonSize = 46.0;
  static const double bannerHeight = 44.0;
  static const double circularButtonMargin = 5.0;
  static const double horizontalPadding = 24.0;
  static const double titleContainerHeight = 46.0;
  static const EdgeInsets titlePadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  static const double spaceBetweenButtonAndTitle = 8.0;
  static const double borderRadius = 20.0;
  static const double scrollThreshold = 80.0;
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ScrollController _scrollController = ScrollController();
  final FavoritesService _favoritesService = FavoritesService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isScrolled = false;
  String? _userId;
  Stream<List<Favorite>>? _favoritesStream;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
        _favoritesStream = _favoritesService.getUserFavorites(user.uid);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > _FavoritesStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= _FavoritesStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: _FavoritesStyles.circularButtonSize,
      height: _FavoritesStyles.circularButtonSize,
      margin: EdgeInsets.symmetric(
          horizontal: _FavoritesStyles.circularButtonMargin),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(_FavoritesStyles.appBarTotalHeight),
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
          toolbarHeight: _FavoritesStyles.appBarTotalHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Container(
                width: double.infinity,
                height: _FavoritesStyles.bannerHeight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: _FavoritesStyles.buttonRowHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: _FavoritesStyles.horizontalPadding),
                        child: Row(
                          children: [
                            _buildCircularButton(
                              icon: const Icon(CupertinoIcons.back,
                                  color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                        height: _FavoritesStyles.spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: _FavoritesStyles.titleContainerHeight,
                      margin: EdgeInsets.symmetric(
                          horizontal: _FavoritesStyles.horizontalPadding),
                      padding: _FavoritesStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            _FavoritesStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Mes Favoris',
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

  Widget _buildFavoriteCard(EventSpace eventSpace) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(eventSpace.photoUrls.first),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventSpace.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${eventSpace.commune.name}, ${eventSpace.city.name}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            CupertinoIcons.heart_fill,
            color: Colors.red,
            size: 20,
          ),
          onPressed: () => _toggleFavorite(eventSpace.id),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EventSpaceDetailScreen(eventSpace: eventSpace),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(String eventSpaceId) async {
    if (_userId != null) {
      await _favoritesService.toggleFavorite(_userId!, eventSpaceId);
    }
  }

  Widget _buildFavoritesList() {
    if (_userId == null) {
      return const Center(
        child: Text('Veuillez vous connecter pour voir vos favoris'),
      );
    }

    return StreamBuilder<List<Favorite>>(
      stream: _favoritesStream,
      builder: (context, snapshotFavorites) {
        if (snapshotFavorites.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshotFavorites.hasData || snapshotFavorites.data!.isEmpty) {
          return const Center(
            child: Text('Aucun favori pour le moment'),
          );
        }

        final favorites = snapshotFavorites.data!
            .where((favorite) => favorite.isActive)
            .toList();

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('event_spaces')
              .where('id',
                  whereIn: favorites.map((f) => f.eventSpaceId).toList())
              .snapshots(),
          builder: (context, snapshotSpaces) {
            if (!snapshotSpaces.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final eventSpaces = snapshotSpaces.data!.docs
                .map((doc) =>
                    EventSpace.fromJson(doc.data() as Map<String, dynamic>))
                .toList();

            return ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: eventSpaces.length,
              itemBuilder: (context, index) =>
                  _buildFavoriteCard(eventSpaces[index]),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            top: _FavoritesStyles.appBarTotalHeight + 20,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: _buildFavoritesList(),
        ),
      ),
    );
  }
}
