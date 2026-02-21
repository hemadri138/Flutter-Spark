class ApiConfig {
  // ─── CHANGE THIS based on where you're testing ───────────────────────────
  //
  // Android Emulator  → 'http://10.0.2.2:3000/api/v1'
  // iOS Simulator     → 'http://localhost:3000/api/v1'
  // Real device (WiFi)→ 'http://YOUR_PC_IP:3000/api/v1'  e.g. 192.168.1.5
  // Production        → 'https://your-app.onrender.com/api/v1'
  //
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  // ── Auth ─────────────────────────────────────────────────────────────────
  static const String sendOtp      = '/auth/send-otp';
  static const String verifyOtp    = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh';

  // ── Profile ───────────────────────────────────────────────────────────────
  static const String profileMe     = '/profile/me';
  static const String profileSetup  = '/profile/setup';
  static const String profileUpdate = '/profile/update';
  static String profileById(String id) => '/profile/$id';

  // ── Plans ─────────────────────────────────────────────────────────────────
  static const String plans       = '/plans';
  static const String planHistory = '/plans/history/all';
  static String planById(String id) => '/plans/$id';

  // ── Matching ──────────────────────────────────────────────────────────────
  static String candidates(String planId) => '/matching/candidates/$planId';
  static const String spark     = '/matching/spark';
  static const String myMatches = '/matching/matches';
  static String unmatch(String id) => '/matching/unmatch/$id';

  // ── Chat ──────────────────────────────────────────────────────────────────
  static const String chatRooms = '/chat/rooms';
  static String roomById(String id)       => '/chat/rooms/$id';
  static String sendMessage(String id)    => '/chat/rooms/$id/messages';
  static String extendChat(String id)     => '/chat/rooms/$id/extend';
  static String changeMode(String id)     => '/chat/rooms/$id/mode';
  static String roomMessages(String id)   => '/chat/rooms/$id/messages';

  // ── Coupons ───────────────────────────────────────────────────────────────
  static const String coupons = '/coupons';
  static String couponById(String id)    => '/coupons/$id';
  static String redeemCoupon(String id)  => '/coupons/$id/redeem';
  static String couponsForPlan(String id)=> '/coupons/for-plan/$id';
}
