import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCityScreen extends StatefulWidget {
  final String cityId;
  final String initialName;

  const EditCityScreen({
    super.key,
    required this.cityId,
    required this.initialName,
  });

  @override
  State<EditCityScreen> createState() => _EditCityScreenState();
}

class _EditCityScreenState extends State<EditCityScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
  }

  Future<void> _updateCity() async {
    final updatedName = _nameController.text.trim();
    if (updatedName.isEmpty) return;

    try {
      await _firestore.collection('cities').doc(widget.cityId).update({
        'name': updatedName,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ville mise à jour avec succès !')),
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
        title: const Text('Modifier une ville'),
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
              onPressed: _updateCity,
              child: const Text('Mettre à jour'),
            ),
          ],
        ),
      ),
    );
  }
}
