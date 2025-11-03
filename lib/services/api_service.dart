import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = "https://api.mindtrack.shop";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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

    // Store access + refresh tokens
    await _storage.write(key: 'access_token', value: data['access_token']);
    await _storage.write(key: 'refresh_token', value: data['refresh_token']);
    await _storage.write(key: 'uid', value: data['uid']);
    await _storage.write(
        key: 'token_expiry',
        value: (DateTime.now()
            .add(Duration(seconds: int.parse(data['expires_in'] ?? "3600")))
            .millisecondsSinceEpoch)
            .toString());

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
        await logout(await _storage.read(key: 'uid') ?? '');
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

  // ---------- Auth Headers ----------
  Future<Map<String, String>> _authHeaders() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        await _refreshToken(refreshToken);
        token = await _storage.read(key: 'access_token');
      }
    }

    if (token == null) throw Exception("Not authenticated");

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

    return jsonDecode(resp.body);
  }

  // ---------- Logout ----------
  Future<void> logout(String uid) async {
    final url = Uri.parse("$baseUrl/auth/logout");
    final headers = await _authHeaders();

    final resp = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"uid": uid}),
    );

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Logout failed");
      throw Exception(error);
    }

    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
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