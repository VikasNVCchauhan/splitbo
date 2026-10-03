import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// True while user is browsing without signing in (tapped "Skip" on login).
/// Cleared automatically when auth state resolves to a real user.
final guestModeProvider = StateProvider<bool>((ref) => false);
