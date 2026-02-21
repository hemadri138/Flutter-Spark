import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class MatchesScreen extends StatefulWidget {
  final String? planId;
  const MatchesScreen({super.key, this.planId});
  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<dynamic> _candidates = [];
  List<dynamic> _matches    = [];
  bool _loading = true;
  String _tab = 'find'; // 'find' | 'matched'
  String? _activePlanId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // Load mutual matches
      final mRes = await MatchingService.getMatches();
      _matches = mRes['matches'] ?? [];

      // Load candidates if we have a planId
      if (widget.planId != null) {
        _activePlanId = widget.planId;
        await _loadCandidates(_activePlanId!);
      } else {
        // Try to find latest plan
        final pRes = await PlanService.getMyPlans();
        final plans = pRes['plans'] as List? ?? [];
        if (plans.isNotEmpty) {
          _activePlanId = plans.first['id'] as String;
          await _loadCandidates(_activePlanId!);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadCandidates(String planId) async {
    try {
      final res = await MatchingService.getCandidates(planId);
      _candidates = res['candidates'] ?? [];
    } catch (_) {}
  }

  Future<void> _spark(Map<String, dynamic> candidate) async {
    if (_activePlanId == null) return;
    try {
      final res = await MatchingService.spark(
        fromPlanId: _activePlanId!,
        toPlanId:   candidate['planId'] as String,
        toUserId:   candidate['userId'] as String,
      );
      if (!mounted) return;
      if (res['matched'] == true) {
        showSnack(context, '🎉 It\'s a match! Chat is now open.');
        setState(() => _tab = 'matched');
        _load();
      } else {
        showSnack(context, '✦ Spark sent!');
        setState(() => _candidates.remove(candidate));
      }
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Column(children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.glass, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(child: Text('←', style: TextStyle(color: AppColors.chalk, fontSize: 18))),
              ),
            ),
            const SizedBox(height: 16),
            RichText(text: TextSpan(children: [
              TextSpan(text: 'Your\n',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.chalk, height: 1.15,
                )),
              TextSpan(text: 'Matches.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28, fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic, color: AppColors.fire, height: 1.15,
                )),
            ])),
            const SizedBox(height: 14),

            // Tab toggle
            Row(children: [
              _TabBtn(label: 'Find (${_candidates.length})', active: _tab == 'find',
                onTap: () => setState(() => _tab = 'find')),
              const SizedBox(width: 10),
              _TabBtn(label: 'Matched (${_matches.length})', active: _tab == 'matched',
                onTap: () => setState(() => _tab = 'matched')),
            ]),
          ]),
        ),

        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.fire))
          : _tab == 'find' ? _candidateList() : _matchedList(),
        ),
      ]),
    );
  }

  Widget _candidateList() {
    if (_candidates.isEmpty) return _empty('No candidates yet.\nCreate a plan to find matches!');
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _candidates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final c = _candidates[i] as Map<String, dynamic>;
        return _CandidateCard(candidate: c, onSpark: () => _spark(c));
      },
    );
  }

  Widget _matchedList() {
    if (_matches.isEmpty) return _empty('No matches yet.\nSpark someone to connect!');
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final m = _matches[i] as Map<String, dynamic>;
        return _MatchCard(match: m);
      },
    );
  }

  Widget _empty(String msg) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('✦', style: TextStyle(fontSize: 40, color: AppColors.fire)),
      const SizedBox(height: 12),
      Text(msg,
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.dust, height: 1.6)),
    ]),
  );
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          gradient: active ? AppColors.gradient : null,
          color: active ? null : AppColors.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? Colors.transparent : AppColors.border),
        ),
        child: Text(label,
          style: GoogleFonts.dmSans(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: active ? Colors.white : AppColors.dust,
          )),
      ),
    );
  }
}

class _CandidateCard extends StatefulWidget {
  final Map<String, dynamic> candidate;
  final VoidCallback onSpark;
  const _CandidateCard({required this.candidate, required this.onSpark});
  @override
  State<_CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends State<_CandidateCard> {
  bool _sparked = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.candidate;
    final score = c['matchScore'] as int? ?? 0;
    final label = c['matchLabel'] as String? ?? '';
    final activities = (c['planActivities'] as List?)?.join(' + ') ?? '';
    final dist = c['distanceKm'];
    final interests = (c['interests'] as List?)?.cast<String>() ?? [];

    final badgeColor = score == 3 ? AppColors.fire
        : score == 2 ? AppColors.ember
        : AppColors.warm;

    return GlassCard(
      highlighted: score == 3,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Avatar
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(child: Text(
              (c['name'] as String? ?? '?').substring(0, 1).toUpperCase(),
              style: GoogleFonts.playfairDisplay(
                fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
              ),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('${c['name'] ?? ''}, ${c['age'] ?? ''}',
                style: GoogleFonts.dmSans(
                  fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.chalk,
                )),
              if (c['isKycVerified'] == true) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('✓ KYC',
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.green, fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
            const SizedBox(height: 2),
            Text('📍 ${c['planLocation'] ?? ''}${dist != null ? ' · ${dist}km' : ''}',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.dust)),
          ])),

          // Spark button
          GestureDetector(
            onTap: _sparked ? null : () {
              setState(() => _sparked = true);
              widget.onSpark();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50, height: 50,
              decoration: BoxDecoration(
                gradient: _sparked ? null : AppColors.gradient,
                color: _sparked ? AppColors.glass : null,
                borderRadius: BorderRadius.circular(18),
                boxShadow: _sparked ? null : [BoxShadow(
                  color: AppColors.fire.withOpacity(0.4),
                  blurRadius: 12, offset: const Offset(0, 4),
                )],
              ),
              child: Center(child: Text(
                _sparked ? '✓' : '✦',
                style: TextStyle(
                  fontSize: 20,
                  color: _sparked ? AppColors.dust : Colors.white,
                ),
              )),
            ),
          ),
        ]),

        const SizedBox(height: 12),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 10),

        // Match badge + plan
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(label,
              style: GoogleFonts.dmSans(
                fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor,
              )),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(activities,
            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.warm),
            overflow: TextOverflow.ellipsis,
          )),
        ]),

        if (interests.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: interests.take(3).map((t) =>
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.glass,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(t, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.dust)),
            ),
          ).toList()),
        ],
      ]),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final score = match['match_score'] as int? ?? 0;
    final label = score == 3 ? 'Perfect Match' : score == 2 ? 'Partial Match' : 'Good Match';
    final badgeColor = score == 3 ? AppColors.fire : score == 2 ? AppColors.ember : AppColors.warm;

    return GlassCard(
      highlighted: true,
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(child: Text(
            (match['other_name'] as String? ?? '?').substring(0, 1).toUpperCase(),
            style: GoogleFonts.playfairDisplay(
              fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white,
            ),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(match['other_name'] ?? '',
            style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.chalk)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
              style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor)),
          ),
        ])),
        if (match['room_id'] != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('Chat 💬',
              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
      ]),
    );
  }
}
