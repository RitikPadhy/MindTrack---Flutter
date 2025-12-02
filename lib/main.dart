import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mind_track/pages/auth/auth_page.dart';
import 'package:mind_track/pages/main/main_view.dart';
import 'package:mind_track/services/api_service.dart';
import 'package:mind_track/services/notification_service.dart';
import 'package:mind_track/services/localization_service.dart';
import 'package:mind_track/l10n/app_localizations.dart';

void main() async {
  // Required to call native APIs before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service and schedule the first random notification
  try {
    await NotificationService().init();
    debugPrint('✅ NotificationService initialized');
    
    await NotificationService().scheduleRandomDailyNotification();
    debugPrint('✅ Initial notification scheduled');
    
    // Check pending notifications for debugging
    await NotificationService().checkPendingNotifications();
  } catch (e) {
    debugPrint('❌ Error initializing notifications: $e');
  }

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
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Load saved language
    final savedLocale = await _localizationService.loadLanguage();
    setState(() {
      _locale = savedLocale;
    });
    
    // Check login status
    _checkLogin();
  }

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  Future<void> _checkLogin() async {
    try {
      final isLoggedIn = await _api.tryAutoLogin();
      if (isLoggedIn) {
        // Reschedule the daily notification upon successful auto-login/app startup
        await NotificationService().scheduleRandomDailyNotification();
        debugPrint('✅ Notification rescheduled after login');
        
        // Check pending notifications
        await NotificationService().checkPendingNotifications();
        
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
    return MaterialApp(
      title: 'Better Days Daily',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      locale: _locale,
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
          changeLanguage: changeLanguage,
          child: child!,
        );
      },
    );
  }
}

class LocalizationProvider extends InheritedWidget {
  final Function(Locale) changeLanguage;

  const LocalizationProvider({
    required this.changeLanguage,
    required super.child,
  });

  static LocalizationProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocalizationProvider>();
  }

  @override
  bool updateShouldNotify(LocalizationProvider oldWidget) => false;
}