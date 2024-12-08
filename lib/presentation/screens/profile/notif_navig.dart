import 'package:flutter/material.dart';
import 'package:event_app/data/models/blog_post.dart';
import 'package:event_app/presentation/screens/profile/notification_detail_screen.dart';

class NotificationNavigationService {
  static void navigateToBlogPostDetail(
      BuildContext context, Map<String, dynamic> data) async {
    if (data['type'] == 'blog_post' && data['blogPostId'] != null) {
      try {
        final blogPost = await BlogPost.fetchBlogPostById(data['blogPostId']);

        if (blogPost != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogPostDetailScreen(blogPost: blogPost),
            ),
          );
        } else {
          // Afficher un écran d'erreur personnalisé ou une boîte de dialogue
          _showDetailedErrorDialog(context, 'Publication non trouvée',
              'Le billet de blog que vous recherchez n\'existe plus ou a été supprimé.');
        }
      } catch (e) {
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