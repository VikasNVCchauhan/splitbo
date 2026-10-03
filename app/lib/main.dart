import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/splitbo_app.dart';
import 'src/app/app_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start loading the login card image bytes immediately — by the time
  // the login screen renders, the bytes are already in the bundle cache.
  rootBundle.load('assets/images/login_cards.png');

  final overrides = await AppBootstrap.init();

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const SplitboApp(),
    ),
  );
}
