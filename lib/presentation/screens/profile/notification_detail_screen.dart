import 'package:event_app/presentation/screens/event_space/event_space_detail.dart';
import 'package:event_app/presentation/screens/profile/notif_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:event_app/data/models/blog_post.dart';
import 'package:event_app/data/models/event_space.dart';

class BlogPostDetailScreen extends StatefulWidget {
  final BlogPost blogPost;

  const BlogPostDetailScreen({super.key, required this.blogPost});

  @override
  State<BlogPostDetailScreen> createState() => _BlogPostDetailScreenState();
}

class _BlogPostDetailScreenState extends State<BlogPostDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isAdmin = false;

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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkAdminStatus();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > scrollThreshold && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= scrollThreshold && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  bool _isOfferExpired() {
    final now = DateTime.now();

    // Check promotional price expiration if exists
    if (widget.blogPost.promotionalPrice != null) {
      if (!widget.blogPost.promotionalPrice!.isCurrentlyActive()) {
        return true;
      }
    }

    // Check overall validity period
    if (widget.blogPost.validUntil != null) {
      return now.isAfter(widget.blogPost.validUntil!);
    }

    return false;
  }

  Widget _buildExpirationBanner() {
    if (_isOfferExpired()) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_outlined, color: Colors.red[700], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cette offre a expiré',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: circularButtonSize,
      height: circularButtonSize,
      margin: EdgeInsets.symmetric(horizontal: circularButtonMargin),
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
      preferredSize: Size.fromHeight(appBarTotalHeight),
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
          toolbarHeight: appBarTotalHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Container(
                width: double.infinity,
                height: bannerHeight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: buttonRowHeight,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                    SizedBox(height: spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: titleContainerHeight,
                      margin:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      padding: titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: FutureBuilder<EventSpace>(
                        future: EventSpace.fetchEventSpaceDetails(
                            widget.blogPost.eventSpaceId),
                        builder: (context, snapshot) {
                          final title = snapshot.hasData
                              ? '${widget.blogPost.title} - ${snapshot.data!.name}'
                              : widget.blogPost.title;

                          return Text(
                            title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
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

  Widget _buildPriceSection() {
    if (widget.blogPost.tags.contains(BlogTag.gratuit)) {
      return const SizedBox.shrink(); // This will not render anything
    }
    return Container(
      width: double.infinity, // Make full width
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Prix de l\'espace',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.blogPost.promotionalPrice != null) ...[
                    Text(
                      '${widget.blogPost.eventSpacePrice} FCFA',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      '${widget.blogPost.promotionalPrice!.promotionalPrice} FCFA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ] else
                    Text(
                      '${widget.blogPost.eventSpacePrice} FCFA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (widget.blogPost.promotionalPrice != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Offre valable du ${DateFormat('dd/MM/yyyy').format(widget.blogPost.promotionalPrice!.startDate)} au ${DateFormat('dd/MM/yyyy').format(widget.blogPost.promotionalPrice!.endDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventSpaceSection() {
    return GestureDetector(
      onTap: () async {
        try {
          final eventSpace = await EventSpace.fetchEventSpaceDetails(
              widget.blogPost.eventSpaceId);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventSpaceDetailScreen(
                eventSpace: eventSpace,
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Impossible de charger les détails de l\'espace')),
          );
        }
      },
      child: Container(
        width: double.infinity, // Make full width
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Voir l'espace",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            FutureBuilder<EventSpace>(
              future: EventSpace.fetchEventSpaceDetails(
                  widget.blogPost.eventSpaceId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${snapshot.data!.commune.name}, ${snapshot.data!.city.name}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }
                return Container(); // Or a loading indicator
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminNotificationButton() {
    if (!_isAdmin) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: _sendPushNotification,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active),
            SizedBox(width: 8),
            Text(
              'Envoyer une notification push',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            top: appBarTotalHeight - 100,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add expiration banner at the top
              _buildExpirationBanner(),

              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.blogPost.tags
                    .map((tag) => _buildTagChip(tag))
                    .toList(),
              ),
              const SizedBox(height: 25),
              Text(
                widget.blogPost.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              _buildPriceSection(),
              _buildEventSpaceSection(),

              // Add the admin notification button
              _buildAdminNotificationButton(),

              // Previous validity section remains the same
              if (widget.blogPost.validUntil != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isOfferExpired() ? Colors.red[50] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _isOfferExpired()
                            ? Colors.red[200]!
                            : Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color:
                            _isOfferExpired() ? Colors.red[700] : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Valable jusqu\'au ${DateFormat('dd/MM/yyyy').format(widget.blogPost.validUntil!)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: _isOfferExpired()
                                ? Colors.red[700]
                                : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
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

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isAdmin = user.email == 'ouattarajunior418@gmail.com';
      });
    }
  }

  Future<void> _sendPushNotification() async {
    try {
      // Fetch event space details to get the name
      final eventSpace =
          await EventSpace.fetchEventSpaceDetails(widget.blogPost.eventSpaceId);

      // Truncate description to first 50 characters
      String truncatedDescription = widget.blogPost.description.length > 50
          ? '${widget.blogPost.description.substring(0, 50)}...'
          : widget.blogPost.description;

      await PushNotificationService.sendPushNotification(
        context: context,
        title: '${widget.blogPost.title} - ${eventSpace.name}',
        body: truncatedDescription,
        data: {
          'blogPostId': widget.blogPost.id,
          'type': 'blog_post',
          'eventSpaceId': widget.blogPost.eventSpaceId,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de l\'envoi de la notification : $e')),
      );
    }
  }
}
