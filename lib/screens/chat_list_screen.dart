import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<dynamic> _rooms = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ChatService.getRooms();
      setState(() { _rooms = res['rooms'] ?? []; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _timeLeft(String expiresAt) {
    final exp = DateTime.tryParse(expiresAt);
    if (exp == null) return '';
    final diff = exp.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m left';
    return '${diff.inMinutes}m left';
  }

  String _modeIcon(String? mode) {
    switch (mode) {
      case 'disappear_24h': return '⏳';
      case 'disappear_read': return '👁️';
      default: return '💬';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 20, 24, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(text: TextSpan(children: [
                  TextSpan(text: 'Your\n',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.chalk, height: 1.15,
                    )),
                  TextSpan(text: 'Chats.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28, fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic, color: AppColors.fire, height: 1.15,
                    )),
                ])),
                const SizedBox(height: 4),
                Text('All chats are timed. Keep the spark alive.',
                  style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.dust)),
              ]),
            ),
          ),

          if (_loading)
            const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.fire),
              )),
            )
          else if (_rooms.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(children: [
                    const Text('💬', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text('No chats yet', style: GoogleFonts.playfairDisplay(
                      fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.chalk,
                    )),
                    const SizedBox(height: 6),
                    Text('Match with someone to start chatting!',
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.dust),
                      textAlign: TextAlign.center),
                  ]),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final r = _rooms[i] as Map<String, dynamic>;
                  final unread = int.tryParse(r['unread_count']?.toString() ?? '0') ?? 0;
                  final timeLeft = _timeLeft(r['expires_at'] as String? ?? '');
                  final isExpiring = (){
                    final exp = DateTime.tryParse(r['expires_at'] as String? ?? '');
                    if (exp == null) return false;
                    return exp.difference(DateTime.now()).inMinutes < 30;
                  }();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: GlassCard(
                      highlighted: unread > 0,
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          roomId: r['id'] as String,
                          otherName: r['other_name'] as String? ?? '',
                        ),
                      )).then((_) => _load()),
                      child: Row(children: [
                        // Avatar
                        Stack(children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(child: Text(
                              (r['other_name'] as String? ?? '?').substring(0, 1).toUpperCase(),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white,
                              ),
                            )),
                          ),
                          if (unread > 0)
                            Positioned(right: 0, top: 0,
                              child: Container(
                                width: 18, height: 18,
                                decoration: const BoxDecoration(
                                  color: AppColors.fire, shape: BoxShape.circle,
                                ),
                                child: Center(child: Text('$unread',
                                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700))),
                              )),
                        ]),
                        const SizedBox(width: 12),

                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(r['other_name'] ?? '',
                              style: GoogleFonts.dmSans(
                                fontSize: 15, fontWeight: FontWeight.w600,
                                color: unread > 0 ? AppColors.chalk : AppColors.warm,
                              ))),
                            Text(_modeIcon(r['message_mode'] as String?),
                              style: const TextStyle(fontSize: 14)),
                          ]),
                          const SizedBox(height: 2),
                          Text(r['last_message'] ?? 'Start the conversation!',
                            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.dust),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        ])),

                        const SizedBox(width: 10),

                        // Timer
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isExpiring
                                  ? AppColors.fire.withOpacity(0.2)
                                  : AppColors.glass,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isExpiring ? AppColors.fire.withOpacity(0.4) : AppColors.border,
                              ),
                            ),
                            child: Text(timeLeft,
                              style: GoogleFonts.dmSans(
                                fontSize: 11, fontWeight: FontWeight.w600,
                                color: isExpiring ? AppColors.fire : AppColors.dust,
                              )),
                          ),
                        ]),
                      ]),
                    ),
                  );
                },
                childCount: _rooms.length,
              ),
            ),
        ],
      ),
    );
  }
}
