import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/models/commune.dart';
import 'package:event_app/presentation/screens/communes/commune_detail_screen.dart';

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

class CityDetailScreen extends StatefulWidget {
  final String cityId;
  final String cityName;

  const CityDetailScreen({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends State<CityDetailScreen> {
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
                      child: Text(
                        widget.cityName,
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
          // Ajoute un espace équivalent à la hauteur totale de l'AppBar
          SizedBox(height: appBarHeight + 20), // +20 pour un espacement visuel
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('communes')
                  .where('cityId', isEqualTo: widget.cityId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Une erreur est survenue'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final communes = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Commune(
                    id: doc.id,
                    name: data['name'] as String,
                    photoUrl: data['photoUrl'] as String,
                    cityId: data['cityId'] as String,
                  );
                }).toList();

                if (communes.isEmpty) {
                  return const Center(
                    child: Text('Aucune commune trouvée'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: communes.length,
                  itemBuilder: (context, index) {
                    final commune = communes[index];
                    return CommuneListItem(
                      name: commune.name,
                      imageUrl: commune.photoUrl,
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

class CommuneListItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback onTap;

  const CommuneListItem({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 50,
                  color: Colors.grey[300],
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: 60,
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
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
    );
  }
}
