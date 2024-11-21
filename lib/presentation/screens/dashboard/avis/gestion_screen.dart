import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewsStyles {
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

class EventSpacesDashboardScreen extends StatefulWidget {
  const EventSpacesDashboardScreen({super.key});

  @override
  State<EventSpacesDashboardScreen> createState() =>
      _EventSpacesDashboardScreenState();
}

class _EventSpacesDashboardScreenState
    extends State<EventSpacesDashboardScreen> {
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
    if (_scrollController.offset > ReviewsStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= ReviewsStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: ReviewsStyles.circularButtonSize,
      height: ReviewsStyles.circularButtonSize,
      margin:
          EdgeInsets.symmetric(horizontal: ReviewsStyles.circularButtonMargin),
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
      preferredSize: Size.fromHeight(ReviewsStyles.appBarTotalHeight),
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
          toolbarHeight: ReviewsStyles.appBarTotalHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Container(
                width: double.infinity,
                height: ReviewsStyles.bannerHeight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: ReviewsStyles.buttonRowHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ReviewsStyles.horizontalPadding),
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
                    SizedBox(height: ReviewsStyles.spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: ReviewsStyles.titleContainerHeight,
                      margin: EdgeInsets.symmetric(
                          horizontal: ReviewsStyles.horizontalPadding),
                      padding: ReviewsStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(ReviewsStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Gestion des Avis',
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
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: StreamBuilder<int>(
        stream: _fetchTotalReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Aucune donnée disponible'));
          }

          return SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                top: ReviewsStyles.appBarTotalHeight + 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Tableau de Bord',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Total des Avis: ${snapshot.data}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Stream<int> _fetchTotalReviews() {
    return FirebaseFirestore.instance
        .collection('reviews')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
