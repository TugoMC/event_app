import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  Widget _buildCircularButton({
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 46,
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
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
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtrer par activité',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildCircularButton(
                  icon: const Icon(CupertinoIcons.xmark, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_availableActivities.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Aucune activité disponible',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFA0A5BA),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                mainAxisSpacing: 8,
                crossAxisSpacing: 16,
                // Ajusté pour éviter l'overflow
                childAspectRatio: 0.82,
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
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFF8773F8)
                                    : const Color(0xFF8773F8).withOpacity(0.1),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF8773F8)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                activity.icon,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF8773F8),
                                size: 30,
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF8773F8),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Color(0xFF8773F8),
                                    size: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activity.type,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF8773F8)
                                : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF8773F8).withOpacity(0.1)
                                : const Color(0xFFF6F6F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF8773F8)
                                  : const Color(0xFFA0A5BA),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
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
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF8773F8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFF8773F8)),
                        ),
                      ),
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        widget.onFilterChanged(_selectedActivities.toList());
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8773F8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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
