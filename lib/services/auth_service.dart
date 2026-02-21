import '../config/api_config.dart';
import '../utils/storage.dart';
import 'api_service.dart';

class AuthService {
  // ── Send OTP ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> sendOtp({
    required String contact,
    required String type, // 'phone' or 'email'
  }) async {
    return ApiService.post(
      ApiConfig.sendOtp,
      body: {'contact': contact, 'type': type},
      auth: false,
    );
  }

  // ── Verify OTP → returns token ────────────────────────────────────────────
  static Future<Map<String, dynamic>> verifyOtp({
    required String contact,
    required String otp,
    required String type,
  }) async {
    final res = await ApiService.post(
      ApiConfig.verifyOtp,
      body: {'contact': contact, 'otp': otp, 'type': type},
      auth: false,
    );

    // Persist token + user meta locally
    if (res['token'] != null) {
      await Storage.saveToken(res['token'] as String);
      final user = res['user'] as Map<String, dynamic>? ?? {};
      await Storage.saveUserMeta(
        userId: user['id'] as String? ?? '',
        isVerified: user['isVerified'] as bool? ?? false,
        isProfileComplete: user['isProfileComplete'] as bool? ?? false,
      );
    }

    return res;
  }

  // ── Refresh token ─────────────────────────────────────────────────────────
  static Future<void> refreshToken() async {
    final token = await Storage.getToken();
    if (token == null) return;
    final res = await ApiService.post(
      ApiConfig.refreshToken,
      body: {'token': token},
      auth: false,
    );
    if (res['token'] != null) {
      await Storage.saveToken(res['token'] as String);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await Storage.clearAll();
  }

  // ── Is logged in ──────────────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await Storage.getToken();
    return token != null && token.isNotEmpty;
  }
}
