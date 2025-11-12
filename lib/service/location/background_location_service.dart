import 'dart:async';
import 'dart:io';

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
    if (_isTracking) {
      _debugLog('Tracking already started');
      return true; // Already tracking
    }

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

      // Configure location settings optimized for background tracking
      final locationSettings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        timeLimit: interval,
      );

      _debugLog('Starting position stream with background support...');
      // Start listening to position updates
      // This stream will continue even when app is in background
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
      
      _debugLog('✅ Background location tracking STARTED successfully');
      _debugLog('Tracking status: ${getTrackingStatus()}');
      
      // Initialize Firestore live tracking if routeId and driverId are provided
      if (routeId != null && driverId != null) {
        try {
          // Get current position for initial Firestore update
          Position? currentPosition = _latestPosition;
          if (currentPosition == null) {
            // Try to get current position if not available
            try {
              currentPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: accuracy,
              );
              _latestPosition = currentPosition;
            } catch (e) {
              _debugLog('⚠️ Could not get current position: $e');
            }
          }
          
          if (currentPosition != null) {
            await LiveTrackingFirestoreService.startTracking(
              routeId: routeId,
              driverId: driverId,
              initialLatitude: currentPosition.latitude,
              initialLongitude: currentPosition.longitude,
            );
          } else {
            // Initialize without position, will be updated on first location update
            _debugLog('⚠️ Initializing Firestore tracking without position, will update on first location update');
          }
        } catch (e) {
          _debugLog('⚠️ Failed to start Firestore live tracking: $e');
        }
      }
      
      // Register periodic background task for location updates
      // This ensures location updates continue even when app is in background
      if (Platform.isAndroid) {
        try {
          await Workmanager().registerPeriodicTask(
            _workManagerTaskName,
            _workManagerTaskName,
            frequency: const Duration(minutes: 1), // Update every minute in background
          );
          _debugLog('✅ Background workmanager task registered');
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

  /// Stop background location tracking
  Future<void> stopTracking({String? routeId}) async {
    if (!_isTracking) {
      _debugLog('Tracking already stopped');
      return; // Already stopped
    }

    _debugLog('Stopping background location tracking...');
    
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
    
    _debugLog('📍 Location update: lat=${position.latitude}, lng=${position.longitude}, accuracy=${position.accuracy}m');
    _debugLog('   Timestamp: ${position.timestamp}');
    _debugLog('   Speed: ${position.speed}m/s, Heading: ${position.heading}°');
    
    // Save location to local storage
    _saveLatestPosition(position);
    
    // Update Firestore live tracking if routeId and driverId are available
    // Use unawaited to make this non-blocking for background execution
    if (_currentRouteId != null && _currentDriverId != null) {
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
      ).catchError((error) {
        _debugLog('⚠️ Failed to update Firestore live tracking: $error');
      });
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
        _staticDebugLog('🔄 Background location update task started');
        
        // Get routeId and driverId from shared preferences
        final prefs = await SharedPreferences.getInstance();
        final routeId = prefs.getString('bg_route_id');
        final driverId = prefs.getString('bg_driver_id');
        
        if (routeId == null || driverId == null) {
          _staticDebugLog('⚠️ No routeId or driverId found, skipping background update');
          return Future.value(true);
        }
        
        // Get current location
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
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
        }
        
        return Future.value(true);
      } catch (e) {
        _staticDebugLog('❌ Error in background location update callback: $e');
        return Future.value(false);
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

