import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mind_track/pages/main/content_page_1.dart' as cp1;
import 'package:mind_track/pages/main/content_page_2.dart' as cp2;
import 'package:mind_track/pages/main/content_page_3.dart' as cp3;
import 'package:mind_track/pages/main/content_page_4.dart' as cp4;
import 'package:mind_track/pages/main/content_page_5.dart' as cp5;
import 'package:mind_track/services/notification_service.dart';
import 'package:mind_track/l10n/app_localizations.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with WidgetsBindingObserver {
  final PageController _controller = PageController(initialPage: 2);
  int _currentPage = 2;

  @override
  void initState() {
    super.initState();
    _setSystemNavBar(); // initial styling
    WidgetsBinding.instance.addObserver(this);
    // Ensure notifications are scheduled when main view loads
    _ensureNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app comes back to foreground, ensure notifications are still scheduled
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 App resumed, checking notifications...');
      _ensureNotifications();
    }
  }

  Future<void> _ensureNotifications() async {
    try {
      await NotificationService().ensureNotificationsScheduled();
    } catch (e) {
      debugPrint('⚠️ Error ensuring notifications: $e');
    }
  }

  void _setSystemNavBar() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white, // light grey nav bar
        systemNavigationBarIconBrightness: Brightness.dark, // dark icons
        statusBarColor: Colors.transparent, // transparent top bar
        statusBarIconBrightness: Brightness.dark, // dark top icons
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _controller.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    _setSystemNavBar();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          cp1.ContentPage1(),
          cp2.ContentPage2(),
          cp3.ContentPage3(),
          cp4.ContentPage4(),
          cp5.ContentPage5(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 56,
        selectedIndex: _currentPage,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: Colors.lightBlue[100],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.book_outlined, size: 22),
            selectedIcon: const Icon(Icons.book, size: 22),
            label: l10n.reading,
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_outlined, size: 22),
            selectedIcon: const Icon(Icons.show_chart, size: 22),
            label: l10n.track,
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_outlined, size: 22),
            selectedIcon: const Icon(Icons.home, size: 22),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline, size: 22),
            selectedIcon: const Icon(Icons.chat_bubble, size: 22),
            label: l10n.feedback,
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined, size: 22),
            selectedIcon: const Icon(Icons.emoji_events, size: 22),
            label: l10n.goals,
          ),
        ],
      ),
    );
  }
}