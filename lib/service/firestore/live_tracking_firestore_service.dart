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
    // Wait for update to complete to ensure it's written
    await _updateLocationInternal(
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
        'latitude': double.parse(latitude.toStringAsFixed(4)),
        'longitude': double.parse(longitude.toStringAsFixed(4)),
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
      final docRef = _firestore
          .collection(_collectionName)
          .doc(routeId.toString());
      
      // Use set() with merge: true - this is more efficient for background updates
      // and doesn't require reading the document first
      await docRef.set(locationData, SetOptions(merge: true));
      
      // Print update confirmation (reduced frequency to avoid spam)
      final now = DateTime.now();
      if (now.second % 5 == 0) { // Log every 5 seconds
        print('✅ Firestore updated: route=$routeId, lat=$latitude, lng=$longitude, accuracy=${accuracy?.toStringAsFixed(1)}m');
      }
    } catch (e, stackTrace) {
      // Log error but don't fail the location tracking
      // Use more detailed logging for debugging background issues
      print('❌ Error updating live tracking in Firestore: $e');
      print('❌ Stack trace: $stackTrace');
      if (e.toString().contains('permission') || e.toString().contains('network')) {
        print('⚠️ Network or permission issue - location update skipped');
      }
      rethrow; // Re-throw so caller knows it failed
    }
  }

  /// Initialize live tracking document when tracking starts
  static Future<void> startTracking({
    required String routeId,
    required String driverId,
    required double initialLatitude,
    required double initialLongitude,
  }) async {
    print('═══════════════════════════════════════════════════════');
    print('🔥 START TRACKING CALLED');
    print('📍 routeId: $routeId');
    print('📍 driverId: $driverId');
    print('📍 location: lat=$initialLatitude, lng=$initialLongitude');
    print('═══════════════════════════════════════════════════════');
    
    // Check if Firebase is initialized
    FirebaseApp? firebaseApp;
    try {
      firebaseApp = Firebase.app();
      print('✅ Firebase is initialized: ${firebaseApp.name}');
      print('✅ Project ID: ${firebaseApp.options.projectId}');
    } catch (e) {
      print('⚠️ Firebase not initialized, attempting to initialize...');
      print('⚠️ Error: $e');
      try {
        final apps = Firebase.apps;
        print('📊 Existing Firebase apps: ${apps.length}');
        if (apps.isEmpty) {
          print('🔄 Initializing Firebase...');
          firebaseApp = await Firebase.initializeApp();
          print('✅ Firebase initialized successfully: ${firebaseApp.name}');
        } else {
          firebaseApp = apps.first;
          print('✅ Using existing Firebase app: ${firebaseApp.name}');
        }
      } catch (initError, stackTrace) {
        print('❌ Failed to initialize Firebase for live tracking start');
        print('❌ Error: $initError');
        print('❌ Stack trace: $stackTrace');
        throw Exception('Firebase initialization failed: $initError');
      }
    }
    
    print('📍 Starting live tracking in Firestore');
    print('📍 Collection: $_collectionName');
    print('📍 Document ID: $routeId');
    
    try {
      // Verify Firestore instance
      final firestore = FirebaseFirestore.instance;
      print('✅ Firestore instance obtained');
      
      final trackingData = <String, dynamic>{
        'route_id': routeId,
        'driver_id': driverId,
        'latitude': double.parse(initialLatitude.toStringAsFixed(4)),
        'longitude': double.parse(initialLongitude.toStringAsFixed(4)),
        'started_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'is_active': true,
      };

      print('📝 Tracking data prepared:');
      print('   - route_id: $routeId');
      print('   - driver_id: $driverId');
      print('   - latitude: $initialLatitude');
      print('   - longitude: $initialLongitude');
      print('   - is_active: true');

      final docRef = firestore
          .collection(_collectionName)
          .doc(routeId.toString());
      
      print('📝 Writing to Firestore...');
      print('   Collection: $_collectionName');
      print('   Document: $routeId');
      
      await docRef.set(trackingData, SetOptions(merge: true));
      
      print('✅ Firestore write completed');
      print('✅ Live tracking document created successfully');
      print('✅ Document ID: $routeId');
      print('═══════════════════════════════════════════════════════');
      
      // Verify document was created by reading it back
      try {
        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          print('✅ Document verified - exists in Firestore');
          print('✅ Document data: ${docSnapshot.data()}');
        } else {
          print('⚠️ WARNING: Document write succeeded but document does not exist!');
        }
      } catch (verifyError) {
        print('⚠️ Could not verify document: $verifyError');
      }
      
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════════════════════');
      print('❌ ERROR CREATING FIRESTORE DOCUMENT');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Error message: $e');
      print('❌ Stack trace: $stackTrace');
      print('═══════════════════════════════════════════════════════');
      // Re-throw the error so caller knows it failed
      throw Exception('Failed to create Firestore document: $e');
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

