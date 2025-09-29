import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_router.dart';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  late GoRouter _router;

  Future<void> init({required GoRouter router}) async {
    if (_initialized) return;
    _initialized = true;
    _router = router;

    await Firebase.initializeApp();

    // iOS permissions
    await _messaging.requestPermission(
      alert: true, badge: true, sound: true, provisional: false,
    );

    // Android notification channel
    const channel = AndroidNotificationChannel(
      'high_importance', 'High Importance Notifications',
      description: 'Used for critical route alerts and updates',
      importance: Importance.high,
    );

    // Initialize local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    await _fln.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          NotificationRouter.routeFromData(
            _router,
            _parsePayload(payload),
          );
        }
      },
    );

    // Create Android channel
    await _fln
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Foreground presentation (iOS)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );

    // Token (optional: send to backend)
    final token = await _messaging.getToken();
    debugPrint('FCM token: $token');

    // Listen: foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen: user taps from background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Cold start: app opened from terminated via a notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleRouting(initial);
    }

    // Optional: topic subscription
    // await _messaging.subscribeToTopic('drivers');
  }

  // Foreground => show local banner
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    // Build a compact payload (stringified map) for tap handling
    final payload = _stringifyData(message.data);

    if (notification != null) {
      await _fln.show(
        notification.hashCode,
        notification.title ?? 'Navex',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance',
            'High Importance Notifications',
            channelDescription: 'Used for critical route alerts and updates',
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            priority: Priority.high,
            importance: Importance.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    }
  }

  // Background -> foreground via tap
  void _onMessageOpenedApp(RemoteMessage message) {
    _handleRouting(message);
  }

  void _handleRouting(RemoteMessage message) {
    // Prefer 'data' payload for routing
    final data = message.data;
    if (data.isNotEmpty) {
      NotificationRouter.routeFromData(_router, data);
    } else if (message.notification != null) {
      // Fallback: basic route from title/body if you encoded it (optional)
      _router.go('/');
    }
  }

  // Helpers to safely pass data through local notifications payload
  String _stringifyData(Map<String, dynamic> data) {
    // Simple key=value;key=value encoding to avoid JSON issues with plugin payload
    return data.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join(';');
  }

  Map<String, dynamic> _parsePayload(String payload) {
    final map = <String, dynamic>{};
    for (final pair in payload.split(';')) {
      if (pair.isEmpty) continue;
      final idx = pair.indexOf('=');
      if (idx <= 0) continue;
      final k = Uri.decodeComponent(pair.substring(0, idx));
      final v = Uri.decodeComponent(pair.substring(idx + 1));
      map[k] = v;
    }
    return map;
  }
}