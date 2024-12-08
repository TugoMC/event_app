import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:uuid/uuid.dart';

class BlogPost {
  final String id;
  final String title;
  final String description;
  final String eventSpaceId;
  final double eventSpacePrice;
  final DateTime createdAt;
  final DateTime? validUntil;
  final List<BlogTag> tags;
  final BlogPromotionalPrice? promotionalPrice;

  BlogPost({
    String? id,
    required this.title,
    required this.description,
    required this.eventSpaceId,
    required this.eventSpacePrice,
    required this.createdAt,
    this.validUntil,
    required this.tags,
    this.promotionalPrice,
  }) : id = id ?? Uuid().v4() {
    // Extensive validation
    _validateFields();
  }

  void _validateFields() {
    // Price validation
    if (eventSpacePrice < 0) {
      throw ArgumentError('Price cannot be negative');
    }

    // Promotional price validation
    if (promotionalPrice != null) {
      if (promotionalPrice!.promotionalPrice >= eventSpacePrice) {
        throw ArgumentError(
            'Promotional price must be lower than original price');
      }

      // Ensure valid until date for limited offers
      if (tags.contains(BlogTag.offreLimitee) && validUntil == null) {
        throw ArgumentError('A limited offer must have a validity period');
      }

      // Promotional period validation
      if (promotionalPrice!.startDate.isAfter(promotionalPrice!.endDate)) {
        throw ArgumentError('Promotional start date must be before end date');
      }
    }

    // Title and description validations could be added here
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }

    if (description.trim().isEmpty) {
      throw ArgumentError('Description cannot be empty');
    }
  }

  // Asynchronous method to fetch event space price from Firestore
  static Future<double> fetchEventSpacePrice(String eventSpaceId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('eventSpaces')
          .doc(eventSpaceId)
          .get();

      if (!docSnapshot.exists) {
        throw ArgumentError('EventSpace not found');
      }

      final price = docSnapshot.data()?['price'];
      if (price == null) {
        throw ArgumentError('Price not found for event space');
      }

      // Ensure price is converted to double
      return (price is int) ? price.toDouble() : price;
    } catch (e) {
      print('Error fetching event space price: $e');
      throw ArgumentError('Could not retrieve event space price');
    }
  }

  // Method to get current applicable price
  double getCurrentPrice() {
    if (promotionalPrice != null && promotionalPrice!.isCurrentlyActive()) {
      return promotionalPrice!.promotionalPrice;
    }
    return eventSpacePrice;
  }

  // Async creation method
  static Future<BlogPost> create({
    required String title,
    required String description,
    required String eventSpaceId,
    required DateTime createdAt,
    DateTime? validUntil,
    required List<BlogTag> tags,
    BlogPromotionalPrice? promotionalPrice,
  }) async {
    // Fetch price asynchronously
    final price = await fetchEventSpacePrice(eventSpaceId);

    return BlogPost(
      title: title,
      description: description,
      eventSpaceId: eventSpaceId,
      eventSpacePrice: price,
      createdAt: createdAt,
      validUntil: validUntil,
      tags: tags,
      promotionalPrice: promotionalPrice,
    );
  }

  // JSON serialization methods
  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      eventSpaceId: json['eventSpaceId'],
      eventSpacePrice: _parsePrice(json['eventSpacePrice']),
      createdAt: DateTime.parse(json['createdAt']),
      validUntil: json['validUntil'] != null
          ? DateTime.parse(json['validUntil'])
          : null,
      tags: (json['tags'] as List<dynamic>)
          .map((tag) => BlogTag.values.firstWhere((e) => e.name == tag))
          .toList(),
      promotionalPrice: json['promotionalPrice'] != null
          ? BlogPromotionalPrice.fromJson(json['promotionalPrice'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'eventSpaceId': eventSpaceId,
      'eventSpacePrice': eventSpacePrice,
      'createdAt': createdAt.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'tags': tags.map((tag) => tag.name).toList(),
      'promotionalPrice': promotionalPrice?.toJson(),
    };
  }

  // Helper method to parse different price formats
  static double _parsePrice(dynamic price) {
    if (price is int) return price.toDouble();
    if (price is double) return price;
    if (price is String) return double.parse(price);
    throw FormatException('Invalid price format: $price');
  }

  // In blog_post.dart
  static Future<BlogPost?> fetchBlogPostById(String blogPostId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('blogPosts')
          .doc(blogPostId)
          .get();

      print('Fetching blog post with ID: $blogPostId');
      print('Document exists: ${docSnapshot.exists}');

      if (!docSnapshot.exists) {
        print('Blog post not found in Firestore');
        return null;
      }

      final data = docSnapshot.data();
      print('Blog post data: $data');

      return BlogPost.fromJson({'id': docSnapshot.id, ...data!});
    } catch (e) {
      print('Error fetching blog post: $e');
      return null;
    }
  }
}

enum BlogTag {
  gratuit,
  special,
  nouveaute,
  offreLimitee,
}

class BlogPromotionalPrice {
  final double promotionalPrice;
  final DateTime startDate;
  final DateTime endDate;

  BlogPromotionalPrice({
    required this.promotionalPrice,
    required this.startDate,
    required this.endDate,
  });

  bool isCurrentlyActive() {
    final now = DateTime.now();
    return (now.isAtSameMomentAs(startDate) || now.isAfter(startDate)) &&
        (now.isAtSameMomentAs(endDate) || now.isBefore(endDate));
  }

  // JSON serialization methods
  factory BlogPromotionalPrice.fromJson(Map<String, dynamic> json) {
    return BlogPromotionalPrice(
      promotionalPrice: double.parse(json['promotionalPrice'].toString()),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promotionalPrice': promotionalPrice,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
