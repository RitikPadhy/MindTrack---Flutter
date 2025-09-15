import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // ✅ Use HTTPS (production-ready)
  final String baseUrl = "https://api.mindtrack.shop/auth";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ---------- Signup ----------
  Future<Map<String, dynamic>> signup({
    required String uid,
    required String email,
    required String password,
    String role = "user",
  }) async {
    final url = Uri.parse("$baseUrl/signup");
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "uid": uid,
        "email": email,
        "password": password,
        "role": role,
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
    final url = Uri.parse("$baseUrl/login");
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

    // ✅ Store the correct token
    final token = data['access_token'] ?? data['idToken'];
    if (token != null) {
      await _storage.write(key: 'access_token', value: token);
    }

    return data;
  }

  // ---------- Get Profile ----------
  Future<Map<String, dynamic>> getProfile() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) throw Exception("No access token found. Please login first.");

    final url = Uri.parse("$baseUrl/me");
    final resp = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Failed to fetch profile");
      throw Exception(error);
    }

    return jsonDecode(resp.body);
  }

  // ---------- Logout ----------
  Future<void> logout(String uid) async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) throw Exception("No access token found.");

    final url = Uri.parse("$baseUrl/logout");
    final resp = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"uid": uid}),
    );

    if (resp.statusCode != 200) {
      final error = _safeError(resp.body, "Logout failed");
      throw Exception(error);
    }

    // ✅ Clear token after logout
    await _storage.delete(key: 'access_token');
  }

  // ---------- DNS Check ----------
  Future<List<InternetAddress>> resolveApi() async {
    try {
      final uri = Uri.parse(baseUrl);
      final host = uri.host; // 'api.mindtrack.shop'
      final addresses = await InternetAddress.lookup(host);
      return addresses;
    } on SocketException catch (e) {
      print("DNS lookup failed for $baseUrl: $e");
      return [];
    }
  }

  // ---------- Helper ----------
  String _safeError(String body, String fallback) {
    try {
      return jsonDecode(body)['detail'] ?? fallback;
    } catch (_) {
      return fallback;
    }
  }
}