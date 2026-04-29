import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles Firebase Cloud Messaging and local notifications.
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'business_india_channel';
  static const _channelName = 'BusIndia Alerts';

  /// Must be called once at app startup (after Firebase.initializeApp).
  Future<void> initialize() async {
    // 1. Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialize local notification plugin
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // 3. Create notification channel (Android)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Real-time bus arrival alerts',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Handle foreground FCM messages
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        showLocalNotification(
          title: notification.title ?? 'BusIndia',
          body: notification.body ?? '',
          payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
        );
      }
    });

    // 5. Subscribe to initial city topic placeholder
    // Actual subscription happens after city selection.
  }

  /// Subscribes to FCM topic for a city to receive city-wide alerts.
  Future<void> subscribeToCityTopic(String cityId) async {
    await _messaging.subscribeToTopic('city_$cityId');
  }

  Future<void> unsubscribeFromCityTopic(String cityId) async {
    await _messaging.unsubscribeFromTopic('city_$cityId');
  }

  /// Returns the FCM registration token for this device.
  Future<String?> getToken() => _messaging.getToken();

  /// Displays an immediate local notification.
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    const iosDetails = DarwinNotificationDetails();
    await _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  /// Schedules a bus arrival alert notification.
  Future<void> scheduleArrivalAlert({
    required int id,
    required String routeNumber,
    required String stopName,
    required int alertBeforeMins,
    required DateTime scheduledTime,
  }) async {
    final showAt = scheduledTime.subtract(Duration(minutes: alertBeforeMins));
    if (showAt.isBefore(DateTime.now())) return;

    // flutter_local_notifications zonedSchedule requires timezone package;
    // simplified here — show as immediate local for now.
    await showLocalNotification(
      id: id,
      title: '🚌 Bus $routeNumber is almost here!',
      body: 'Arriving at $stopName in ~$alertBeforeMins min',
      payload: jsonEncode({'screen': 'live_map'}),
    );
  }

  /// Cancels a scheduled notification.
  Future<void> cancelAlert(int notificationId) =>
      _localNotifications.cancel(notificationId);

  void _onLocalNotificationTap(NotificationResponse response) {
    // Navigation handled by app router based on payload JSON.
    // Parse response.payload → deep link to correct screen.
  }
}
