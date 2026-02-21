import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ─── FIRE BUTTON ─────────────────────────────────────────────────────────────
class FireButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final Widget? icon;

  const FireButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: AppColors.gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.fire.withOpacity(0.38),
              blurRadius: 28, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 8)],
                    Text(label,
                      style: GoogleFonts.dmSans(
                        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
                      )),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── GHOST BUTTON ────────────────────────────────────────────────────────────
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const GhostButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(label,
            style: GoogleFonts.dmSans(
              fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.chalk,
            )),
        ),
      ),
    );
  }
}

// ─── SPARK INPUT ─────────────────────────────────────────────────────────────
class SparkInput extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? label;
  final Widget? suffix;
  final bool light; // light bg variant

  const SparkInput({
    super.key,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.obscure = false,
    this.label,
    this.suffix,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 11, fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: light ? Colors.black38 : AppColors.dust,
            )),
          const SizedBox(height: 7),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          style: TextStyle(color: light ? Colors.black87 : AppColors.chalk, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: light ? Colors.black38 : AppColors.dust),
            filled: true,
            fillColor: light ? Colors.black.withOpacity(0.06) : AppColors.glass,
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: light ? Colors.black12 : AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: light ? Colors.black12 : AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.fire),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ],
    );
  }
}

// ─── SECTION LABEL ────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  final bool dark;
  const SectionLabel(this.text, {super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 11, fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: dark ? Colors.black38 : AppColors.dust,
        )),
    );
  }
}

// ─── GLASS CARD ───────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool highlighted;

  const GlassCard({
    super.key, required this.child, this.onTap,
    this.padding, this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: highlighted
              ? AppColors.fire.withOpacity(0.08)
              : AppColors.glass,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: highlighted
                ? AppColors.fire.withOpacity(0.35)
                : AppColors.border,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ─── CHIP SELECTOR ────────────────────────────────────────────────────────────
class SparkChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SparkChip({
    super.key, required this.label,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.gradient : null,
          color: selected ? null : AppColors.glass,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Text(label,
          style: GoogleFonts.dmSans(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.warm,
          )),
      ),
    );
  }
}

// ─── BOTTOM NAV ───────────────────────────────────────────────────────────────
class SparkBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SparkBottomNav({
    super.key, required this.currentIndex, required this.onTap,
  });

  static const _items = [
    {'icon': '🏠', 'label': 'Home'},
    {'icon': '✦',  'label': 'Plans'},
    {'icon': '💬', 'label': 'Chats'},
    {'icon': '🏷️', 'label': 'Offers'},
    {'icon': '👤', 'label': 'Me'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF50A0805),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.only(
        top: 12, bottom: MediaQuery.of(context).padding.bottom + 8,
        left: 8, right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final active = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_items[i]['icon']!,
                  style: TextStyle(
                    fontSize: 22,
                    color: active ? null : Colors.white,
                  ).copyWith(
                    shadows: active ? [
                      Shadow(color: AppColors.fire.withOpacity(0.8), blurRadius: 12),
                    ] : null,
                  )),
                const SizedBox(height: 3),
                Text(_items[i]['label']!,
                  style: GoogleFonts.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w500,
                    color: active ? AppColors.fire : AppColors.dust,
                  )),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── SNACKBAR HELPER ─────────────────────────────────────────────────────────
void showSnack(BuildContext ctx, String msg, {bool error = false}) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg, style: GoogleFonts.dmSans(color: Colors.white)),
    backgroundColor: error ? Colors.red[700] : AppColors.fire,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ));
}

// ─── SCREEN ILLUSTRATION PAINTER ─────────────────────────────────────────────
// Warm floating orbs used as decorative background
class OrbPainter extends CustomPainter {
  final Color color;
  final double opacity;
  OrbPainter({required this.color, this.opacity = 0.15});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    paint.color = color.withOpacity(opacity);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 140, paint);

    paint.color = color.withOpacity(opacity * 0.7);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 100, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
