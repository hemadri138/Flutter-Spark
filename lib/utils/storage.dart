import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const _tokenKey   = 'spark_jwt';
  static const _userIdKey  = 'spark_user_id';
  static const _verifiedKey= 'spark_verified';
  static const _profileKey = 'spark_profile_complete';

  // ── Token ─────────────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── User meta ─────────────────────────────────────────────────────────────
  static Future<void> saveUserMeta({
    required String userId,
    required bool isVerified,
    required bool isProfileComplete,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setBool(_verifiedKey, isVerified);
    await prefs.setBool(_profileKey, isProfileComplete);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<bool> isVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_verifiedKey) ?? false;
  }

  static Future<bool> isProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_profileKey) ?? false;
  }

  // ── Clear all (logout) ────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
