import 'package:data/data.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _green = Color(0xFFC3FD00);
const _dark = Color(0xFF0A0A0A);

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
      backgroundColor: const Color(0xFF2A2A2A),
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
      backgroundColor: _dark,
      body: Stack(
        children: [
          // Green glow top-left
          Positioned(
            top: -120, left: -80,
            child: Container(
              width: 320, height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withOpacity(0.15),
              ),
            ),
          ),
          // Green glow bottom-right
          Positioned(
            bottom: -80, right: -60,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withOpacity(0.10),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Full stacked logo (icon + SplitBo wordmark)
                  Center(
                    child: Image.asset(
                      'assets/images/logo_full.jpg',
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tagline
                  const Text(
                    'Split bills. Keep friends.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Illustrated expense cards
                  const _ExpenseIllustration(),
                  const SizedBox(height: 28),

                  // Subtitle
                  const Text(
                    'Share expenses, not stress.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.1,
                    ),
                  ),

                  const Spacer(),

                  // Feature pills row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeaturePill(icon: Icons.bolt_rounded, label: 'Split'),
                      const SizedBox(width: 10),
                      _FeaturePill(icon: Icons.bar_chart_rounded, label: 'Track'),
                      const SizedBox(width: 10),
                      _FeaturePill(icon: Icons.sync_rounded, label: 'Settle'),
                      const SizedBox(width: 10),
                      _FeaturePill(icon: Icons.favorite_border_rounded, label: 'Together'),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Get Started button
                  if (_loading)
                    const Center(
                        child: CircularProgressIndicator(
                            color: _green, strokeWidth: 2.5))
                  else
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLockedOut ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: _green.withOpacity(0.4),
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
                  const SizedBox(height: 14),

                  // Continue with Email
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: _showEmailSheet,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF333333)),
                        shape: const StadiumBorder(),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF141414),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email_outlined, size: 18, color: Color(0xFFAAAAAA)),
                          SizedBox(width: 8),
                          Text(
                            'Continue with Email',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sign In link
                  GestureDetector(
                    onTap: _signIn,
                    child: const Text(
                      'Sign In',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: _green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Expense illustration ───────────────────────────────────────────────────────
class _ExpenseIllustration extends StatelessWidget {
  const _ExpenseIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back card (tilted left)
          Positioned(
            left: 20,
            top: 10,
            child: Transform.rotate(
              angle: -0.12,
              child: const _ExpenseCard(
                title: 'Apartment',
                amount: '₹12,000',
                members: 4,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ),
          // Front card (slightly tilted right)
          Positioned(
            right: 20,
            top: 0,
            child: Transform.rotate(
              angle: 0.08,
              child: const _ExpenseCard(
                title: 'Dinner',
                amount: '₹2,400',
                members: 3,
                color: Color(0xFF232323),
                accent: _green,
              ),
            ),
          ),
          // Center card (straight, on top)
          const _ExpenseCard(
            title: 'Road Trip',
            amount: '₹6,300',
            members: 5,
            color: Color(0xFF1A1A1A),
            elevated: true,
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.title,
    required this.amount,
    required this.members,
    required this.color,
    this.accent,
    this.elevated = false,
  });

  final String title;
  final String amount;
  final int members;
  final Color color;
  final Color? accent;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: elevated ? _green.withOpacity(0.4) : const Color(0xFF303030),
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: _green.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: (accent ?? const Color(0xFF444444)).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 14,
                  color: accent ?? Colors.white70,
                ),
              ),
              const Spacer(),
              Text(
                amount,
                style: TextStyle(
                  color: accent ?? Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              members.clamp(0, 4),
              (i) => Container(
                width: 18,
                height: 18,
                margin: EdgeInsets.only(right: i < members - 1 ? 3 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF444444),
                  border: Border.all(color: color, width: 1.5),
                ),
                child: const Icon(Icons.person, size: 10, color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature pill ──────────────────────────────────────────────────────────────
class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _green),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
      backgroundColor: const Color(0xFF2A2A2A),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
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
                    onPressed: () {
                      setState(() {
                        _sent = false;
                        _emailCtrl.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF333333)),
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
                  child: Text('Continue with Email',
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
                    'We\'ll send you a one-tap sign-in link. No password needed.',
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
                    hintStyle: TextStyle(color: Color(0xFF666666)),
                    prefixIcon: Icon(Icons.email_outlined,
                        color: Color(0xFF666666), size: 20),
                    filled: true,
                    fillColor: Color(0xFF1E1E1E),
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
                            width: 20, height: 20,
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
                    style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
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
