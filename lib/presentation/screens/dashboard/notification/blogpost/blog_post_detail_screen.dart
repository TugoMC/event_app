import 'package:event_app/data/models/blog_post.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class BlogPostDetailScreen extends StatefulWidget {
  final BlogPost post;

  const BlogPostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  _BlogPostDetailScreenState createState() => _BlogPostDetailScreenState();
}

class _BlogPostDetailScreenState extends State<BlogPostDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize date formatting for French locale
    initializeDateFormatting('fr_FR');
  }

  // Helper method to format price in FCFA with thousands separator
  String _formatPrice(double price) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(price)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title
            Text(
              widget.post.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Event Space Details
            _buildDetailRow(
              context,
              icon: Icons.location_on,
              label: 'Espace événementiel',
              value: widget.post.eventSpaceId,
            ),

            // Description
            const SizedBox(height: 16),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              widget.post.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 16),

            // Pricing Section
            _buildDetailRow(
              context,
              icon: Icons.attach_money,
              label: 'Prix original',
              value: _formatPrice(widget.post.eventSpacePrice),
            ),

            // Promotional Price (if available)
            if (widget.post.promotionalPrice != null) ...[
              _buildDetailRow(
                context,
                icon: Icons.discount,
                label: 'Prix promotionnel',
                value: _formatPrice(
                    widget.post.promotionalPrice!.promotionalPrice),
                valueStyle: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            // Creation Date
            _buildDetailRow(
              context,
              icon: Icons.calendar_today,
              label: 'Date de création',
              value: DateFormat('dd MMMM yyyy', 'fr_FR')
                  .format(widget.post.createdAt),
            ),

            // Validity Period (if available)
            if (widget.post.validUntil != null) ...[
              _buildDetailRow(
                context,
                icon: Icons.event,
                label: 'Valable jusqu\'au',
                value: DateFormat('dd MMMM yyyy', 'fr_FR')
                    .format(widget.post.validUntil!),
              ),
            ],

            // Tags
            const SizedBox(height: 16),
            Text(
              'Étiquettes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: widget.post.tags.map((tag) {
                return Chip(
                  label: Text(
                    _getTagLabel(tag),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: _getTagColor(tag),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create a row with icon, label, and value
  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  value,
                  style: valueStyle ?? Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get tag labels in French
  String _getTagLabel(BlogTag tag) {
    switch (tag) {
      case BlogTag.gratuit:
        return 'Gratuit';
      case BlogTag.special:
        return 'Spécial';
      case BlogTag.nouveaute:
        return 'Nouveauté';
      case BlogTag.offreLimitee:
        return 'Offre Limitée';
    }
  }

  // Helper method to get tag colors
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
}
