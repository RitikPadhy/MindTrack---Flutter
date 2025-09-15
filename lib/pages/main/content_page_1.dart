import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContentPage1 extends StatelessWidget {
  const ContentPage1({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure system nav bar stays consistent
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.grey[200], // light grey
        systemNavigationBarIconBrightness: Brightness.dark, // dark icons
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
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
                  color: Colors.redAccent.shade100,
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

              _buildCard(
                color: Colors.pink.shade100,
                icon: Icons.directions_walk,
                text: 'When you feel low, keep moving',
              ),
              _buildCard(
                color: Colors.pink.shade100,
                icon: Icons.edit_note,
                text: 'Busy hands, calm mind',
              ),
              _buildCard(
                color: Colors.pink.shade100,
                icon: Icons.people,
                text: 'Doing with others',
              ),
              _buildCard(
                color: Colors.pink.shade100,
                text: 'Power of doing',
                showIcon: false,
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
    bool showIcon = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
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
      child: Row(
        children: [
          if (showIcon)
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.black,
              ),
            ),
          if (showIcon) const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}