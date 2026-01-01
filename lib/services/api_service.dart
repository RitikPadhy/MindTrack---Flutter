import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ApiService {
  final String baseUrl = "https://api.mindtrack.shop";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Key for storing the user's tasks/schedule data
  static const String scheduleStorageKey = 'user_schedule_data';

  // ---------- Login with UID ----------
  Future<Map<String, dynamic>> login({
    required String uid,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "uid": uid,
        "password": password,
      }),
    );

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Login failed");
      throw Exception(error);
    }

    final data = jsonDecode(resp.body);
    final customToken = data['custom_token'] as String;

    // 🔑 Exchange custom token for Firebase ID token
    final idToken = await _exchangeCustomToken(customToken);

    // Store ID token + UID securely
    await _storage.write(key: 'access_token', value: idToken);
    await _storage.write(key: 'uid', value: uid);

    debugPrint('DEBUG: ID Token saved. Length: ${idToken.length}');

    return data;
  }

  // ---------- Exchange Custom Token for ID Token ----------
  Future<String> _exchangeCustomToken(String customToken) async {
    try {
      // Ensure Firebase is initialized only once
      await Firebase.initializeApp();

      final userCredential =
      await FirebaseAuth.instance.signInWithCustomToken(customToken);
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception("Failed to get ID token from Firebase user.");
      }
      return idToken;
    } catch (e) {
      debugPrint('ERROR: Failed to exchange custom token: $e');
      throw Exception('Failed to authenticate with Firebase.');
    }
  }

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

  // ---------- Auto Login ----------
  Future<bool> tryAutoLogin() async {
    final token = await _storage.read(key: 'access_token');
    final uid = await _storage.read(key: 'uid');
    return token != null && uid != null;
  }

  // ---------- Auth Headers ----------
  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) throw Exception("Not authenticated. Access token missing.");

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ---------- Get Profile ----------
  Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse("$baseUrl/auth/me");
    final headers = await _authHeaders();

    final resp = await http.get(url, headers: headers);

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Failed to fetch profile");
      throw Exception(error);
    }

    final data = jsonDecode(resp.body);

    // Save gender
    if (data.containsKey('gender')) {
      await _storage.write(key: 'gender', value: data['gender']);
    }

    // Save creation date
    if (data.containsKey('createdAt')) {
      final prefs = await SharedPreferences.getInstance();
      try {
        final createdAtDate = DateTime.parse(data['createdAt']);
        await prefs.setString(
            'user_created_at', createdAtDate.millisecondsSinceEpoch.toString());
      } catch (_) {}
    }

    // Save tasks
    if (data.containsKey('tasks')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(scheduleStorageKey, jsonEncode(data['tasks']));
    }

    return data;
  }

  // ---------- Logout ----------
  Future<void> logout() async {
    final uid = await _storage.read(key: 'uid');
    if (uid == null) return;

    final url = Uri.parse("$baseUrl/auth/logout");
    final headers =
    await _authHeaders().catchError((_) => {"Content-Type": "application/json"});

    await http.post(url, headers: headers, body: jsonEncode({"uid": uid}));

    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'uid');
    await _storage.delete(key: 'gender');
    await _storage.delete(key: 'token_expiry');
  }

  // ---------- DNS Check ----------
  Future<List<InternetAddress>> resolveApi() async {
    try {
      final uri = Uri.parse(baseUrl);
      final host = uri.host;
      final addresses = await InternetAddress.lookup(host);
      return addresses;
    } on SocketException {
      return [];
    }
  }

  // ---------- Get Reading Material ----------
  Future<Map<String, dynamic>> getReadingMaterial(int sectionId) async {
    final url = Uri.parse("$baseUrl/reading/reading-material/$sectionId");
    final resp = await http.get(url, headers: {"Content-Type": "application/json"});

    if (resp.statusCode != 200) {
      throw Exception("Failed to fetch section: ${resp.body}");
    }

    return jsonDecode(resp.body);
  }

  // ---------- Get Day Routine ----------
  Future<Map<String, dynamic>> getDayRoutine(String date) async {
    final url = Uri.parse("$baseUrl/routines/get-day-routine?date=$date");
    final headers = await _authHeaders();

    final resp = await http.get(url, headers: headers);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else if (resp.statusCode == 404) {
      final error = _safeError(resp.body, "No routine found for date $date");
      throw Exception(error);
    } else {
      final error = _safeError(resp.body, "Failed to fetch routine for date $date");
      throw Exception(error);
    }
  }

  // ---------- Save Day Completion Granular ----------
  Future<void> saveDayCompletionGranular({
    required String date,
    required Map<String, Map<String, bool>> hourSlotsStatus,
  }) async {
    final url = Uri.parse("$baseUrl/routines/save-day");
    final headers = await _authHeaders();

    final payload = {
      "date": date,
      "hour_slots_status": hourSlotsStatus,
    };

    final resp = await http.post(url, headers: headers, body: jsonEncode(payload));

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Failed to save granular day completion for $date");
      throw Exception(error);
    }
  }

  // ---------- Update Weekly Feedback ----------
  Future<void> updateWeeklyFeedback({
    required int weekNumber,
    required double energyLevels,
    required double satisfaction,
    required double happiness,
    required double proudOfAchievements,
    required double howBusy,
    String? feedbackText,
  }) async {
    final url = Uri.parse("$baseUrl/weekly-feedback/update-week");
    final headers = await _authHeaders();

    final payload = {
      "week_number": weekNumber,
      "energy_levels": energyLevels,
      "satisfaction": satisfaction,
      "happiness": happiness,
      "proud_of_achievements": proudOfAchievements,
      "how_busy": howBusy,
      "feedback_text": feedbackText,
    };

    final resp = await http.patch(url, headers: headers, body: jsonEncode(payload));

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Failed to update weekly feedback for week $weekNumber");
      throw Exception(error);
    }
  }

  // ---------- Get Weekly Achievements ----------
  Future<List<dynamic>> getWeeklyAchievements() async {
    final url = Uri.parse("$baseUrl/messages");
    final headers = await _authHeaders();

    final resp = await http.get(url, headers: headers);

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Failed to load weekly achievements");
      throw Exception(error);
    }

    return jsonDecode(resp.body);
  }

  // ---------- Helper: Safe Error ----------
  String _safeError(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded.containsKey('detail')) return decoded['detail'];
      return body;
    } catch (_) {
      return fallback;
    }
  }
}