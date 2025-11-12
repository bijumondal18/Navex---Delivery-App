import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../data/models/route.dart';

class RouteFirestoreService {
  static const String _collectionName = 'routes';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create or update a route document in Firestore
  /// Uses route_id as the document ID
  static Future<void> createOrUpdateRoute({
    required String routeId,
    required RouteData routeData,
  }) async {
    try {
      // Check if Firebase is initialized - try to get the default app
      FirebaseApp? firebaseApp;
      try {
        firebaseApp = Firebase.app();
        print('✅ Firebase is initialized: ${firebaseApp.name}');
      } catch (e) {
        // Firebase not initialized, try to initialize it
        print('⚠️ Firebase not initialized: $e');
        print('⚠️ Attempting to initialize Firebase in service...');
        try {
          // Check if there are any existing apps
          final apps = Firebase.apps;
          print('📋 Existing Firebase apps: ${apps.length}');
          
          if (apps.isEmpty) {
            // No apps exist, try to initialize
            firebaseApp = await Firebase.initializeApp();
            print('✅ Firebase initialized successfully in service: ${firebaseApp.name}');
          } else {
            // Use the first available app
            firebaseApp = apps.first;
            print('✅ Using existing Firebase app: ${firebaseApp.name}');
          }
        } catch (initError, stackTrace) {
          print('❌ Failed to initialize Firebase: $initError');
          print('❌ Stack trace: $stackTrace');
          print('❌ Skipping Firestore operation');
          print('💡 Make sure google-services.json is in android/app/ and rebuild the app');
          return;
        }
      }
      
      print('📝 Starting Firestore route document creation for route_id: $routeId');

      // Prepare route data map with all available fields
      final routeDataMap = <String, dynamic>{
        'route_id': routeId,
        'pharmacy_id': routeData.pharmacyId?.toString() ?? '',
        'route_name': routeData.routeName?.toString() ?? '',
        'start_date': routeData.startDate?.toString() ?? '',
        'start_time': routeData.startTime?.toString() ?? '',
        'pickup_address': routeData.pickupAddress?.toString() ?? '',
        'pickup_lat': routeData.pickupLat,
        'pickup_long': routeData.pickupLong,
        'asigned_driver': routeData.asignedDriver?.toString() ?? '',
        'total_distance': routeData.totalDistance,
        'total_distance_km': routeData.totalDistanceKm,
        'total_time_seconds': routeData.totalTimeSeconds,
        'total_time': routeData.totalTime,
        'polyline': routeData.polyline?.toString() ?? '',
        'route_order': routeData.routeOrder,
        'route_type': routeData.routeType,
        'driver_should_return': routeData.driverShouldReturn,
        'return_eta': routeData.returnEta?.toString() ?? '',
        'return_time': routeData.returnTime,
        'return_distance': routeData.returnDistance,
        'is_loaded': routeData.isLoaded,
        'current_waypoint': routeData.currentWaypoint?.toString() ?? '',
        'status': routeData.status,
        'accepted_by': routeData.acceptedBy?.toString() ?? '',
        'trip_start_time': routeData.tripStartTime?.toString() ?? '',
        'trip_end_time': routeData.tripEndTime?.toString() ?? '',
        'del_flag': routeData.delFlag,
        'created_by': routeData.createdBy?.toString() ?? '',
        'created_by_ip': routeData.createdByIp?.toString() ?? '',
        'updated_by': routeData.updatedBy?.toString() ?? '',
        'updated_by_ip': routeData.updatedByIp?.toString() ?? '',
        'created_at': routeData.createdAt?.toString() ?? '',
        'updated_at': routeData.updatedAt?.toString() ?? '',
        'accepted_at': FieldValue.serverTimestamp(),
        'updated_at_firestore': FieldValue.serverTimestamp(),
      };

      // Add waypoints if available
      if (routeData.waypoints != null && routeData.waypoints!.isNotEmpty) {
        final waypointsList = routeData.waypoints!.map((waypoint) {
          return <String, dynamic>{
            'id': waypoint.id?.toString() ?? '',
            'route_id': waypoint.routeId?.toString() ?? '',
            'customer_id': waypoint.customerId?.toString() ?? '',
            'address': waypoint.address?.toString() ?? '',
            'address_lat': waypoint.addressLat,
            'address_long': waypoint.addressLong,
            'optimize_order': waypoint.optimizeOrder?.toString() ?? '',
            'eta': waypoint.eta?.toString() ?? '',
            'eta_distance': waypoint.etaDistance,
            'eta_duration': waypoint.etaDuration,
            'type': waypoint.type,
            'priority': waypoint.priority,
            'package_count': waypoint.packageCount?.toString() ?? '',
            'product': waypoint.product?.toString() ?? '',
            'external_id': waypoint.externalId?.toString() ?? '',
            'seller_name': waypoint.sellerName?.toString() ?? '',
            'seller_website': waypoint.sellerWebsite?.toString() ?? '',
            'seller_order_id': waypoint.sellerOrderId?.toString() ?? '',
            'seller_note': waypoint.sellerNote?.toString() ?? '',
            'driver_note': waypoint.driverNote?.toString() ?? '',
            'status': waypoint.status,
            // 'delivered_to': waypoint.deliveredTo?.toString() ?? '',
            // 'barcode_type': waypoint.barcodeType?.toString() ?? '',
            // 'drx_logid': waypoint.drxLogid?.toString() ?? '',
            // 'drx_id': waypoint.drxId?.toString() ?? '',
            // 'drx_number': waypoint.drxNumber?.toString() ?? '',
            'del_flag': waypoint.delFlag,
            'created_at': waypoint.createdAt?.toString() ?? '',
            'updated_at': waypoint.updatedAt?.toString() ?? '',
            // Add customer data if available
            // if (waypoint.customer != null) ...[
            //   'customer': <String, dynamic>{
            //     'id': waypoint.customer!.id?.toString() ?? '',
            //     'user_id': waypoint.customer!.userId?.toString() ?? '',
            //     'pharmacy_id': waypoint.customer!.pharmacyId?.toString() ?? '',
            //     'name': waypoint.customer!.name?.toString() ?? '',
            //     'email': waypoint.customer!.email?.toString() ?? '',
            //     'phone': waypoint.customer!.phone?.toString() ?? '',
            //     'address': waypoint.customer!.address?.toString() ?? '',
            //     'address_lat': waypoint.customer!.addressLat,
            //     'address_long': waypoint.customer!.addressLong,
            //     'city': waypoint.customer!.city?.toString() ?? '',
            //     'state': waypoint.customer!.state?.toString() ?? '',
            //     'zip': waypoint.customer!.zip?.toString() ?? '',
            //     'status': waypoint.customer!.status,
            //     'del_flag': waypoint.customer!.delFlag,
            //     'created_by': waypoint.customer!.createdBy?.toString() ?? '',
            //     'created_by_ip': waypoint.customer!.createdByIp?.toString() ?? '',
            //     'updated_by': waypoint.customer!.updatedBy?.toString() ?? '',
            //     'updated_by_ip': waypoint.customer!.updatedByIp?.toString() ?? '',
            //     'created_at': waypoint.customer!.createdAt?.toString() ?? '',
            //     'updated_at': waypoint.customer!.updatedAt?.toString() ?? '',
            //   },
            // ],
          };
        }).toList();
        routeDataMap['waypoints'] = waypointsList;
        routeDataMap['waypoints_count'] = waypointsList.length;
      } else {
        routeDataMap['waypoints'] = <Map<String, dynamic>>[];
        routeDataMap['waypoints_count'] = 0;
      }

      print('📦 Route data prepared: ${routeDataMap.keys.toList()}');
      
      // Use route_id as document ID and set/update the document
      final docRef = _firestore
          .collection(_collectionName)
          .doc(routeId.toString());
      
      print('💾 Writing to Firestore: routes/$routeId');
      
      await docRef.set(routeDataMap, SetOptions(merge: true)); // merge: true updates existing or creates new
      
      print('✅ Route document created/updated successfully');

      // Update timestamps separately
      await docRef.update({
        'updated_at_firestore': FieldValue.serverTimestamp(),
      });
      
      print('✅ Timestamps updated successfully');
    } catch (e, stackTrace) {
      // Log error but don't fail the accept route process
      print('❌ Error saving route to Firestore: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  /// Update route status in Firestore
  static Future<void> updateRouteStatus({
    required String routeId,
    required dynamic status,
  }) async {
    try {
      final docRef = _firestore
          .collection(_collectionName)
          .doc(routeId.toString());
      
      await docRef.update({
        'status': status,
        'updated_at_firestore': FieldValue.serverTimestamp(),
      });
      
      print('✅ Route status updated in Firestore: route_id=$routeId, status=$status');
    } catch (e) {
      print('❌ Error updating route status in Firestore: $e');
    }
  }

  /// Get route document from Firestore
  static Future<Map<String, dynamic>?> getRoute(String routeId) async {
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
      print('❌ Error getting route from Firestore: $e');
      return null;
    }
  }

  /// Delete route document from Firestore
  static Future<void> deleteRoute(String routeId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(routeId.toString())
          .delete();
      
      print('✅ Route document deleted from Firestore: route_id=$routeId');
    } catch (e) {
      print('❌ Error deleting route from Firestore: $e');
    }
  }
}

