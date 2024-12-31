import 'package:event_app/data/models/blog_post.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/presentation/screens/profile/notif_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'blog_post_detail_screen.dart';
import 'blog_post_edit_screen.dart';

class BlogStyles {
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

class BlogPostListScreen extends StatefulWidget {
  const BlogPostListScreen({Key? key}) : super(key: key);

  @override
  _BlogPostListScreenState createState() => _BlogPostListScreenState();
}

class _BlogPostListScreenState extends State<BlogPostListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isScrolled = false;
  String _searchQuery = '';
  List<String> _selectedTags = [];
  bool _sortDescending = true;
  bool _isAdmin = false;

  List<BlogPost> _allBlogPosts = [];
  List<BlogPost> _filteredBlogPosts = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchBlogPosts();
    _checkAdminStatus();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > BlogStyles.scrollThreshold && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= BlogStyles.scrollThreshold &&
        _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isAdmin = user.email == 'ouattarajunior418@gmail.com';
      });
    }
  }

  Future<void> _sendNotification(BlogPost post) async {
    try {
      final eventSpace =
          await EventSpace.fetchEventSpaceDetails(post.eventSpaceId);

      String truncatedDescription = post.description.length > 50
          ? '${post.description.substring(0, 50)}...'
          : post.description;

      await PushNotificationService.sendPushNotification(
        context: context,
        title: '${post.title} - ${eventSpace.name}',
        body: truncatedDescription,
        data: {
          'blogPostId': post.id,
          'type': 'blog_post',
          'eventSpaceId': post.eventSpaceId,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de l\'envoi de la notification : $e')),
      );
    }
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

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Méthode pour envoyer une notification locale pour un article
  Future<void> _sendLocalNotification(BlogPost post) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'blog_post_channel',
      'Blog Post Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Personnaliser le message de notification en fonction des tags
    String notificationBody = post.description;
    if (post.tags.contains(BlogTag.offreLimitee)) {
      notificationBody += " 🔥 Offre limitée !";
    }
    if (post.tags.contains(BlogTag.nouveaute)) {
      notificationBody += " 🆕 Nouveauté !";
    }

    // Prix actuel (avec prise en compte de la promotion éventuelle)
    String priceInfo = "Prix: ${post.getCurrentPrice().toStringAsFixed(2)}€";
    notificationBody += "\n$priceInfo";

    await flutterLocalNotificationsPlugin.show(
      post.hashCode, // ID unique de notification
      post.title,
      notificationBody,
      platformChannelSpecifics,
    );
  }

  Future<void> _fetchBlogPosts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('blogPosts')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _allBlogPosts = querySnapshot.docs.map((doc) {
          return BlogPost.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          });
        }).toList();
        _applyFilters();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredBlogPosts = _allBlogPosts.where((post) {
        // Filtrage par recherche (insensible à la casse)
        bool matchesSearch = _searchQuery.isEmpty ||
            post.title.toLowerCase().contains(_searchQuery.toLowerCase());

        // Filtrage par tags
        bool matchesTags = _selectedTags.isEmpty ||
            _selectedTags
                .any((tag) => post.tags.any((postTag) => postTag.name == tag));

        return matchesSearch && matchesTags;
      }).toList();

      // Tri
      _filteredBlogPosts.sort((a, b) {
        return _sortDescending
            ? b.createdAt.compareTo(a.createdAt)
            : a.createdAt.compareTo(b.createdAt);
      });
    });
  }

  // Méthode pour construire les chips de tags dynamiques
  List<Widget> _buildDynamicTagFilters() {
    // Extraire tous les tags uniques des articles
    Set<String> allTags = _allBlogPosts
        .expand((post) => post.tags.map((tag) => tag.name))
        .toSet();

    return allTags.map((tagName) {
      return FilterChip(
        label: Text(tagName),
        selected: _selectedTags.contains(tagName),
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedTags.add(tagName);
            } else {
              _selectedTags.remove(tagName);
            }
            _applyFilters();
          });
        },
      );
    }).toList();
  }

  Widget _buildBlogPostCard(BlogPost post) {
    bool isExpired = _isOfferExpired(post);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  post.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: post.tags
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isAdmin && !isExpired)
                  IconButton(
                    icon:
                        Icon(CupertinoIcons.bell_fill, color: Colors.blue[400]),
                    onPressed: () => _sendNotification(post),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(CupertinoIcons.ellipsis_vertical),
                  onSelected: (String value) {
                    switch (value) {
                      case 'edit':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BlogPostEditScreen(post: post),
                          ),
                        );
                        break;
                      case 'delete':
                        _deletePost(post.id);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.pencil,
                              color: Colors.blue[400], size: 18),
                          const SizedBox(width: 12),
                          const Text('Modifier'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.delete,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 12),
                          const Text('Supprimer',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlogPostDetailScreen(post: post),
                ),
              );
            },
          ),
          if (isExpired) _buildExpirationBanner(post),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(BlogStyles.appBarTotalHeight),
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
          toolbarHeight: BlogStyles.appBarTotalHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            children: [
              Container(
                width: double.infinity,
                height: BlogStyles.bannerHeight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: BlogStyles.buttonRowHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: BlogStyles.horizontalPadding),
                        child: Row(
                          children: [
                            _buildCircularButton(
                              icon: const Icon(CupertinoIcons.back,
                                  color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            if (_isAdmin)
                              _buildCircularButton(
                                icon: const Icon(CupertinoIcons.add,
                                    color: Colors.black),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BlogPostEditScreen(),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: BlogStyles.spaceBetweenButtonAndTitle),
                    Container(
                      width: double.infinity,
                      height: BlogStyles.titleContainerHeight,
                      margin: EdgeInsets.symmetric(
                          horizontal: BlogStyles.horizontalPadding),
                      padding: BlogStyles.titlePadding,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(BlogStyles.borderRadius),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Articles de blog',
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
      width: BlogStyles.circularButtonSize,
      height: BlogStyles.circularButtonSize,
      margin: EdgeInsets.symmetric(horizontal: BlogStyles.circularButtonMargin),
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
            top: BlogStyles.appBarTotalHeight + 20,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Articles de blog',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              if (_filteredBlogPosts.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.doc_text,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun article trouvé',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredBlogPosts.length,
                  itemBuilder: (context, index) {
                    return _buildBlogPostCard(_filteredBlogPosts[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmer la suppression'),
          content:
              const Text('Êtes-vous sûr de vouloir supprimer cet article ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
        await _firestore.collection('blogPosts').doc(postId).delete();
        _fetchBlogPosts(); // Recharger tous les articles
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article supprimé avec succès')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de suppression : $e')),
      );
    }
  }

  // Méthode de couleur de tag inchangée
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
