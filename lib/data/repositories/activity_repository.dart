// lib/data/repositories/activity_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_app/data/models/activity.dart';

class ActivityRepository {
  final FirebaseFirestore _firestore;

  // Singleton pattern
  static final ActivityRepository _instance = ActivityRepository._internal();

  factory ActivityRepository({FirebaseFirestore? firestore}) {
    if (firestore != null) {
      return ActivityRepository._custom(firestore);
    }
    return _instance;
  }

  ActivityRepository._internal() : _firestore = FirebaseFirestore.instance;
  ActivityRepository._custom(this._firestore);

  Future<List<Activity>> fetchUniqueActivities() async {
    try {
      final QuerySnapshot eventSpacesSnapshot = await _firestore
          .collection('eventSpaces')
          .where('isActive', isEqualTo: true)
          .get();

      final Set<Activity> uniqueActivities = {};

      for (var doc in eventSpacesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('activities')) {
          final List<dynamic> activities = data['activities'] as List<dynamic>;
          final parsedActivities = activities
              .map((a) => Activity.fromJson(a as Map<String, dynamic>));
          uniqueActivities.addAll(parsedActivities);
        }
      }

      final sortedActivities = uniqueActivities.toList()
        ..sort((a, b) => a.type.compareTo(b.type));

      return sortedActivities;
    } catch (e) {
      print('Erreur lors de la récupération des activités: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getActivityCounts() async {
    try {
      final QuerySnapshot eventSpacesSnapshot = await _firestore
          .collection('eventSpaces')
          .where('isActive', isEqualTo: true)
          .get();

      final Map<String, int> activityCounts = {};

      for (var doc in eventSpacesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('activities')) {
          final List<dynamic> activities = data['activities'] as List<dynamic>;
          for (var activity in activities) {
            final activityMap = activity as Map<String, dynamic>;
            final String activityId = activityMap['id'] as String;
            activityCounts[activityId] = (activityCounts[activityId] ?? 0) + 1;
          }
        }
      }

      return activityCounts;
    } catch (e) {
      print('Erreur lors du comptage des activités: $e');
      rethrow;
    }
  }
}
