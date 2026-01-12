import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_track/l10n/app_localizations.dart';
import 'dart:convert';
import '../../services/api_service.dart';

class ContentPage5 extends StatefulWidget {
  const ContentPage5({super.key});

  @override
  State<ContentPage5> createState() => _ContentPage5State();
}

class _ContentPage5State extends State<ContentPage5> {
  List<Map<String, String>> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndLoadAchievements();
  }

  /// Fetches achievements from API and updates SharedPreferences
  Future<void> _fetchAndLoadAchievements() async {
    setState(() => _isLoading = true);

    try {
      final apiAchievements = await ApiService().getWeeklyAchievements();

      // Convert all values to String
      final List<Map<String, String>> formatted = apiAchievements.map((item) {
        return {
          "title": item['title'].toString(),
          "message1": item['message1'].toString(),
          "message2": item['message2'].toString(),
        };
      }).toList();

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList(
        'weekly_achievements',
        formatted.map((m) => jsonEncode(m)).toList(),
      );

      if (mounted) {
        setState(() {
          _achievements = formatted;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching achievements: $e");

      // Load cached achievements if API fails
      final prefs = await SharedPreferences.getInstance();
      final List<String> cached = prefs.getStringList('weekly_achievements') ?? [];

      if (mounted) {
        setState(() {
          _achievements = cached.map((s) {
            final Map<String, dynamic> data = jsonDecode(s);
            return data.map((key, value) => MapEntry(key, value.toString()));
          }).toList();

          _isLoading = false;
        });
      }
    }
  }

  String _getEmojiForTitle(String title) {
    const Map<String, String> emojiMap = {
      "Habit Hero": "🏆",
      "Steady Steps": "🏆",
      "Daily Rhythm Builder": "🏆",
      "Whole-Self Nurturer": "🌱",
      "Life Balance Seeker": "🌱",
      "Explorer of Routines": "🌱",
      "Time Alchemist": "⏳",
      "Purposeful Hours": "⏳",
      "Mindful Moments": "⏳",
    };
    return emojiMap.entries.firstWhere(
          (e) => title.contains(e.key),
      orElse: () => MapEntry("", "⭐"),
    ).value;
  }

  List<Map<String, String>> _getDefaultMessages(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {
        "title": l10n.translate('mind_track_welcome'),
        "message1": l10n.translate('check_back_after_sync'),
        "message2": l10n.translate('achievements_appear_here')
      },
      {
        "title": l10n.translate('consistency_goal'),
        "message1": l10n.translate('keep_tracking'),
        "message2": l10n.translate('tiny_actions')
      },
      {
        "title": l10n.translate('variety_goal'),
        "message1": l10n.translate('explore_activities'),
        "message2": l10n.translate('aim_for_variety')
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<Map<String, String>> achievementsToShow =
    _achievements.isNotEmpty ? _achievements : _getDefaultMessages(context);

    final Map<String, String> mainAchievement = achievementsToShow[0];

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
                child: Text(
                  l10n.translate('achievements'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Loading / Congratulations
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                  _isLoading ? l10n.translate('fetching_report') : l10n.translate('congratulations'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xA6000000),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Main Achievement Circle
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
                        color: Colors.blue.withOpacity(0.3),
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
                          Text(
                            mainAchievement['message1']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
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

              // Other Achievements
              ...achievementsToShow.asMap().entries.map((entry) {
                final index = entry.key;
                final achievement = entry.value;
                if (index == 0) return const SizedBox.shrink();

                return _buildAchievementMessage(
                  emoji: _getEmojiForTitle(achievement['title']!),
                  title: achievement['title']!,
                  message: achievement['message2']!,
                );
              }),

              // Encourage if less than 3 achievements
              if (!_isLoading && achievementsToShow.length < 2)
                _buildAchievementMessage(
                  emoji: '👍',
                  title: l10n.translate('getting_started'),
                  message: l10n.translate('more_achievements'),
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