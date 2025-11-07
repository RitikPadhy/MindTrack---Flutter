import 'package:flutter/material.dart';
import 'package:mind_track/pages/auth/auth_page.dart';
import 'package:mind_track/pages/main/main_view.dart';
import 'package:mind_track/services/api_service.dart';
import 'package:mind_track/services/notification_service.dart'; // Import the new service

void main() async {
  // Required to call native APIs before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service and schedule the first random notification
  await NotificationService().init();
  NotificationService().scheduleRandomDailyNotification();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ApiService _api = ApiService();
  Widget _home = const Scaffold(body: Center(child: CircularProgressIndicator()));

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      final isLoggedIn = await _api.tryAutoLogin();
      if (isLoggedIn) {
        // Reschedule the daily notification upon successful auto-login/app startup
        NotificationService().scheduleRandomDailyNotification();
        setState(() => _home = const MainView());
      } else {
        setState(() => _home = const AuthPage());
      }
    } catch (_) {
      setState(() => _home = const AuthPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Better Days Daily',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: _home,
    );
  }
}