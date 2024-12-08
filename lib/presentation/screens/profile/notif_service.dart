import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' show Client;

class PushNotificationService {
  static Future<void> sendPushNotification({
    required BuildContext context,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Récupérer les tokens des utilisateurs ayant activé les notifications
      final notificationTokensSnapshot = await FirebaseFirestore.instance
          .collection('user_notification_tokens')
          .where('receive_notifications', isEqualTo: true)
          .get();

      // Collecter les tokens
      List<String> tokens = notificationTokensSnapshot.docs
          .map((doc) => doc.data()['token'] as String)
          .toList();

      if (tokens.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun utilisateur avec les notifications activées'),
          ),
        );
        return;
      }

      // Obtenir un client authentifié pour l'API FCM V1
      final client = await _getAuthenticatedClient();

      // Préparer les requêtes de notification
      final List<Future<http.Response>> notificationFutures =
          tokens.map((token) {
        final url = Uri.parse(
            'https://fcm.googleapis.com/v1/projects/event-app-14690/messages:send');

        final message = {
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': data,
          }
        };

        return client.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(message),
        );
      }).toList();

      // Envoyer toutes les notifications en parallèle
      final responses = await Future.wait(notificationFutures);

      // Vérifier les résultats
      final successfulNotifications =
          responses.where((response) => response.statusCode == 200).length;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Notification envoyée à $successfulNotifications utilisateurs'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi de la notification : $e'),
        ),
      );
    }
  }

  static Future<Client> _getAuthenticatedClient() async {
    // Assurez-vous de remplacer ce chemin par le chemin correct de votre fichier de service
    final serviceAccountCredentials = auth.ServiceAccountCredentials.fromJson({
      // Vos informations d'identification de compte de service Google
      // (à obtenir depuis la console Firebase/Google Cloud)
      "type": "service_account",
      "project_id": "event-app-14690",
      "private_key_id": "51477d9b2bf4e54142e1e9e22e9eda30fc030e8a",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC60WWuaDvYjdf6\nmTkaZn+C1airhfVM2Jk8Xpt1zxN9Xlvehps4PreGR+xAL5m43tro3MZhXozR9+DE\nyCxFjAhkewXGHx3ClAx0tlih5G09BZH6o2rAGl9qPIQKA3kraB/LzorY9zFG91ZF\noJAbXBGbfmyeLqlf8x4pbOBIwaHkQeY4KuSrHno/YLUb19y3iYw/hvmm7YYGEmt6\ny+P9CCvY3CJTsQG5OtANjLmdSoiHo6fog50/QtPC8cUiF/4Mq3XwsXQChNH0g09b\nSSs0L6xrgNYBn9CBUQHWJw/6TwsM06UvDtAsKl6Yddkdqz76l7zKzz7E7msAJzbs\nD4IYim6VAgMBAAECggEAJhBOIGf6cZgM/nFDsj5aEqVH1ZLYtQyYxDUehbVoai3U\nmBVjAOW+bOywlS9dqc42WiXJgcNK++j+cfm7E3yBpT9voLtsS93wX8NbcbjiDQHa\niW/Ma1G0SSgFWyj0AkUX3WW64pQTBTuV51/cnMZ4i+8JYH1vYy5c4eHeHNTfEGuH\nUErUhb5aVapBdg4MOZXhD2iTLCTBl9p8E83ystV9aFffSO10LQ85hmXnbqg087ux\nLa4RcliQBj4bC8OpV02oIrgSAuHBPKBYNrh6UxFdlb9l3mxsOhTGA8+q2NSL56Uw\nl9bI3QQ8jhSs5ijSDXhBIZDVCJe5+4vhR76jGs4HDQKBgQDyQxh0e+f3Ss9wl4Z1\nrD/f8tlVnDDmVxlwW1E1KG8H/1hJ8W/+fd4skAaXJiwIuwvXTiB3uErKx6OuYw0k\nq4uBVQOEGQKE3atu+KjWoe6L+ZSUBSVLwy3qtl6kB215//Q+TRQ7Ll0FYIZ46wwA\nqRzcklinxVQidcz3D8xQA/QEqwKBgQDFaWwlcSqCMCk4ZPZjlL89p2zPYBwfhyus\nHFqPhvfhzmjDQqn5zwixkdGPNzoJjJXhVTYDkPAhFZFbXUWvZN0Ewz71DRO3Y51n\n48XeIxpKnuGCgKSRndBEQykrMkFahbDn6GnNiFqwztm2TRWbBvQgH5Q8rB1KuIVL\nFUL37JLZvwKBgHFnQw1T6xPxawVTiNeQmB3m+iF/CczpPLlBpdPyZ3cg6l1CraA9\nn0DQ8qTSc45qsHJK2hvwouIlbdN1/nMJ8jXKa+jsJCe59EPwFmjSSG4xmIFpnznF\n1bqnP8ocx/xx+g0n266QV27q7kewD2BHyYDe6K0wS+ANsLJ+LK/QCewdAoGAfuPF\ndMepyCbGyA31ZYq95hZQ1Xb0fLt4sddDyo+5k3YGVsPp171g3CpbZc/cyTiJOl54\nKpCmGM3xMaXhXdzaR+5r8D1ol+86xQVeMOulQaOgVi70GPk0XjxBIRfbdCEM1fPI\n1ii4Cn/a5tfjdFNi5acGtHz5EwdJ/jn7Yrq4pacCgYEAlrQUpYitvIVsF/knNbPb\nrnCZOZS9ebSyMBmkhV1EqgKkhAD3mnQappxUFs2N/LUwGr23BAwUMndUqmGxShng\nkG5CYnwUI0uh6eNh0HP8A7i05gVYPP1bm69t00j9u0IQvyYyggOLVsWMWS7Dbzg7\nEw7ErJ1XbVWTPUDLaieXPC0=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-7wci4@event-app-14690.iam.gserviceaccount.com",
      "client_id": "109355611021043363765",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-7wci4%40event-app-14690.iam.gserviceaccount.com"
    });

    // Obtenir un client authentifié avec les scopes FCM
    final client = await auth.clientViaServiceAccount(serviceAccountCredentials,
        ['https://www.googleapis.com/auth/firebase.messaging']);

    return client;
  }
}
