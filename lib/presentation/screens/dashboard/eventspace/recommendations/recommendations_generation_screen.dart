import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/data/models/recommendations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationsGenerationScreen extends StatefulWidget {
  const RecommendationsGenerationScreen({super.key});

  @override
  State<RecommendationsGenerationScreen> createState() =>
      _RecommendationsGenerationScreenState();
}

class _RecommendationsGenerationScreenState
    extends State<RecommendationsGenerationScreen> {
  final Set<String> _selectedEventSpaces = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

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
            Text(
              'Prix: ${eventSpace.price.toStringAsFixed(2)} FCFA',
              style: TextStyle(color: Colors.green),
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

  Future<void> _generateRecommendations() async {
    if (_selectedEventSpaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Veuillez sélectionner au moins un espace événementiel'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch full EventSpace details for selected spaces
      final selectedEventSpacesDetails = await Future.wait(
        _selectedEventSpaces.map((id) async {
          final doc = await FirebaseFirestore.instance
              .collection('event_spaces')
              .doc(id)
              .get();
          return EventSpace.fromJson(doc.data()!);
        }),
      );

      // Créer l'objet Recommendations
      final recommendations = Recommendations(
        eventSpaces: selectedEventSpacesDetails,
        userId: 'system', // Utiliser un identifiant système
      );

      // Enregistrer les recommandations dans Firestore
      final recommendationRef = await FirebaseFirestore.instance
          .collection('recommendations')
          .add(recommendations.toJson());

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recommandations générées avec succès pour ${selectedEventSpacesDetails.length} espace(s). ID: ${recommendationRef.id}',
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Reset selection
        setState(() {
          _selectedEventSpaces.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Erreur lors de la génération des recommandations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer des Recommandations'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_selectedEventSpaces.isNotEmpty) ...[
            TextButton.icon(
              icon: const Icon(Icons.recommend, color: Colors.white),
              label: Text(
                '${_selectedEventSpaces.length}',
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: _generateRecommendations,
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Rechercher par nom',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Trigger rebuild to filter
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
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

                    final docs = snapshot.data!.docs.where((doc) {
                      final eventSpace = EventSpace.fromJson(
                        doc.data() as Map<String, dynamic>,
                      );

                      // Apply search filter if text is not empty
                      return _searchController.text.isEmpty ||
                          eventSpace.name
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase());
                    }).toList();

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
              ),
            ],
          ),
          if (_isLoading)
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
                      onPressed: _generateRecommendations,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.recommend),
                      label: const Text('Générer'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
