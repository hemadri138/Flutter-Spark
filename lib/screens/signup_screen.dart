import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/widgets.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  final bool isLogin;
  const SignupScreen({super.key, this.isLogin = false});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _contactCtrl = TextEditingController();
  String _type = 'phone';
  bool _loading = false;

  Future<void> _sendOtp() async {
    final contact = _contactCtrl.text.trim();
    if (contact.isEmpty) { showSnack(context, 'Enter your phone or email', error: true); return; }

    setState(() => _loading = true);
    try {
      final res = await AuthService.sendOtp(contact: contact, type: _type);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => OTPScreen(contact: contact, type: _type),
      ));
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          // Background orbs
          Positioned.fill(child: CustomPaint(
            painter: OrbPainter(color: AppColors.fire),
          )),

          // Illustration top half
          Positioned(top: 0, left: 0, right: 0, height: 300,
            child: _SignupIllustration()),

          // Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  left: 28, right: 28, top: 32,
                  bottom: MediaQuery.of(context).padding.bottom + 32,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ink2,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.fire.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('CREATE ACCOUNT',
                        style: GoogleFonts.dmSans(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          letterSpacing: 2, color: AppColors.fire,
                        )),
                    ),
                    const SizedBox(height: 12),

                    RichText(text: TextSpan(children: [
                      TextSpan(
                        text: widget.isLogin ? 'Welcome\nback ' : 'Join ',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32, fontWeight: FontWeight.w900,
                          color: AppColors.chalk, height: 1.15,
                        ),
                      ),
                      TextSpan(
                        text: widget.isLogin ? '✦' : 'Spark',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32, fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: AppColors.fire, height: 1.15,
                        ),
                      ),
                      if (!widget.isLogin) TextSpan(
                        text: '\ntoday.',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32, fontWeight: FontWeight.w900,
                          color: AppColors.chalk, height: 1.15,
                        ),
                      ),
                    ])),
                    const SizedBox(height: 6),
                    Text('Verified profiles only. Your safety matters.',
                      style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppColors.dust, height: 1.6,
                      )),
                    const SizedBox(height: 24),

                    // Toggle phone/email
                    Row(children: [
                      _TypeToggle(
                        label: '📱 Phone', value: 'phone',
                        selected: _type == 'phone',
                        onTap: () => setState(() => _type = 'phone'),
                      ),
                      const SizedBox(width: 10),
                      _TypeToggle(
                        label: '📧 Email', value: 'email',
                        selected: _type == 'email',
                        onTap: () => setState(() => _type = 'email'),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    SparkInput(
                      label: _type == 'phone' ? 'Mobile Number' : 'Email Address',
                      hint: _type == 'phone' ? '+91 98765 43210' : 'you@example.com',
                      controller: _contactCtrl,
                      keyboardType: _type == 'phone'
                          ? TextInputType.phone
                          : TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    FireButton(
                      label: 'Send OTP →',
                      loading: _loading,
                      onTap: _sendOtp,
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(text: TextSpan(children: [
                          TextSpan(
                            text: widget.isLogin ? 'New here? ' : 'Already have an account? ',
                            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.dust),
                          ),
                          TextSpan(
                            text: widget.isLogin ? 'Create account' : 'Sign in',
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
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _TypeToggle({required this.label, required this.value,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.gradient : null,
          color: selected ? null : AppColors.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? Colors.transparent : AppColors.border),
        ),
        child: Text(label,
          style: GoogleFonts.dmSans(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.dust,
          )),
      ),
    );
  }
}

class _SignupIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SignupPainter());
  }
}

class _SignupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final paint = Paint()
      ..color = AppColors.fire.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(Offset(cx, size.height * 0.4), 130, paint);

    // Big phone outline
    final phonePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, size.height * 0.45), width: 100, height: 170),
      const Radius.circular(16),
    );
    canvas.drawRRect(phoneRect, phonePaint);

    // Screen inside phone
    final screenPaint = Paint()
      ..color = AppColors.fire.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, size.height * 0.42), width: 84, height: 135),
        const Radius.circular(8),
      ),
      screenPaint,
    );

    // Floating hearts
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final (dx, dy, size2, op) in [
      (-100.0, 80.0, 22.0, 0.6),
      (100.0, 90.0, 16.0, 0.5),
      (-70.0, 130.0, 14.0, 0.3),
      (80.0, 60.0, 12.0, 0.4),
    ]) {
      tp.text = TextSpan(
        text: '♥',
        style: TextStyle(fontSize: size2, color: AppColors.ember.withOpacity(op)),
      );
      tp.layout();
      tp.paint(canvas, Offset(cx + dx, dy));
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
