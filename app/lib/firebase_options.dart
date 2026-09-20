// app/lib/firebase_options.dart
// GENERATED from Firebase Console config — do not edit manually.
// To update: get new config from Firebase Console → Project Settings → Your apps → Config
//
// iOS/Android configs: add those apps in Firebase Console, then update the
// android and ios sections below with values from their GoogleService-Info.plist
// and google-services.json files.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios; // macOS uses same config as iOS
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for: $defaultTargetPlatform',
        );
    }
  }

  // ── Web ───────────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDLWgzUy_UYUcyg0Rp5RBO-lxQMmpM10WU',
    appId: '1:715213443351:web:914a3fef97f02c14382752',
    messagingSenderId: '715213443351',
    projectId: 'splitbo',
    authDomain: 'splitbo.firebaseapp.com',
    storageBucket: 'splitbo.firebasestorage.app',
    measurementId: 'G-8BS7GLRQP9',
  );

  // ── Android ───────────────────────────────────────────────────────────────
  // TODO: Add Android app in Firebase Console → + Add app → Android
  // Bundle ID: com.splitbo.app
  // Download google-services.json → place in app/android/app/
  // Then update these values from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER_ADD_ANDROID_APP_IN_FIREBASE_CONSOLE',
    appId: 'PLACEHOLDER',
    messagingSenderId: '715213443351',
    projectId: 'splitbo',
    storageBucket: 'splitbo.firebasestorage.app',
  );

  // ── iOS ───────────────────────────────────────────────────────────────────
  // TODO: Add iOS app in Firebase Console → + Add app → iOS
  // Bundle ID: com.splitbo.app
  // Download GoogleService-Info.plist → place in app/ios/Runner/
  // Then update these values from GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER_ADD_IOS_APP_IN_FIREBASE_CONSOLE',
    appId: 'PLACEHOLDER',
    messagingSenderId: '715213443351',
    projectId: 'splitbo',
    storageBucket: 'splitbo.firebasestorage.app',
    iosClientId: 'PLACEHOLDER',
    iosBundleId: 'com.splitbo.app',
  );
}
