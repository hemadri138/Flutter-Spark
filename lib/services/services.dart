import '../config/api_config.dart';
import 'api_service.dart';

// ─── PROFILE SERVICE ─────────────────────────────────────────────────────────
class ProfileService {
  static Future<Map<String, dynamic>> getMe() =>
      ApiService.get(ApiConfig.profileMe);

  static Future<Map<String, dynamic>> setup({
    required String name,
    required int age,
    required String city,
    required String gender,
    required String genderPref,
    required List<String> interests,
  }) =>
      ApiService.put(ApiConfig.profileSetup, {
        'name': name,
        'age': age,
        'city': city,
        'gender': gender,
        'gender_pref': genderPref,
        'interests': interests,
      });

  static Future<Map<String, dynamic>> update(Map<String, dynamic> fields) =>
      ApiService.patch(ApiConfig.profileUpdate, fields);

  static Future<Map<String, dynamic>> getById(String id) =>
      ApiService.get(ApiConfig.profileById(id));

  static Future<Map<String, dynamic>> deleteAccount() =>
      ApiService.delete(ApiConfig.profileMe);
}

// ─── PLAN SERVICE ─────────────────────────────────────────────────────────────
class PlanService {
  static Future<Map<String, dynamic>> createPlan({
    required List<String> activities,
    required String location,
    required String city,
    required String planDate,
    double? lat,
    double? lng,
    String? timeFrom,
    String? timeTo,
  }) =>
      ApiService.post(ApiConfig.plans, body: {
        'activities': activities,
        'location': location,
        'city': city,
        'plan_date': planDate,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (timeFrom != null) 'time_from': timeFrom,
        if (timeTo != null) 'time_to': timeTo,
      });

  static Future<Map<String, dynamic>> getMyPlans() =>
      ApiService.get(ApiConfig.plans);

  static Future<Map<String, dynamic>> getPlanById(String id) =>
      ApiService.get(ApiConfig.planById(id));

  static Future<Map<String, dynamic>> updatePlan(String id, Map<String, dynamic> fields) =>
      ApiService.patch(ApiConfig.planById(id), fields);

  static Future<Map<String, dynamic>> deletePlan(String id) =>
      ApiService.delete(ApiConfig.planById(id));

  static Future<Map<String, dynamic>> getPlanHistory() =>
      ApiService.get(ApiConfig.planHistory);
}

// ─── MATCHING SERVICE ─────────────────────────────────────────────────────────
class MatchingService {
  static Future<Map<String, dynamic>> getCandidates(String planId) =>
      ApiService.get(ApiConfig.candidates(planId));

  static Future<Map<String, dynamic>> spark({
    required String fromPlanId,
    required String toPlanId,
    required String toUserId,
  }) =>
      ApiService.post(ApiConfig.spark, body: {
        'fromPlanId': fromPlanId,
        'toPlanId': toPlanId,
        'toUserId': toUserId,
      });

  static Future<Map<String, dynamic>> getMatches() =>
      ApiService.get(ApiConfig.myMatches);

  static Future<Map<String, dynamic>> unmatch(String matchId) =>
      ApiService.delete(ApiConfig.unmatch(matchId));
}

// ─── CHAT SERVICE ─────────────────────────────────────────────────────────────
class ChatService {
  static Future<Map<String, dynamic>> getRooms() =>
      ApiService.get(ApiConfig.chatRooms);

  static Future<Map<String, dynamic>> getRoom(String roomId) =>
      ApiService.get(ApiConfig.roomById(roomId));

  static Future<Map<String, dynamic>> sendMessage(String roomId, String content) =>
      ApiService.post(ApiConfig.sendMessage(roomId), body: {'content': content});

  static Future<Map<String, dynamic>> extendChat(String roomId) =>
      ApiService.post(ApiConfig.extendChat(roomId));

  static Future<Map<String, dynamic>> changeMode(String roomId, String mode) =>
      ApiService.post(ApiConfig.changeMode(roomId), body: {'mode': mode});

  static Future<Map<String, dynamic>> getMessages(String roomId, {String? before}) =>
      ApiService.get(ApiConfig.roomMessages(roomId),
          query: before != null ? {'before': before} : null);
}

// ─── COUPON SERVICE ───────────────────────────────────────────────────────────
class CouponService {
  static Future<Map<String, dynamic>> getCoupons({String? city, double? lat, double? lng}) =>
      ApiService.get(ApiConfig.coupons, query: {
        if (city != null) 'city': city,
        if (lat != null) 'lat': lat.toString(),
        if (lng != null) 'lng': lng.toString(),
      });

  static Future<Map<String, dynamic>> getCoupon(String id) =>
      ApiService.get(ApiConfig.couponById(id));

  static Future<Map<String, dynamic>> redeem(String id) =>
      ApiService.post(ApiConfig.redeemCoupon(id));

  static Future<Map<String, dynamic>> getCouponsForPlan(String planId) =>
      ApiService.get(ApiConfig.couponsForPlan(planId));
}
