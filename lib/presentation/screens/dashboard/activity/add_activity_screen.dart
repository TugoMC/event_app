import 'package:event_app/data/models/event_icons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/models/activity.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final TextEditingController _typeController = TextEditingController();
  IconData _selectedIcon = EventIcons.eventIcons[0]['icon'] as IconData;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveActivity() async {
    if (_typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir le type d\'activité')),
      );
      return;
    }

    try {
      // Créer une référence de document avec un ID auto-généré
      final docRef = _firestore.collection('activities').doc();

      final activity = Activity(
        id: docRef.id, // Utiliser l'ID auto-généré
        type: _typeController.text.trim(),
        icon: _selectedIcon,
      );

      // Sauvegarder avec l'ID spécifique
      await docRef.set(activity.toJson());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activité ajoutée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une activité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveActivity,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type d\'activité',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choisir une icône',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: EventIcons.eventIcons.length,
              itemBuilder: (context, index) {
                final iconData = EventIcons.eventIcons[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconData['icon'] as IconData;
                      if (_typeController.text.isEmpty) {
                        _typeController.text = iconData['name'] as String;
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedIcon == iconData['icon']
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        width: _selectedIcon == iconData['icon'] ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconData['icon'] as IconData,
                          color: _selectedIcon == iconData['icon']
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          iconData['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: _selectedIcon == iconData['icon']
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
