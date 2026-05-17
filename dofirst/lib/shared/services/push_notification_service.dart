import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'focus_notification_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permission from the user
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get the token each time the application loads
      String? token = await _fcm.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await registerToken(token);
      }

      // Any time the token refreshes, store it in the database too.
      _fcm.onTokenRefresh.listen((newToken) {
        registerToken(newToken);
      });

      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        
        if (message.notification != null) {
          debugPrint('Message also contained a notification: ${message.notification?.title}');
          FocusNotificationService().notify(
            title: message.notification?.title ?? 'Notification',
            body: message.notification?.body ?? '',
          );
        }
      });
    }
  }

  Future<void> registerToken(String fcmToken) async {
    try {
      final response = await ApiClient.post(
        '/notifications/register-token',
        body: {'fcmToken': fcmToken},
      );
      debugPrint('FCM Token registered successfully: $response');
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }
}

// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint("Handling a background message: ${message.messageId}");
}
