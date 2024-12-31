import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/blog_post.dart'; // Import the BlogPost model
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsHeader extends StatefulWidget {
  final EventSpace eventSpace;

  const DetailsHeader({Key? key, required this.eventSpace}) : super(key: key);

  @override
  _DetailsHeaderState createState() => _DetailsHeaderState();
}

class _DetailsHeaderState extends State<DetailsHeader> {
  BlogPost? _associatedBlogPost;
  double? _currentPrice;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchAssociatedBlogPost();
  }

  Future<void> _fetchAssociatedBlogPost() async {
    try {
      // Fetch the blog post associated with this event space
      final querySnapshot = await FirebaseFirestore.instance
          .collection('blogPosts')
          .where('eventSpaceId', isEqualTo: widget.eventSpace.id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final blogPostData = querySnapshot.docs.first.data();
        final blogPost = BlogPost.fromJson(blogPostData);

        setState(() {
          _associatedBlogPost = blogPost;
          // Utilisez la méthode getCurrentPrice() qui gère déjà la logique de prix promotionnel
          _currentPrice = blogPost.getCurrentPrice();
        });
      } else {
        setState(() {
          _currentPrice = widget.eventSpace.price;
        });
      }
    } catch (e) {
      print('Error fetching associated blog post: $e');
      setState(() {
        _currentPrice = widget.eventSpace.price;
      });
    }
  }

  Future<double> _calculateAverageRating() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('eventSpaceId', isEqualTo: widget.eventSpace.id)
        .get();

    if (querySnapshot.docs.isEmpty) return 0.0;

    final ratings = querySnapshot.docs.map((doc) => doc['rating'] as int);
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  Widget _buildExpandableDescription() {
    const int maxCharacters = 1500;
    const int initialDisplayCharacters = 100;
    final String description = widget.eventSpace.description;
    final bool isLongDescription =
        description.length > initialDisplayCharacters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: _isDescriptionExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Text(
                  isLongDescription
                      ? '${description.substring(0, initialDisplayCharacters)}...'
                      : description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                ),
                secondChild: Text(
                  description.length > maxCharacters
                      ? '${description.substring(0, maxCharacters)}...'
                      : description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            if (isLongDescription)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDescriptionExpanded = !_isDescriptionExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8773F8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isDescriptionExpanded
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 16,
                      color: const Color(0xFF8773F8),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (description.length > maxCharacters && _isDescriptionExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Texte tronqué à ${maxCharacters} caractères',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResponsiveContainer({
    required IconData icon,
    required String text,
    Color? iconColor,
    Color? textColor,
    Color? backgroundColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isNarrowScreen = constraints.maxWidth < 350;

        return Container(
          constraints: BoxConstraints(
            minWidth: isNarrowScreen ? 90 : 110,
            maxHeight: 45,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isNarrowScreen ? 10 : 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: backgroundColor == null
                  ? const Color(0xFF8773F8).withOpacity(0.2)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor ?? const Color(0xFF8773F8),
                size: isNarrowScreen ? 16 : 18,
              ),
              if (!isNarrowScreen) const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: textColor ?? const Color(0xFF2D3142),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _calculateAverageRating(),
      builder: (context, snapshot) {
        final averageRating = snapshot.data ?? 0.0;
        final hasReviews = averageRating > 0;
        final displayPrice = _currentPrice ?? widget.eventSpace.price;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Responsive Info Row
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.start,
                    children: [
                      // Rating Container (only if reviews exist)
                      if (hasReviews)
                        _buildResponsiveContainer(
                          icon: CupertinoIcons.star_fill,
                          text: averageRating.toStringAsFixed(1),
                        ),

                      // Hours Container
                      _buildResponsiveContainer(
                        icon: CupertinoIcons.clock_fill,
                        text: widget.eventSpace.hours,
                      ),

                      // Wrap breaker to force price to next line
                      SizedBox(
                        width: double.infinity,
                        child: _buildResponsiveContainer(
                          icon: CupertinoIcons.circle,
                          text: '${displayPrice.toStringAsFixed(0)} FCFA',
                          backgroundColor:
                              _associatedBlogPost?.promotionalPrice != null &&
                                      _associatedBlogPost!.promotionalPrice!
                                          .isCurrentlyActive()
                                  ? const Color(0xFF8773F8)
                                  : null,
                          iconColor:
                              _associatedBlogPost?.promotionalPrice != null &&
                                      _associatedBlogPost!.promotionalPrice!
                                          .isCurrentlyActive()
                                  ? Colors.white
                                  : null,
                          textColor:
                              _associatedBlogPost?.promotionalPrice != null &&
                                      _associatedBlogPost!.promotionalPrice!
                                          .isCurrentlyActive()
                                  ? Colors.white
                                  : null,
                        ),
                      ),

                      if (_associatedBlogPost?.promotionalPrice != null &&
                          _associatedBlogPost!.promotionalPrice!
                              .isCurrentlyActive())
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${widget.eventSpace.price.toStringAsFixed(0)} FCFA',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                TextSpan(
                                  text: '  Offre limitée !',
                                  style: TextStyle(
                                    color: Color(0xFF8773F8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Rest of the existing code remains the same...
              const SizedBox(height: 24),

              // Description
              _buildExpandableDescription(),

              const SizedBox(height: 24),

              // Phone Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Téléphone',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8773F8).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            CupertinoIcons.phone_fill,
                            size: 16,
                            color: Color(0xFF8773F8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.eventSpace.phoneNumber,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
