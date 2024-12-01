import 'package:event_app/data/models/recommendations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/presentation/screens/dashboard/eventspace/recommendations/recommendation_detail_screen.dart';

class RecommendationsListScreen extends StatefulWidget {
  const RecommendationsListScreen({super.key});

  @override
  State<RecommendationsListScreen> createState() =>
      _RecommendationsListScreenState();
}

class _RecommendationsListScreenState extends State<RecommendationsListScreen> {
  List<Recommendations> _recommendations = [];
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
        _recommendations = querySnapshot.docs
            .map((doc) {
              // Récupérer les données du document
              final docData = doc.data();

              // Vérifier si les données sont null ou ne sont pas un Map
              if (docData == null || docData is! Map<String, dynamic>) {
                print('Document invalide détecté: ${doc.id}');
                return null;
              }

              try {
                final recommendation = Recommendations.fromJson(docData);

                // Trier les espaces d'événements par ordre
                recommendation.eventSpaces
                    .sort((a, b) => a.order.compareTo(b.order));

                return recommendation;
              } catch (e) {
                print('Erreur lors du parsing du document ${doc.id}: $e');
                return null;
              }
            })
            .whereType<Recommendations>() // Filtrer les null
            .toList();

        _isLoading = false;

        // Afficher le nombre de recommandations valides
        print('Nombre de recommandations valides: ${_recommendations.length}');
      });
    } catch (e) {
      print('Erreur lors de la récupération des recommandations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _reorderEventSpaces(Recommendations recommendation) async {
    final result = await showDialog<List<EventSpaceOrder>>(
      context: context,
      builder: (context) =>
          _ReorderEventSpacesDialog(recommendation.eventSpaces),
    );

    if (result != null) {
      try {
        // Créer une nouvelle recommandation avec les espaces réordonnés
        final updatedRecommendation = recommendation.copyWith(
          eventSpaces: result
              .map((eventSpaceOrder) => EventSpaceOrder(
                  eventSpace: eventSpaceOrder.eventSpace,
                  order: result
                      .indexOf(eventSpaceOrder) // Utiliser l'index comme ordre
                  ))
              .toList(),
        );

        // Mettre à jour Firestore
        await FirebaseFirestore.instance
            .collection('recommendations')
            .doc(recommendation.id)
            .update(updatedRecommendation.toJson());

        // Mettre à jour l'état local
        setState(() {
          final index =
              _recommendations.indexWhere((r) => r.id == recommendation.id);
          if (index != -1) {
            _recommendations[index] = updatedRecommendation;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ordre des espaces mis à jour')),
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de l\'ordre: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  void _toggleRecommendationActivation(Recommendations recommendation) async {
    try {
      // Désactiver toutes les autres recommandations
      final batch = FirebaseFirestore.instance.batch();
      final activeRecommendationsSnapshot = await FirebaseFirestore.instance
          .collection('recommendations')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in activeRecommendationsSnapshot.docs) {
        batch.update(doc.reference, {'isActive': false});
      }

      // Activer la recommandation sélectionnée
      final recommendationRef = FirebaseFirestore.instance
          .collection('recommendations')
          .doc(recommendation.id);

      batch.update(recommendationRef, {
        'isActive': !recommendation.isActive,
        'updatedAt': DateTime.now().toIso8601String()
      });

      // Commit the batch
      await batch.commit();

      // Mettre à jour l'état local
      setState(() {
        for (var r in _recommendations) {
          r.isActive = r.id == recommendation.id && !r.isActive;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(recommendation.isActive
              ? 'Recommandation désactivée'
              : 'Recommandation activée'),
        ),
      );
    } catch (e) {
      print('Erreur lors de l\'activation/désactivation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Widget _buildRecommendationCard(Recommendations recommendation) {
    return Card(
      color: recommendation.isActive ? Colors.green[50] : null,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RecommendationDetailScreen(recommendation: recommendation),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Recommandations du ${recommendation.createdAt.toLocal()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _reorderEventSpaces(recommendation),
                        child: const Text('Réorganiser'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () =>
                            _toggleRecommendationActivation(recommendation),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: recommendation.isActive
                              ? Colors.red
                              : Colors.green,
                        ),
                        child: Text(
                          recommendation.isActive ? 'Désactiver' : 'Activer',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Nombre d\'espaces: ${recommendation.eventSpaces.length}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              // Afficher l'ordre actuel des espaces
              ...recommendation.eventSpaces
                  .map((eventSpaceOrder) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${eventSpaceOrder.order}: ${eventSpaceOrder.eventSpace.name}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Recommandations'),
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
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    return _buildRecommendationCard(_recommendations[index]);
                  },
                ),
    );
  }
}

// Dialogue personnalisé pour réorganiser les espaces d'événements
class _ReorderEventSpacesDialog extends StatefulWidget {
  final List<EventSpaceOrder> eventSpaces;

  const _ReorderEventSpacesDialog(this.eventSpaces);

  @override
  __ReorderEventSpacesDialogState createState() =>
      __ReorderEventSpacesDialogState();
}

class __ReorderEventSpacesDialogState extends State<_ReorderEventSpacesDialog> {
  late List<EventSpaceOrder> _reorderableEventSpaces;

  @override
  void initState() {
    super.initState();
    _reorderableEventSpaces = List.from(widget.eventSpaces);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Réorganiser les espaces'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ReorderableListView.builder(
          itemCount: _reorderableEventSpaces.length,
          itemBuilder: (context, index) {
            final eventSpaceOrder = _reorderableEventSpaces[index];
            return ListTile(
              key: ValueKey(eventSpaceOrder.eventSpace.id),
              title: Text(eventSpaceOrder.eventSpace.name),
              trailing: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              ),
            );
          },
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final EventSpaceOrder item =
                  _reorderableEventSpaces.removeAt(oldIndex);
              _reorderableEventSpaces.insert(newIndex, item);

              // Réinitialiser les ordres
              for (int i = 0; i < _reorderableEventSpaces.length; i++) {
                _reorderableEventSpaces[i] =
                    _reorderableEventSpaces[i].copyWith(order: i);
              }
            });
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_reorderableEventSpaces);
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
