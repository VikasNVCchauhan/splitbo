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
  // ── Android ──────────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAkb6vPlJsVD8qLv-5DilP3acuZ7a5TxNo',
    appId: '1:715213443351:android:5f15bce55b147469382752',
    messagingSenderId: '715213443351',
    projectId: 'splitbo',
    storageBucket: 'splitbo.firebasestorage.app',
  );

  // ── iOS ───────────────────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqabp5A4UzE1HyQR8eO0jcHFDS_qzbBeI',
    appId: '1:715213443351:ios:efb3bc04c4ab70a7382752',
    messagingSenderId: '715213443351',
    projectId: 'splitbo',
    storageBucket: 'splitbo.firebasestorage.app',
    iosClientId: '715213443351-to1vueged5gov6schhqe52oqd5bpl91r.apps.googleusercontent.com',
    iosBundleId: 'com.splitbo.app',
  );
}
