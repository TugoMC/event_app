import 'package:event_app/presentation/screens/dashboard/eventspace/recommendations/recommendations_deletion_screen.dart';
import 'package:event_app/presentation/screens/dashboard/eventspace/recommendations/recommendations_generation_screen.dart';
import 'package:event_app/presentation/screens/dashboard/eventspace/recommendations/recommendations_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class RecommendationsManagementScreen extends StatefulWidget {
  const RecommendationsManagementScreen({super.key});

  @override
  State<RecommendationsManagementScreen> createState() =>
      _RecommendationsManagementScreenState();
}

class _RecommendationsManagementScreenState
    extends State<RecommendationsManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Recommandations'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuItem(
            icon: Icon(CupertinoIcons.refresh_thick, color: Colors.blue[400]),
            title: 'Générer des recommandations',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecommendationsGenerationScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icon(CupertinoIcons.list_bullet, color: Colors.green[400]),
            title: 'Voir les recommandations existantes',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecommendationsListScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icon(CupertinoIcons.delete, color: Colors.red[400]),
            title: 'Supprimer des recommandations',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecommendationsDeletionScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required Icon icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: icon,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
