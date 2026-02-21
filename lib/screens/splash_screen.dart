import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../utils/storage.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      final profileDone = await Storage.isProfileComplete();
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => profileDone ? const HomeScreen() : const ProfileScreen(),
      ));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0E8), // warm chalk background
      body: Stack(
        children: [
          // ── Warm gradient orbs ──────────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _WarmOrbPainter(),
            ),
          ),

          // ── Floating illustration elements ──────────────────────────────
          Positioned(top: 80, left: 40, child: _floatingHeart(30, 0.6)),
          Positioned(top: 120, right: 60, child: _floatingStar(20, 0.4)),
          Positioned(top: 200, left: 80, child: _floatingStar(14, 0.3)),
          Positioned(top: 160, right: 30, child: _floatingHeart(20, 0.5)),

          // ── Envelope illustration ───────────────────────────────────────
          Positioned(
            top: 80, left: 0, right: 0,
            child: _EnvelopeIllustration(),
          ),

          // ── Bottom content sheet ────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 28, right: 28,
                    top: 36,
                    bottom: MediaQuery.of(context).padding.bottom + 36,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F0E8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24, offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.fire.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.fire.withOpacity(0.2)),
                        ),
                        child: Text('✦ SPARK',
                          style: GoogleFonts.dmSans(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: AppColors.fire, letterSpacing: 2,
                          )),
                      ),
                      const SizedBox(height: 14),

                      // Title
                      RichText(text: TextSpan(children: [
                        TextSpan(
                          text: 'Your story\nstarts ',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36, fontWeight: FontWeight.w900,
                            color: Colors.black87, height: 1.15,
                          ),
                        ),
                        TextSpan(
                          text: 'here.',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36, fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: AppColors.fire, height: 1.15,
                          ),
                        ),
                      ])),
                      const SizedBox(height: 10),

                      Text(
                        'KYC verified profiles only. Real plans.\nReal people. Real connections.',
                        style: GoogleFonts.dmSans(
                          fontSize: 14, color: Colors.black45, height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Get started button
                      _FireButtonLight(
                        label: 'Get Started →',
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SignupScreen())),
                      ),
                      const SizedBox(height: 14),

                      // Sign in
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SignupScreen(isLogin: true))),
                          child: RichText(text: TextSpan(children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.black45),
                            ),
                            TextSpan(
                              text: 'Sign in',
                              style: GoogleFonts.dmSans(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.fire,
                              ),
                            ),
                          ])),
                        ),
                      ),
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

  Widget _floatingHeart(double size, double opacity) => Text('♥',
    style: TextStyle(fontSize: size, color: AppColors.ember.withOpacity(opacity)));

  Widget _floatingStar(double size, double opacity) => Text('✦',
    style: TextStyle(fontSize: size, color: Colors.black.withOpacity(opacity)));
}

// ── Envelope illustration ─────────────────────────────────────────────────────
class _EnvelopeIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: CustomPaint(painter: _EnvelopePainter()),
    );
  }
}

class _EnvelopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final strokePaint = Paint()
      ..color = AppColors.ember.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppColors.ember.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Envelope body
    final envRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 95, cy - 45, 190, 130),
      const Radius.circular(14),
    );
    canvas.drawRRect(envRect, fillPaint);
    canvas.drawRRect(envRect, strokePaint);

    // Envelope flap (V shape)
    final flapPath = Path()
      ..moveTo(cx - 95, cy - 45)
      ..lineTo(cx, cy + 5)
      ..lineTo(cx + 95, cy - 45);
    canvas.drawPath(flapPath, strokePaint);

    // Bottom corners
    canvas.drawLine(Offset(cx - 95, cy + 85), Offset(cx - 40, cy + 30), strokePaint);
    canvas.drawLine(Offset(cx + 95, cy + 85), Offset(cx + 40, cy + 30), strokePaint);

    // Floating hearts above
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final (dx, dy, size, op) in [
      (0.0, -80.0, 24.0, 1.0),
      (-35.0, -100.0, 18.0, 0.7),
      (35.0, -110.0, 15.0, 0.6),
      (-60.0, -115.0, 11.0, 0.4),
      (60.0, -95.0, 13.0, 0.5),
    ]) {
      tp.text = TextSpan(
        text: '♥',
        style: TextStyle(
          fontSize: size,
          color: AppColors.ember.withOpacity(op),
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(cx + dx - tp.width / 2, cy + dy));
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Warm orb background ───────────────────────────────────────────────────────
class _WarmOrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    paint.color = AppColors.ember.withOpacity(0.12);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 150, paint);

    paint.color = AppColors.glow.withOpacity(0.15);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.5), 120, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Fire button in light style ────────────────────────────────────────────────
class _FireButtonLight extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FireButtonLight({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: AppColors.gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.fire.withOpacity(0.35),
              blurRadius: 24, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(label,
            style: GoogleFonts.dmSans(
              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
            )),
        ),
      ),
    );
  }
}
