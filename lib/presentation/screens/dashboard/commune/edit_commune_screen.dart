import 'package:event_app/data/models/commune.dart';
import 'package:event_app/data/models/city.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCommuneScreen extends StatefulWidget {
  final String communeId;

  const EditCommuneScreen({super.key, required this.communeId});

  @override
  State<EditCommuneScreen> createState() => _EditCommuneScreenState();
}

class _EditCommuneScreenState extends State<EditCommuneScreen> {
  final _nameController = TextEditingController();
  final _photoUrlController = TextEditingController();
  String? _selectedCityId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<City> _cities = []; // Liste des villes disponibles

  @override
  void initState() {
    super.initState();
    _loadCommune();
    _fetchCities(); // Charger les villes depuis Firestore
  }

  // Récupérer les villes depuis Firestore
  void _fetchCities() async {
    try {
      final citiesSnapshot = await _firestore.collection('cities').get();
      final cities = citiesSnapshot.docs.map((doc) {
        return City.fromJson(doc.data());
      }).toList();

      setState(() {
        _cities = cities;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des villes : $e')),
      );
    }
  }

  // Charger la commune existante
  Future<void> _loadCommune() async {
    try {
      final doc =
          await _firestore.collection('communes').doc(widget.communeId).get();
      if (doc.exists) {
        final commune = Commune.fromJson(doc.data() as Map<String, dynamic>);
        _nameController.text = commune.name;
        _photoUrlController.text = commune.photoUrl;
        _selectedCityId = commune.cityId;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement : $e')),
      );
    }
  }

  // Mettre à jour la commune
  void _updateCommune() async {
    if (_nameController.text.isEmpty ||
        _photoUrlController.text.isEmpty ||
        _selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final updatedCommune = Commune(
      id: widget.communeId,
      name: _nameController.text.trim(),
      photoUrl: _photoUrlController.text.trim(),
      cityId: _selectedCityId!,
    );

    try {
      await _firestore
          .collection('communes')
          .doc(widget.communeId)
          .update(updatedCommune.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commune mise à jour')),
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
      appBar: AppBar(title: const Text('Modifier une commune')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom de la commune'),
            ),
            TextField(
              controller: _photoUrlController,
              decoration: const InputDecoration(labelText: 'URL de la photo'),
            ),
            // Champ de sélection pour la ville
            DropdownButton<String>(
              value: _selectedCityId,
              hint: const Text('Sélectionner une ville'),
              items: _cities.map((City city) {
                return DropdownMenuItem<String>(
                  value: city.id,
                  child: Text(city.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCityId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateCommune,
              child: const Text('Mettre à jour'),
            ),
          ],
        ),
      ),
    );
  }
}
