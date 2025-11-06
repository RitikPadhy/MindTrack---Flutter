import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl = "https://api.mindtrack.shop";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Key for storing the user's tasks/schedule data
  static const String scheduleStorageKey = 'user_schedule_data';

  // ---------- Signup ----------
  Future<Map<String, dynamic>> signup({
    required String uid,
    required String email,
    required String password,
    required String gender,
    String role = "Patient",
  }) async {
    final url = Uri.parse("$baseUrl/auth/signup");
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "uid": uid,
        "email": email,
        "password": password,
        "role": role,
        "gender": gender,
      }),
    );

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Sign up failed");
      throw Exception(error);
    }

    return jsonDecode(resp.body);
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
      // Expired → try refreshing
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