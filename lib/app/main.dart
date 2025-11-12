import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:navex/app/navex_app.dart';

import '../core/navigation/app_router.dart';
import '../service/OTA/ota_updater.dart';
import '../service/location/background_location_service.dart';
import '../service/notifications/fcm_background_handler.dart';
import '../service/notifications/push_notification_service.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (with error handling for missing config)
  try {
    debugPrint('🔥 Starting Firebase initialization...');
    
    // Try to initialize with explicit options first (more reliable)
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCMeEiScFy4YFsgN3esIkF1_OBXO_ANGB4',
          appId: '1:906489789394:android:2c341548da1b5b6aee660b',
          messagingSenderId: '906489789394',
          projectId: 'navex-8fe81',
          storageBucket: 'navex-8fe81.firebasestorage.app',
        ),
      );
      debugPrint('✅ Firebase initialized successfully with explicit options');
    } catch (explicitError) {
      // Fallback to default initialization (uses google-services.json)
      debugPrint('⚠️ Explicit initialization failed, trying default: $explicitError');
      await Firebase.initializeApp();
      debugPrint('✅ Firebase initialized successfully with default options');
    }
    
    // Verify Firebase is actually initialized
    try {
      final app = Firebase.app();
      debugPrint('✅ Firebase app verified: ${app.name}');
      debugPrint('✅ Firebase options loaded: ${app.options.projectId}');
    } catch (e) {
      debugPrint('⚠️ Firebase app verification failed: $e');
    }
    
    // Register background handler early (must be top-level function)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Init notifications with router
    await PushNotificationService.instance.init(router: appRouter);
  } catch (e, stackTrace) {
    // Firebase config files not found - app can still run without Firebase
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('⚠️ Error type: ${e.runtimeType}');
    debugPrint('⚠️ Stack trace: $stackTrace');
    debugPrint('⚠️ Please add google-services.json (Android) and GoogleService-Info.plist (iOS)');
    debugPrint('⚠️ See FIREBASE_SETUP.md for instructions');
    debugPrint('⚠️ App will continue without Firebase features');
    // Continue app initialization without Firebase
  }

  // Initialize Workmanager for background location updates
  await Workmanager().initialize(
    BackgroundLocationService.backgroundLocationUpdateCallback,
    isInDebugMode: false,
  );

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
