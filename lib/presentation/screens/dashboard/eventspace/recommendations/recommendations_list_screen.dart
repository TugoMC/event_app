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
        _recommendations = querySnapshot.docs.map((doc) {
          final recommendationData = doc.data() as Map<String, dynamic>;
          final recommendation = Recommendations.fromJson(recommendationData);

          return Recommendations(
            eventSpaces: recommendation.eventSpaces,
            userId: recommendation.userId,
            id: doc.id,
            createdAt: recommendation.createdAt,
            updatedAt: recommendation.updatedAt,
            version: recommendation.version,
            isActive: recommendationData['isActive'] ?? false,
          );
        }).toList();

        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des recommandations: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setActiveRecommendation(Recommendations recommendation) async {
    try {
      // Désactiver toutes les autres recommandations
      for (var rec in _recommendations) {
        if (rec.id != recommendation.id) {
          await FirebaseFirestore.instance
              .collection('recommendations')
              .doc(rec.id)
              .update({'isActive': false});
        }
      }

      // Activer la recommandation sélectionnée
      await FirebaseFirestore.instance
          .collection('recommendations')
          .doc(recommendation.id)
          .update({'isActive': true});

      // Mettre à jour l'état local
      setState(() {
        _recommendations = _recommendations.map((rec) {
          return rec.id == recommendation.id
              ? rec.copyWith(isActive: true)
              : rec.copyWith(isActive: false);
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Recommandation "${recommendation.id}" activée')),
      );
    } catch (e) {
      print('Erreur lors de l\'activation de la recommandation: $e');
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
                  if (!recommendation.isActive)
                    ElevatedButton(
                      onPressed: () => _setActiveRecommendation(recommendation),
                      child: const Text('Activer'),
                    ),
                  if (recommendation.isActive)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Nombre d\'espaces: ${recommendation.eventSpaces.length}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.info, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    'Cliquez pour voir les détails',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
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
