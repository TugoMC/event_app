import 'package:event_app/data/models/city.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CitiesListScreen extends StatelessWidget {
  const CitiesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner une ville'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cities').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Erreur lors du chargement des villes'));
          }

          final cities = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return City(
              id: doc.id,
              name: data['name'],
              communes: [], // Si vous n'avez pas besoin de communes ici
            );
          }).toList();

          return ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return ListTile(
                title: Text(city.name),
                onTap: () {
                  Navigator.pop(
                      context, city); // Retourne la ville sélectionnée
                },
              );
            },
          );
        },
      ),
    );
  }
}
