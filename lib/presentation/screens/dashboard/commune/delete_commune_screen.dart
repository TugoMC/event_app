import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteCommuneScreen extends StatelessWidget {
  final String communeId;

  const DeleteCommuneScreen({super.key, required this.communeId});

  Future<void> _confirmDelete(BuildContext context) async {
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
      _deleteCommune(context);
    }
  }

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
            const Text(
                'Cliquez sur le bouton ci-dessous pour confirmer la suppression.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmDelete(context),
              child: const Text('Supprimer'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
