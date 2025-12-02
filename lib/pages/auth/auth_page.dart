// auth_page.dart (Modified)
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mind_track/pages/main/main_view.dart';
import 'package:mind_track/services/api_service.dart';
import 'package:mind_track/services/localization_service.dart';
import 'package:mind_track/l10n/app_localizations.dart';
import 'package:mind_track/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final ApiService _api = ApiService();
  final LocalizationService _localizationService = LocalizationService();

  bool _isLogin = true;
  bool _loading = false;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF2A3848),
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _loadLanguage() async {
    final locale = await _localizationService.loadLanguage();
    setState(() {
      _selectedLanguage = locale.languageCode;
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    await _localizationService.setLanguage(languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
    
    // Trigger app rebuild with new locale
    final provider = _LocalizationProvider.of(context);
    provider?.changeLanguage(Locale(languageCode));
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: LocalizationService.supportedLanguages.map((lang) {
              return RadioListTile<String>(
                title: Text(lang.nativeName),
                subtitle: Text(lang.name),
                value: lang.code,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  if (value != null) {
                    _changeLanguage(value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _handleAuth() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    // Check for empty fields based on mode
    if (_isLogin) {
      if (email.isEmpty || oldPassword.isEmpty) {
        _showMessage(l10n.enterEmailPassword);
        return;
      }
    } else {
      if (email.isEmpty || oldPassword.isEmpty || newPassword.isEmpty) {
        _showMessage(l10n.fillAllFields);
        return;
      }
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
        _showMessage(l10n.cannotReachServer);
        return;
      }

      // ---------- Login / Change Password ----------
      if (_isLogin) {
        // --- LOGIN LOGIC (Remains the same) ---
        await _api.login(email: email, password: oldPassword); // oldPassword is the current password

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
        // --- CHANGE PASSWORD LOGIC (New) ---
        await _api.changePassword(
          email: email,
          oldPassword: oldPassword,
          newPassword: newPassword,
        );

        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        _showMessage(l10n.passwordChanged);
        // Clear all fields and switch back to login mode after successful change
        setState(() {
          _isLogin = true;
          _emailController.clear();
          _oldPasswordController.clear();
          _newPasswordController.clear();
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
    final l10n = AppLocalizations.of(context);
    final passwordHintText = _isLogin ? l10n.password : l10n.oldPassword;

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
          // Language selector button at top right
          Positioned(
            top: 48,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showLanguageSelector,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha((0.5 * 255).round())),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        LocalizationService.getLanguageName(_selectedLanguage),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // New Password Field (Replaces Gender/User ID field)
                  if (!_isLogin) ...[
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.9 * 255).round()),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: TextFormField(
                        controller: _newPasswordController,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: l10n.newPassword,
                          hintStyle: const TextStyle(fontSize: 12),
                          prefixIcon: const Icon(Icons.lock_open, size: 14),
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
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
                      decoration: InputDecoration(
                        hintText: l10n.email,
                        hintStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(Icons.email_outlined, size: 14),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Old/Current Password Field
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.9 * 255).round()),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: TextFormField(
                      controller: _oldPasswordController, // Now for old/current password
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: passwordHintText,
                        hintStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(Icons.lock_outline, size: 14),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Sign In / Change Password Button
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
                      _isLogin ? l10n.signIn : l10n.setNewPassword,
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
                        // Clear New Password field when switching back to Login
                        if (_isLogin) _newPasswordController.clear();
                      });
                    },
                    child: Text(
                      _isLogin
                          ? l10n.forgotPassword
                          : l10n.rememberedPassword,
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