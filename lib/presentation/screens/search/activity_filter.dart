import 'package:flutter/material.dart';
import 'package:event_app/data/models/activity.dart';
import 'package:event_app/data/models/event_space.dart';

class ActivityFilterModal extends StatefulWidget {
  final Function(List<Activity>) onFilterChanged;
  final List<Activity> initialSelectedActivities;
  final List<EventSpace> eventSpaces;

  const ActivityFilterModal({
    Key? key,
    required this.onFilterChanged,
    required this.eventSpaces,
    this.initialSelectedActivities = const [],
  }) : super(key: key);

  @override
  State<ActivityFilterModal> createState() => _ActivityFilterModalState();
}

class _ActivityFilterModalState extends State<ActivityFilterModal> {
  final Set<Activity> _selectedActivities = {};
  late List<Activity> _availableActivities;
  Map<String, int> _activityCounts = {};

  @override
  void initState() {
    super.initState();
    _selectedActivities.addAll(widget.initialSelectedActivities);
    _loadActivitiesFromEventSpaces();
  }

  void _loadActivitiesFromEventSpaces() {
    _availableActivities = EventSpace.getUsedActivities(widget.eventSpaces);
    _activityCounts = {};
    for (var eventSpace in widget.eventSpaces) {
      for (var activity in eventSpace.activities) {
        _activityCounts[activity.type] =
            (_activityCounts[activity.type] ?? 0) + 1;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtrer par activité',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          if (_availableActivities.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Aucune activité disponible',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 12, // Reduced from 16 to prevent overflow
                crossAxisSpacing: 16,
                childAspectRatio: 0.75, // Added to control item height
                children: _availableActivities.map((activity) {
                  final isSelected = _selectedActivities.contains(activity);
                  final count = _activityCounts[activity.type] ?? 0;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedActivities.remove(activity);
                        } else {
                          _selectedActivities.add(activity);
                        }
                        widget.onFilterChanged(_selectedActivities.toList());
                      });
                    },
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Added to prevent expansion
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30, // Slightly reduced from 32
                              backgroundColor: isSelected
                                  ? const Color(0xFF8773F8)
                                  : const Color(0xFF8773F8).withOpacity(0.2),
                              child: Icon(
                                activity.icon,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF8773F8),
                                size: 30, // Slightly reduced from 32
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF8773F8),
                                    size: 18, // Slightly reduced from 20
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6), // Reduced from 8
                        Text(
                          activity.type,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF8773F8)
                                : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF8773F8).withOpacity(0.1)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? const Color(0xFF8773F8)
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          // Bottom buttons
          SafeArea(
            // Added SafeArea to prevent overlap with system UI
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _selectedActivities.isEmpty
                          ? null
                          : () {
                              setState(() {
                                _selectedActivities.clear();
                                widget.onFilterChanged([]);
                              });
                            },
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8773F8),
                      ),
                      child: const Text('Voir les résultats'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
