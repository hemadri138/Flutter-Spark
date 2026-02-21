import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'matches_screen.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});
  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final Set<String> _activities = {};
  final _locationCtrl = TextEditingController();
  final _cityCtrl     = TextEditingController();
  DateTime _date      = DateTime.now();
  TimeOfDay? _timeFrom;
  TimeOfDay? _timeTo;
  bool _loading = false;

  static const _activityOptions = [
    ['🌳', 'Park'],   ['☕', 'Coffee'],  ['🎬', 'Movie'],
    ['🍽️', 'Dinner'], ['🚗', 'Drive'],  ['🎨', 'Art'],
  ];

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.fire)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? (_timeFrom ?? TimeOfDay.now()) : (_timeTo ?? TimeOfDay.now()),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.fire)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => isFrom ? _timeFrom = picked : _timeTo = picked);
  }

  Future<void> _create() async {
    if (_activities.isEmpty) { showSnack(context, 'Pick at least one activity', error: true); return; }
    if (_locationCtrl.text.trim().isEmpty) { showSnack(context, 'Enter location', error: true); return; }
    if (_cityCtrl.text.trim().isEmpty) { showSnack(context, 'Enter city', error: true); return; }

    setState(() => _loading = true);
    try {
      final res = await PlanService.createPlan(
        activities: _activities.toList(),
        location: _locationCtrl.text.trim(),
        city: _cityCtrl.text.trim().toLowerCase(),
        planDate: DateFormat('yyyy-MM-dd').format(_date),
        timeFrom: _timeFrom != null ? _fmt(_timeFrom!) : null,
        timeTo:   _timeTo   != null ? _fmt(_timeTo!)   : null,
      );
      if (!mounted) return;
      final planId = res['plan']?['id'] as String?;
      showSnack(context, '✦ Plan created! Finding matches...');
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => MatchesScreen(planId: planId)));
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
          // AppBar
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20, right: 20, bottom: 20,
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.glass,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Center(
                      child: Text('←', style: TextStyle(color: AppColors.chalk, fontSize: 18))),
                  ),
                ),
                const SizedBox(width: 14),
                RichText(text: TextSpan(children: [
                  TextSpan(text: "Today's ",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.chalk)),
                  TextSpan(text: 'Plan',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22, fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic, color: AppColors.fire)),
                ])),
              ]),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(delegate: SliverChildListDelegate([

              SectionLabel("What's the vibe?"),
              GridView.count(
                crossAxisCount: 3, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.25,
                children: _activityOptions.map((a) {
                  final sel = _activities.contains(a[1]);
                  return GestureDetector(
                    onTap: () => setState(() => sel ? _activities.remove(a[1]) : _activities.add(a[1])),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: sel ? AppColors.gradient : null,
                        color: sel ? null : AppColors.glass,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: sel ? Colors.transparent : AppColors.border),
                        boxShadow: sel ? [BoxShadow(
                          color: AppColors.fire.withOpacity(0.3), blurRadius: 12,
                          offset: const Offset(0, 4),
                        )] : null,
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(a[0], style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 4),
                        Text(a[1], style: GoogleFonts.dmSans(
                          fontSize: 12, fontWeight: FontWeight.w500,
                          color: sel ? Colors.white : AppColors.warm,
                        )),
                      ]),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              SparkInput(label: 'Where?', hint: 'Cubbon Park, Bengaluru', controller: _locationCtrl),
              const SizedBox(height: 12),
              SparkInput(label: 'City', hint: 'bengaluru', controller: _cityCtrl),
              const SizedBox(height: 22),

              SectionLabel('When? (optional)'),
              Row(children: [
                Expanded(child: _DTPill(
                  label: '📅', value: DateFormat('dd MMM').format(_date), onTap: _pickDate)),
                const SizedBox(width: 8),
                Expanded(child: _DTPill(
                  label: '▶', value: _timeFrom != null ? _fmt(_timeFrom!) : 'From',
                  onTap: () => _pickTime(true))),
                const SizedBox(width: 8),
                Expanded(child: _DTPill(
                  label: '⏹', value: _timeTo != null ? _fmt(_timeTo!) : 'To',
                  onTap: () => _pickTime(false))),
              ]),
              const SizedBox(height: 22),

              // Live ticket
              if (_activities.isNotEmpty) ...[
                SectionLabel('Your Ticket'),
                _TicketPreview(
                  activities: _activities.toList(),
                  location: _locationCtrl.text.isNotEmpty ? _locationCtrl.text : '—',
                  city: _cityCtrl.text.isNotEmpty ? _cityCtrl.text.toUpperCase() : '—',
                  date: DateFormat('dd MMM yy').format(_date),
                  time: _timeFrom != null ? '${_fmt(_timeFrom!)}–${_fmt(_timeTo!)}' : 'Anytime',
                ),
                const SizedBox(height: 22),
              ],

              FireButton(
                label: '✦  Create Plan & Find Matches',
                loading: _loading, onTap: _create,
              ),
            ])),
          ),
        ],
      ),
    );
  }
}

class _DTPill extends StatelessWidget {
  final String label, value;
  final VoidCallback onTap;
  const _DTPill({required this.label, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.glass, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 3),
        Text(value, style: GoogleFonts.dmSans(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.chalk),
          overflow: TextOverflow.ellipsis),
      ]),
    ),
  );
}

class _TicketPreview extends StatelessWidget {
  final List<String> activities;
  final String location, city, date, time;
  const _TicketPreview({
    required this.activities, required this.location,
    required this.city, required this.date, required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: AppColors.fire.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SPARK EVENT TICKET', style: GoogleFonts.dmSans(
              fontSize: 10, fontWeight: FontWeight.w700,
              letterSpacing: 2.5, color: Colors.white60)),
            const SizedBox(height: 8),
            Text(activities.join(' + '), style: GoogleFonts.playfairDisplay(
              fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 12),
            Row(children: [
              _TD('CITY', city), const SizedBox(width: 22),
              _TD('DATE', date), const SizedBox(width: 22),
              _TD('TIME', time),
            ]),
          ]),
        ),
        // Perforation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(children: [
            const SizedBox(width: 16),
            Expanded(child: DashedLine()),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('STATUS', style: GoogleFonts.dmSans(
                  fontSize: 9, letterSpacing: 1.5, color: Colors.white60)),
                const SizedBox(height: 2),
                Text('SEEKING MATCH', style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
              Row(children: List.generate(14, (i) => Container(
                width: i.isEven ? 2.5 : 1.5,
                height: i % 3 == 0 ? 32 : 22,
                margin: const EdgeInsets.symmetric(horizontal: 0.6),
                color: Colors.white.withOpacity(0.7),
              ))),
            ],
          ),
        ),
      ]),
    );
  }
}

class _TD extends StatelessWidget {
  final String l, v;
  const _TD(this.l, this.v);
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(l, style: GoogleFonts.dmSans(fontSize: 9, letterSpacing: 1.5, color: Colors.white60)),
    const SizedBox(height: 2),
    Text(v, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
  ]);
}

class DashedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => Row(
      children: List.generate((c.maxWidth / 8).floor(), (i) => Expanded(child: Container(
        height: 1,
        color: i.isEven ? Colors.white30 : Colors.transparent,
      ))),
    ),
  );
}
