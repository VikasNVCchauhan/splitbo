// app/lib/src/app/app_bootstrap.dart
//
// Runs before runApp. Initialises Firebase and returns ProviderScope overrides.
// Keeping this in a separate file makes main.dart testable with a mock bootstrap.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../firebase_options.dart';

abstract final class AppBootstrap {
  static Future<List<Override>> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Return any provider overrides needed at startup (e.g. seeded auth state).
    return const [];
  }
}
