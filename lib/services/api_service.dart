import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://api.mindtrack.shop";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String scheduleStorageKey = 'user_schedule_data';

  /* -------------------------------------------------------------------------- */
  /*                                   LOGIN                                    */
  /* -------------------------------------------------------------------------- */

  Future<Map<String, dynamic>> login({
    required String uid,
    required String password,
  }) async {
    final resp = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "uid": uid,
        "password": password,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception(_safeError(resp.body, "Login failed"));
    }

    final data = jsonDecode(resp.body);
    final customToken = data['custom_token'] as String;

    final userCredential =
    await FirebaseAuth.instance.signInWithCustomToken(customToken);

    final idToken = await userCredential.user?.getIdToken(true);
    if (idToken == null) {
      throw Exception("Failed to retrieve Firebase ID token");
    }

    await _storage.write(key: 'uid', value: uid);

    debugPrint('✅ Login successful — UID: $uid');
    return data;
  }

  /* -------------------------------------------------------------------------- */
  /*                                CHANGE PASSWORD                                 */
  /* -------------------------------------------------------------------------- */

  // ---------- Change Password (Set New Password via UID + Current Password) ----------
  Future<void> changePassword({
    required String uid,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse("$baseUrl/auth/set-new-password");

    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "uid": uid,
        "password": oldPassword, // current password
        "new_password": newPassword,
      }),
    );

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Failed to change password");
      throw Exception(error);
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                AUTO LOGIN                                  */
  /* -------------------------------------------------------------------------- */

  Future<bool> tryAutoLogin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      await user.getIdToken(true); // force refresh if needed
      await _storage.write(key: 'uid', value: user.uid);

      debugPrint('✅ Auto-login successful for ${user.uid}');
      return true;
    } catch (e) {
      debugPrint('❌ Auto-login failed: $e');
      return false;
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                               AUTH HEADERS                                 */
  /* -------------------------------------------------------------------------- */

  Future<Map<String, String>> _authHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Not authenticated");

    final token = await user.getIdToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  /* -------------------------------------------------------------------------- */
  /*                                 PROFILE                                    */
  /* -------------------------------------------------------------------------- */

  Future<Map<String, dynamic>> getProfile() async {
    final resp = await http.get(
      Uri.parse("$baseUrl/auth/me"),
      headers: await _authHeaders(),
    );

    if (resp.statusCode != 200) {
      throw Exception(_safeError(resp.body, "Failed to fetch profile"));
    }

    final data = jsonDecode(resp.body);

    final prefs = await SharedPreferences.getInstance();

    if (data['gender'] != null) {
      await _storage.write(key: 'gender', value: data['gender']);
    }

    if (data['createdAt'] != null) {
      try {
        final createdAt = DateTime.parse(data['createdAt']);
        await prefs.setInt(
            'user_created_at', createdAt.millisecondsSinceEpoch);
      } catch (_) {}
    }

    if (data['tasks'] != null) {
      await prefs.setString(
          scheduleStorageKey, jsonEncode(data['tasks']));
    }

    return data;
  }

  /* -------------------------------------------------------------------------- */
  /*                                   LOGOUT                                   */
  /* -------------------------------------------------------------------------- */

  Future<void> logout() async {
    try {
      final uid = await _storage.read(key: 'uid');
      if (uid != null) {
        await http.post(
          Uri.parse("$baseUrl/auth/logout"),
          headers: await _authHeaders(),
          body: jsonEncode({"uid": uid}),
        );
      }
    } catch (_) {}

    await FirebaseAuth.instance.signOut();
    await _storage.deleteAll();
  }

  /* -------------------------------------------------------------------------- */
  /*                               NETWORK UTILS                                */
  /* -------------------------------------------------------------------------- */

  Future<List<InternetAddress>> resolveApi() async {
    try {
      return await InternetAddress.lookup(Uri.parse(baseUrl).host);
    } on SocketException {
      return [];
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                             READING MATERIAL                                */
  /* -------------------------------------------------------------------------- */

  Future<Map<String, dynamic>> getReadingMaterial(int sectionId) async {
    final resp = await http.get(
      Uri.parse("$baseUrl/reading/reading-material/$sectionId"),
      headers: const {"Content-Type": "application/json"},
    );

    if (resp.statusCode != 200) {
      throw Exception("Failed to fetch reading material");
    }

    return jsonDecode(resp.body);
  }

  Future<void> incrementReadingView(int sectionId) async {
    final resp = await http.post(
      Uri.parse("$baseUrl/reading/reading-material/$sectionId/view"),
      headers: await _authHeaders(),
    );

    if (resp.statusCode != 200) {
      throw Exception("Failed to update reading count");
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                ROUTINES                                    */
  /* -------------------------------------------------------------------------- */

  Future<Map<String, dynamic>> getDayRoutine(String date) async {
    final resp = await http.get(
      Uri.parse("$baseUrl/routines/get-day-routine?date=$date"),
      headers: await _authHeaders(),
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }

    throw Exception(_safeError(resp.body, "Routine not found"));
  }

  Future<void> saveDayCompletionGranular({
    required String date,
    required Map<String, Map<String, Map<String, dynamic>>> hourSlotsStatus,
  }) async {
    final resp = await http.patch(
      Uri.parse("$baseUrl/routines/update-day"),
      headers: await _authHeaders(),
      body: jsonEncode({
        "date": date,
        "hour_slots_status": hourSlotsStatus,
      }),
    );

    if (resp.statusCode != 200) {
      // This will help you catch 422 (validation) or 500 (logic) errors
      debugPrint("SERVER ERROR: ${resp.statusCode} - ${resp.body}");
      throw Exception("Failed to save routine: ${resp.body}");
    }
  }

  // ---------- Get Progress (Day / Week / Month) ----------
  Future<Map<String, dynamic>> getProgress(String period) async {
    final url = Uri.parse("$baseUrl/track_progress/progress/$period");
    final headers = await _authHeaders(); // Needs valid token

    final resp = await http.get(url, headers: headers);

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Failed to fetch progress");
      throw Exception(error);
    }

    return jsonDecode(resp.body);
  }

  /* -------------------------------------------------------------------------- */
  /*                            WEEKLY FEEDBACK                                 */
  /* -------------------------------------------------------------------------- */

  Future<void> updateWeeklyFeedback({
    required int weekNumber,
    required double energyLevels,
    required double satisfaction,
    required double happiness,
    required double proudOfAchievements,
    required double howBusy,
    String? feedbackText,
  }) async {
    final resp = await http.patch(
      Uri.parse("$baseUrl/weekly-feedback/update-week"),
      headers: await _authHeaders(),
      body: jsonEncode({
        "week_number": weekNumber,
        "energy_levels": energyLevels,
        "satisfaction": satisfaction,
        "happiness": happiness,
        "proud_of_achievements": proudOfAchievements,
        "how_busy": howBusy,
        "feedback_text": feedbackText,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception("Failed to update weekly feedback");
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                             ACHIEVEMENTS                                   */
  /* -------------------------------------------------------------------------- */

  Future<List<dynamic>> getWeeklyAchievements() async {
    final resp = await http.get(
      Uri.parse("$baseUrl/achievements/messages"),
      headers: await _authHeaders(),
    );

    if (resp.statusCode != 200) {
      throw Exception("Failed to load achievements");
    }

    return jsonDecode(resp.body);
  }

  /* -------------------------------------------------------------------------- */
  /*                                   MAUQ                                     */
  /* -------------------------------------------------------------------------- */

  Future<void> submitMAUQ(Map<String, dynamic> responses) async {
    final resp = await http.post(
      Uri.parse("$baseUrl/question/mauq"),
      headers: await _authHeaders(),
      body: jsonEncode(responses),
    );

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception("Failed to submit MAUQ");
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                                   UTILS                                    */
  /* -------------------------------------------------------------------------- */

  String _safeError(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['detail'] != null) {
        return decoded['detail'];
      }
      return body;
    } catch (_) {
      return fallback;
    }
  }
}