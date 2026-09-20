// app/lib/src/app/app_bootstrap.dart
//
// Runs before runApp. Initialises Firebase and returns ProviderScope overrides.
// Keeping this in a separate file makes main.dart testable with a mock bootstrap.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../firebase_options.dart';

// Background message handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handling is done by the service worker on web.
  // On mobile this would show a local notification.
}

abstract final class AppBootstrap {
  // Get this from Firebase Console → Project Settings → Cloud Messaging
  // → Web Push certificates → Generate key pair
  static const _vapidKey =
      'BFbCEVSwBnNlXWvHAiFOFGqH7fE4aSs2PXJkIPaZvFxXSTxEz_kW5Av7AZ8SxME8L9YxRe9VjHNOFSwWZf4Dn2Y';

  static Future<List<Override>> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (web shows browser prompt; mobile shows OS dialog)
    if (kIsWeb) {
      try {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        if (kDebugMode) {
          debugPrint('FCM permission: ${settings.authorizationStatus}');
        }
      } catch (_) {
        // Permission denied or browser doesn't support notifications — silent fail
      }
    }

    return const [];
  }

  /// Returns the FCM token for this device/browser, or null if unavailable.
  static Future<String?> getFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken(vapidKey: _vapidKey);
    } catch (_) {
      return null;
    }
  }
}
