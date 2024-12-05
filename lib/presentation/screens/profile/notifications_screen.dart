import 'package:event_app/data/models/blog_post.dart';
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
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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

  // Dans la méthode _buildNotificationItem, remplacez l'existant par :
  Widget _buildNotificationItem(BlogPost blogPost) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                blogPost.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                blogPost.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
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

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  var blogPostData = doc.data() as Map<String, dynamic>;
                  BlogPost blogPost = BlogPost.fromJson(blogPostData);
                  return _buildNotificationItem(blogPost);
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
