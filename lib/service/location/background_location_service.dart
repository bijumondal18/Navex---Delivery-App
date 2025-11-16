import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../firestore/live_tracking_firestore_service.dart';

class BackgroundLocationService {
  static final BackgroundLocationService _instance = BackgroundLocationService._internal();
  factory BackgroundLocationService() => _instance;
  BackgroundLocationService._internal();

  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isTracking = false;
  Position? _latestPosition;
  DateTime? _lastUpdateTime;
  String? _currentRouteId;
  String? _currentDriverId;
  static const String _isTrackingKey = 'background_location_tracking';
  static const String _workManagerTaskName = 'backgroundLocationUpdate';
  static const bool _debugMode = true; // Set to false in production
  
  // Method channel for native Android service
  static const MethodChannel _channel = MethodChannel('com.navex.navex/location_service');

  /// Check if location tracking is currently active
  bool get isTracking => _isTracking;

  /// Get the latest tracked position
  Position? get latestPosition => _latestPosition;

  /// Get the time of last location update
  DateTime? get lastUpdateTime => _lastUpdateTime;

  /// Get tracking status information for debugging
  Map<String, dynamic> getTrackingStatus() {
    return {
      'isTracking': _isTracking,
      'hasSubscription': _positionStreamSubscription != null,
      'latestPosition': _latestPosition != null
          ? {
              'latitude': _latestPosition!.latitude,
              'longitude': _latestPosition!.longitude,
              'timestamp': _latestPosition!.timestamp.toString(),
              'accuracy': _latestPosition!.accuracy,
            }
          : null,
      'lastUpdateTime': _lastUpdateTime?.toString(),
    };
  }

  void _debugLog(String message) {
    if (_debugMode) {
      print('[BackgroundLocationService] $message');
    }
  }

  /// Start background location tracking
  Future<bool> startTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
    Duration? interval,
    String? routeId,
    String? driverId,
  }) async {
    print('═══════════════════════════════════════════════════════');
    print('🎯 BackgroundLocationService.startTracking() CALLED');
    print('📍 routeId: $routeId');
    print('📍 driverId: $driverId');
    print('📍 accuracy: $accuracy');
    print('📍 distanceFilter: $distanceFilter');
    print('📍 Current tracking status: $_isTracking');
    print('═══════════════════════════════════════════════════════');
    
    // Update routeId and driverId even if already tracking
    bool wasAlreadyTracking = _isTracking;
    if (wasAlreadyTracking) {
      print('⚠️ Tracking already started, but will update route/driver info and ensure Firestore document exists');
      _debugLog('Tracking already started, updating route info');
    }

    print('🔄 Starting new tracking session...');
    _debugLog('Starting background location tracking...');
    _debugLog('Settings: accuracy=$accuracy, distanceFilter=$distanceFilter meters');

    try {
      // Check permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      _debugLog('Location service enabled: $serviceEnabled');
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      _debugLog('Current permission: $permission');
      
      if (permission == LocationPermission.denied) {
        _debugLog('Requesting location permission...');
        permission = await Geolocator.requestPermission();
        _debugLog('Permission after request: $permission');
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Request background location permission for Android (API 29+)
      // For background location, we need "always" permission
      if (Platform.isAndroid) {
        _debugLog('Platform: Android - Checking background permission');
        // Check if we need to request background location permission
        if (permission == LocationPermission.whileInUse) {
          _debugLog('Requesting "always" permission for background location...');
          // Request always permission for background location
          permission = await Geolocator.requestPermission();
          _debugLog('Permission after background request: $permission');
        }
        // Note: On Android 10+, user needs to grant "Allow all the time" permission
        // This will show a system dialog if needed
      }

      // Update tracking state
      _isTracking = true;
      _currentRouteId = routeId;
      _currentDriverId = driverId;
      await _saveTrackingState(true);
      
      // Save routeId and driverId for background work
      if (routeId != null && driverId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bg_route_id', routeId);
        await prefs.setString('bg_driver_id', driverId);
      }
      
      if (!wasAlreadyTracking) {
        _debugLog('✅ Background location tracking STARTED successfully');
      } else {
        _debugLog('✅ Background location tracking UPDATED (was already running)');
      }
      _debugLog('Tracking status: ${getTrackingStatus()}');
      
      // CRITICAL: Create/Update Firestore document FIRST before starting native service
      // This ensures document exists even if native service fails
      // ALWAYS create/update document, even if tracking was already started
      if (routeId != null && driverId != null) {
        bool documentCreated = false;
        try {
          // Try to get current position for initial Firestore update
          Position? currentPosition = _latestPosition;
          if (currentPosition == null) {
            try {
              // Try to get current position with timeout
              currentPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: accuracy,
              ).timeout(
                const Duration(seconds: 5),
              );
              _latestPosition = currentPosition;
              _debugLog('📍 Got current position: lat=${currentPosition.latitude}, lng=${currentPosition.longitude}');
            } on TimeoutException {
              _debugLog('⚠️ Timeout getting current position, will create document without position');
            } catch (e) {
              _debugLog('⚠️ Could not get current position: $e');
            }
          }
          
          // Create document with or without position - WAIT for completion
          _debugLog('📝 Creating Firestore document: routeId=$routeId, driverId=$driverId');
          await LiveTrackingFirestoreService.startTracking(
            routeId: routeId,
            driverId: driverId,
            initialLatitude: currentPosition?.latitude ?? 0.0,
            initialLongitude: currentPosition?.longitude ?? 0.0,
          );
          documentCreated = true;
          _debugLog('✅ Firestore tracking document created successfully');
        } catch (e, stackTrace) {
          _debugLog('❌ Failed to create Firestore document: $e');
          _debugLog('Stack trace: $stackTrace');
          // Don't continue if document creation fails - this is critical
          throw Exception('Failed to create Firestore tracking document: $e');
        }
        
        // Only start native service if document was created successfully
        if (documentCreated) {
          // Use native Android foreground service for better reliability (survives app kill)
          if (Platform.isAndroid) {
            try {
              _debugLog('🚀 Starting/Updating native Android foreground service...');
              await _channel.invokeMethod('startLocationTracking', {
                'routeId': routeId,
                'driverId': driverId,
              });
              _debugLog('✅ Native Android foreground service started/updated');
            } catch (e) {
              _debugLog('⚠️ Failed to start native Android service: $e');
              // Only start Flutter tracking if it wasn't already started
              if (!wasAlreadyTracking) {
                _debugLog('⚠️ Falling back to Flutter-based tracking');
                _startFlutterLocationTracking(accuracy, distanceFilter, interval);
              }
            }
          } else {
            // iOS: Use Flutter-based tracking (only if not already started)
            if (!wasAlreadyTracking) {
              _startFlutterLocationTracking(accuracy, distanceFilter, interval);
            }
          }
        }
      }
      
      // Register periodic background task for location updates (backup mechanism)
      // This ensures location updates continue even when app is in background
      if (Platform.isAndroid) {
        try {
          await Workmanager().registerPeriodicTask(
            _workManagerTaskName,
            _workManagerTaskName,
            frequency: const Duration(seconds: 5), // Update every 5 seconds for debugging
          );
          _debugLog('✅ Background workmanager task registered (5 seconds for debugging)');
        } catch (e) {
          _debugLog('⚠️ Failed to register background workmanager task: $e');
        }
      }
      
      return true;
    } catch (e) {
      _isTracking = false;
      await _saveTrackingState(false);
      _debugLog('❌ Failed to start tracking: $e');
      return false;
    }
  }

  /// Start Flutter-based location tracking (fallback for iOS or if native service fails)
  void _startFlutterLocationTracking(
    LocationAccuracy accuracy,
    int distanceFilter,
    Duration? interval,
  ) {
    _debugLog('Starting Flutter-based location tracking...');
    
    // Configure location settings optimized for background tracking
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      timeLimit: interval,
    );

    // Start listening to position updates
    // This stream will continue even when app is in background
    // Geolocator automatically handles foreground service on Android when proper permissions are granted
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        // Handle position updates - this will be called even in background
        _onLocationUpdate(position);
      },
      onError: (error) {
        // Handle errors
        _onLocationError(error);
      },
      cancelOnError: false, // Continue tracking even on errors
    );
  }

  /// Stop background location tracking
  Future<void> stopTracking({String? routeId}) async {
    if (!_isTracking) {
      _debugLog('Tracking already stopped');
      return; // Already stopped
    }

    _debugLog('Stopping background location tracking...');
    
    // Stop native Android service if running
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('stopLocationTracking');
        _debugLog('✅ Native Android foreground service stopped');
      } catch (e) {
        _debugLog('⚠️ Failed to stop native Android service: $e');
      }
    }
    
    // Stop Firestore live tracking if routeId is available
    final routeIdToStop = routeId ?? _currentRouteId;
    if (routeIdToStop != null) {
      try {
        await LiveTrackingFirestoreService.stopTracking(routeId: routeIdToStop);
      } catch (e) {
        _debugLog('⚠️ Failed to stop Firestore live tracking: $e');
      }
    }
    
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
    _currentRouteId = null;
    _currentDriverId = null;
    await _saveTrackingState(false);
    
    // Cancel background workmanager task
    if (Platform.isAndroid) {
      try {
        await Workmanager().cancelByUniqueName(_workManagerTaskName);
        _debugLog('✅ Background workmanager task cancelled');
      } catch (e) {
        _debugLog('⚠️ Failed to cancel background workmanager task: $e');
      }
    }
    
    // Clear saved routeId and driverId
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bg_route_id');
    await prefs.remove('bg_driver_id');
    
    _debugLog('✅ Background location tracking STOPPED');
  }

  /// Handle location updates
  void _onLocationUpdate(Position position) {
    _latestPosition = position;
    _lastUpdateTime = DateTime.now();
    
    // Print location update to console (always visible)
    print('═══════════════════════════════════════════════════════');
    print('📍 LOCATION UPDATE');
    print('📍 Lat: ${position.latitude}');
    print('📍 Lng: ${position.longitude}');
    print('📍 Accuracy: ${position.accuracy}m');
    print('📍 Speed: ${position.speed}m/s');
    print('📍 Heading: ${position.heading}°');
    print('📍 Timestamp: ${position.timestamp}');
    print('═══════════════════════════════════════════════════════');
    
    _debugLog('📍 Location update: lat=${position.latitude}, lng=${position.longitude}, accuracy=${position.accuracy}m');
    _debugLog('   Timestamp: ${position.timestamp}');
    _debugLog('   Speed: ${position.speed}m/s, Heading: ${position.heading}°');
    
    // Save location to local storage
    _saveLatestPosition(position);
    
    // Update Firestore live tracking if routeId and driverId are available
    // Use unawaited to make this non-blocking for background execution
    if (_currentRouteId != null && _currentDriverId != null) {
      print('📝 Updating Firestore with location...');
      // Firestore update is async and non-blocking - won't block location updates
      LiveTrackingFirestoreService.updateLocation(
        routeId: _currentRouteId!,
        driverId: _currentDriverId!,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp,
      ).then((_) {
        print('✅ Firestore updated successfully');
      }).catchError((error) {
        print('❌ Failed to update Firestore: $error');
        _debugLog('⚠️ Failed to update Firestore live tracking: $error');
      });
    } else {
      print('⚠️ Cannot update Firestore: routeId or driverId is null');
    }
  }

  /// Handle location errors
  void _onLocationError(dynamic error) {
    // Handle location errors
    _debugLog('❌ Location tracking error: $error');
    // You might want to log this or notify the user
  }

  /// Save latest position to shared preferences
  Future<void> _saveLatestPosition(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_latitude', position.latitude);
      await prefs.setDouble('last_longitude', position.longitude);
      await prefs.setString('last_location_timestamp', position.timestamp.toString());
    } catch (e) {
      print('Error saving position: $e');
    }
  }

  /// Get latest saved position
  Future<Position?> getLatestPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('last_latitude');
      final lng = prefs.getDouble('last_longitude');
      final timestampStr = prefs.getString('last_location_timestamp');

      if (lat != null && lng != null) {
        return Position(
          latitude: lat,
          longitude: lng,
          timestamp: timestampStr != null
              ? DateTime.parse(timestampStr)
              : DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    } catch (e) {
      print('Error getting latest position: $e');
    }
    return null;
  }

  /// Save tracking state
  Future<void> _saveTrackingState(bool isTracking) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isTrackingKey, isTracking);
    } catch (e) {
      print('Error saving tracking state: $e');
    }
  }

  /// Load tracking state
  Future<void> loadTrackingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isTracking = prefs.getBool(_isTrackingKey) ?? false;
    } catch (e) {
      print('Error loading tracking state: $e');
      _isTracking = false;
    }
  }

  /// Dispose resources
  void dispose() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
  }

  /// Background callback for workmanager
  /// This is called periodically when app is in background
  @pragma('vm:entry-point')
  static void backgroundLocationUpdateCallback() {
    Workmanager().executeTask((task, inputData) async {
      try {
        _staticDebugLog('🔄 Background location update task started: $task');
        
        // Get routeId and driverId from shared preferences
        final prefs = await SharedPreferences.getInstance();
        final routeId = prefs.getString('bg_route_id');
        final driverId = prefs.getString('bg_driver_id');
        
        if (routeId == null || driverId == null) {
          _staticDebugLog('⚠️ No routeId or driverId found, skipping background update');
          return Future.value(true); // Return true to prevent retry
        }
        
        // Check if location services are enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _staticDebugLog('⚠️ Location services are disabled');
          return Future.value(true); // Return true to prevent retry
        }
        
        // Check permissions
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied || 
            permission == LocationPermission.deniedForever) {
          _staticDebugLog('⚠️ Location permission denied: $permission');
          return Future.value(true); // Return true to prevent retry
        }
        
        // Get current location with timeout
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Location request timed out');
            },
          );
          
          // Update Firestore
          await LiveTrackingFirestoreService.updateLocation(
            routeId: routeId,
            driverId: driverId,
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            speed: position.speed,
            heading: position.heading,
            timestamp: position.timestamp,
          );
          
          _staticDebugLog('✅ Background location updated: lat=${position.latitude}, lng=${position.longitude}');
        } catch (e) {
          _staticDebugLog('❌ Error getting location in background: $e');
          // Return true to prevent retry on timeout/permission errors
          // Return false only for transient errors that should be retried
          if (e is TimeoutException) {
            return Future.value(true);
          }
          return Future.value(false); // Retry on other errors
        }
        
        return Future.value(true);
      } catch (e) {
        _staticDebugLog('❌ Error in background location update callback: $e');
        return Future.value(false); // Retry on unexpected errors
      }
    });
  }

  /// Static debug log for background callback
  static void _staticDebugLog(String message) {
    if (_debugMode) {
      print('[BackgroundLocationService] $message');
    }
  }
}

