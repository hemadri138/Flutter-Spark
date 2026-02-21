import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String otherName;
  const ChatRoomScreen({super.key, required this.roomId, required this.otherName});
  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _msgCtrl   = TextEditingController();
  final _scrollCtrl= ScrollController();
  List<dynamic> _messages = [];
  Map<String, dynamic>? _room;
  bool _loading  = true;
  bool _sending  = false;
  String? _myId;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ChatService.getRoom(widget.roomId);
      _myId = (await _meId());
      setState(() {
        _room     = res['room'] as Map<String, dynamic>?;
        _messages = res['messages'] as List? ?? [];
        _loading  = false;
      });
      _scrollToBottom();
    } catch (_) { setState(() => _loading = false); }
  }

  Future<String?> _meId() async {
    try {
      final res = await ProfileService.getMe();
      return (res['user'] as Map?)!['id'] as String?;
    } catch (_) { return null; }
  }

  Future<void> _send() async {
    final content = _msgCtrl.text.trim();
    if (content.isEmpty) return;
    _msgCtrl.clear();
    setState(() => _sending = true);
    try {
      final res = await ChatService.sendMessage(widget.roomId, content);
      final msg = res['message'] as Map<String, dynamic>?;
      if (msg != null) setState(() => _messages.add(msg));
      _scrollToBottom();
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _extend() async {
    try {
      final res = await ChatService.extendChat(widget.roomId);
      if (mounted) showSnack(context, '✦ ${res['message']}');
      _load();
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _changeMode(String mode) async {
    try {
      final res = await ChatService.changeMode(widget.roomId, mode);
      if (mounted) {
        final msg = res['confirmed'] == true ? res['message'] : res['message'];
        showSnack(context, msg as String? ?? '');
        _load();
      }
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _timeLeft() {
    final exp = DateTime.tryParse(_room?['expiresAt'] as String? ?? '');
    if (exp == null) return '';
    final diff = exp.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    return '${diff.inMinutes}m left';
  }

  bool _isExpiring() {
    final exp = DateTime.tryParse(_room?['expiresAt'] as String? ?? '');
    if (exp == null) return false;
    return exp.difference(DateTime.now()).inMinutes < 30;
  }

  String _modeLabel() {
    switch (_room?['messageMode']) {
      case 'disappear_24h': return '⏳ 24h';
      case 'disappear_read': return '👁️ On read';
      default: return '💬 Keep';
    }
  }

  void _showModeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.ink2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Message Mode',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.chalk,
            )),
          const SizedBox(height: 6),
          Text('Both users must agree to change mode',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.dust)),
          const SizedBox(height: 20),
          for (final (mode, icon, label, desc) in [
            ('keep', '💬', 'Keep messages', 'Messages stay until chat expires'),
            ('disappear_24h', '⏳', 'Disappear after 24h', 'Each message deletes itself after 24 hours'),
            ('disappear_read', '👁️', 'Disappear when read', 'Messages vanish the moment they\'re seen'),
          ])
            GestureDetector(
              onTap: () { Navigator.pop(context); _changeMode(mode); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _room?['messageMode'] == mode
                      ? AppColors.fire.withOpacity(0.1) : AppColors.glass,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _room?['messageMode'] == mode
                        ? AppColors.fire.withOpacity(0.3) : AppColors.border,
                  ),
                ),
                child: Row(children: [
                  Text(icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(label, style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.chalk,
                    )),
                    Text(desc, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.dust)),
                  ])),
                  if (_room?['messageMode'] == mode)
                    const Icon(Icons.check_circle, color: AppColors.fire, size: 18),
                ]),
              ),
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Column(children: [
        // Header
        Container(
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.ink2,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text('←', style: TextStyle(color: AppColors.chalk, fontSize: 20)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(
                widget.otherName.isEmpty ? '?' : widget.otherName.substring(0, 1).toUpperCase(),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white,
                ),
              )),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.otherName,
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.chalk)),
              if (_room != null)
                Text(_modeLabel(),
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.dust)),
            ])),

            // Timer
            if (_room != null)
              GestureDetector(
                onTap: _extend,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isExpiring()
                        ? AppColors.fire.withOpacity(0.15) : AppColors.glass,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isExpiring() ? AppColors.fire.withOpacity(0.4) : AppColors.border,
                    ),
                  ),
                  child: Text(_timeLeft(),
                    style: GoogleFonts.dmSans(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: _isExpiring() ? AppColors.fire : AppColors.dust,
                    )),
                ),
              ),

            const SizedBox(width: 8),

            // Mode button
            GestureDetector(
              onTap: _showModeSheet,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.glass, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(child: Icon(Icons.more_horiz, color: AppColors.dust, size: 18)),
              ),
            ),
          ]),
        ),

        // Mode pending banner
        if (_room?['modePending'] != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.ember.withOpacity(0.1),
            child: Row(children: [
              const Text('⏳', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Mode change pending: ${_room!['modePending']['label']}',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.ember),
              )),
              GestureDetector(
                onTap: () => _changeMode(_room!['modePending']['proposed'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.ember.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Accept',
                    style: GoogleFonts.dmSans(
                      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ember,
                    )),
                ),
              ),
            ]),
          ),

        // Messages
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.fire))
            : _messages.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('✦', style: TextStyle(fontSize: 36, color: AppColors.fire)),
                  const SizedBox(height: 8),
                  Text('Say hello!', style: GoogleFonts.playfairDisplay(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.chalk,
                  )),
                  const SizedBox(height: 4),
                  Text('This chat expires in ${_timeLeft()}',
                    style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.dust)),
                ]))
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, i) {
                    final m = _messages[i] as Map<String, dynamic>;
                    final isMe = m['sender_id'] == _myId;
                    final deleted = m['is_deleted'] == true;
                    return _MessageBubble(
                      content: deleted ? '' : m['content'] as String? ?? '',
                      isMe: isMe,
                      isDeleted: deleted,
                      disappearsAt: m['disappears_at'] as String?,
                      time: m['created_at'] as String? ?? '',
                    );
                  },
                ),
        ),

        // Extend banner if expiring soon
        if (_room != null && _isExpiring())
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.fire.withOpacity(0.1),
            child: Row(children: [
              Expanded(child: Text(
                '⚡ Chat expiring soon! Extend to keep going.',
                style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.ember),
              )),
              GestureDetector(
                onTap: _extend,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Extend +2h',
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ]),
          ),

        // Input
        Container(
          padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
          decoration: BoxDecoration(
            color: AppColors.ink2,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.chalk),
                decoration: InputDecoration(
                  hintText: 'Say something...',
                  hintStyle: GoogleFonts.dmSans(color: AppColors.dust),
                  filled: true, fillColor: AppColors.glass,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.fire),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sending ? null : _send,
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: AppColors.fire.withOpacity(0.4),
                    blurRadius: 12, offset: const Offset(0, 4),
                  )],
                ),
                child: Center(child: _sending
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('✦', style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String content, time;
  final bool isMe, isDeleted;
  final String? disappearsAt;
  const _MessageBubble({
    required this.content, required this.isMe,
    required this.time, this.isDeleted = false, this.disappearsAt,
  });

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String? _disappearCountdown() {
    if (disappearsAt == null) return null;
    final exp = DateTime.tryParse(disappearsAt!);
    if (exp == null) return null;
    final diff = exp.difference(DateTime.now());
    if (diff.isNegative) return null;
    if (diff.inHours > 0) return '${diff.inHours}h';
    return '${diff.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isDeleted ? null
                    : isMe ? AppColors.gradient : null,
                color: isDeleted
                    ? AppColors.glass
                    : isMe ? null : const Color(0xFF1E1810),
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(18),
                  topRight:    const Radius.circular(18),
                  bottomLeft:  Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                border: isDeleted ? Border.all(color: AppColors.border) : null,
              ),
              child: isDeleted
                ? Text('💨 Message disappeared',
                    style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppColors.dust, fontStyle: FontStyle.italic,
                    ))
                : Text(content,
                    style: GoogleFonts.dmSans(
                      fontSize: 14, color: Colors.white,
                    )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_formatTime(time),
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.dust)),
                  if (_disappearCountdown() != null) ...[
                    const SizedBox(width: 4),
                    Text('⏳ ${_disappearCountdown()}',
                      style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.ember)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
