import 'package:event_app/data/models/recommendations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationsDeletionScreen extends StatefulWidget {
  const RecommendationsDeletionScreen({super.key});

  @override
  State<RecommendationsDeletionScreen> createState() =>
      _RecommendationsDeletionScreenState();
}

class _RecommendationsDeletionScreenState
    extends State<RecommendationsDeletionScreen> {
  List<Recommendations> _recommendations = [];
  List<String> _selectedRecommendationIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  void _fetchRecommendations() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('recommendations')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _recommendations = querySnapshot.docs.map((doc) {
          final recommendationData = doc.data() as Map<String, dynamic>;
          final recommendation = Recommendations.fromJson(recommendationData);

          return Recommendations(
            eventSpaces: recommendation.eventSpaces,
            userId: recommendation.userId,
            id: doc.id, // Ajouter l'ID du document ici
            createdAt: recommendation.createdAt,
            updatedAt: recommendation.updatedAt,
            version: recommendation.version,
          );
        }).toList();

        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des recommandations: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteSelectedRecommendations() async {
    if (_selectedRecommendationIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune recommandation sélectionnée')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Voulez-vous supprimer ${_selectedRecommendationIds.length} recommandation(s) ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Suppression des recommandations dans Firestore
                final batch = FirebaseFirestore.instance.batch();
                for (var id in _selectedRecommendationIds) {
                  final docRef = FirebaseFirestore.instance
                      .collection('recommendations')
                      .doc(id);
                  batch.delete(docRef);
                }

                await batch.commit();

                setState(() {
                  _recommendations.removeWhere(
                      (rec) => _selectedRecommendationIds.contains(rec.id));
                  _selectedRecommendationIds.clear();
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recommandations supprimées avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la suppression : $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supprimer des Recommandations'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recommendations.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune recommandation disponible',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _recommendations.length,
                        itemBuilder: (context, index) {
                          final recommendation = _recommendations[index];
                          return CheckboxListTile(
                            title: Text(
                                'Recommandations du ${recommendation.createdAt.toLocal()}'),
                            subtitle: Text(
                                '${recommendation.eventSpaces.length} espaces'),
                            value: _selectedRecommendationIds
                                .contains(recommendation.id),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedRecommendationIds
                                      .add(recommendation.id);
                                } else {
                                  _selectedRecommendationIds
                                      .remove(recommendation.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _deleteSelectedRecommendations,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Supprimer ${_selectedRecommendationIds.length} recommandation(s)',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
