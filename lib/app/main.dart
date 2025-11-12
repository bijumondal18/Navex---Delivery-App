import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:navex/app/navex_app.dart';
import 'package:navex/core/themes/theme.dart';
import 'package:navex/presentation/pages/spalsh/splash_screen.dart';

import '../core/navigation/app_router.dart';
import '../service/OTA/ota_updater.dart';
import '../service/location/background_location_service.dart';
import '../service/notifications/fcm_background_handler.dart';
import '../service/notifications/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // GoogleMapsFlutterAndroid().useAndroidViewSurface = false;

  // Register background handler early
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // await Firebase.initializeApp();

  // Init notifications with router
  // await PushNotificationService.instance.init(router: appRouter);

  // Load background location tracking state (in case app was restarted)
  final locationService = BackgroundLocationService();
  await locationService.loadTrackingState();
  // Note: We don't restart tracking here automatically as it requires user context
  // Tracking will be restarted when load vehicle is called again

  // Over The Air Updating App Silently
  final ota = OtaUpdater();
  await ota.init(); // non-blocking after first check

  runApp(const NavexApp());
}
