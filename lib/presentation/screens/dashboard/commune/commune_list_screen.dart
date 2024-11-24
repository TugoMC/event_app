import 'package:event_app/data/models/commune.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_commune_screen.dart'; // Page pour modifier une commune

class CommuneListScreen extends StatelessWidget {
  const CommuneListScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, String communeId) async {
    final bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
              'Êtes-vous sûr de vouloir supprimer cette commune? Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Annuler
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirmer
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      try {
        await FirebaseFirestore.instance
            .collection('communes')
            .doc(communeId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commune supprimée avec succès!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Toutes les communes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('communes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement'));
          }

          final communes = snapshot.data!.docs.map((doc) {
            return Commune.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: communes.length,
            itemBuilder: (context, index) {
              final commune = communes[index];
              return ListTile(
                title: Text(commune.name),
                subtitle: Text('Ville: ${commune.cityId}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Naviguer vers la page de modification
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditCommuneScreen(communeId: commune.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context, commune.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
