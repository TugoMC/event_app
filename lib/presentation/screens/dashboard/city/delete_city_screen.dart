import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteCityScreen extends StatelessWidget {
  const DeleteCityScreen({super.key});

  Future<void> _deleteCity(String cityId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('cities')
          .doc(cityId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ville supprimée avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  void _confirmDeletion(String cityId, String cityName, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content:
              Text('Voulez-vous vraiment supprimer la ville "$cityName" ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                _deleteCity(cityId, context); // Supprime la ville
              },
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supprimer une ville'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('cities').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Erreur de chargement des données.'));
          }
          final cities = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return ListTile(
                title: Text(city['name']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeletion(
                    city.id, // L'identifiant du document
                    city['name'], // Le nom de la ville
                    context,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
