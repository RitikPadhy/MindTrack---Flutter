import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = "http://api.mindtracker.dedyn.io/auth"; // your backend
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
      final error = jsonDecode(resp.body)['detail'] ?? 'Sign up failed';
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
      final error = jsonDecode(resp.body)['detail'] ?? 'Login failed';
      throw Exception(error);
    }

    final data = jsonDecode(resp.body);

    // Save access token in secure storage
    final token = data['idToken'];
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
      throw Exception("Failed to fetch profile: ${resp.body}");
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
      throw Exception("Logout failed: ${resp.body}");
    }

    // Delete token from secure storage
    await _storage.delete(key: 'access_token');
  }
}