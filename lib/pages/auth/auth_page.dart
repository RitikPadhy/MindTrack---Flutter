import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- add this
import 'package:mind_track/pages/main/main_view.dart';
import '../../services/api_service.dart';

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

  @override
  void initState() {
    super.initState();

    // Make system nav bar an even darker shade of the app background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF2A3848), // <-- Updated to the new color
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

  void _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final uid = _userIdController.text.trim();

    setState(() => _loading = true);

    try {
      if (_isLogin) {
        // Login
        await _api.login(email: email, password: password);
        await _api.getProfile(); // Optional: just fetch profile if needed
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainView()),
        );
      } else {
        // Signup
        await _api.signup(uid: uid, email: email, password: password);
        // Switch to login mode silently without showing a message
        setState(() {
          _isLogin = true;
          _userIdController.clear();
        });
      }
    } catch (e) {
      // Only show errors, not success messages
      _showMessage(e.toString());
    } finally {
      setState(() => _loading = false);
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
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.01))),
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
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: TextFormField(
                        controller: _userIdController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: 'User ID',
                          hintStyle: TextStyle(fontSize: 12),
                          prefixIcon: Icon(Icons.person_outline, size: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
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
                        contentPadding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 8.0),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
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
                        contentPadding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 8.0),
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _loading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B8ABF),
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
                      elevation: 4,
                    ),
                    child: _loading
                        ? const SizedBox(
                      height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text(
                      _isLogin ? 'Sign In' : 'Create Account',
                      style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 6),
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
                      _isLogin ? 'Need an account? Sign Up' : 'Already have an account? Sign In',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
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