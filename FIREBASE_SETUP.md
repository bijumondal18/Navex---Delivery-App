# Firebase Setup Instructions

This document provides step-by-step instructions to complete Firebase integration for the Navex Delivery App.

## Prerequisites

1. A Firebase account (create one at https://firebase.google.com/)
2. Flutter CLI installed
3. Android Studio / Xcode installed

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "Navex Delivery App" (or your preferred name)
4. Follow the setup wizard
5. Enable Google Analytics (optional but recommended)

## Step 2: Add Android App to Firebase

1. In Firebase Console, click "Add app" → Android
2. Enter Android package name: `com.navex.navex`
3. Enter app nickname: "Navex Android" (optional)
4. Download `google-services.json`
5. Place `google-services.json` in `android/app/` directory

**Important:** The `google-services.json` file should be at:
```
android/app/google-services.json
```

**⚠️ CRITICAL:** After adding `google-services.json`, you MUST:
1. Clean the project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Rebuild the app: `flutter run`

The Google Services plugin will process `google-services.json` during build and generate the required `values.xml` file automatically.

## Step 3: Add iOS App to Firebase

1. In Firebase Console, click "Add app" → iOS
2. Enter iOS bundle ID: Check your `ios/Runner.xcodeproj` or `Info.plist` for the bundle identifier
3. Enter app nickname: "Navex iOS" (optional)
4. Download `GoogleService-Info.plist`
5. Open Xcode and add `GoogleService-Info.plist` to the `ios/Runner/` directory
6. In Xcode, make sure `GoogleService-Info.plist` is added to the Runner target

**Important:** The `GoogleService-Info.plist` file should be at:
```
ios/Runner/GoogleService-Info.plist
```

## Step 4: Enable Firebase Services

### Cloud Messaging (FCM)
1. In Firebase Console, go to "Cloud Messaging"
2. The service is automatically enabled when you add the app

### Cloud Firestore (if needed)
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database

## Step 5: Install Firebase CLI (Optional)

For easier management, you can install Firebase CLI:
```bash
npm install -g firebase-tools
firebase login
```

## Step 6: Verify Installation

1. Run the app:
   ```bash
   flutter run
   ```

2. Check the console logs for:
   - `FCM token: [your-token]` - This confirms Firebase Messaging is working
   - No Firebase initialization errors

## Step 7: Test Push Notifications

### Using Firebase Console:
1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Click "Send test message"
5. Enter your FCM token (from app logs)
6. Click "Test"

### Using cURL:
```bash
curl -X POST https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "YOUR_FCM_TOKEN",
      "notification": {
        "title": "Test Notification",
        "body": "This is a test message"
      }
    }
  }'
```

## Troubleshooting

### Android Issues:

1. **Build Error: "google-services.json not found"**
   - Ensure `google-services.json` is in `android/app/` directory
   - Clean and rebuild: `flutter clean && flutter pub get && flutter run`

2. **Gradle Sync Failed**
   - Check that `com.google.gms.google-services` plugin is added in `build.gradle.kts`
   - Ensure Google Services classpath is in project-level `build.gradle.kts`

### iOS Issues:

1. **Build Error: "GoogleService-Info.plist not found"**
   - Ensure `GoogleService-Info.plist` is added to Xcode project
   - Check that it's included in the Runner target

2. **Push Notifications Not Working**
   - Enable Push Notifications capability in Xcode
   - Ensure APNs certificates are configured in Firebase Console
   - Check that background modes include "Remote notifications"

### General Issues:

1. **Firebase Initialization Error**
   - Verify configuration files are in correct locations
   - Check that package name/bundle ID matches Firebase project
   - Ensure internet connection is available

2. **FCM Token Not Generated**
   - Check app permissions (especially on iOS)
   - Verify Firebase initialization completed successfully
   - Check console logs for error messages

## Additional Resources

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Cloud Messaging Guide](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Setup](https://firebase.flutter.dev/docs/overview)

## Current Firebase Features Enabled

✅ Firebase Core
✅ Firebase Cloud Messaging (FCM)
✅ Firebase Cloud Firestore
✅ Push Notifications (Foreground & Background)
✅ Notification Routing

## Next Steps

After completing setup, you can:
1. Send push notifications from your backend
2. Store data in Cloud Firestore
3. Implement analytics tracking
4. Set up remote config
5. Add crash reporting

