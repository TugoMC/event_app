import 'package:flutter/material.dart';
import 'package:event_app/data/models/blog_post.dart';
import 'package:event_app/presentation/screens/profile/notification_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationNavigationService {
  static void navigateToBlogPostDetail(
      BuildContext context, Map<String, dynamic> data) async {
    if (data['type'] == 'blog_post' && data['blogPostId'] != null) {
      try {
        // Directly fetch the blog post from Firestore
        final docSnapshot = await FirebaseFirestore.instance
            .collection('blogPosts')
            .doc(data['blogPostId'])
            .get();

        if (docSnapshot.exists) {
          // Combine the document ID with its data
          final blogPostData = {'id': docSnapshot.id, ...docSnapshot.data()!};

          // Create BlogPost object from the fetched data
          final blogPost = BlogPost.fromJson(blogPostData);

          // Navigate to the blog post detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogPostDetailScreen(blogPost: blogPost),
            ),
          );
        } else {
          // Show error dialog if blog post not found
          _showDetailedErrorDialog(context, 'Publication non trouvée',
              'Le billet de blog que vous recherchez n\'existe plus ou a été supprimé.');
        }
      } catch (e) {
        // Show error dialog if there's an exception
        _showDetailedErrorDialog(context, 'Erreur de chargement',
            'Impossible de charger les détails de la publication. Veuillez réessayer.');
      }
    } else {
      _showDetailedErrorDialog(context, 'Données invalides',
          'Les informations de notification sont incorrectes.');
    }
  }

  static void _showDetailedErrorDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
