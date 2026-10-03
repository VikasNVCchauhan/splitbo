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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/login_cards.png'), context);
  }

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
          // Ambient glow — top-left
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
          // Ambient glow — bottom-right
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

          // Main content — single scale factor so everything fits any screen
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // One number scales every element. Base design = 750px tall.
                // Phone 600px → scale 0.8. Laptop 1000px → scale 1.33.
                final s = (constraints.maxHeight / 750.0).clamp(0.55, 1.6);
                final contentW =
                    (constraints.maxWidth * 0.88).clamp(260.0, 480.0);

                return Center(
                  child: SizedBox(
                    width: contentW,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Logo ─────────────────────────────────────────────
                        Center(child: SplitboLogoMark(size: 90 * s)),
                        SizedBox(height: 8 * s),
                        Center(
                          child: Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                text: 'Split',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36 * s,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                ),
                              ),
                              TextSpan(
                                text: 'Bo',
                                style: TextStyle(
                                  color: _green,
                                  fontSize: 36 * s,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(height: 10 * s),

                        // Tagline
                        Text(
                          'Split bills. Keep friends.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFAAAAAA),
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 24 * s),

                        // ── Card illustration — Flutter widgets, instant render ─
                        _LoginCards(s: s),
                        SizedBox(height: 10 * s),

                        Text(
                          'Share expenses, not stress.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF888888),
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 28 * s),

                        // ── Get Started ───────────────────────────────────────
                        if (_loading)
                          const Center(
                            child: CircularProgressIndicator(
                                color: _green, strokeWidth: 2.5),
                          )
                        else
                          SizedBox(
                            height: 54 * s,
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
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 17 * s,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 8 * s),

                        // ── Sign In ───────────────────────────────────────────
                        TextButton(
                          onPressed: _showEmailSheet,
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Login card fan illustration ───────────────────────────────────────────────
class _LoginCards extends StatelessWidget {
  const _LoginCards({required this.s});
  final double s;

  @override
  Widget build(BuildContext context) {
    final cw = 272.0 * s;
    final ch = 74.0 * s;
    final totalH = ch * 2.8;
    final totalW = cw + 56 * s;

    return SizedBox(
      height: totalH,
      width: totalW,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0, top: 28 * s,
              child: _GreenSparks(s: s)),
          Positioned(right: 0, top: 10 * s,
              child: _GreenSparks(s: s, mirrored: true)),

          // Bottom — Apartment
          Positioned(
            bottom: 0, left: 24 * s,
            child: Transform.rotate(angle: 0.04,
              child: _LoginCard(
                s: s, w: cw, h: ch,
                avatarIcon: Icons.group_rounded,
                avatarColor: const Color(0xFF7B9ED9),
                title: 'Apartment',
                memberColors: const [Color(0xFF9CD246), Color(0xFF7B9ED9), Color(0xFFD97B7B)],
                extra: 3, splitAmt: '₹12,200', totalAmt: '₹12,000',
              )),
          ),

          // Middle
          Positioned(
            bottom: ch * 0.75, left: 16 * s,
            child: Transform.rotate(angle: -0.02,
              child: _LoginCard(
                s: s, w: cw, h: ch,
                avatarIcon: Icons.person_rounded,
                avatarColor: const Color(0xFF444444),
                title: null,
                secondIcon: Icons.shopping_bag_outlined,
                splitAmt: '₹700', totalAmt: '₹6,300',
              )),
          ),

          // Top — Dinner
          Positioned(
            top: 0, left: 8 * s,
            child: Transform.rotate(angle: -0.06,
              child: _LoginCard(
                s: s, w: cw, h: ch,
                avatarIcon: Icons.person_rounded,
                avatarColor: const Color(0xFF8EB5E8),
                title: 'Dinner',
                memberColors: const [Color(0xFF8EB5E8), Color(0xFFE8A08E), Color(0xFF9CD246)],
                extra: 2, splitAmt: '₹400', totalAmt: '₹2,400',
              )),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.s, required this.w, required this.h,
    required this.avatarIcon, required this.avatarColor,
    this.title, this.secondIcon,
    this.memberColors = const [], this.extra = 0,
    required this.splitAmt, required this.totalAmt,
  });

  final double s, w, h;
  final IconData avatarIcon;
  final Color avatarColor;
  final String? title;
  final IconData? secondIcon;
  final List<Color> memberColors;
  final int extra;
  final String splitAmt, totalAmt;

  @override
  Widget build(BuildContext context) {
    final av = h * 0.66;
    final dot = h * 0.20;

    return Container(
      width: w, height: h,
      padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(w * 0.055),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.13),
            blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        // Avatar
        Container(
          width: av, height: av,
          decoration: BoxDecoration(shape: BoxShape.circle, color: avatarColor),
          child: Icon(avatarIcon, color: Colors.white, size: av * 0.58),
        ),
        if (secondIcon != null) ...[
          SizedBox(width: 4 * s),
          Container(
            width: av * 0.78, height: av * 0.78,
            decoration: BoxDecoration(shape: BoxShape.circle,
                color: _green.withOpacity(0.12)),
            child: Icon(secondIcon, color: _green, size: av * 0.44),
          ),
        ],
        SizedBox(width: 8 * s),

        // Title + member dots
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (title != null)
              Text(title!, style: TextStyle(color: const Color(0xFF111111),
                  fontSize: h * 0.22, fontWeight: FontWeight.w700)),
            if (memberColors.isNotEmpty) ...[
              if (title != null) SizedBox(height: 3 * s),
              Row(mainAxisSize: MainAxisSize.min, children: [
                ...memberColors.map((c) => Container(
                  width: dot, height: dot,
                  margin: EdgeInsets.only(right: 2 * s),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c),
                )),
                if (extra > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4 * s),
                    height: dot,
                    decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(dot)),
                    child: Center(child: Text('+$extra',
                      style: TextStyle(color: Colors.black,
                          fontSize: dot * 0.62, fontWeight: FontWeight.w800))),
                  ),
              ]),
            ],
          ],
        )),

        // Amounts
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(splitAmt, style: TextStyle(color: const Color(0xFF888888),
                fontSize: h * 0.16, fontWeight: FontWeight.w500)),
            SizedBox(height: 2 * s),
            Text(totalAmt, style: TextStyle(color: const Color(0xFF111111),
                fontSize: h * 0.26, fontWeight: FontWeight.w800)),
          ],
        ),
      ]),
    );
  }
}

class _GreenSparks extends StatelessWidget {
  const _GreenSparks({required this.s, this.mirrored = false});
  final double s;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(2 * s);
    Widget w = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 3 * s, height: 16 * s,
            decoration: BoxDecoration(color: _green, borderRadius: r)),
        SizedBox(height: 4 * s),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 18 * s, height: 3 * s,
              decoration: BoxDecoration(color: _green, borderRadius: r)),
          SizedBox(width: 4 * s),
          Container(width: 10 * s, height: 3 * s,
              decoration: BoxDecoration(color: _green, borderRadius: r)),
        ]),
        SizedBox(height: 4 * s),
        Container(width: 3 * s, height: 10 * s,
            decoration: BoxDecoration(color: _green, borderRadius: r)),
      ],
    );
    if (!mirrored) return w;
    return Transform(
      transform: Matrix4.rotationY(3.14159),
      alignment: Alignment.center,
      child: w,
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
