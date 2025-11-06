import 'dart:io';
import 'dart:convert'; // For jsonEncode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mind_track/pages/main/main_view.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For local data storage

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final ApiService _api = ApiService();

  bool _isLogin = true;
  bool _loading = false;

  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF2A3848),
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final uid = _userIdController.text.trim();

    if (!_isLogin && _selectedGender == null) {
      _showMessage("Please select your gender.");
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);

    try {
      // ---------- DNS Check ----------
      try {
        final addresses = await _api.resolveApi();
        if (addresses.isEmpty) {
          throw SocketException("No IP found for api.mindtrack.shop");
        }
      } on SocketException catch (_) {
        _showMessage(
          "Cannot reach server. Please check your internet or DNS settings.",
        );
        return;
      }

      // ---------- Login / Signup ----------
      if (_isLogin) {
        await _api.login(email: email, password: password);

        // ✅ 1. Call API to get profile which includes the dynamic 'tasks' array
        final profileData = await _api.getProfile();

        // ✅ 2. Extract the tasks array and cast it
        final List<Map<String, dynamic>> fetchedTasks =
        (profileData['tasks'] as List).cast<Map<String, dynamic>>();

        // ✅ 3. Save the tasks array locally using shared_preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            ApiService.scheduleStorageKey,
            jsonEncode(fetchedTasks) // Convert List<Map> to JSON string for saving
        );

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainView()),
        );
      } else {
        await _api.signup(
          uid: uid,
          email: email,
          password: password,
          gender: _selectedGender ?? "Other",
        );

        if (!mounted) return;
        setState(() {
          _isLogin = true;
          _userIdController.clear();
        });
      }
    } catch (e) {
      if (mounted) _showMessage(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/logo.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withAlpha((0.01 * 255).round())),
          ),
          Positioned.fill(
            child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
          ),
          Positioned.fill(child: Container(color: Colors.black.withAlpha(128))),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_isLogin) ...[
                    // Gender Dropdown Field (Vertical Alignment Fixed, Dropdown BG White)
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.9 * 255).round()),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        dropdownColor: Colors.white,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.person, size: 14),
                          // Adjusted to push content up for better vertical centering
                          contentPadding:
                          EdgeInsets.fromLTRB(8, 4, 8, 12),
                          hintText: 'Select Gender',
                          hintStyle: TextStyle(fontSize: 12),
                        ),
                        isDense: true,
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                        items: ['Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedGender = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // User ID / Username Field
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.9 * 255).round()),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: TextFormField(
                        controller: _userIdController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: 'Username (User ID)',
                          hintStyle: TextStyle(fontSize: 12),
                          prefixIcon: Icon(Icons.badge, size: 14),
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Email Field
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.9 * 255).round()),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(fontSize: 12),
                        prefixIcon: Icon(Icons.email_outlined, size: 14),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Password Field
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.9 * 255).round()),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(fontSize: 12),
                        prefixIcon: Icon(Icons.lock_outline, size: 14),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Sign In / Create Account Button
                  ElevatedButton(
                    onPressed: _loading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B8ABF),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0)),
                      elevation: 4,
                    ),
                    child: _loading
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      _isLogin ? 'Sign In' : 'Create Account',
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Toggle Button
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                      setState(() {
                        _isLogin = !_isLogin;
                        if (_isLogin) _userIdController.clear();
                      });
                    },
                    child: Text(
                      _isLogin
                          ? 'Need an account? Sign Up'
                          : 'Already have an account? Sign In',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}