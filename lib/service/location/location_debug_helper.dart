import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navex/service/location/background_location_service.dart';

/// Helper class for debugging background location tracking
class LocationDebugHelper {
  static final BackgroundLocationService _locationService =
      BackgroundLocationService();

  /// Check if tracking is active
  static bool isTracking() {
    return _locationService.isTracking;
  }

  /// Get current tracking status as a formatted string
  static String getStatusString() {
    final status = _locationService.getTrackingStatus();
    final buffer = StringBuffer();
    buffer.writeln('=== Background Location Tracking Status ===');
    buffer.writeln('Is Tracking: ${status['isTracking']}');
    buffer.writeln('Has Subscription: ${status['hasSubscription']}');
    
    if (status['latestPosition'] != null) {
      final pos = status['latestPosition'] as Map<String, dynamic>;
      buffer.writeln('Latest Position:');
      buffer.writeln('  Latitude: ${pos['latitude']}');
      buffer.writeln('  Longitude: ${pos['longitude']}');
      buffer.writeln('  Accuracy: ${pos['accuracy']}m');
      buffer.writeln('  Timestamp: ${pos['timestamp']}');
    } else {
      buffer.writeln('Latest Position: None');
    }
    
    buffer.writeln('Last Update Time: ${status['lastUpdateTime'] ?? 'Never'}');
    buffer.writeln('==========================================');
    
    return buffer.toString();
  }

  /// Print status to console
  static void printStatus() {
    print(getStatusString());
  }

  /// Show status in a dialog (useful for debugging in UI)
  static Future<void> showStatusDialog(BuildContext context) async {
    final status = _locationService.getTrackingStatus();
    final latestPos = _locationService.latestPosition;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Tracking Status'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusRow('Is Tracking', status['isTracking'].toString()),
              _buildStatusRow('Has Subscription', status['hasSubscription'].toString()),
              const Divider(),
              if (latestPos != null) ...[
                _buildStatusRow('Latitude', latestPos.latitude.toStringAsFixed(6)),
                _buildStatusRow('Longitude', latestPos.longitude.toStringAsFixed(6)),
                _buildStatusRow('Accuracy', '${latestPos.accuracy.toStringAsFixed(1)}m'),
                _buildStatusRow('Speed', '${latestPos.speed.toStringAsFixed(2)}m/s'),
                _buildStatusRow('Heading', '${latestPos.heading.toStringAsFixed(1)}°'),
                _buildStatusRow('Timestamp', latestPos.timestamp.toString()),
              ] else
                const Text('No location data yet'),
              const Divider(),
              _buildStatusRow('Last Update', status['lastUpdateTime']?.toString() ?? 'Never'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              printStatus();
              Navigator.of(context).pop();
            },
            child: const Text('Print to Console'),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Check location permissions
  static Future<Map<String, dynamic>> checkPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    
    return {
      'serviceEnabled': serviceEnabled,
      'permission': permission.toString(),
      'isGranted': permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse,
      'isAlwaysGranted': permission == LocationPermission.always,
    };
  }

  /// Show permission status dialog
  static Future<void> showPermissionDialog(BuildContext context) async {
    final permissions = await checkPermissions();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permissions'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusRow('Service Enabled', permissions['serviceEnabled'].toString()),
            _buildStatusRow('Permission', permissions['permission']),
            _buildStatusRow('Is Granted', permissions['isGranted'].toString()),
            _buildStatusRow('Is Always Granted', permissions['isAlwaysGranted'].toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

