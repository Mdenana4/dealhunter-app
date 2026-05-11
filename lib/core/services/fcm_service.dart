import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// FCM Service — handles Firebase Cloud Messaging for deal notifications.
/// 
/// REQUIRED packages in pubspec.yaml:
///   firebase_core: ^2.24.2
///   firebase_messaging: ^14.7.10
///   flutter_local_notifications: ^16.3.2
///
/// REQUIRED setup:
///   1. Add google-services.json to android/app/
///   2. Run: flutterfire configure
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  bool _initialized = false;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize Firebase, subscribe to topic, create notification channel.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Initialize Firebase
      await Firebase.initializeApp();
      debugPrint('[FCM] Firebase initialized');

      // 2. Request notification permission
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[FCM] Permission: ${settings.authorizationStatus.name}');

      // 3. Create Android notification channel (required for Android 8+)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'deal_alerts', // MUST match backend channel_id
        'Deal Alerts',
        description: 'Notifications for new deals and price drops',
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      debugPrint('[FCM] Notification channel created');

      // 4. Initialize local notifications plugin
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosInit =
          DarwinInitializationSettings();
      const InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );
      await _localNotifications.initialize(initSettings);

      // 5. Subscribe to tier_free topic (for free tier users)
      await FirebaseMessaging.instance.subscribeToTopic('tier_free');
      debugPrint('[FCM] Subscribed to tier_free');

      // 6. Listen to foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM] Foreground: ${message.notification?.title}');
        _showLocalNotification(message);
      });

      // 7. Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // 8. Handle notification tap when app is terminated
      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
            '[FCM] App opened from notification: ${initialMessage.notification?.title}');
      }

      // 9. Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint(
            '[FCM] Notification tapped: ${message.notification?.title}');
      });

      _initialized = true;
      debugPrint('[FCM] Service fully initialized');
    } catch (e, stack) {
      debugPrint('[FCM] Init error: $e');
      debugPrint(stack.toString());
    }
  }

  /// Show local notification when FCM message arrives in foreground.
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deal_alerts',
          'Deal Alerts',
          channelDescription: 'Notifications for new deals and price drops',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  bool get isInitialized => _initialized;
}

/// Background message handler (must be a top-level function).
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background: ${message.notification?.title}');
}
