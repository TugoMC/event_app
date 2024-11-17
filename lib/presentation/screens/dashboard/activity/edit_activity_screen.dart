import 'package:event_app/data/models/event_icons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/models/activity.dart';

class EditActivityScreen extends StatefulWidget {
  final String activityId;

  const EditActivityScreen({super.key, required this.activityId});

  @override
  _EditActivityScreenState createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _typeController = TextEditingController();
  IconData? _selectedIcon;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final docSnapshot = await _firestore
          .collection('activities')
          .doc(widget.activityId)
          .get();

      if (docSnapshot.exists) {
        final activity = Activity.fromJson(
          docSnapshot.data() as Map<String, dynamic>,
          docSnapshot.id,
        );

        setState(() {
          _typeController.text = activity.type;
          _selectedIcon = activity.icon;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Activité non trouvée')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement : $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _updateActivity() async {
    if (_typeController.text.isEmpty || _selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      final activity = Activity(
        id: widget.activityId,
        type: _typeController.text.trim(),
        icon: _selectedIcon!,
      );

      await _firestore
          .collection('activities')
          .doc(widget.activityId)
          .update(activity.toJson());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activité mise à jour')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de mise à jour : $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modifier une activité')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier une activité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateActivity,
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
