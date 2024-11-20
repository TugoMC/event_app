import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:event_app/data/models/event_space.dart';

class DeleteEventSpacesScreen extends StatefulWidget {
  const DeleteEventSpacesScreen({Key? key}) : super(key: key);

  @override
  _DeleteEventSpacesScreenState createState() =>
      _DeleteEventSpacesScreenState();
}

class _DeleteEventSpacesScreenState extends State<DeleteEventSpacesScreen> {
  final Set<String> _selectedEventSpaces = {};
  bool _isDeleting = false;
  final TextEditingController _confirmationController = TextEditingController();

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _deleteSelectedEventSpaces() async {
    if (_selectedEventSpaces.isEmpty) return;

    setState(() => _isDeleting = true);

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (String id in _selectedEventSpaces) {
        DocumentReference docRef =
            FirebaseFirestore.instance.collection('event_spaces').doc(id);
        batch.delete(docRef);
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_selectedEventSpaces.length} espace(s) supprimé(s) avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedEventSpaces.clear();
          _confirmationController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _showSecondConfirmationDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation finale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pour confirmer la suppression définitive, veuillez écrire "SUPPRIMER" ci-dessous :',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmationController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'SUPPRIMER',
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _confirmationController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (_confirmationController.text == 'SUPPRIMER') {
                  Navigator.of(context).pop();
                  _deleteSelectedEventSpaces();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez écrire exactement "SUPPRIMER"'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text(
                'Confirmer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFirstConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Première confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Vous êtes sur le point de supprimer ${_selectedEventSpaces.length} espace(s) événementiel(s).',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Cette action est irréversible et supprimera définitivement toutes les données associées.',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSecondConfirmationDialog();
              },
              child: const Text(
                'Continuer',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventSpaceItem(EventSpace eventSpace, String docId) {
    final bool isSelected = _selectedEventSpaces.contains(docId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _selectedEventSpaces.add(docId);
            } else {
              _selectedEventSpaces.remove(docId);
            }
          });
        },
        title: Text(eventSpace.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${eventSpace.city.name} - ${eventSpace.commune.name}'),
            Text(
              eventSpace.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        secondary: eventSpace.photoUrls.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  eventSpace.photoUrls[0],
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supprimer des espaces'),
        actions: [
          if (_selectedEventSpaces.isNotEmpty) ...[
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.white),
              label: Text(
                '${_selectedEventSpaces.length}',
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: _showFirstConfirmationDialog,
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('event_spaces')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(
                  child: Text('Aucun espace événementiel disponible'),
                );
              }

              return ListView.builder(
                itemCount: docs.length,
                padding: const EdgeInsets.only(bottom: 80),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final eventSpace = EventSpace.fromJson(
                    doc.data() as Map<String, dynamic>,
                  );
                  return _buildEventSpaceItem(eventSpace, doc.id);
                },
              );
            },
          ),
          if (_isDeleting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomSheet: _selectedEventSpaces.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedEventSpaces.length} espace(s) sélectionné(s)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showFirstConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Supprimer'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
