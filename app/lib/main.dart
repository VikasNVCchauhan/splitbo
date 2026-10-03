import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/splitbo_app.dart';
import 'src/app/app_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Warm up login assets — bytes cached before runApp so first render is instant
  rootBundle.load('assets/images/login_cards.png');
  rootBundle.load('packages/design_system/assets/images/logo_icon.svg');

  final overrides = await AppBootstrap.init();

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const SplitboApp(),
    ),
  );
}
