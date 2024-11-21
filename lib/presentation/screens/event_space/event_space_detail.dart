import 'package:event_app/presentation/screens/event_space/widgets/activities_section.dart';
import 'package:event_app/presentation/screens/event_space/widgets/app_bar_styles.dart';
import 'package:event_app/presentation/screens/event_space/widgets/bottom_buttons.dart';
import 'package:event_app/presentation/screens/event_space/widgets/details_header.dart';
import 'package:event_app/presentation/screens/event_space/widgets/image_carousel.dart';
import 'package:event_app/presentation/screens/event_space/widgets/review_modal.dart';
import 'package:event_app/presentation/screens/event_space/widgets/reviews_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:event_app/data/models/event_space.dart';

class EventSpaceDetailScreen extends StatefulWidget {
  final EventSpace eventSpace;

  const EventSpaceDetailScreen({Key? key, required this.eventSpace})
      : super(key: key);

  @override
  _EventSpaceDetailScreenState createState() => _EventSpaceDetailScreenState();
}

class _EventSpaceDetailScreenState extends State<EventSpaceDetailScreen> {
  PreferredSizeWidget _buildAppBar(BuildContext context,
      {required bool showBanner}) {
    final appBarHeight = showBanner
        ? AppBarStyles.appBarTotalHeight
        : AppBarStyles.appBarTotalHeight - AppBarStyles.bannerHeight;

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
                              CupertinoIcons.bubble_right,
                              color: Colors.black,
                            ),
                            onPressed: () => _showReviewModal(context),
                          ),
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

  void _showReviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => ReviewModal(
        eventSpaceId: widget.eventSpace.id,
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
              const SliverPadding(
                padding: EdgeInsets.only(top: 20),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageCarousel(photoUrls: widget.eventSpace.photoUrls),
                    DetailsHeader(eventSpace: widget.eventSpace),
                    ActivitiesSection(activities: widget.eventSpace.activities),
                    ReviewsSection(eventSpaceId: widget.eventSpace.id),
                    const SizedBox(
                        height: 100), // Add padding for bottom buttons
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomButtons(eventSpace: widget.eventSpace),
          ),
        ],
      ),
    );
  }
}
