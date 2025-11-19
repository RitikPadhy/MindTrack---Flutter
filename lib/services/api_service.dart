import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://api.mindtrack.shop";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Key for storing the user's tasks/schedule data
  static const String scheduleStorageKey = 'user_schedule_data';

  // --7- NEW: Change Password ---
  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse("$baseUrl/auth/change-password");
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "old_password": oldPassword,
        "new_password": newPassword,
      }),
    );

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Failed to change password");
      throw Exception(error);
    }
    // No data to return, just a success message
  }

  // ---------- Login ----------
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Login failed");
      throw Exception(error);
    }

    final data = jsonDecode(resp.body);

    // Store access + refresh tokens (using flutter_secure_storage)
    await _storage.write(key: 'access_token', value: data['access_token']);
    await _storage.write(key: 'refresh_token', value: data['refresh_token']);
    // ... other storage logic ...

    debugPrint('DEBUG: Token saved. Access Token length: ${data['access_token'].length}');

    return data;
  }

  // ---------- Auto Login Logic ----------
  Future<bool> tryAutoLogin() async {
    final accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(key: 'refresh_token');
    final expiryStr = await _storage.read(key: 'token_expiry');

    if (accessToken == null || refreshToken == null || expiryStr == null) {
      return false; // No session saved
    }

    final expiry =
    DateTime.fromMillisecondsSinceEpoch(int.tryParse(expiryStr) ?? 0);

    if (DateTime.now().isBefore(expiry)) {
      // Token still valid
      return true;
    } else {
      // Expired -> try refreshing
      try {
        await _refreshToken(refreshToken);
        return true;
      } catch (_) {
        // You should not call logout here as it requires a token/uid which might be missing/invalid
        return false;
      }
    }
  }

  // ---------- Refresh Token ----------
  Future<void> _refreshToken(String refreshToken) async {
    final url = Uri.parse("$baseUrl/auth/refresh-token");
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh_token": refreshToken}),
    );

    if (resp.statusCode != 200) {
      throw Exception("Token refresh failed");
    }

    final data = jsonDecode(resp.body);

    await _storage.write(key: 'access_token', value: data['access_token']);
    await _storage.write(key: 'refresh_token', value: data['refresh_token']);
    await _storage.write(
        key: 'token_expiry',
        value: (DateTime.now()
            .add(Duration(seconds: int.parse(data['expires_in'] ?? "3600")))
            .millisecondsSinceEpoch)
            .toString());
  }

  // ---------- Auth Headers (Includes Refresh Logic) ----------
  Future<Map<String, String>> _authHeaders() async {
    debugPrint('DEBUG: Attempting to retrieve access token...');
    String? token = await _storage.read(key: 'access_token');

    // 1. If access token is missing, try to refresh using the refresh token
    if (token == null) {
      debugPrint('DEBUG: Access token is NULL. Checking for refresh token.');
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        debugPrint('DEBUG: Refresh token found. Attempting refresh...');
        try {
          await _refreshToken(refreshToken);
          token = await _storage.read(key: 'access_token');
          debugPrint('DEBUG: Token refreshed successfully. New token length: ${token?.length}');
        } catch (e) {
          debugPrint('DEBUG ERROR: Token refresh failed: $e');
          // Refresh failed, token remains null
        }
      }
    }

    // 2. If token is still null after checking/refreshing, throw exception
    if (token == null) {
      debugPrint('DEBUG ERROR: Final token is NULL. Throwing "Not authenticated."');
      throw Exception("Not authenticated. Access token not available.");
    }

    debugPrint('DEBUG: Auth Headers successfully created. Token length: ${token.length}');

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

    // Save 'gender' to secure storage (as per original code)
    if (data.containsKey('gender')) {
      await _storage.write(key: 'gender', value: data['gender']);
    }

    // New logic: Save 'createdAt' to SharedPreferences
    if (data.containsKey('createdAt')) {
      final prefs = await SharedPreferences.getInstance();
      // Assuming 'createdAt' from API is an ISO string or similar, we convert it
      // to a millisecond timestamp string for easy loading in ContentPage4.
      try {
        final createdAtDate = DateTime.parse(data['createdAt']);
        await prefs.setString(
            'user_created_at',
            createdAtDate.millisecondsSinceEpoch.toString()
        );
      } catch (e) {
        debugPrint('ERROR: Failed to parse and save createdAt date: $e');
      }
    }

    return data;
  }

  // ---------- Logout ----------
  Future<void> logout(String uid) async {
    final url = Uri.parse("$baseUrl/auth/logout");
    // We try to get headers, but proceed even if token is missing (for cleanup)
    final headers = await _authHeaders().catchError((_) => {"Content-Type": "application/json"});

    final resp = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"uid": uid}),
    );

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Logout failed");
      debugPrint("Logout failed: $error");
    }

    // Always clear local tokens on logout attempt
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'uid');
    await _storage.delete(key: 'token_expiry');
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

  // NEW METHOD to fetch historical or future day routine and tasks
  Future<Map<String, dynamic>> getDayRoutine(String date) async {
    final url = Uri.parse("$baseUrl/routines/get-day-routine?date=$date");
    final headers = await _authHeaders(); // Needs valid token

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

  // 🚩 NEW METHOD: Saves the local checkbox state (i-j-k) after conversion to granular HH:MM slots
  Future<void> saveDayCompletionGranular({
    required String date,
    required Map<String, Map<String, bool>> hourSlotsStatus,
  }) async {
    final url = Uri.parse("$baseUrl/routines/save-day");
    final headers = await _authHeaders(); // Needs valid token

    final payload = {
      "date": date,
      "hour_slots_status": hourSlotsStatus,
    };

    debugPrint("DEBUG: Sending granular completion for $date");

    final resp = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Failed to save granular day completion for $date");
      throw Exception(error);
    }
  }

  // Week Feedback
  // Week Feedback
  Future<void> updateWeeklyFeedback({
    required int weekNumber,
    required double energyLevels,
    required double satisfaction,
    required double happiness,
    required double proudOfAchievements,
    required double howBusy,
    String? feedbackText, // ✅ NEW PARAMETER
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
      "feedback_text": feedbackText, // ✅ NEW FIELD IN PAYLOAD
    };

    final resp = await http.patch(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Failed to update weekly feedback for week $weekNumber");
      throw Exception(error);
    }
  }

  // 🏆 NEW METHOD: Fetch weekly achievement messages
  Future<List<dynamic>> getWeeklyAchievements() async {
    final url = Uri.parse("$baseUrl/messages"); // Endpoint: /messages
    final headers = await _authHeaders();

    final resp = await http.get(url, headers: headers);

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Failed to load weekly achievements");
      throw Exception(error);
    }

    // The API returns a JSON array of achievement maps
    return jsonDecode(resp.body);
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