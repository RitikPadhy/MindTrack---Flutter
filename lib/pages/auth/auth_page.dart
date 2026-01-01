// auth_page.dart (Updated for UID login)
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mind_track/pages/main/main_view.dart';
import 'package:mind_track/services/api_service.dart';
import 'package:mind_track/services/localization_service.dart';
import 'package:mind_track/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _uidController = TextEditingController();
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
    if (mounted) {
      setState(() {
        _selectedLanguage = languageCode;
      });
    }
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
              final isSelected = lang.code == _selectedLanguage;
              return ListTile(
                title: Text(lang.nativeName),
                subtitle: Text(lang.name),
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? Colors.green : Colors.grey,
                ),
                selected: isSelected,
                onTap: () {
                  _changeLanguage(lang.code);
                  Navigator.pop(context);
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
    final uid = _uidController.text.trim();
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    // Check for empty fields based on mode
    if (_isLogin) {
      if (uid.isEmpty || oldPassword.isEmpty) {
        _showMessage(l10n.enterUidPassword);
        return;
      }
    } else {
      if (uid.isEmpty || oldPassword.isEmpty || newPassword.isEmpty) {
        _showMessage(l10n.fillAllFields);
        return;
      }
    }

    setState(() => _loading = true);

    try {
      // ---------- DNS Check ----------
      try {
        final addresses = await _api.resolveApi();
        if (addresses.isEmpty) throw SocketException("No IP found for API");
      } on SocketException {
        _showMessage(l10n.cannotReachServer);
        return;
      }

      // ---------- Login / Change Password ----------
      if (_isLogin) {
        // --- LOGIN LOGIC ---
        await _api.login(uid: uid, password: oldPassword);

        // Get profile which includes tasks
        final profileData = await _api.getProfile();

        // Save tasks locally
        if (profileData.containsKey('tasks')) {
          final List<Map<String, dynamic>> fetchedTasks =
          (profileData['tasks'] as List).cast<Map<String, dynamic>>();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              ApiService.scheduleStorageKey, jsonEncode(fetchedTasks));
        }

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainView()),
        );
      } else {
        // --- CHANGE PASSWORD LOGIC ---
        await _api.changePassword(
          uid: uid,
          oldPassword: oldPassword,
          newPassword: newPassword,
        );

        if (!mounted) return;
        _showMessage(l10n.passwordChanged);
        // Clear fields and switch back to login
        setState(() {
          _isLogin = true;
          _uidController.clear();
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
          // Language selector button
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
                  // UID Field
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.9 * 255).round()),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: TextFormField(
                      controller: _uidController,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: l10n.uid,
                        hintStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(Icons.person_outline, size: 14),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                      ),
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
                      controller: _oldPasswordController,
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
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                      setState(() {
                        _isLogin = !_isLogin;
                        if (_isLogin) _newPasswordController.clear();
                      });
                    },
                    child: Text(
                      _isLogin ? l10n.forgotPassword : l10n.rememberedPassword,
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