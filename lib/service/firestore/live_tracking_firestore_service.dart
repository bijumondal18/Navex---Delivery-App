import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class LiveTrackingFirestoreService {
  static const String _collectionName = 'live_tracking';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create or update live tracking document in Firestore
  /// Uses route_id as the document ID
  /// This method is optimized for background execution - non-blocking and resilient
  static Future<void> updateLocation({
    required String routeId,
    required String driverId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    double? heading,
    DateTime? timestamp,
  }) async {
    // Use unawaited to make this non-blocking for background execution
    _updateLocationInternal(
      routeId: routeId,
      driverId: driverId,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      speed: speed,
      heading: heading,
      timestamp: timestamp,
    );
  }

  /// Internal method to update location (called asynchronously)
  static Future<void> _updateLocationInternal({
    required String routeId,
    required String driverId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    double? heading,
    DateTime? timestamp,
  }) async {
    try {
      // Check if Firebase is initialized - try to get the default app
      try {
        Firebase.app();
      } catch (e) {
        // Firebase not initialized, try to initialize it
        try {
          // Check if there are any existing apps
          final apps = Firebase.apps;
          
          if (apps.isEmpty) {
            // No apps exist, try to initialize
            await Firebase.initializeApp();
          }
        } catch (initError) {
          print('❌ Failed to initialize Firebase for live tracking: $initError');
          return;
        }
      }
      
      // Prepare location data with timestamp as string for better background compatibility
      final locationData = <String, dynamic>{
        'route_id': routeId,
        'driver_id': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'updated_at': FieldValue.serverTimestamp(),
        'is_active': true,
      };

      // Add optional fields if available
      if (accuracy != null && accuracy >= 0) {
        locationData['accuracy'] = accuracy;
      }
      if (speed != null && speed >= 0) {
        locationData['speed'] = speed;
      }
      if (heading != null && heading >= 0) {
        locationData['heading'] = heading;
      }
      if (timestamp != null) {
        locationData['location_timestamp'] = timestamp.toIso8601String();
      } else {
        locationData['location_timestamp'] = DateTime.now().toIso8601String();
      }

      // Use route_id as document ID and set/update the document
      // Use set() with merge: true for better background performance
      final docRef = _firestore
          .collection(_collectionName)
          .doc(routeId.toString());
      
      // Use set() with merge: true - this is more efficient for background updates
      // and doesn't require reading the document first
      await docRef.set(locationData, SetOptions(merge: true));
      
      // Only print in debug mode to reduce background logging
      if (DateTime.now().millisecond % 10 == 0) { // Log every 10th update to reduce spam
        print('✅ Live tracking updated: route=$routeId, lat=$latitude, lng=$longitude');
      }
    } catch (e) {
      // Log error but don't fail the location tracking
      // Use more detailed logging for debugging background issues
      print('❌ Error updating live tracking in Firestore: $e');
      if (e.toString().contains('permission') || e.toString().contains('network')) {
        print('⚠️ Network or permission issue - location update skipped');
      }
    }
  }

  /// Initialize live tracking document when tracking starts
  static Future<void> startTracking({
    required String routeId,
    required String driverId,
    required double initialLatitude,
    required double initialLongitude,
  }) async {
    try {
      // Check if Firebase is initialized
      try {
        Firebase.app();
      } catch (e) {
        try {
          final apps = Firebase.apps;
          if (apps.isEmpty) {
            await Firebase.initializeApp();
          }
        } catch (initError) {
          print('❌ Failed to initialize Firebase for live tracking start: $initError');
          return;
        }
      }
      
      print('📍 Starting live tracking in Firestore: route_id=$routeId, driver_id=$driverId');
      
      final trackingData = <String, dynamic>{
        'route_id': routeId,
        'driver_id': driverId,
        'latitude': initialLatitude,
        'longitude': initialLongitude,
        'started_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'is_active': true,
      };

      final docRef = _firestore
          .collection(_collectionName)
          .doc(routeId.toString());
      
      await docRef.set(trackingData, SetOptions(merge: true));
      
      print('✅ Live tracking started in Firestore: route_id=$routeId');
    } catch (e) {
      print('❌ Error starting live tracking in Firestore: $e');
    }
  }

  /// Stop live tracking (mark as inactive)
  static Future<void> stopTracking({
    required String routeId,
  }) async {
    try {
      // Check if Firebase is initialized
      try {
        Firebase.app();
      } catch (e) {
        try {
          final apps = Firebase.apps;
          if (apps.isEmpty) {
            await Firebase.initializeApp();
          }
        } catch (initError) {
          print('❌ Failed to initialize Firebase for live tracking stop: $initError');
          return;
        }
      }
      
      print('🛑 Stopping live tracking in Firestore: route_id=$routeId');
      
      final docRef = _firestore
          .collection(_collectionName)
          .doc(routeId.toString());
      
      await docRef.update({
        'is_active': false,
        'stopped_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      print('✅ Live tracking stopped in Firestore: route_id=$routeId');
    } catch (e) {
      print('❌ Error stopping live tracking in Firestore: $e');
    }
  }

  /// Get live tracking document from Firestore
  static Future<Map<String, dynamic>?> getTracking(String routeId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(routeId.toString())
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error getting live tracking from Firestore: $e');
      return null;
    }
  }
}

