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

  @override
  void initState() {
    super.initState();
    _fetchAssociatedBlogPost();
  }

  Future<void> _fetchAssociatedBlogPost() async {
    try {
      // Fetch the blog post associated with this event space
      final querySnapshot = await FirebaseFirestore.instance
          .collection('blog_posts')
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
            minWidth: isNarrowScreen ? 80 : 100,
            maxHeight: 40,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isNarrowScreen ? 8 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: backgroundColor ?? const Color(0xFF8773F8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor ?? const Color(0xFF8773F8),
                size: isNarrowScreen ? 14 : 16,
              ),
              if (!isNarrowScreen) const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? const Color(0xFF8773F8),
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

                      // Price Container avec logique promotionnelle
                      // Price Container avec logique promotionnelle
                      _buildResponsiveContainer(
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
              Text(
                widget.eventSpace.description,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
              ),

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
