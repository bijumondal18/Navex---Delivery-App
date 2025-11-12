import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class LiveTrackingFirestoreService {
  static const String _collectionName = 'live_tracking';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create or update live tracking document in Firestore
  /// Uses route_id as the document ID
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
    try {
      // Check if Firebase is initialized - try to get the default app
      FirebaseApp? firebaseApp;
      try {
        firebaseApp = Firebase.app();
      } catch (e) {
        // Firebase not initialized, try to initialize it
        try {
          // Check if there are any existing apps
          final apps = Firebase.apps;
          
          if (apps.isEmpty) {
            // No apps exist, try to initialize
            firebaseApp = await Firebase.initializeApp();
          } else {
            // Use the first available app
            firebaseApp = apps.first;
          }
        } catch (initError) {
          print('❌ Failed to initialize Firebase for live tracking: $initError');
          return;
        }
      }
      
      // Prepare location data
      final locationData = <String, dynamic>{
        'route_id': routeId,
        'driver_id': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'updated_at': FieldValue.serverTimestamp(),
        'is_active': true,
      };

      // Add optional fields if available
      if (accuracy != null) {
        locationData['accuracy'] = accuracy;
      }
      if (speed != null) {
        locationData['speed'] = speed;
      }
      if (heading != null) {
        locationData['heading'] = heading;
      }
      if (timestamp != null) {
        locationData['location_timestamp'] = timestamp.toIso8601String();
      }

      // Use route_id as document ID and set/update the document
      final docRef = _firestore
          .collection(_collectionName)
          .doc(routeId.toString());
      
      await docRef.set(locationData, SetOptions(merge: true)); // merge: true updates existing or creates new
      
      print('✅ Live tracking updated in Firestore: route_id=$routeId, lat=$latitude, lng=$longitude');
    } catch (e, stackTrace) {
      // Log error but don't fail the location tracking
      print('❌ Error updating live tracking in Firestore: $e');
      print('❌ Stack trace: $stackTrace');
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
      FirebaseApp? firebaseApp;
      try {
        firebaseApp = Firebase.app();
      } catch (e) {
        try {
          final apps = Firebase.apps;
          if (apps.isEmpty) {
            firebaseApp = await Firebase.initializeApp();
          } else {
            firebaseApp = apps.first;
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
      FirebaseApp? firebaseApp;
      try {
        firebaseApp = Firebase.app();
      } catch (e) {
        try {
          final apps = Firebase.apps;
          if (apps.isEmpty) {
            firebaseApp = await Firebase.initializeApp();
          } else {
            firebaseApp = apps.first;
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

