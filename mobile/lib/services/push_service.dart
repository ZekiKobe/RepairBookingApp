<<<<<<< HEAD
import 'package:firebase_core/firebase_core.dart';
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_service.dart';

/// Handles FCM token registration and foreground message handling.
/// Call [init] once after the user logs in.
class PushService {
  final _api = ApiService();

  static final PushService _instance = PushService._();
  factory PushService() => _instance;
  PushService._();

  Future<void> init() async {
    try {
<<<<<<< HEAD
      if (Firebase.apps.isEmpty) {
        return;
      }
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      final messaging = FirebaseMessaging.instance;

      // Request permission (iOS / web)
      await messaging.requestPermission(alert: true, badge: true, sound: true);

<<<<<<< HEAD
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Foreground: app may show in-app banner or rely on local notifications
        if (message.notification != null) {
          // ignore: avoid_print
          print('[FCM foreground] ${message.notification?.title}');
        }
      });

=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
      // Get token and send to backend
      final token = await messaging.getToken();
      if (token != null) {
        await _registerToken(token);
      }

      // Refresh token listener
      messaging.onTokenRefresh.listen(_registerToken);
    } catch (_) {
      // Firebase not configured — silently skip in dev/mock mode
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await _api.dio.put('/users/fcm-token', data: {'fcmToken': token});
    } catch (_) {}
  }
}
