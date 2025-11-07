import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Added for jsonDecode

class ContentPage5 extends StatefulWidget {
  const ContentPage5({super.key});

  @override
  State<ContentPage5> createState() => _ContentPage5State();
}

class _ContentPage5State extends State<ContentPage5> {
  // Structure to hold achievement data: List of maps with 'title', 'message1', 'message2'
  List<Map<String, String>> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  // Loads achievements from SharedPreferences
  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the list of achievement strings saved by ContentPage4
    final List<String> achievementStrings = prefs.getStringList('weekly_achievements') ?? [];

    final List<Map<String, String>> loadedAchievements = achievementStrings.map((s) {
      final Map<String, dynamic> data = jsonDecode(s);
      // Ensure all values are converted to string for type safety in the UI
      return data.map((key, value) => MapEntry(key, value.toString()));
    }).toList();

    if (mounted) {
      setState(() {
        _achievements = loadedAchievements.isEmpty
            ? _getDefaultMessages() // Fallback if nothing is synced yet
            : loadedAchievements;
        _isLoading = false;
      });
    }
  }

  // Default messages for the initial state before the first weekly sync
  List<Map<String, String>> _getDefaultMessages() {
    return [
      {"title": "Mind Track Welcome", "message1": "Check back after your first weekly sync!", "message2": "Your weekly achievements will appear here."},
      {"title": "Consistency Goal", "message1": "Keep tracking your routines.", "message2": "Tiny actions build big habits. Aim for 5 days of activity."},
      {"title": "Variety Goal", "message1": "Explore different activities.", "message2": "Aim to track activities in 3 or more life areas."}
    ];
  }

  // Helper to map the achievement type to a relevant emoji
  String _getEmojiForTitle(String title) {
    if (title.contains('Hero') || title.contains('Steady') || title.contains('Rhythm')) return '🏆'; // Consistency
    if (title.contains('Balance') || title.contains('Explorer') || title.contains('Nurturer')) return '🌱'; // Variety
    if (title.contains('Time') || title.contains('Mindful') || title.contains('Purposeful')) return '⏳'; // Time Spent
    return '⭐';
  }

  @override
  Widget build(BuildContext context) {
    // Use the first achievement for the main circle display
    final Map<String, String> mainAchievement = _achievements.isNotEmpty
        ? _achievements[0]
        : _getDefaultMessages()[0]; // Use default if list is empty

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF9FE2BF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Achievements',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Loading/Congratulations Card
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(128, 128, 128, 0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _isLoading
                      ? 'Fetching your weekly report...'
                      : 'Congratulations! Here is your Mind Track Weekly Report.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xA6000000),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🏆 Achievement Celebration Section (Dynamic Content)
              Center(
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 60,
                            color: Colors.yellowAccent,
                          ),
                          const SizedBox(height: 10),
                          // TITLE FROM API
                          Text(
                            mainAchievement['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // MESSAGE 1 FROM API
                          Text(
                            mainAchievement['message1']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ✅ Achievement Boxes (Dynamically generated using message2)
              // This section uses the three items fetched from the API.
              ..._achievements.asMap().entries.map((entry) {
                final index = entry.key;
                final achievement = entry.value;

                if (index == 0) return const SizedBox.shrink();

                return _buildAchievementMessage(
                  emoji: _getEmojiForTitle(achievement['title']!),
                  title: achievement['title']!,
                  message: achievement['message2']!,
                );
              }),

              // If less than 3 achievements (only the main one is shown in the list),
              // and we are not loading, show a static encouraging message.
              if (!_isLoading && _achievements.length < 2)
                _buildAchievementMessage(
                  emoji: '👍',
                  title: 'Getting Started',
                  message: 'Keep tracking your daily routines! More achievements unlock after next week\'s sync.',
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementMessage({
    required String emoji,
    required String title,
    required String message,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(128, 128, 128, 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xA6000000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}