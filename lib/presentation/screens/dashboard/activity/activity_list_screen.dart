import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/models/activity.dart';
import 'edit_activity_screen.dart';

class ActivitiesListScreen extends StatefulWidget {
  const ActivitiesListScreen({super.key});

  @override
  State<ActivitiesListScreen> createState() => _ActivitiesListScreenState();
}

class _ActivitiesListScreenState extends State<ActivitiesListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour obtenir les activités depuis Firestore
  Stream<List<Activity>> _getActivities() {
    return _firestore.collection('activities').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Activity.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id, // Passez l'ID du document ici
        );
      }).toList();
    });
  }

  // Fonction de suppression d'une activité
  Future<void> _deleteActivity(String activityId) async {
    if (activityId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID de l\'activité invalide')),
      );
      return;
    }

    try {
      await _firestore.collection('activities').doc(activityId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activité supprimée')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des activités')),
      body: StreamBuilder<List<Activity>>(
        stream: _getActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final activities = snapshot.data ?? [];

          if (activities.isEmpty) {
            return const Center(
              child: Text('Aucune activité disponible'),
            );
          }

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];

              return ListTile(
                leading: Icon(activity.icon),
                title: Text(activity.type),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditActivityScreen(activityId: activity.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmer la suppression'),
                            content: Text(
                                'Voulez-vous vraiment supprimer l\'activité "${activity.type}" ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteActivity(activity.id);
                                },
                                child: const Text('Supprimer'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditActivityScreen(activityId: activity.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
