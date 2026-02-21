import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../utils/storage.dart';
import '../widgets/widgets.dart';
import 'profile_screen.dart';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String contact;
  final String type;
  const OTPScreen({super.key, required this.contact, required this.type});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _ctls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _foci = List.generate(6, (_) => FocusNode());
  bool _loading = false;

  String get _otp => _ctls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_otp.length < 6) { showSnack(context, 'Enter the 6-digit OTP', error: true); return; }
    setState(() => _loading = true);
    try {
      final res = await AuthService.verifyOtp(
        contact: widget.contact, otp: _otp, type: widget.type,
      );
      if (!mounted) return;
      final profileDone = await Storage.isProfileComplete();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => profileDone ? const HomeScreen() : const ProfileScreen()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    try {
      await AuthService.sendOtp(contact: widget.contact, type: widget.type);
      if (mounted) showSnack(context, 'New OTP sent!');
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: OrbPainter(color: AppColors.fire, opacity: 0.1))),

          // Illustration
          Positioned(top: 60, left: 0, right: 0, height: 270,
            child: CustomPaint(painter: _OTPIlloPainter())),

          // Content
          Align(
            alignment: Alignment.bottomCenter,
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.glass,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(child: Text('←', style: TextStyle(color: AppColors.chalk, fontSize: 18))),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('VERIFICATION',
                    style: GoogleFonts.dmSans(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      letterSpacing: 2, color: AppColors.fire,
                    )),
                  const SizedBox(height: 8),

                  RichText(text: TextSpan(children: [
                    TextSpan(text: 'Enter the\n',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.chalk, height: 1.15,
                      )),
                    TextSpan(text: 'secret code.',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 30, fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic, color: AppColors.fire, height: 1.15,
                      )),
                  ])),
                  const SizedBox(height: 6),
                  Text('Sent to ${widget.contact}',
                    style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.dust)),
                  const SizedBox(height: 28),

                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) => _OTPBox(
                      controller: _ctls[i],
                      focusNode: _foci[i],
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) {
                          _foci[i + 1].requestFocus();
                        }
                        if (v.isEmpty && i > 0) {
                          _foci[i - 1].requestFocus();
                        }
                        if (_otp.length == 6) _verify();
                        setState(() {});
                      },
                    )),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: _resend,
                      child: RichText(text: TextSpan(children: [
                        TextSpan(text: "Didn't get it? ",
                          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.dust)),
                        TextSpan(text: 'Resend OTP',
                          style: GoogleFonts.dmSans(
                            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.fire,
                          )),
                      ])),
                    ),
                  ),
                  const SizedBox(height: 20),

                  FireButton(label: 'Verify & Continue →', loading: _loading, onTap: _verify),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OTPBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OTPBox({required this.controller, required this.focusNode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48, height: 58,
      decoration: BoxDecoration(
        color: filled ? AppColors.fire.withOpacity(0.1) : AppColors.glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: filled ? AppColors.fire : AppColors.border,
          width: filled ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        style: GoogleFonts.playfairDisplay(
          fontSize: 22, fontWeight: FontWeight.w700,
          color: filled ? AppColors.fire : AppColors.chalk,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _OTPIlloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final glowPaint = Paint()
      ..color = AppColors.fire.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    canvas.drawCircle(Offset(cx, cy), 100, glowPaint);

    // Lock body
    final lockPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    final lockStroke = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final lockRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 20), width: 80, height: 65),
      const Radius.circular(14),
    );
    canvas.drawRRect(lockRect, lockPaint);
    canvas.drawRRect(lockRect, lockStroke);

    // Shackle
    final shacklePath = Path()
      ..moveTo(cx - 28, cy + 20 - 32)
      ..lineTo(cx - 28, cy - 32)
      ..arcToPoint(Offset(cx + 28, cy - 32),
        radius: const Radius.circular(28), clockwise: false)
      ..lineTo(cx + 28, cy + 20 - 32);
    canvas.drawPath(shacklePath, lockStroke);

    // Keyhole
    final kPaint = Paint()..color = AppColors.fire.withOpacity(0.8);
    canvas.drawCircle(Offset(cx, cy + 15), 9, kPaint);
    final keyPath = Path()
      ..addRect(Rect.fromCenter(center: Offset(cx, cy + 26), width: 7, height: 14));
    canvas.drawPath(keyPath, kPaint);

    // Sparkle rays
    final rayPaint = Paint()
      ..color = AppColors.ember.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      canvas.drawLine(
        Offset(cx + 55 * cos(angle), cy + 55 * sin(angle)),
        Offset(cx + 75 * cos(angle), cy + 75 * sin(angle)),
        rayPaint,
      );
    }
  }

  double cos(double rad) => _cos(rad);
  double sin(double rad) => _sin(rad);
  double _cos(double x) {
    double result = 1, term = 1;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / (2 * i * (2 * i - 1));
      result += term;
    }
    return result;
  }
  double _sin(double x) {
    double result = x, term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i + 1) * 2 * i);
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(_) => false;
}
