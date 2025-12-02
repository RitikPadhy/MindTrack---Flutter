import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';
  
  // Singleton pattern
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  // Current locale
  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;

  // Supported languages
  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
    LanguageOption(code: 'hi', name: 'Hindi', nativeName: 'हिंदी'),
    LanguageOption(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    LanguageOption(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
  ];

  // Load saved language preference
  Future<Locale> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    _currentLocale = Locale(languageCode);
    debugPrint('🌐 Loaded language: $languageCode');
    return _currentLocale;
  }

  // Save language preference
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    _currentLocale = Locale(languageCode);
    debugPrint('🌐 Language set to: $languageCode');
  }

  // Get language name by code
  static String getLanguageName(String code) {
    return supportedLanguages
        .firstWhere((lang) => lang.code == code, orElse: () => supportedLanguages[0])
        .nativeName;
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}