import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteCommuneScreen extends StatelessWidget {
  final String communeId;

  const DeleteCommuneScreen({super.key, required this.communeId});

  Future<void> _deleteCommune(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('communes')
          .doc(communeId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commune supprimée avec succès!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supprimer la Commune')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Êtes-vous sûr de vouloir supprimer cette commune?'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _deleteCommune(context),
              child: const Text('Supprimer'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
