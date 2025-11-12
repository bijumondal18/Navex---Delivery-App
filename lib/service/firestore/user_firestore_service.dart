import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:navex/data/models/login_response.dart';

class UserFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'users';

  /// Create or update user document in Firestore
  /// Uses user_id as the document ID
  static Future<void> createOrUpdateUser({
    required int userId,
    required LoginResponse loginResponse,
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
      
      print('📝 Starting Firestore user document creation for user_id: $userId');

      final user = loginResponse.user;
      if (user == null) {
        print('❌ User data is null - cannot save to Firestore');
        return; // No user data to save
      }
      
      print('✅ User data found: name=${user.name}, email=${user.email}');

      // Prepare user data map with all available fields
      final userData = <String, dynamic>{
        'user_id': userId,
        'name': user.name?.toString() ?? '',
        'email': user.email?.toString() ?? '',
        'pharmacy_key': loginResponse.pharmacyKey?.toString() ?? '',
        'token': loginResponse.token?.toString() ?? '', // Store token if needed
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'last_login': FieldValue.serverTimestamp(),
        'is_logged_in': true,
      };

      // Add user fields if they exist
      if (user.id != null) {
        userData['id'] = user.id;
      }
      if (user.profileImage != null) {
        userData['profile_image'] = user.profileImage.toString();
      }
      if (user.emailVerifiedAt != null) {
        userData['email_verified_at'] = user.emailVerifiedAt.toString();
      }
      if (user.role != null) {
        userData['role'] = user.role.toString();
      }
      if (user.status != null) {
        userData['status'] = user.status;
      }

      // Add driver data if available
      if (user.driver != null) {
        final driver = user.driver!;
        final driverData = <String, dynamic>{};
        
        if (driver.id != null) driverData['id'] = driver.id;
        if (driver.name != null) driverData['name'] = driver.name.toString();
        if (driver.email != null) driverData['email'] = driver.email.toString();
        if (driver.phone != null) driverData['phone'] = driver.phone.toString();
        if (driver.bio != null) driverData['bio'] = driver.bio.toString();
        if (driver.address != null) driverData['address'] = driver.address.toString();
        if (driver.addressLat != null) driverData['address_lat'] = driver.addressLat;
        if (driver.addressLong != null) driverData['address_long'] = driver.addressLong;
        if (driver.city != null) driverData['city'] = driver.city.toString();
        if (driver.state != null) driverData['state'] = driver.state.toString();
        if (driver.zip != null) driverData['zip'] = driver.zip.toString();
        if (driver.location != null) driverData['location'] = driver.location.toString();
        if (driver.locationLat != null) driverData['location_lat'] = driver.locationLat;
        if (driver.locationLong != null) driverData['location_long'] = driver.locationLong;
        // if (driver.isOnline != null) driverData['is_online'] = driver.isOnline?.toString() ?? '';
        
        // Add nested state_details if available
        if (driver.stateDetails != null) {
          final stateDetails = driver.stateDetails!;
          final stateData = <String, dynamic>{};
          if (stateDetails.id != null) stateData['id'] = stateDetails.id;
          if (stateDetails.country != null) stateData['country'] = stateDetails.country.toString();
          if (stateDetails.countryCode != null) stateData['country_code'] = stateDetails.countryCode.toString();
          if (stateDetails.state != null) stateData['state'] = stateDetails.state.toString();
          if (stateDetails.stateCode != null) stateData['state_code'] = stateDetails.stateCode.toString();
          driverData['state_details'] = stateData;
        }
        
        // Add nested pharmacy if available
        if (driver.pharmacy != null) {
          final pharmacy = driver.pharmacy!;
          final pharmacyData = <String, dynamic>{};
          if (pharmacy.id != null) pharmacyData['id'] = pharmacy.id;
          if (pharmacy.name != null) pharmacyData['name'] = pharmacy.name.toString();
          // if (pharmacy.email != null) pharmacyData['email'] = pharmacy.email.toString();
          // if (pharmacy.phone != null) pharmacyData['phone'] = pharmacy.phone.toString();
          // if (pharmacy.address != null) pharmacyData['address'] = pharmacy.address.toString();
          driverData['pharmacy'] = pharmacyData;
        }
        
        userData['driver'] = driverData;
      }

      print('📦 User data prepared: ${userData.keys.toList()}');
      
      // Use user_id as document ID and set/update the document
      final docRef = _firestore
          .collection(_collectionName)
          .doc(userId.toString());
      
      print('💾 Writing to Firestore: users/$userId');
      
      await docRef.set(userData, SetOptions(merge: true)); // merge: true updates existing or creates new
      
      print('✅ User document created/updated successfully');

      // Update last_login timestamp separately
      await docRef.update({
        'last_login': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      print('✅ Timestamps updated successfully');
    } catch (e, stackTrace) {
      // Log error but don't fail the login process
      print('❌ Error saving user to Firestore: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  /// Update user's last activity timestamp
  static Future<void> updateLastActivity(int userId) async {
    try {
      try {
        Firebase.app();
      } catch (e) {
        return;
      }

      await _firestore
          .collection(_collectionName)
          .doc(userId.toString())
          .update({
        'last_activity': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last activity: $e');
    }
  }

  /// Get user document from Firestore
  static Future<Map<String, dynamic>?> getUser(int userId) async {
    try {
      try {
        Firebase.app();
      } catch (e) {
        return null;
      }

      final doc = await _firestore
          .collection(_collectionName)
          .doc(userId.toString())
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user from Firestore: $e');
      return null;
    }
  }

  /// Update user's logout status
  static Future<void> updateLogoutStatus(int userId) async {
    try {
      try {
        Firebase.app();
      } catch (e) {
        return;
      }

      await _firestore
          .collection(_collectionName)
          .doc(userId.toString())
          .update({
        'is_logged_in': false,
        'last_logout': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating logout status: $e');
    }
  }
}

