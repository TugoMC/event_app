import 'package:event_app/data/models/blog_post.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'blog_post_detail_screen.dart';
import 'blog_post_edit_screen.dart';

class BlogPostListScreen extends StatefulWidget {
  const BlogPostListScreen({Key? key}) : super(key: key);

  @override
  _BlogPostListScreenState createState() => _BlogPostListScreenState();
}

class _BlogPostListScreenState extends State<BlogPostListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Filtrage et recherche
  String _searchQuery = '';
  List<String> _selectedTags = [];
  bool _sortDescending = true;

  // Liste complète des articles
  List<BlogPost> _allBlogPosts = [];
  List<BlogPost> _filteredBlogPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchBlogPosts();
    _initializeNotifications();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles de blog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlogPostEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ... (autres widgets inchangés)

          Expanded(
            child: _filteredBlogPosts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucun article trouvé',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredBlogPosts.length,
                    itemBuilder: (context, index) {
                      BlogPost post = _filteredBlogPosts[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(
                            post.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: post.tags
                                    .map((tag) => Chip(
                                          label: Text(tag.name),
                                          backgroundColor: _getTagColor(tag),
                                          labelStyle:
                                              const TextStyle(fontSize: 10),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BlogPostDetailScreen(post: post),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Bouton de notification
                              IconButton(
                                icon: const Icon(Icons.notifications_active,
                                    color: Colors.blue),
                                onPressed: () => _sendLocalNotification(post),
                              ),
                              // Menu d'options existant
                              PopupMenuButton<String>(
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
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Modifier'),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: ListTile(
                                      leading:
                                          Icon(Icons.delete, color: Colors.red),
                                      title: Text('Supprimer',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
