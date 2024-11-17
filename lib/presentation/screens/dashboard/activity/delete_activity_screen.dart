import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/models/activity.dart';

class DeleteActivityScreen extends StatefulWidget {
  final String activityId;

  const DeleteActivityScreen({super.key, required this.activityId});

  @override
  _DeleteActivityScreenState createState() => _DeleteActivityScreenState();
}

class _DeleteActivityScreenState extends State<DeleteActivityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Activity _activity;

  @override
  void initState() {
    super.initState();
    if (widget.activityId.isEmpty) {
      // Si l'ID est vide, on affiche une erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID de l\'activité invalide')),
      );
      return;
    }
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    try {
      final docSnapshot = await _firestore
          .collection('activities')
          .doc(widget.activityId)
          .get();
      if (docSnapshot.exists) {
        _activity =
            Activity.fromJson(docSnapshot.data() as Map<String, dynamic>);
        setState(() {});
      } else {
        // Si le document n'existe pas
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activité non trouvée')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur de chargement : $e')));
    }
  }

  Future<void> _deleteActivity() async {
    try {
      if (widget.activityId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID de l\'activité est vide')),
        );
        return;
      }
      await _firestore.collection('activities').doc(widget.activityId).delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Activité supprimée')));
      Navigator.pop(context); // Retourner à la liste après suppression
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si _activity n'est pas encore chargé, on affiche un indicateur de chargement.
    if (_activity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Supprimer une activité')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supprimer une activité'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Êtes-vous sûr de vouloir supprimer cette activité ?'),
            const SizedBox(height: 20),
            Text(_activity.type,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Icon(_activity.icon, size: 50, color: Colors.grey),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteActivity,
              child: const Text('Supprimer'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }
}
