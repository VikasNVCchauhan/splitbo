import 'package:data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _green = Color(0xFFC3FD00);
const _bg = Colors.black;
const _surface = Color(0xFF1A1A1A);
const _textSecondary = Color(0xFF9E9E9E);

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
            backgroundColor: _surface,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo + wordmark
              Image.asset(
                'assets/images/logo_full.jpg',
                width: 220,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              const Text(
                'Split bills. Keep friends.',
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                  letterSpacing: 0.1,
                ),
              ),

              const Spacer(flex: 2),

              // Stacked expense cards
              const _ExpenseCards(),
              const SizedBox(height: 14),
              const Text(
                'Share expenses, not stress.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                ),
              ),

              const Spacer(flex: 2),

              // Buttons
              if (_loading)
                const CircularProgressIndicator(color: _green, strokeWidth: 2.5)
              else ...[
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
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
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: _signIn,
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _green,
                    ),
                  ),
                ),
              ],

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stacked expense preview cards ─────────────────────────────────────────────
class _ExpenseCards extends StatelessWidget {
  const _ExpenseCards();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back card (tilted left)
          Transform.rotate(
            angle: -0.06,
            child: _ExpenseCard(
              icon: Icons.home_outlined,
              title: 'Apartment',
              avatarColors: const [Color(0xFF4CAF50), Color(0xFF2196F3)],
              amount: '₹12,000',
              offset: const Offset(0, 20),
            ),
          ),
          // Front card (slight tilt right)
          Transform.rotate(
            angle: 0.04,
            child: _ExpenseCard(
              icon: Icons.restaurant_outlined,
              title: 'Dinner',
              avatarColors: const [Color(0xFFFF9800), Color(0xFF9C27B0)],
              amount: '₹2,400',
              offset: Offset.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.icon,
    required this.title,
    required this.avatarColors,
    required this.amount,
    required this.offset,
  });

  final IconData icon;
  final String title;
  final List<Color> avatarColors;
  final String amount;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2C2C2C), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _green, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (int i = 0; i < avatarColors.length; i++)
                        Padding(
                          padding: EdgeInsets.only(right: i < avatarColors.length - 1 ? 4 : 0),
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: avatarColors[i],
                            child: const Icon(Icons.person, size: 9, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: _green,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
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
