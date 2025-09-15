import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContentPage4 extends StatelessWidget {
  const ContentPage4({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure system nav bar stays consistent
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.grey[200],
        systemNavigationBarIconBrightness: Brightness.dark,
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
              // Header Container (similar to Page4)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.redAccent.shade100,
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

              // Congratulations Card
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Congratulate yourself for your achievements',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Achievement Circle with stars
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 220,
                      width: 220,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 60,
                      child: Icon(Icons.star,
                          size: 25, color: Colors.blue.shade100),
                    ),
                    Positioned(
                      top: 20,
                      left: 100,
                      child: Icon(Icons.star_border,
                          size: 20, color: Colors.cyan.shade200),
                    ),
                    Positioned(
                      top: 25,
                      right: 80,
                      child: Icon(Icons.star,
                          size: 18, color: Colors.pink.shade300),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 100,
                      child: Icon(Icons.star,
                          size: 30, color: Colors.pink.shade300),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'Great Job !\nYou have completed\nall your self care\ntasks this week !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Achievement Ribbons
              _buildAchievementRibbon(),
              _buildAchievementRibbon(),

              const Spacer(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementRibbon() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 40,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}