import 'package:event_app/data/models/blog_post.dart';
import 'package:flutter/material.dart';

class BlogPostDetailScreen extends StatelessWidget {
  final BlogPost post;

  const BlogPostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Event Space: ${post.eventSpaceId}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Description: ${post.description}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Price: ${post.eventSpacePrice} €',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Created: ${post.createdAt}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children:
                  post.tags.map((tag) => Chip(label: Text(tag.name))).toList(),
            ),
            if (post.promotionalPrice != null) ...[
              const SizedBox(height: 10),
              Text(
                'Promotional Price: ${post.promotionalPrice!.promotionalPrice} €',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
