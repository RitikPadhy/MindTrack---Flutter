import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for system nav bar styling
import 'package:mind_track/pages/main/content_page_1.dart' as cp1;
import 'package:mind_track/pages/main/content_page_2.dart' as cp2;
import 'package:mind_track/pages/main/content_page_3.dart' as cp3;
import 'package:mind_track/pages/main/content_page_4.dart' as cp4;
import 'package:mind_track/pages/main/content_page_5.dart' as cp5;

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final PageController _controller = PageController(initialPage: 2);
  int _currentPage = 2;

  @override
  void initState() {
    super.initState();
    _setSystemNavBar(); // initial styling
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
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _controller.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    _setSystemNavBar(); // ensure nav bar stays correct on rebuild

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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined, size: 22),
            selectedIcon: Icon(Icons.book, size: 22),
            label: 'Reading',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined, size: 22),
            selectedIcon: Icon(Icons.show_chart, size: 22),
            label: 'Track',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined, size: 22),
            selectedIcon: Icon(Icons.home, size: 22),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, size: 22),
            selectedIcon: Icon(Icons.chat_bubble, size: 22),
            label: 'Feedback',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined, size: 22),
            selectedIcon: Icon(Icons.emoji_events, size: 22),
            label: 'Goals',
          ),
        ],
      ),
    );
  }
}