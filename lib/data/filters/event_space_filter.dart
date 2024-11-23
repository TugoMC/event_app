// lib/data/filters/event_space_filter.dart
import 'package:event_app/data/models/activity.dart';
import 'package:event_app/data/models/event_space.dart';

class EventSpaceFilter {
  static List<EventSpace> filterEventSpaces({
    required List<EventSpace> eventSpaces,
    String? searchQuery,
    List<Activity>? selectedActivities,
  }) {
    if (eventSpaces.isEmpty) {
      return [];
    }

    // Commencer avec tous les espaces événementiels
    List<EventSpace> filteredSpaces = List.from(eventSpaces);

    // Filtrer par la recherche textuelle si une requête est fournie
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      filteredSpaces = filteredSpaces.where((space) {
        return space.name.toLowerCase().contains(query) ||
            space.description.toLowerCase().contains(query) ||
            space.commune.name.toLowerCase().contains(query) ||
            space.city.name.toLowerCase().contains(query);
      }).toList();
    }

    // Filtrer par activités sélectionnées si des activités sont fournies
    if (selectedActivities != null && selectedActivities.isNotEmpty) {
      filteredSpaces = EventSpace.filterByActivities(
        filteredSpaces,
        selectedActivities,
      );
    }

    // Trier les résultats par note moyenne décroissante
    filteredSpaces.sort((a, b) {
      final ratingA = a.getAverageRating();
      final ratingB = b.getAverageRating();
      return ratingB.compareTo(ratingA);
    });

    return filteredSpaces;
  }
}
