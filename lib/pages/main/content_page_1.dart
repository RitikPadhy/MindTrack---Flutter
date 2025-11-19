import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mind_track/services/api_service.dart';

class ContentPage1 extends StatelessWidget {
  const ContentPage1({super.key});

  // Example card data
  final List<Map<String, dynamic>> _cards = const [
    {"id": 1, "text": "Feeling low energy?", "icon": Icons.battery_alert},
    {"id": 2, "text": "Feeling stressed?", "icon": Icons.sentiment_dissatisfied},
    {"id": 3, "text": "Feeling lonely?", "icon": Icons.person_off},
    {"id": 4, "text": "Why \"doing\" is important", "icon": Icons.lightbulb},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF9FE2BF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Reading Material',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Build all cards dynamically
              for (var card in _cards)
                _buildCard(
                  color: Colors.white,
                  icon: card["icon"],
                  text: card["text"],
                  onTap: () => _showSection(context, card["id"], card["text"]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build each card
  Widget _buildCard({
    required Color color,
    IconData? icon,
    required String text,
    VoidCallback? onTap,
    bool showIcon = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(128, 128, 128, 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (showIcon)
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.black54,
                ),
              ),
            if (showIcon) const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xA6000000),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch section and show in scrollable dialog
  void _showSection(BuildContext context, int sectionId, String title) async {
    final api = ApiService();

    // Dim system bars
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black54,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.black54,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500, // lighter font weight
          ),
        ),
        content: FutureBuilder<Map<String, dynamic>>(
          future: api.getReadingMaterial(sectionId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!['material'] == null) {
              return const Text("No content available.");
            } else {
              final content = snapshot.data!['material'] as String;
              return ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 250, // limit height
                ),
                child: SingleChildScrollView(
                  child: Center(
                    child: Text(
                      content,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );

    // Restore system bars after closing dialog
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }
}