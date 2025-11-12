# Firestore Document Creation Troubleshooting

## Issue: Document not created after login

If the Firestore document is not being created after login, check the following:

### 1. Check Console Logs

After logging in, look for these log messages in your console:

**Expected logs:**
```
🔐 Login successful. User ID: {userId}
📤 Attempting to save user to Firestore...
✅ Firebase is initialized
📝 Starting Firestore user document creation for user_id: {userId}
✅ User data found: name=..., email=...
📦 User data prepared: [list of keys]
💾 Writing to Firestore: users/{userId}
✅ User document created/updated successfully
✅ Timestamps updated successfully
✅ Firestore save completed
```

**If you see errors:**
- `❌ Firebase not initialized` → Firebase config files missing
- `❌ User data is null` → Login response doesn't contain user data
- `⚠️ Invalid user ID: 0` → User ID is 0 or invalid
- `❌ Error saving user to Firestore` → Check the error message

### 2. Verify Firebase Initialization

Check if Firebase is properly initialized in `main.dart`:
- Look for: `✅ Firebase initialization successful` (or similar)
- If you see: `⚠️ Firebase initialization failed` → Add config files

### 3. Check Firestore Security Rules

**Most Common Issue:** Firestore security rules might be blocking writes.

Go to Firebase Console → Firestore Database → Rules

**For Development (Temporary - NOT for production):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if true; // Allows all reads and writes
    }
  }
}
```

**For Production (Recommended):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Allow users to read/write their own document
      allow read, write: if request.auth != null && request.auth.uid == userId;
      // OR if you're not using Firebase Auth, allow based on your logic
      allow read, write: if true; // Only for testing - change this!
    }
  }
}
```

**Important:** After updating rules, click "Publish" in Firebase Console.

### 4. Verify User ID

Check if the user ID is valid:
- User ID should be > 0
- Check login response: `loginResponse.user?.id`

### 5. Check Network Connection

- Ensure device/emulator has internet connection
- Check if Firebase services are accessible

### 6. Verify Firestore is Enabled

1. Go to Firebase Console
2. Navigate to Firestore Database
3. Ensure database is created
4. Check if it's in "Production mode" or "Test mode"

### 7. Test Firestore Connection

Add this test code temporarily to verify Firestore works:

```dart
// Test Firestore write
try {
  await FirebaseFirestore.instance
      .collection('test')
      .doc('test123')
      .set({'test': 'value', 'timestamp': FieldValue.serverTimestamp()});
  print('✅ Test Firestore write successful');
} catch (e) {
  print('❌ Test Firestore write failed: $e');
}
```

### 8. Common Errors and Solutions

**Error: "Missing or insufficient permissions"**
- **Solution:** Update Firestore security rules (see #3)

**Error: "Firebase not initialized"**
- **Solution:** Ensure `google-services.json` is in `android/app/` and rebuild

**Error: "User data is null"**
- **Solution:** Check login API response structure

**Error: "Invalid user ID: 0"**
- **Solution:** Verify login response contains valid user ID

### 9. Debug Steps

1. **Check logs** - Look for all the emoji-prefixed log messages
2. **Verify Firebase** - Ensure Firebase is initialized
3. **Check Security Rules** - Most common issue
4. **Test Connection** - Use test code above
5. **Verify User ID** - Ensure it's not 0
6. **Check Firestore Console** - Manually check if document exists

### 10. Manual Verification

1. Go to Firebase Console → Firestore Database
2. Look for `users` collection
3. Check if document with user_id exists
4. If document exists but wasn't created on login, check `last_login` timestamp

### Still Not Working?

1. Share the complete console logs (all emoji-prefixed messages)
2. Check Firebase Console for any error messages
3. Verify Firestore security rules are published
4. Ensure `google-services.json` is correct and in the right location

