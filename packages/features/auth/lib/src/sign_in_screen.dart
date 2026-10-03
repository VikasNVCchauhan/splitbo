import 'dart:math' as math;

import 'package:data/data.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Brand tokens
const _green = Color(0xFF9CD246);
const _black = Color(0xFF000000);

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _loading = false;
  int _googleAttempts = 0;
  DateTime? _lockoutUntil;

  bool get _isLockedOut =>
      _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);

  Future<void> _signIn() async {
    if (_isLockedOut) {
      final secs = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      _toast('Too many attempts. Try again in ${secs}s.');
      return;
    }
    _googleAttempts++;
    if (_googleAttempts > 3) {
      _lockoutUntil = DateTime.now().add(const Duration(seconds: 60));
      _toast('Too many attempts. Locked for 60 seconds.');
      return;
    }
    setState(() => _loading = true);
    final result = await ref.read(authRepositoryProvider).signInWithGoogle();
    if (mounted) {
      setState(() => _loading = false);
      result.fold(
        ok: (_) {},
        err: (err) => _toast(err.message),
      );
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF1A1A1A),
    ));
  }

  void _showEmailSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: const _EmailSignInSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _black,
      body: Stack(
        children: [
          // Green ambient glow — top-left
          Positioned(
            top: -140, left: -100,
            child: Container(
              width: 360, height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withOpacity(0.14),
              ),
            ),
          ),
          // Green ambient glow — bottom-right
          Positioned(
            bottom: -100, right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withOpacity(0.10),
              ),
            ),
          ),

          // Main content — constrained + centered for web
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 36),

                      // ── Logo: vector icon + SplitBo wordmark ─────────────
                      const Center(
                        child: Column(
                          children: [
                            _SplitboIcon(size: 72),
                            SizedBox(height: 10),
                            Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                  text: 'Split',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    height: 1,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Bo',
                                  style: TextStyle(
                                    color: _green,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                    height: 1,
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tagline
                      const Text(
                        'Split bills. Keep friends.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFAAAAAA),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Expense card fan illustration ────────────────────
                      const _CardFan(),
                      const SizedBox(height: 16),

                      const Text(
                        'Share expenses, not stress.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Get Started ──────────────────────────────────────
                      if (_loading)
                        const Center(
                          child: CircularProgressIndicator(
                              color: _green, strokeWidth: 2.5),
                        )
                      else
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLockedOut ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.black,
                              disabledBackgroundColor:
                                  _green.withOpacity(0.4),
                              elevation: 0,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // ── Sign In (outlined) ───────────────────────────────
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _showEmailSheet,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF444444), width: 1.5),
                            shape: const StadiumBorder(),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Fine print
                      const Text(
                        'Better splits. Brighter relationships.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── SplitBo icon (vector, no background) ─────────────────────────────────────
class _SplitboIcon extends StatelessWidget {
  const _SplitboIcon({this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SplitboIconPainter(),
    );
  }
}

class _SplitboIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = _green
      ..style = PaintingStyle.fill;

    // Top dot — person head
    canvas.drawCircle(Offset(s.width * 0.28, s.height * 0.20), s.width * 0.11, p);

    // Diagonal bar
    canvas.save();
    canvas.translate(s.width * 0.50, s.height * 0.50);
    canvas.rotate(-0.55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset.zero,
            width: s.width * 0.82,
            height: s.width * 0.25),
        Radius.circular(s.width * 0.10),
      ),
      p,
    );
    canvas.restore();

    // Bottom outer circle
    canvas.drawCircle(Offset(s.width * 0.72, s.height * 0.78), s.width * 0.19, p);
    // Hole — cut with background colour
    canvas.drawCircle(
      Offset(s.width * 0.72, s.height * 0.78),
      s.width * 0.09,
      Paint()..color = _black..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Fanned expense card illustration ─────────────────────────────────────────
// Three white cards rotated to fan out, matching the brand reference.
class _CardFan extends StatelessWidget {
  const _CardFan();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth.clamp(0.0, 380.0);
      final cardW = w * 0.72;
      final fanH = cardW * 0.55;

      return Center(
        child: SizedBox(
          width: w,
          height: fanH + 30,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Left card — rotated CCW
              Positioned(
                bottom: 0,
                left: w * 0.0,
                child: Transform.rotate(
                  angle: -0.22,
                  alignment: Alignment.bottomCenter,
                  child: _ExpenseCard(
                    width: cardW,
                    height: fanH,
                    avatarColor: const Color(0xFF7B9ED9),
                    title: 'Apartment',
                    amount: '₹12,000',
                    members: const [
                      Color(0xFF7B9ED9),
                      Color(0xFFD97B7B),
                      Color(0xFF7BD9A5),
                    ],
                  ),
                ),
              ),
              // Right card — rotated CW
              Positioned(
                bottom: 0,
                right: w * 0.0,
                child: Transform.rotate(
                  angle: 0.22,
                  alignment: Alignment.bottomCenter,
                  child: _ExpenseCard(
                    width: cardW,
                    height: fanH,
                    avatarColor: const Color(0xFFD9A87B),
                    title: 'Dinner',
                    amount: '₹2,400',
                    members: const [
                      Color(0xFFD9A87B),
                      Color(0xFF7BC4D9),
                    ],
                  ),
                ),
              ),
              // Centre card — straight, on top
              _ExpenseCard(
                width: cardW,
                height: fanH,
                avatarColor: _green,
                title: 'Road Trip',
                amount: '₹6,300',
                members: const [
                  Color(0xFF9CD246),
                  Color(0xFF7B9ED9),
                  Color(0xFFD97B7B),
                ],
                elevated: true,
              ),

              // Spark left
              Positioned(
                top: 0,
                left: w * 0.04,
                child: const _Spark(),
              ),
              // Spark right
              Positioned(
                top: 4,
                right: w * 0.04,
                child: Transform(
                  transform: Matrix4.rotationY(math.pi),
                  alignment: Alignment.center,
                  child: const _Spark(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.width,
    required this.height,
    required this.avatarColor,
    required this.title,
    required this.amount,
    required this.members,
    this.elevated = false,
  });

  final double width;
  final double height;
  final Color avatarColor;
  final String title;
  final String amount;
  final List<Color> members;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final avatarR = height * 0.28;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.06, vertical: height * 0.14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(width * 0.06),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(elevated ? 0.35 : 0.20),
            blurRadius: elevated ? 24 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: avatarR * 2,
            height: avatarR * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor,
            ),
            child: Icon(Icons.person_rounded,
                color: Colors.white, size: avatarR * 1.2),
          ),
          SizedBox(width: width * 0.04),
          // Title + member dots
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF111111),
                    fontSize: height * 0.18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: height * 0.06),
                Row(
                  children: members
                      .map((c) => Container(
                            width: height * 0.14,
                            height: height * 0.14,
                            margin: const EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: c),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            amount,
            style: TextStyle(
              color: const Color(0xFF111111),
              fontSize: height * 0.19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Green spark ───────────────────────────────────────────────────────────────
class _Spark extends StatelessWidget {
  const _Spark();

  @override
  Widget build(BuildContext context) {
    const c = _green;
    const r = BorderRadius.all(Radius.circular(2));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: 3, height: 16,
            decoration: const BoxDecoration(color: c, borderRadius: r)),
        const SizedBox(height: 4),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 18, height: 3,
              decoration: const BoxDecoration(color: c, borderRadius: r)),
          const SizedBox(width: 4),
          Container(
              width: 10, height: 3,
              decoration: const BoxDecoration(color: c, borderRadius: r)),
        ]),
        const SizedBox(height: 4),
        Container(
            width: 3, height: 10,
            decoration: const BoxDecoration(color: c, borderRadius: r)),
      ],
    );
  }
}

// ── Email magic-link sheet ────────────────────────────────────────────────────
class _EmailSignInSheet extends ConsumerStatefulWidget {
  const _EmailSignInSheet();

  @override
  ConsumerState<_EmailSignInSheet> createState() => _EmailSignInSheetState();
}

class _EmailSignInSheetState extends ConsumerState<_EmailSignInSheet> {
  final _emailCtrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;
  int _attempts = 0;
  static const _maxAttempts = 3;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_attempts >= _maxAttempts) {
      _toast('Too many attempts. Please try Google sign-in.');
      return;
    }
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _toast('Enter a valid email address.');
      return;
    }
    _attempts++;
    setState(() => _sending = true);
    final result =
        await ref.read(authRepositoryProvider).sendEmailSignInLink(email);
    if (!mounted) return;
    setState(() => _sending = false);
    result.fold(
      ok: (_) => setState(() => _sent = true),
      err: (err) => _toast(err.message),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF1A1A1A),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_sent) ...[
              const Icon(Icons.mark_email_read_outlined,
                  color: _green, size: 52),
              const SizedBox(height: 16),
              const Text('Check your email',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'We sent a sign-in link to ${_emailCtrl.text.trim()}.\nTap it to sign in — no password needed.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFFAAAAAA), fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _sent = false;
                      _emailCtrl.clear();
                    }),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF444444)),
                      shape: const StadiumBorder(),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Use a different email'),
                  ),
                ),
              ),
            ] else ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sign in with Email',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "We'll send a one-tap sign-in link. No password needed.",
                    style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'you@example.com',
                    hintStyle: TextStyle(color: Color(0xFF555555)),
                    prefixIcon: Icon(Icons.email_outlined,
                        color: Color(0xFF555555), size: 20),
                    filled: true,
                    fillColor: Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Color(0xFF333333)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Color(0xFF333333)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: _green),
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_sending || _attempts >= _maxAttempts)
                        ? null
                        : _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: _green.withOpacity(0.3),
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black))
                        : const Text('Send Sign-In Link',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              if (_attempts >= _maxAttempts)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Max attempts reached. Please use Google sign-in.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
                  ),
                ),
            ],
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
