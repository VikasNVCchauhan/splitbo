import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.65)),
    );
    _ctrl.forward();
    _launch();
  }

  Future<void> _launch() async {
    await Future.wait([
      _precache(),
      Future.delayed(const Duration(milliseconds: 1500)),
    ]);
    if (mounted) context.go('/auth/sign-in');
  }

  Future<void> _precache() async {
    final ctx = context;
    await Future.wait([
      precacheImage(const AssetImage('assets/images/login_cards.png'), ctx),
      precacheImage(const AssetImage('assets/images/face_18.jpg'), ctx),
      precacheImage(const AssetImage('assets/images/face_19.jpg'), ctx),
      precacheImage(const AssetImage('assets/images/face_20.jpg'), ctx),
    ]);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: const SplitboLogoMark(size: 88),
            ),
          ),
        ),
      ),
    );
  }
}
