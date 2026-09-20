// app/lib/main.dart
//
// Entry point. Order of operations:
//   1. Flutter binding + error handlers
//   2. Firebase (lazily wired via ProviderScope overrides in app_bootstrap.dart)
//   3. ProviderScope wraps the whole tree — all Riverpod providers live here
//   4. go_router is a provider so it can read auth state reactively

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/splitbo_app.dart';
import 'src/app/app_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final overrides = await AppBootstrap.init();

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const SplitboApp(),
    ),
  );
}
