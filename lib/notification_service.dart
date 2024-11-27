import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission for notifications
    await _firebaseMessaging.requestPermission();

    // Get the FCM token
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Subscribe to the 'all' topic
    if (token != null) {
      await _firebaseMessaging.subscribeToTopic("all");
      print("Subscribed to 'all' topic");
    } else {
      print("Unable to subscribe to 'all' topic as token is null");
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received: ${message.notification?.title}");
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print("Background message: ${message.notification?.title}");
  }
}
