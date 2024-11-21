import 'package:flutter/material.dart';
import 'package:event_app/presentation/screens/villes/city_detail.dart';

class CityCard extends StatelessWidget {
  final String id;
  final String name;

  const CityCard({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CityDetailScreen(
              cityId: id,
              cityName: name,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 80,
        height: 95,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 70,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  name.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 80,
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
