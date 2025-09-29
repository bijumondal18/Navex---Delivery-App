import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point') // needed for background isolates
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized in background
  await Firebase.initializeApp();

  // You can add lightweight logging/analytics here
  // Avoid UI or heavy work in background isolate
}