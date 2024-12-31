import 'package:event_app/data/models/blog_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class BlogDetailStyles {
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

class BlogPostDetailScreen extends StatefulWidget {
  final BlogPost post;

  const BlogPostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  _BlogPostDetailScreenState createState() => _BlogPostDetailScreenState();
}

class _BlogPostDetailScreenState extends State<BlogPostDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    initializeDateFormatting('fr_FR');
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > BlogDetailStyles.scrollThreshold &&
        !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= BlogDetailStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(price)} FCFA';
  }

  bool _isOfferExpired(BlogPost post) {
    final now = DateTime.now();
    if (post.promotionalPrice != null) {
      if (!post.promotionalPrice!.isCurrentlyActive()) {
        return true;
      }
    }
    if (post.validUntil != null) {
      return now.isAfter(post.validUntil!);
    }
    return false;
  }

  Widget _buildExpirationBanner(BlogPost post) {
    if (_isOfferExpired(post)) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_outlined, color: Colors.red[700], size: 16),
            const SizedBox(width: 8),
            Text(
              'Offre expirée',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildDetailCard(String title, String content, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            content,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(BlogDetailStyles.appBarTotalHeight),
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
          toolbarHeight: BlogDetailStyles.appBarTotalHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Container(
                width: double.infinity,
                height: BlogDetailStyles.bannerHeight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: BlogDetailStyles.buttonRowHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: BlogDetailStyles.horizontalPadding),
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
                        height: BlogDetailStyles.spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: BlogDetailStyles.titleContainerHeight,
                      margin: EdgeInsets.symmetric(
                          horizontal: BlogDetailStyles.horizontalPadding),
                      padding: BlogDetailStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            BlogDetailStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Détails de l\'article',
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

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: BlogDetailStyles.circularButtonSize,
      height: BlogDetailStyles.circularButtonSize,
      margin: EdgeInsets.symmetric(
          horizontal: BlogDetailStyles.circularButtonMargin),
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

  Color _getTagColor(BlogTag tag) {
    switch (tag) {
      case BlogTag.gratuit:
        return Colors.green;
      case BlogTag.special:
        return Colors.purple;
      case BlogTag.nouveaute:
        return Colors.blue;
      case BlogTag.offreLimitee:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            top: BlogDetailStyles.appBarTotalHeight + 20,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.post.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailCard(
                'Description',
                widget.post.description,
              ),
              if (_isOfferExpired(widget.post))
                _buildExpirationBanner(widget.post),
              _buildDetailCard(
                'Espace événementiel',
                widget.post.eventSpaceId,
                trailing: const Icon(Icons.location_on, color: Colors.blue),
              ),
              _buildDetailCard(
                'Prix original',
                _formatPrice(widget.post.eventSpacePrice),
                trailing: const Icon(Icons.attach_money, color: Colors.green),
              ),
              if (widget.post.promotionalPrice != null)
                _buildDetailCard(
                  'Prix promotionnel',
                  _formatPrice(widget.post.promotionalPrice!.promotionalPrice),
                  trailing: const Icon(Icons.discount, color: Colors.orange),
                ),
              _buildDetailCard(
                'Date de création',
                DateFormat('dd MMMM yyyy', 'fr_FR')
                    .format(widget.post.createdAt),
                trailing:
                    const Icon(Icons.calendar_today, color: Colors.purple),
              ),
              if (widget.post.validUntil != null)
                _buildDetailCard(
                  'Valable jusqu\'au',
                  DateFormat('dd MMMM yyyy', 'fr_FR')
                      .format(widget.post.validUntil!),
                  trailing: const Icon(Icons.event, color: Colors.red),
                ),
              Container(
                margin: const EdgeInsets.only(top: 16, bottom: 8),
                child: const Text(
                  'Étiquettes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.post.tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getTagColor(tag).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag.name,
                            style: TextStyle(
                              color: _getTagColor(tag),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
