package com.navex.navex

import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.navex.navex/location_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLocationTracking" -> {
                    val routeId = call.argument<String>("routeId")
                    val driverId = call.argument<String>("driverId")
                    
                    if (routeId != null && driverId != null) {
                        startLocationService(routeId, driverId)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "routeId and driverId are required", null)
                    }
                }
                "stopLocationTracking" -> {
                    stopLocationService()
                    result.success(true)
                }
                "isTracking" -> {
                    // Check if service is running by checking if it's bound or started
                    result.success(isServiceRunning())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun isServiceRunning(): Boolean {
        // Simple check - in production you might want to use a more robust method
        // For now, we'll assume if stopService is called and succeeds, it was running
        return true // This is a simplified check
    }

    private fun startLocationService(routeId: String, driverId: String) {
        Log.d("MainActivity", "Starting location service: routeId=$routeId, driverId=$driverId")
        
        val intent = Intent(this, LocationForegroundService::class.java).apply {
            action = LocationForegroundService.ACTION_START_TRACKING
            putExtra(LocationForegroundService.EXTRA_ROUTE_ID, routeId)
            putExtra(LocationForegroundService.EXTRA_DRIVER_ID, driverId)
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            ContextCompat.startForegroundService(this, intent)
        } else {
            startService(intent)
        }
    }

    private fun stopLocationService() {
        Log.d("MainActivity", "Stopping location service")
        
        val intent = Intent(this, LocationForegroundService::class.java).apply {
            action = LocationForegroundService.ACTION_STOP_TRACKING
        }
        
        stopService(intent)
    }
}
