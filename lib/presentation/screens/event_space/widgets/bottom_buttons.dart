import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_app/data/models/event_space.dart';

class BottomButtons extends StatelessWidget {
  final EventSpace eventSpace;

  const BottomButtons({Key? key, required this.eventSpace}) : super(key: key);

  Future<void> _openMap(BuildContext context) async {
    final Uri locationUri = Uri.parse(
        eventSpace.location); // L'URL complète stockée dans la base de données

    try {
      // Tente d'ouvrir l'URL dans une application de cartographie
      if (await canLaunchUrl(locationUri)) {
        await launchUrl(
          locationUri,
          mode: LaunchMode
              .externalApplication, // Force le lancement dans une application externe
        );
      } else {
        // Si l'application de cartographie échoue, tente d'ouvrir dans le navigateur
        if (await canLaunchUrl(locationUri)) {
          await launchUrl(locationUri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Impossible d\'ouvrir la carte.')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de l\'ouverture : ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 245,
              height: 62,
              child: ElevatedButton(
                onPressed: () async {
                  final Uri phoneUri =
                      Uri.parse('tel:${eventSpace.phoneNumber}');
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Impossible de passer l\'appel')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8773F8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'APPELER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF8773F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => _openMap(context),
                icon: const Icon(
                  CupertinoIcons.location_solid,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
