import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    final result = await ref.read(authRepositoryProvider).signInWithGoogle();
    if (mounted) {
      setState(() => _loading = false);
      result.fold(
        ok: (_) {},
        err: (err) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.message),
            backgroundColor: const Color(0xFF1A1A1A),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Real logo image (mark + wordmark on black bg) ──
              Image.asset(
                'assets/images/logo_full.jpg',
                width: 240,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 10),
              const Text(
                'Split bills. Keep friends.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF9E9E9E),
                  letterSpacing: 0.1,
                ),
              ),

              const Spacer(flex: 2),

              // ── Buttons ────────────────────────────────────────
              if (_loading)
                const CircularProgressIndicator(
                  color: Color(0xFFC3FD00),
                  strokeWidth: 2.5,
                )
              else ...[
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC3FD00),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: _signIn,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                          color: Color(0xFF2C2C2C), width: 1.5),
                      shape: const StadiumBorder(),
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
              ],

              const Spacer(flex: 2),

              // ── Receipt illustration ───────────────────────────
              const _ReceiptIllustration(),

              const SizedBox(height: 16),
              const Text(
                'Good people split everything better.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9E9E9E),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Receipt illustration ──────────────────────────────────────────────────────
class _ReceiptIllustration extends StatelessWidget {
  const _ReceiptIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Receipt card
          Container(
            width: 62,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  if (i < 2) const SizedBox(height: 5),
                ],
                const SizedBox(height: 8),
                const Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF424242),
                  ),
                ),
              ],
            ),
          ),

          // Spark marks
          const Positioned(
            top: 0,
            left: 90,
            child: Text('/',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFC3FD00))),
          ),
          const Positioned(
            top: 12,
            left: 100,
            child: Text('/',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFC3FD00))),
          ),
          const Positioned(
            top: 0,
            right: 90,
            child: Text('\\',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFC3FD00))),
          ),
          const Positioned(
            top: 12,
            right: 100,
            child: Text('\\',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFC3FD00))),
          ),

          // Left avatars
          Positioned(
            left: 20,
            top: 6,
            child: _avatar(const Color(0xFF4CAF50), 40),
          ),
          Positioned(
            left: 14,
            bottom: 2,
            child: _avatar(const Color(0xFFFF9800), 34),
          ),

          // Right avatar
          Positioned(
            right: 20,
            top: 6,
            child: _avatar(const Color(0xFF2196F3), 40),
          ),
        ],
      ),
    );
  }

  Widget _avatar(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Icon(Icons.person, size: size * 0.55, color: Colors.white),
    );
  }
}

// ── SplitBo logo mark painter — mirrors logo_mark.svg (viewBox 0 0 512 512) ──
class SplitboMarkPainter extends CustomPainter {
  final Color color;
  const SplitboMarkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 512;
    final p = Paint()..color = color..style = PaintingStyle.fill;

    // Dot
    canvas.drawCircle(Offset(178 * s, 120 * s), 48 * s, p);

    // Blade
    final blade = Path()
      ..moveTo(166 * s, 218 * s)
      ..cubicTo(105 * s, 275 * s, 100 * s, 324 * s, 154 * s, 378 * s)
      ..cubicTo(192 * s, 416 * s, 246 * s, 364 * s, 290 * s, 320 * s)
      ..lineTo(426 * s, 184 * s)
      ..lineTo(426 * s, 84 * s)
      ..lineTo(326 * s, 84 * s)
      ..close();
    canvas.drawPath(blade, p);

    // Crescent with evenodd hole (center 288,368 r=38)
    final crescent = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(346 * s, 294 * s)
      ..cubicTo(407 * s, 237 * s, 412 * s, 188 * s, 358 * s, 134 * s)
      ..cubicTo(320 * s, 96 * s, 266 * s, 148 * s, 222 * s, 192 * s)
      ..lineTo(86 * s, 328 * s)
      ..lineTo(86 * s, 428 * s)
      ..lineTo(186 * s, 428 * s)
      ..close();
    crescent.addOval(
        Rect.fromCircle(center: Offset(288 * s, 368 * s), radius: 38 * s));
    canvas.drawPath(crescent, p);
  }

  @override
  bool shouldRepaint(covariant SplitboMarkPainter old) => old.color != color;
}
