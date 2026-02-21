import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});
  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  List<dynamic> _coupons = [];
  bool _loading = true;
  String _filter = 'all';

  static const _types = ['all', 'cafe', 'restaurant', 'cinema', 'activity'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await CouponService.getCoupons();
      setState(() { _coupons = res['coupons'] ?? []; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  List<dynamic> get _filtered => _filter == 'all'
      ? _coupons
      : _coupons.where((c) => c['business_type'] == _filter).toList();

  Future<void> _redeem(Map<String, dynamic> coupon) async {
    try {
      final res = await CouponService.redeem(coupon['id'] as String);
      if (!mounted) return;
      _showRedeemSheet(res, coupon);
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  void _showRedeemSheet(Map<String, dynamic> res, Map<String, dynamic> coupon) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ink2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24,
          MediaQuery.of(context).padding.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('Coupon Redeemed!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.chalk,
            )),
          const SizedBox(height: 6),
          Text(coupon['business_name'] as String? ?? '',
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.dust)),
          const SizedBox(height: 20),

          // Code box
          if (res['code'] != null)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: res['code'] as String));
                showSnack(context, 'Code copied!');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.fire.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.fire.withOpacity(0.3)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(res['code'] as String,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26, fontWeight: FontWeight.w900,
                      color: AppColors.fire, letterSpacing: 4,
                    )),
                  const SizedBox(width: 10),
                  const Icon(Icons.copy, color: AppColors.fire, size: 18),
                ]),
              ),
            ),

          const SizedBox(height: 12),
          Text(res['instructions'] as String? ?? 'Show this code at the counter',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.dust),
            textAlign: TextAlign.center),
          const SizedBox(height: 20),
          GhostButton(label: 'Done', onTap: () => Navigator.pop(context)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 20, 24, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Illustration strip
                SizedBox(height: 80,
                  child: CustomPaint(painter: _CouponIlloPainter())),
                const SizedBox(height: 12),

                RichText(text: TextSpan(children: [
                  TextSpan(text: 'Date\n',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.chalk, height: 1.15,
                    )),
                  TextSpan(text: 'Offers.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28, fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic, color: AppColors.fire, height: 1.15,
                    )),
                ])),
                const SizedBox(height: 4),
                Text('Exclusive deals for your date night.',
                  style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.dust)),
                const SizedBox(height: 16),

                // Type filter
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _types.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final t = _types[i];
                      final active = _filter == t;
                      final icons = {'all': '✦', 'cafe': '☕', 'restaurant': '🍽️',
                        'cinema': '🎬', 'activity': '🎯'};
                      return GestureDetector(
                        onTap: () => setState(() => _filter = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            gradient: active ? AppColors.gradient : null,
                            color: active ? null : AppColors.glass,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: active ? Colors.transparent : AppColors.border),
                          ),
                          child: Center(child: Text(
                            '${icons[t] ?? ''} ${t[0].toUpperCase()}${t.substring(1)}',
                            style: GoogleFonts.dmSans(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: active ? Colors.white : AppColors.dust,
                            ),
                          )),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),

          if (_loading)
            const SliverToBoxAdapter(child: Center(
              child: Padding(padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.fire)),
            ))
          else if (_filtered.isEmpty)
            SliverToBoxAdapter(child: Center(
              child: Padding(padding: const EdgeInsets.all(48), child: Column(children: [
                const Text('🏷️', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text('No offers nearby', style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.dust)),
              ])),
            ))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final c = _filtered[i] as Map<String, dynamic>;
                  final redeemed = c['already_redeemed'] == true;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: _CouponCard(coupon: c, redeemed: redeemed, onRedeem: () => _redeem(c)),
                  );
                },
                childCount: _filtered.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final bool redeemed;
  final VoidCallback onRedeem;
  const _CouponCard({required this.coupon, required this.redeemed, required this.onRedeem});

  String _typeIcon(String? type) {
    switch (type) {
      case 'cafe': return '☕';
      case 'restaurant': return '🍽️';
      case 'cinema': return '🎬';
      case 'bar': return '🍸';
      default: return '🎯';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dist = coupon['distanceKm'];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        // Top
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: AppColors.fire.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(_typeIcon(coupon['business_type'] as String?),
                style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(coupon['title'] as String? ?? '',
                style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.chalk)),
              Text(coupon['business_name'] as String? ?? '',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.dust)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(coupon['discount_text'] as String? ?? '',
                style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white,
                )),
            ),
          ]),
        ),

        // Perforation
        Row(children: [
          Container(width: 16, height: 16,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8), bottomRight: Radius.circular(8),
              ),
            )),
          Expanded(child: SizedBox(height: 16,
            child: CustomPaint(painter: _DashPainter()))),
          Container(width: 16, height: 16,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), bottomLeft: Radius.circular(8),
              ),
            )),
        ]),

        // Bottom
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Row(children: [
            if (dist != null) ...[
              const Icon(Icons.location_on, color: AppColors.dust, size: 13),
              const SizedBox(width: 2),
              Text('${dist}km away',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.dust)),
              const SizedBox(width: 12),
            ],
            if (coupon['code'] != null) ...[
              const Icon(Icons.local_offer, color: AppColors.ember, size: 13),
              const SizedBox(width: 4),
              Text(coupon['code'] as String,
                style: GoogleFonts.dmSans(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ember,
                )),
            ],
            const Spacer(),
            GestureDetector(
              onTap: redeemed ? null : onRedeem,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  gradient: redeemed ? null : AppColors.gradient,
                  color: redeemed ? AppColors.glass : null,
                  borderRadius: BorderRadius.circular(12),
                  border: redeemed ? Border.all(color: AppColors.border) : null,
                ),
                child: Text(redeemed ? '✓ Used' : 'Redeem',
                  style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: redeemed ? AppColors.dust : Colors.white,
                  )),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(x + 5, size.height / 2), p);
      x += 10;
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _CouponIlloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = AppColors.fire.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), 60, glow);

    // Gift box outline
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 8), width: 60, height: 44), paint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy - 18), width: 60, height: 12), paint);
    canvas.drawLine(Offset(cx, cy - 24), Offset(cx, cy + 30), paint);

    // Tags
    final tagPaint = Paint()
      ..color = AppColors.ember.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 70, cy), width: 50, height: 26),
        const Radius.circular(6),
      ),
      tagPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 70, cy + 10), width: 44, height: 22),
        const Radius.circular(6),
      ),
      tagPaint,
    );
  }
  @override bool shouldRepaint(_) => false;
}
