import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'create_plan_screen.dart';
import 'matches_screen.dart';
import 'chat_list_screen.dart';
import 'coupons_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  List<dynamic> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final res = await PlanService.getMyPlans();
      setState(() { _plans = res['plans'] ?? []; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Widget _body() {
    switch (_tab) {
      case 1: return const CreatePlanScreen();
      case 2: return const ChatListScreen();
      case 3: return const CouponsScreen();
      default: return _homeBody();
    }
  }

  Widget _homeBody() {
    return RefreshIndicator(
      onRefresh: _loadPlans,
      color: AppColors.fire,
      child: CustomScrollView(
        slivers: [
          // Header with illustration
          SliverToBoxAdapter(child: _HomeHeader()),

          // Plan prompt
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _PlanPromptCard(onTap: () => setState(() => _tab = 1)),
            ),
          ),

          // Quick activities
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            sliver: SliverToBoxAdapter(child: _QuickActivities(
              onTap: () => setState(() => _tab = 1),
            )),
          ),

          // Active plans
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionLabel('Active Plans'),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MatchesScreen())),
                    child: Text('View matches →',
                      style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppColors.fire, fontWeight: FontWeight.w500,
                      )),
                  ),
                ],
              ),
            ),
          ),

          if (_loading)
            const SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: AppColors.fire)),
            ))
          else if (_plans.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GlassCard(
                  onTap: () => setState(() => _tab = 1),
                  child: Column(children: [
                    const Text('✦', style: TextStyle(fontSize: 32, color: AppColors.fire)),
                    const SizedBox(height: 8),
                    Text('No active plans yet',
                      style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.chalk)),
                    const SizedBox(height: 4),
                    Text('Create your first plan to find matches!',
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.dust)),
                  ]),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: _PlanCard(plan: _plans[i]),
                ),
                childCount: _plans.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: _body(),
      bottomNavigationBar: SparkBottomNav(
        currentIndex: _tab,
        onTap: (i) {
          if (i == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePlanScreen()))
                .then((_) => _loadPlans());
          } else {
            setState(() => _tab = i);
          }
        },
      ),
    );
  }
}

// ── Home header with illustration ─────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(height: 220, width: double.infinity,
          child: CustomPaint(painter: _SkylinePainter())),
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 24, right: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Good evening 🌆',
                  style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.ember.withOpacity(0.7))),
                const SizedBox(height: 2),
                RichText(text: TextSpan(children: [
                  TextSpan(text: 'Hey ',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.chalk,
                    )),
                  TextSpan(text: '✦',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.fire,
                    )),
                ])),
              ]),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(child: Text('😊', style: TextStyle(fontSize: 22))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dark gradient background
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF0D0A07), AppColors.ink],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Moon
    final moonPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(size.width * 0.82, 45), 28, moonPaint);

    // Stars
    final starPaint = Paint()..color = Colors.white.withOpacity(0.5);
    for (final (x, y, r) in [
      (0.12, 0.08, 2.0), (0.25, 0.05, 1.5), (0.45, 0.12, 2.0),
      (0.6, 0.06, 1.5), (0.35, 0.18, 1.5),
    ]) {
      canvas.drawCircle(Offset(size.width * x, size.height * y), r, starPaint);
    }

    // Buildings
    final buildPaint = Paint()
      ..color = AppColors.fire.withOpacity(0.06)
      ..style = PaintingStyle.fill;
    final buildStroke = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final buildings = [
      [0.0, 0.55, 0.08, 1.0],
      [0.07, 0.45, 0.06, 1.0],
      [0.12, 0.35, 0.08, 1.0],
      [0.19, 0.50, 0.06, 1.0],
      [0.24, 0.40, 0.07, 1.0],
      [0.30, 0.28, 0.06, 1.0],
      [0.35, 0.22, 0.07, 1.0],
      [0.42, 0.32, 0.06, 1.0],
      [0.47, 0.38, 0.07, 1.0],
      [0.53, 0.25, 0.06, 1.0],
      [0.58, 0.35, 0.08, 1.0],
      [0.65, 0.42, 0.06, 1.0],
      [0.70, 0.30, 0.07, 1.0],
      [0.76, 0.45, 0.06, 1.0],
      [0.81, 0.38, 0.08, 1.0],
      [0.88, 0.50, 0.06, 1.0],
      [0.93, 0.42, 0.07, 1.0],
    ];

    for (final b in buildings) {
      final rect = Rect.fromLTWH(
        size.width * b[0], size.height * b[1],
        size.width * b[2], size.height * b[3],
      );
      canvas.drawRect(rect, buildPaint);
      canvas.drawRect(rect, buildStroke);
    }

    // Two silhouettes
    final figPaint = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.fill;
    final figStroke = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final cx = size.width / 2;
    final ground = size.height * 0.88;

    for (final (dx, isLeft) in [(-18.0, true), (18.0, false)]) {
      // Head
      canvas.drawCircle(Offset(cx + dx, ground - 42), 11, figPaint);
      canvas.drawCircle(Offset(cx + dx, ground - 42), 11, figStroke);
      // Body
      final bodyRect = Rect.fromCenter(
        center: Offset(cx + dx, ground - 18),
        width: 20, height: 30,
      );
      canvas.drawRect(bodyRect, figPaint);
      canvas.drawRect(bodyRect, figStroke);
    }

    // Holding hands line
    final handPaint = Paint()
      ..color = AppColors.fire
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 8, ground - 18), Offset(cx + 8, ground - 18), handPaint);

    // Heart above
    final tp = TextPainter(
      text: TextSpan(text: '♥', style: TextStyle(fontSize: 14, color: AppColors.fire)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, ground - 65));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _PlanPromptCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PlanPromptCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.fire.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.fire.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RichText(text: TextSpan(children: [
          TextSpan(text: "What's your plan\n",
            style: GoogleFonts.playfairDisplay(
              fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.chalk,
            )),
          TextSpan(text: 'today?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20, fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic, color: AppColors.fire,
            )),
        ])),
        const SizedBox(height: 6),
        Text('Create an intent, find your match.',
          style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.dust)),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                color: AppColors.fire.withOpacity(0.4),
                blurRadius: 16, offset: const Offset(0, 6),
              )],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('✦', style: TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(width: 8),
              Text('Create Plan',
                style: GoogleFonts.dmSans(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
                )),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _QuickActivities extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickActivities({required this.onTap});

  static const _items = [
    ['🌳', 'Park'], ['☕', 'Coffee'], ['🎬', 'Movie'],
    ['🍽️', 'Dinner'], ['🚗', 'Drive'], ['🎨', 'Art'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionLabel('Popular in BLR'),
      SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (ctx, i) => GestureDetector(
            onTap: onTap,
            child: Container(
              width: 72, padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.glass,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_items[i][0], style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                Text(_items[i][1],
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.dust, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _PlanCard extends StatelessWidget {
  final dynamic plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final activities = (plan['activities'] as List?)?.join(' + ') ?? '';
    final timeFrom = plan['time_from'] ?? '';
    final timeTo   = plan['time_to'] ?? '';
    final timeStr  = timeFrom.isNotEmpty ? '$timeFrom – $timeTo' : 'Anytime';

    return GlassCard(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => MatchesScreen(planId: plan['id']))),
      child: Row(children: [
        const Text('🌳', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(activities,
            style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.chalk)),
          const SizedBox(height: 2),
          Text('📍 ${plan['city'] ?? ''} · $timeStr',
            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.dust)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.fire.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('✦ Find',
            style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.fire)),
        ),
      ]),
    );
  }
}
