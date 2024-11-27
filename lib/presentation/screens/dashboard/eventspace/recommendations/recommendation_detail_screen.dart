import 'package:event_app/data/models/recommendations.dart';
import 'package:event_app/data/models/event_space.dart';
import 'package:event_app/presentation/screens/event_space/event_space_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class RecommendationDetailScreen extends StatelessWidget {
  final Recommendations recommendation;

  const RecommendationDetailScreen({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Recommandation'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommandations du ${recommendation.createdAt.toLocal()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Nombre d\'espaces: ${recommendation.eventSpaces.length}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recommendation.eventSpaces.length,
              itemBuilder: (context, index) {
                final eventSpace = recommendation.eventSpaces[index];
                return _buildEventSpaceCard(context, eventSpace);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSpaceCard(BuildContext context, EventSpace eventSpace) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          eventSpace.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${eventSpace.city.name} - ${eventSpace.commune.name}'),
            Text(
              'Prix: ${eventSpace.price.toStringAsFixed(2)} FCFA',
              style: TextStyle(color: Colors.green[700]),
            ),
            Text(
              'Note moyenne: ${eventSpace.getAverageRating().toStringAsFixed(1)}',
              style: TextStyle(color: Colors.amber[700]),
            ),
          ],
        ),
        leading: eventSpace.photoUrls.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  eventSpace.photoUrls[0],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              )
            : null,
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: Naviguer vers les détails de l'espace d'événement
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EventSpaceDetailScreen(eventSpace: eventSpace),
            ),
          );
        },
      ),
    );
  }
}
