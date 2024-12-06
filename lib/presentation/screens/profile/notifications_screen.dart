import 'package:event_app/data/models/blog_post.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/presentation/screens/profile/notification_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class _NotificationsScreenStyles {
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
  static const double switchHeight = 52.0;
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _showExpiredPosts = false;

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
    if (_scrollController.offset > _NotificationsScreenStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <=
            _NotificationsScreenStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: _NotificationsScreenStyles.circularButtonSize,
      height: _NotificationsScreenStyles.circularButtonSize,
      margin: EdgeInsets.symmetric(
          horizontal: _NotificationsScreenStyles.circularButtonMargin),
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
      preferredSize:
          Size.fromHeight(_NotificationsScreenStyles.appBarTotalHeight),
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
          toolbarHeight: _NotificationsScreenStyles.appBarTotalHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Container(
                width: double.infinity,
                height: _NotificationsScreenStyles.bannerHeight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: _NotificationsScreenStyles.buttonRowHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                _NotificationsScreenStyles.horizontalPadding),
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
                        height: _NotificationsScreenStyles
                            .spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: _NotificationsScreenStyles.titleContainerHeight,
                      margin: EdgeInsets.symmetric(
                          horizontal:
                              _NotificationsScreenStyles.horizontalPadding),
                      padding: _NotificationsScreenStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            _NotificationsScreenStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Notifications',
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

  Widget _buildNotificationItem(BlogPost blogPost) {
    bool isExpired = blogPost.validUntil != null &&
        DateTime.now().isAfter(blogPost.validUntil!);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlogPostDetailScreen(blogPost: blogPost),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isExpired ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isExpired ? Colors.grey[400]! : Colors.grey[300]!),
        ),
        child: Stack(
          children: [
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<EventSpace>(
                    future: EventSpace.fetchEventSpaceDetails(
                        blogPost.eventSpaceId),
                    builder: (context, snapshot) {
                      final title = snapshot.hasData
                          ? '${blogPost.title} - ${snapshot.data!.name} (${snapshot.data!.city.name} - ${snapshot.data!.commune.name})'
                          : blogPost.title;
                      return Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: isExpired ? Colors.grey[600] : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    blogPost.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isExpired ? Colors.grey[500] : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children:
                        blogPost.tags.map((tag) => _buildTagChip(tag)).toList(),
                  ),
                ],
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            if (isExpired)
              Positioned(
                top: 8,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Expiré',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(BlogTag tag) {
    final Map<BlogTag, Color> tagColors = {
      BlogTag.gratuit: Colors.green,
      BlogTag.special: Colors.purple,
      BlogTag.nouveaute: Colors.blue,
      BlogTag.offreLimitee: Colors.orange,
    };

    final Map<BlogTag, String> tagLabels = {
      BlogTag.gratuit: 'Gratuit',
      BlogTag.special: 'Spécial',
      BlogTag.nouveaute: 'Nouveauté',
      BlogTag.offreLimitee: 'Offre Limitée',
    };

    return Chip(
      label: Text(
        tagLabels[tag] ?? tag.name,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: tagColors[tag] ?? Colors.grey,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
            top: _NotificationsScreenStyles.appBarTotalHeight + 20,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('blogPosts')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Erreur : ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Aucune notification'));
              }

              // Convert documents to BlogPost objects
              List<BlogPost> blogPosts = snapshot.data!.docs.map((doc) {
                var blogPostData = doc.data() as Map<String, dynamic>;
                return BlogPost.fromJson(blogPostData);
              }).toList();

              // Sort and filter blog posts
              List<BlogPost> filteredBlogPosts = blogPosts.where((blogPost) {
                bool isExpired = blogPost.validUntil != null &&
                    DateTime.now().isAfter(blogPost.validUntil!);

                // If switch is off, filter out expired posts
                return _showExpiredPosts || !isExpired;
              }).toList();

              // Sort: non-expired first, then expired (if showing expired)
              filteredBlogPosts.sort((a, b) {
                bool aExpired = a.validUntil != null &&
                    DateTime.now().isAfter(a.validUntil!);
                bool bExpired = b.validUntil != null &&
                    DateTime.now().isAfter(b.validUntil!);

                if (aExpired == bExpired) {
                  // If both are expired or both are not expired, sort by creation date
                  return b.createdAt.compareTo(a.createdAt);
                }

                // Move expired to the bottom if not explicitly showing them
                return _showExpiredPosts
                    ? (bExpired ? 1 : -1)
                    : (aExpired ? 1 : -1);
              });

              return Column(
                children: [
                  // Add the new toggle switch
                  _buildExpiredPostsToggle(),

                  // If no posts to show after filtering
                  if (filteredBlogPosts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Aucune notification à afficher',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),

                  // Build notification items
                  ...filteredBlogPosts.map((blogPost) {
                    return _buildNotificationItem(blogPost);
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExpiredPostsToggle() {
    return Container(
      height: _NotificationsScreenStyles.switchHeight,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Afficher les notifications expirées',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Switch(
              value: _showExpiredPosts,
              onChanged: (bool value) {
                setState(() {
                  _showExpiredPosts = value;
                });
              },
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
