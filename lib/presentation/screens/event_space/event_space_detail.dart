import 'package:event_app/data/models/event_space.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

class EventSpaceDetailScreen extends StatefulWidget {
  final EventSpace eventSpace;

  const EventSpaceDetailScreen({super.key, required this.eventSpace});

  @override
  State<EventSpaceDetailScreen> createState() => _EventSpaceDetailScreenState();
}

class _EventSpaceDetailScreenState extends State<EventSpaceDetailScreen> {
  int _currentPage = 0;

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF8773F8)
            : const Color(0xFFC3B9FB),
        borderRadius: BorderRadius.circular(5),
      ),
    );
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
                          const Spacer(),
                          _buildCircularButton(
                            icon: const Icon(
                              CupertinoIcons.heart,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              // Action favori
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
                      widget.eventSpace.name,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, showBanner: true),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Add fixed padding after AppBar
              const SliverPadding(
                padding: EdgeInsets.only(top: 20),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Rest of the content with padding
                    Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 100,
                        top: 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rating, Hours and Price row
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.star,
                                color: Color(0xFF8773F8),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.eventSpace
                                    .getAverageRating()
                                    .toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                CupertinoIcons.clock,
                                size: 16,
                                color: Color(0xFF8773F8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.eventSpace.hours,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF8773F8).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.eventSpace.price.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF8773F8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            widget.eventSpace.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              height: 1.4,
                            ),
                          ),

                          // Phone section
                          const SizedBox(height: 24),
                          const Text(
                            'Téléphone',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(CupertinoIcons.phone, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '+225 01 02 03 04 05',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          // Activities section
                          const SizedBox(height: 24),
                          const Text(
                            'Activités',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                                widget.eventSpace.activities.map((activity) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: const Color(0xFF8773F8)
                                          .withOpacity(0.2),
                                      child: Icon(activity.icon,
                                          color: const Color(0xFF8773F8)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      activity.type,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Fixed bottom buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 245,
                      height: 62,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8773F8),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'APPELER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8773F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          CupertinoIcons.location_solid,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
