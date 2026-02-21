import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl  = TextEditingController();
  final _cityCtrl = TextEditingController();
  String _gender     = '';
  String _genderPref = '';
  final Set<String> _interests = {};
  bool _loading = false;

  static const _allInterests = [
    'Coffee ☕', 'Music 🎵', 'Hiking 🥾', 'Reading 📚',
    'Travel ✈️', 'Foodie 🍜', 'Art 🎨', 'Gym 💪',
    'Dogs 🐕', 'Movies 🎬', 'Gaming 🎮', 'Yoga 🧘',
  ];

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _ageCtrl.text.isEmpty ||
        _cityCtrl.text.trim().isEmpty || _gender.isEmpty || _genderPref.isEmpty) {
      showSnack(context, 'Please fill all required fields', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await ProfileService.setup(
        name: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text),
        city: _cityCtrl.text.trim().toLowerCase(),
        gender: _gender,
        genderPref: _genderPref,
        interests: _interests.toList(),
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(children: [
              SizedBox(
                height: 240,
                child: CustomPaint(painter: _ProfileIlloPainter()),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 24,
                child: Text('YOUR PROFILE',
                  style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    letterSpacing: 2, color: AppColors.fire,
                  )),
              ),
            ]),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            sliver: SliverList(delegate: SliverChildListDelegate([
              RichText(text: TextSpan(children: [
                TextSpan(text: 'Tell us about ',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.chalk,
                  )),
                TextSpan(text: 'you.',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28, fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic, color: AppColors.fire,
                  )),
              ])),
              const SizedBox(height: 4),
              Text('Quick & minimal. No essays. Just vibes.',
                style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.dust)),
              const SizedBox(height: 24),

              SparkInput(label: 'Name', hint: 'Your first name', controller: _nameCtrl),
              const SizedBox(height: 14),

              Row(children: [
                Expanded(child: SparkInput(
                  label: 'Age', hint: '24',
                  controller: _ageCtrl, keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(child: SparkInput(
                  label: 'City', hint: 'Bengaluru', controller: _cityCtrl,
                )),
              ]),
              const SizedBox(height: 20),

              SectionLabel('I am a'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final g in ['Man', 'Woman', 'Non-binary'])
                  SparkChip(
                    label: g,
                    selected: _gender == g.toLowerCase().replaceAll('-', '-'),
                    onTap: () => setState(() => _gender = g.toLowerCase()),
                  ),
              ]),
              const SizedBox(height: 20),

              SectionLabel('Looking for'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final (label, val) in [('Women', 'women'), ('Men', 'men'), ('Everyone', 'everyone')])
                  SparkChip(
                    label: label,
                    selected: _genderPref == val,
                    onTap: () => setState(() => _genderPref = val),
                  ),
              ]),
              const SizedBox(height: 20),

              SectionLabel('Interests (optional)'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final t in _allInterests)
                  SparkChip(
                    label: t,
                    selected: _interests.contains(t),
                    onTap: () => setState(() {
                      _interests.contains(t) ? _interests.remove(t) : _interests.add(t);
                    }),
                  ),
              ]),
              const SizedBox(height: 28),

              FireButton(label: 'Enter Spark ✦', loading: _loading, onTap: _save),
            ])),
          ),
        ],
      ),
    );
  }
}

class _ProfileIlloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    final glow = Paint()
      ..color = AppColors.fire.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawCircle(Offset(cx, size.height * 0.5), 120, glow);

    // Mirror shape
    final mirrorPaint = Paint()
      ..color = AppColors.ember.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 60, size.height * 0.45), width: 84, height: 104),
      mirrorPaint,
    );

    // Stars
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final (dx, dy, text, s, op) in [
      (-100.0, 40.0, '✦', 18.0, 0.5),
      (110.0, 30.0, '♡', 20.0, 0.6),
      (-80.0, 110.0, '♡', 14.0, 0.4),
      (100.0, 120.0, '✦', 14.0, 0.4),
    ]) {
      tp.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: s,
          color: (text == '♡' ? AppColors.ember : Colors.white).withOpacity(op),
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(cx + dx, dy));
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
