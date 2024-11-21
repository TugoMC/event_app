import 'package:flutter/material.dart';
import 'package:event_app/presentation/screens/communes/commune_detail_screen.dart';

class CommuneCard extends StatelessWidget {
  final String name;
  final String imageUrl;

  const CommuneCard({
    super.key,
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommuneDetailsScreen(communeName: name),
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey[300]);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(color: Colors.grey[300]);
                  },
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
