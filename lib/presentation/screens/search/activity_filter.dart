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

  Widget _buildActivityItem(Activity activity, bool isSelected, int count) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = constraints.maxWidth;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_selectedActivities.contains(activity)) {
                  _selectedActivities.remove(activity);
                } else {
                  _selectedActivities.add(activity);
                }
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: itemWidth * 0.6,
                  height: itemWidth * 0.6,
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
                  child: Center(
                    child: Icon(
                      activity.icon,
                      color:
                          isSelected ? Colors.white : const Color(0xFF8773F8),
                      size: itemWidth * 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    activity.type,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF8773F8)
                              : Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF8773F8).withOpacity(0.1)
                        : const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Filtrer par activité',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(CupertinoIcons.xmark, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: _availableActivities.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'Aucune activité disponible',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 16,
                                  color: const Color(0xFFA0A5BA),
                                ),
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final activity = _availableActivities[index];
                            final isSelected =
                                _selectedActivities.contains(activity);
                            final count = _activityCounts[activity.type] ?? 0;

                            return _buildActivityItem(
                                activity, isSelected, count);
                          },
                          childCount: _availableActivities.length,
                        ),
                      ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _selectedActivities.isEmpty
                              ? null
                              : () {
                                  setState(() {
                                    _selectedActivities.clear();
                                    widget.onFilterChanged([]);
                                  });
                                },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF8773F8),
                            side: const BorderSide(color: Color(0xFF8773F8)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Réinitialiser',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            widget
                                .onFilterChanged(_selectedActivities.toList());
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8773F8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Voir les résultats',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
