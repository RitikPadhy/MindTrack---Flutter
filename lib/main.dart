import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Firebase Core
import 'package:mind_track/pages/auth/auth_page.dart';
import 'package:mind_track/pages/main/main_view.dart';
import 'package:mind_track/services/api_service.dart';
import 'package:mind_track/services/notification_service.dart';
import 'package:mind_track/services/localization_service.dart';
import 'package:mind_track/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ApiService _api = ApiService();
  final LocalizationService _localizationService = LocalizationService();
  Widget _home = const Scaffold(body: Center(child: CircularProgressIndicator()));

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _scheduleNotifications();
  }

  Future<void> _initializeApp() async {
    // Load saved language
    await _localizationService.loadLanguage();

    // Check login status
    _checkLogin();
  }

  Future<void> _scheduleNotifications() async {
    try {
      await NotificationService().ensureNotificationScheduled();
      debugPrint('✅ Notifications scheduled successfully');
    } catch (e) {
      debugPrint('❌ Failed to schedule notifications: $e');
    }
  }

  Future<void> _checkLogin() async {
    try {
      final isLoggedIn = await _api.tryAutoLogin();
      if (isLoggedIn) {
        setState(() => _home = const MainView());
      } else {
        setState(() => _home = const AuthPage());
      }
    } catch (e) {
      debugPrint('❌ Error during login check: $e');
      setState(() => _home = const AuthPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _localizationService,
      builder: (context, child) {
        return MaterialApp(
          title: 'Better Days Daily',
          theme: ThemeData(primarySwatch: Colors.blue),
          debugShowCheckedModeBanner: false,
          locale: _localizationService.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('kn'),
            Locale('ml'),
          ],
          home: _home,
          builder: (context, child) {
            return LocalizationProvider(
              changeLanguage: _localizationService.setLanguage, // Direct binding
              child: child!,
            );
          },
        );
      },
    );
  }
}

class LocalizationProvider extends InheritedWidget {
  final Function(Locale) changeLanguage;

  const LocalizationProvider({
    super.key,
    required this.changeLanguage,
    required super.child,
  });

  static LocalizationProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocalizationProvider>();
  }

  @override
  bool updateShouldNotify(LocalizationProvider oldWidget) => false;
}