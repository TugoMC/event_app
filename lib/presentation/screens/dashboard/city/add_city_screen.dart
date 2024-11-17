import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AddCityScreen extends StatefulWidget {
  const AddCityScreen({super.key});

  @override
  State<AddCityScreen> createState() => _AddCityScreenState();
}

class _AddCityScreenState extends State<AddCityScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addCity() async {
    final cityName = _nameController.text.trim();
    if (cityName.isEmpty) return;

    final cityId = const Uuid().v4(); // Generate a unique ID
    try {
      await _firestore.collection('cities').doc(cityId).set({
        'id': cityId,
        'name': cityName,
        'communes': [],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ville ajoutée avec succès !')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une ville'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de la ville',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addCity,
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
