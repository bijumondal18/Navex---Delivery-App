package com.navex.navex

import android.app.*
import android.content.Context
import android.content.Intent
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.FirebaseApp
import com.google.firebase.firestore.FirebaseFirestore
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

class LocationForegroundService : Service() {
    private val binder = LocalBinder()
    private var locationManager: LocationManager? = null
    private var locationListener: LocationListener? = null
    private var executorService: ScheduledExecutorService? = null
    
    private var routeId: String? = null
    private var driverId: String? = null
    private var isTracking = false
    
    companion object {
        private const val TAG = "LocationForegroundService"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "location_tracking_channel"
        private const val CHANNEL_NAME = "Location Tracking"
        
        const val ACTION_START_TRACKING = "com.navex.navex.START_TRACKING"
        const val ACTION_STOP_TRACKING = "com.navex.navex.STOP_TRACKING"
        
        const val EXTRA_ROUTE_ID = "route_id"
        const val EXTRA_DRIVER_ID = "driver_id"
    }
    
    inner class LocalBinder : Binder() {
        fun getService(): LocationForegroundService = this@LocationForegroundService
    }
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")
        createNotificationChannel()
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        executorService = Executors.newSingleThreadScheduledExecutor()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START_TRACKING -> {
                val routeId = intent.getStringExtra(EXTRA_ROUTE_ID)
                val driverId = intent.getStringExtra(EXTRA_DRIVER_ID)
                if (routeId != null && driverId != null) {
                    startLocationTracking(routeId, driverId)
                }
            }
            ACTION_STOP_TRACKING -> {
                stopLocationTracking()
                stopSelf()
            }
        }
        return START_STICKY // Service will restart if killed by system
    }
    
    override fun onBind(intent: Intent?): IBinder {
        return binder
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service destroyed")
        stopLocationTracking()
        executorService?.shutdown()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Tracks your location during active trips"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun startForegroundNotification() {
        val notificationIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Tracking Location")
            .setContentText("Navex is tracking your location for active trip")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
        
        startForeground(NOTIFICATION_ID, notification)
    }
    
    fun startLocationTracking(routeId: String, driverId: String) {
        if (isTracking) {
            Log.d(TAG, "Already tracking, updating route info")
        }
        
        this.routeId = routeId
        this.driverId = driverId
        this.isTracking = true
        
        Log.d(TAG, "Starting location tracking: routeId=$routeId, driverId=$driverId")
        
        startForegroundNotification()
        
        try {
            // Initialize Firebase if not already initialized
            val firebaseApps = FirebaseApp.getApps(this)
            if (firebaseApps.isEmpty()) {
                Log.w(TAG, "Firebase not initialized, attempting to initialize...")
                try {
                    // Firebase should already be initialized by Flutter app
                    // If not, try to initialize (this might fail if google-services.json is missing)
                    FirebaseApp.initializeApp(this)
                    Log.d(TAG, "✅ Firebase initialized successfully in native service")
                } catch (e: Exception) {
                    Log.e(TAG, "❌ Failed to initialize Firebase: ${e.message}", e)
                    Log.w(TAG, "⚠️ Will rely on Flutter side for Firestore updates")
                }
            } else {
                Log.d(TAG, "✅ Firebase already initialized (${firebaseApps.size} app(s))")
            }
            
            // Create initial Firestore document immediately (as backup to Flutter side)
            // Flutter side should have already created it, but this ensures it exists
            createInitialTrackingDocument(routeId, driverId)
            
            locationListener = object : LocationListener {
                override fun onLocationChanged(location: Location) {
                    Log.d(TAG, "═══════════════════════════════════════════════════════")
                    Log.d(TAG, "📍 onLocationChanged CALLED")
                    Log.d(TAG, "📍 Lat: ${location.latitude}, Lng: ${location.longitude}")
                    Log.d(TAG, "📍 Accuracy: ${location.accuracy}m")
                    Log.d(TAG, "═══════════════════════════════════════════════════════")
                    updateLocationToFirestore(location)
                }
                
                override fun onProviderEnabled(provider: String) {
                    Log.d(TAG, "✅ Location provider enabled: $provider")
                }
                
                override fun onProviderDisabled(provider: String) {
                    Log.w(TAG, "⚠️ Location provider disabled: $provider")
                }
            }
            
            val locationManager = this.locationManager ?: run {
                Log.e(TAG, "❌ LocationManager is null, cannot start tracking")
                isTracking = false
                return
            }
            
            Log.d(TAG, "📡 Requesting location updates...")
            Log.d(TAG, "📡 Interval: 5000ms (5 seconds)")
            Log.d(TAG, "📡 Distance filter: 10 meters")
            
            // Request location updates
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    locationManager.requestLocationUpdates(
                        LocationManager.GPS_PROVIDER,
                        5000L, // 5 seconds
                        10f, // 10 meters
                        locationListener as LocationListener,
                        Looper.getMainLooper()
                    )
                    Log.d(TAG, "✅ GPS provider location updates requested (Android S+)")
                } else {
                    @Suppress("DEPRECATION")
                    locationManager.requestLocationUpdates(
                        LocationManager.GPS_PROVIDER,
                        5000L, // 5 seconds
                        10f, // 10 meters
                        locationListener as LocationListener
                    )
                    Log.d(TAG, "✅ GPS provider location updates requested (pre-Android S)")
                }
            } catch (e: SecurityException) {
                Log.e(TAG, "❌ SecurityException requesting GPS updates: ${e.message}", e)
            } catch (e: Exception) {
                Log.e(TAG, "❌ Exception requesting GPS updates: ${e.message}", e)
            }
            
            // Also try network provider as fallback
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    locationManager.requestLocationUpdates(
                        LocationManager.NETWORK_PROVIDER,
                        5000L,
                        10f,
                        locationListener as LocationListener,
                        Looper.getMainLooper()
                    )
                    Log.d(TAG, "✅ Network provider location updates requested (Android S+)")
                } else {
                    @Suppress("DEPRECATION")
                    locationManager.requestLocationUpdates(
                        LocationManager.NETWORK_PROVIDER,
                        5000L,
                        10f,
                        locationListener as LocationListener
                    )
                    Log.d(TAG, "✅ Network provider location updates requested (pre-Android S)")
                }
            } catch (e: SecurityException) {
                Log.e(TAG, "❌ SecurityException requesting Network updates: ${e.message}", e)
            } catch (e: Exception) {
                Log.e(TAG, "❌ Exception requesting Network updates: ${e.message}", e)
            }
            
            Log.d(TAG, "✅ Location tracking started successfully")
            Log.d(TAG, "✅ Waiting for location updates...")
        } catch (e: SecurityException) {
            Log.e(TAG, "Location permission not granted", e)
            isTracking = false
        } catch (e: Exception) {
            Log.e(TAG, "Error starting location tracking", e)
            isTracking = false
        }
    }
    
    fun stopLocationTracking() {
        if (!isTracking) return
        
        Log.d(TAG, "Stopping location tracking")
        
        isTracking = false
        locationListener?.let { listener ->
            locationManager?.removeUpdates(listener)
        }
        locationListener = null
        
        // Mark tracking as inactive in Firestore
        routeId?.let { routeId ->
            updateTrackingStatus(routeId, false)
        }
        
        routeId = null
        driverId = null
    }
    
    private fun createInitialTrackingDocument(routeId: String, driverId: String) {
        executorService?.execute {
            try {
                if (FirebaseApp.getApps(this@LocationForegroundService).isEmpty()) {
                    Log.w(TAG, "Firebase not initialized, cannot create initial document")
                    return@execute
                }
                
                val firestore = FirebaseFirestore.getInstance()
                
                // Try to get current location for initial document
                val locationManager = this@LocationForegroundService.locationManager
                var initialLat = 0.0
                var initialLng = 0.0
                
                try {
                    val lastKnownLocation = locationManager?.getLastKnownLocation(LocationManager.GPS_PROVIDER)
                        ?: locationManager?.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
                    
                    if (lastKnownLocation != null) {
                        initialLat = lastKnownLocation.latitude
                        initialLng = lastKnownLocation.longitude
                        Log.d(TAG, "Using last known location: lat=$initialLat, lng=$initialLng")
                    }
                } catch (e: SecurityException) {
                    Log.w(TAG, "No permission to get last known location", e)
                }
                
                val trackingData = hashMapOf(
                    "route_id" to routeId,
                    "driver_id" to driverId,
                    "latitude" to String.format("%.4f", initialLat).toDouble(),
                    "longitude" to String.format("%.4f", initialLng).toDouble(),
                    "started_at" to com.google.firebase.Timestamp.now(),
                    "updated_at" to com.google.firebase.Timestamp.now(),
                    "is_active" to true
                )
                
                firestore.collection("live_tracking")
                    .document(routeId)
                    .set(trackingData, com.google.firebase.firestore.SetOptions.merge())
                    .addOnSuccessListener {
                        Log.d(TAG, "✅ Initial tracking document created in Firestore: route=$routeId")
                    }
                    .addOnFailureListener { e ->
                        Log.e(TAG, "❌ Error creating initial Firestore document", e)
                    }
            } catch (e: Exception) {
                Log.e(TAG, "Exception creating initial Firestore document", e)
            }
        }
    }
    
    private fun updateLocationToFirestore(location: Location) {
        val currentRouteId = routeId ?: run {
            Log.w(TAG, "⚠️ Cannot update Firestore: routeId is null")
            return
        }
        val currentDriverId = driverId ?: run {
            Log.w(TAG, "⚠️ Cannot update Firestore: driverId is null")
            return
        }
        
        // Log location update
        Log.d(TAG, "═══════════════════════════════════════════════════════")
        Log.d(TAG, "📍 LOCATION UPDATE (Native Service)")
        Log.d(TAG, "📍 Lat: ${location.latitude}")
        Log.d(TAG, "📍 Lng: ${location.longitude}")
        Log.d(TAG, "📍 Accuracy: ${location.accuracy}m")
        Log.d(TAG, "📍 Speed: ${location.speed}m/s")
        Log.d(TAG, "📍 Heading: ${location.bearing}°")
        Log.d(TAG, "📍 RouteId: $currentRouteId")
        Log.d(TAG, "📍 DriverId: $currentDriverId")
        Log.d(TAG, "═══════════════════════════════════════════════════════")
        
        executorService?.execute {
            try {
                // Check and initialize Firebase if needed
                val firebaseApps = FirebaseApp.getApps(this@LocationForegroundService)
                if (firebaseApps.isEmpty()) {
                    Log.w(TAG, "⚠️ Firebase not initialized, attempting to initialize...")
                    try {
                        FirebaseApp.initializeApp(this@LocationForegroundService)
                        Log.d(TAG, "✅ Firebase initialized successfully in native service")
                    } catch (initError: Exception) {
                        Log.e(TAG, "❌ Failed to initialize Firebase: ${initError.message}", initError)
                        Log.e(TAG, "❌ Stack trace: ${initError.stackTraceToString()}")
                        return@execute
                    }
                } else {
                    Log.d(TAG, "✅ Firebase already initialized (${firebaseApps.size} app(s))")
                }
                
                val firestore = FirebaseFirestore.getInstance()
                Log.d(TAG, "📝 Preparing Firestore update...")
                
                val locationData = hashMapOf(
                    "route_id" to currentRouteId,
                    "driver_id" to currentDriverId,
                    "latitude" to String.format("%.4f", location.latitude).toDouble(),
                    "longitude" to String.format("%.4f", location.longitude).toDouble(),
                    "accuracy" to location.accuracy,
                    "speed" to location.speed,
                    "heading" to location.bearing,
                    "location_timestamp" to com.google.firebase.Timestamp.now(),
                    "updated_at" to com.google.firebase.Timestamp.now(),
                    "is_active" to true
                )
                
                Log.d(TAG, "📝 Writing to Firestore: collection=live_tracking, document=$currentRouteId")
                firestore.collection("live_tracking")
                    .document(currentRouteId)
                    .set(locationData, com.google.firebase.firestore.SetOptions.merge())
                    .addOnSuccessListener {
                        Log.d(TAG, "✅ Location updated to Firestore successfully: route=$currentRouteId")
                        Log.d(TAG, "✅ Lat: ${location.latitude}, Lng: ${location.longitude}")
                    }
                    .addOnFailureListener { e ->
                        Log.e(TAG, "❌ Error updating Firestore", e)
                        Log.e(TAG, "❌ Error message: ${e.message}")
                        Log.e(TAG, "❌ Error cause: ${e.cause}")
                        Log.e(TAG, "❌ Stack trace: ${e.stackTraceToString()}")
                    }
            } catch (e: Exception) {
                Log.e(TAG, "❌ Exception updating Firestore", e)
                Log.e(TAG, "❌ Exception message: ${e.message}")
                Log.e(TAG, "❌ Stack trace: ${e.stackTraceToString()}")
            }
        }
    }
    
    private fun updateTrackingStatus(routeId: String, isActive: Boolean) {
        executorService?.execute {
            try {
                if (FirebaseApp.getApps(this@LocationForegroundService).isEmpty()) {
                    return@execute
                }
                
                val firestore = FirebaseFirestore.getInstance()
                val updateData = hashMapOf<String, Any>(
                    "is_active" to isActive,
                    "updated_at" to com.google.firebase.Timestamp.now()
                )
                
                if (!isActive) {
                    updateData["stopped_at"] = com.google.firebase.Timestamp.now()
                }
                
                firestore.collection("live_tracking")
                    .document(routeId)
                    .update(updateData)
                    .addOnSuccessListener {
                        Log.d(TAG, "Tracking status updated: route=$routeId, active=$isActive")
                    }
                    .addOnFailureListener { e ->
                        Log.e(TAG, "Error updating tracking status", e)
                    }
            } catch (e: Exception) {
                Log.e(TAG, "Exception updating tracking status", e)
            }
        }
    }
    
    fun isTracking(): Boolean = isTracking
}

