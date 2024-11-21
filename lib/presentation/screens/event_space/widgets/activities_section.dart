import 'package:event_app/data/models/activity.dart';
import 'package:flutter/material.dart';

class ActivitiesSection extends StatelessWidget {
  final List<Activity> activities;

  const ActivitiesSection({Key? key, required this.activities})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Activités',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: activities.map((activity) {
              return Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF8773F8).withOpacity(0.2),
                      child:
                          Icon(activity.icon, color: const Color(0xFF8773F8)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.type,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
