import 'package:event_app/presentation/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:event_app/presentation/screens/profile/notifications_screen.dart';

class NotificationNavigationService {
  static void navigateToNotifications(BuildContext context) {
    // First ensure we're on the home screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
      (Route<dynamic> route) => false,
    );

    // Then navigate to notifications screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  static void handleNotificationTap(
      BuildContext context, Map<String, dynamic> data) {
    // Navigate to notifications screen regardless of notification type
    navigateToNotifications(context);
  }

  static void _showDetailedErrorDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
