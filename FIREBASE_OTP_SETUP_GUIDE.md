# Firebase OTP Integration Setup Guide

## Overview

The OTP authentication system now uses **Firebase Phone Authentication** for production-ready SMS delivery. This provides:
- ✅ Reliable SMS delivery via Firebase
- ✅ Automatic OTP code generation and verification
- ✅ Built-in security features
- ✅ No need for third-party SMS providers
- ✅ Database validation (only admin-created users can log in)

## Architecture

### Hybrid Authentication Flow

```
1. User enters phone number
   ↓
2. App checks if phone exists in database (backend)
   ↓
3. If exists → Firebase sends OTP via SMS
   ↓
4. User enters OTP
   ↓
5. Firebase verifies OTP
   ↓
6. App fetches user data from database
   ↓
7. User logged in with role/permissions
```

## Firebase Setup Steps

### 1. Firebase Console Setup

1. **Go to [Firebase Console](https://console.firebase.google.com/)**
2. **Create a new project** (or use existing)
3. **Enable Phone Authentication:**
   - Go to **Authentication** → **Sign-in method**
   - Enable **Phone** provider
   - Add your app's SHA-1 fingerprint (for Android)
   - Configure reCAPTCHA (for web)

### 2. Android Setup

#### Step 1: Add Firebase to Android App

1. In Firebase Console, click **Add app** → **Android**
2. Enter your package name (e.g., `com.example.brick_bhatta_management_system`)
3. Download `google-services.json`
4. Place it in `android/app/` directory

#### Step 2: Update Android Gradle Files

**`android/build.gradle.kts`:**
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

**`android/app/build.gradle.kts`:**
```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Add this
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-auth")
}
```

#### Step 3: Get SHA-1 Fingerprint

```bash
# For debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For release keystore
keytool -list -v -keystore android/app/your-release-key.keystore -alias your-key-alias
```

Add SHA-1 to Firebase Console → Project Settings → Your Android App

### 3. iOS Setup

#### Step 1: Add Firebase to iOS App

1. In Firebase Console, click **Add app** → **iOS**
2. Enter your bundle ID
3. Download `GoogleService-Info.plist`
4. Add it to `ios/Runner/` in Xcode

#### Step 2: Update Podfile

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  pod 'Firebase/Auth'
  pod 'Firebase/Core'
end
```

Run:
```bash
cd ios
pod install
```

### 4. Update Firebase Options

Update `lib/firebase_options.dart` with your Firebase project credentials:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY',
  appId: 'YOUR_IOS_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  iosClientId: 'YOUR_IOS_CLIENT_ID',
  iosBundleId: 'com.example.brickBhattaManagementSystem',
);
```

**Or use FlutterFire CLI (Recommended):**
```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

This will automatically update `firebase_options.dart` with your project credentials.

### 5. Firebase Authentication Rules

In Firebase Console → Authentication → Settings:

1. **Authorized domains**: Add your backend domain (if needed)
2. **Phone numbers**: Enable for your region
3. **Quota**: Check your SMS quota limits

### 6. Backend Firebase Admin Setup

The backend already has Firebase Admin SDK configured. Ensure:

1. **Download service account key:**
   - Firebase Console → Project Settings → Service Accounts
   - Click "Generate new private key"
   - Save as `firebase-credentials.json`

2. **Set environment variable:**
   ```bash
   export FIREBASE_CREDENTIALS_PATH=/path/to/firebase-credentials.json
   ```

3. **Or place in project:**
   - Place `firebase-credentials.json` in `backend/` directory
   - Update `backend/app/dependencies.py` if needed

## Testing

### Development/Testing Mode

Firebase provides a **test phone number** for development:

1. Go to Firebase Console → Authentication → Sign-in method → Phone
2. Add test phone numbers (e.g., `+1 650-555-1234`)
3. Use test OTP code: `123456` (for test numbers only)

### Production Testing

1. Use real phone numbers
2. OTP will be sent via SMS
3. Enter the 6-digit code received

## Code Changes Summary

### Frontend (`lib/services/otp_service.dart`)

- ✅ `sendOtpWithFirebase()`: Uses Firebase Phone Auth to send OTP
- ✅ `verifyOtpWithFirebase()`: Verifies OTP with Firebase
- ✅ `getUserFromBackend()`: Fetches user data after Firebase auth
- ✅ `completeOtpFlow()`: Complete authentication flow

### Frontend (`lib/screens/login_screen.dart`)

- ✅ Updated to use Firebase Phone Auth
- ✅ Checks database before sending OTP
- ✅ Verifies OTP with Firebase
- ✅ Fetches user data from backend after verification

### Backend (`backend/app/routers/otp.py`)

- ✅ `/otp/check-phone`: Validates phone exists in database
- ✅ `/otp/get-user-by-phone`: Returns user data after Firebase auth
- ✅ Legacy endpoints kept for backward compatibility

## Security Features

1. **Database Validation**: Only admin-created users can receive OTP
2. **Firebase Security**: Firebase handles OTP generation and verification
3. **Rate Limiting**: Firebase has built-in rate limiting
4. **Account Status**: Inactive accounts are blocked
5. **Token Verification**: Backend can verify Firebase tokens

## Firebase Quota & Pricing

### Free Tier (Spark Plan)
- 10,000 verifications/month
- SMS costs: ~$0.06 per verification (varies by country)

### Blaze Plan (Pay as you go)
- First 10,000 verifications/month: Free
- Additional: Pay per SMS

**Note**: For production, monitor your usage and upgrade if needed.

## Troubleshooting

### Issue: "This app is not authorized to use Firebase Authentication"

**Solution**: 
- Add SHA-1 fingerprint to Firebase Console
- Ensure `google-services.json` is in correct location
- Rebuild the app

### Issue: "reCAPTCHA verification failed"

**Solution**:
- Ensure reCAPTCHA is configured in Firebase Console
- For Android, add SHA-1 fingerprint
- For web, configure authorized domains

### Issue: "SMS not received"

**Solution**:
- Check phone number format (must include country code)
- Verify Firebase quota hasn't been exceeded
- Check Firebase Console → Authentication → Usage for errors
- Ensure phone provider is enabled in Firebase Console

### Issue: "Invalid verification code"

**Solution**:
- OTP expires after a few minutes
- Request a new OTP
- Ensure you're entering the correct 6-digit code

### Issue: "Phone number not registered"

**Solution**:
- User must be created by admin first
- Check database for user with that phone number
- Ensure phone number format matches (with country code)

## Production Checklist

- [ ] Firebase project created and configured
- [ ] `google-services.json` added to Android app
- [ ] `GoogleService-Info.plist` added to iOS app
- [ ] SHA-1 fingerprints added to Firebase Console
- [ ] Phone authentication enabled in Firebase Console
- [ ] `firebase_options.dart` updated with correct credentials
- [ ] Firebase Admin SDK configured on backend
- [ ] Test with real phone numbers
- [ ] Monitor Firebase usage and quota
- [ ] Set up billing (if needed for Blaze plan)
- [ ] Configure reCAPTCHA for web (if applicable)

## Additional Resources

- [Firebase Phone Auth Documentation](https://firebase.google.com/docs/auth/android/phone-auth)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Pricing](https://firebase.google.com/pricing)

## Migration from Custom OTP

If you were using the custom backend OTP system:

1. ✅ Code is already updated to use Firebase
2. ✅ Legacy endpoints are kept for backward compatibility
3. ✅ Database validation still works
4. ✅ User data fetching remains the same

No additional migration steps needed - the system automatically uses Firebase for OTP delivery.

