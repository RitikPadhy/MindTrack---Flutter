import 'package:flutter/material.dart';

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: double.infinity,
            color: Colors.redAccent.shade100,
            child: const Center(
              child: Text(
                'Daily Schedule',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Month Navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: const Color(0xFFFFFDE7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Icon(Icons.chevron_left, size: 28),
                Text(
                  'AUGUST, 2025',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(Icons.chevron_right, size: 28),
              ],
            ),
          ),

          // Week Days
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Fri\n1"),
                Text("Sat\n2"),
                Text("Sun\n3"),
                Text("Mon\n4"),
                Text(
                  "Tue\n5",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ),

          const Divider(),

          // Scrollable Schedule Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                scheduleItem(
                  time: "10 AM - 11 AM",
                  title: "Self Care",
                  isDone: true,
                  hasExtra: true,
                ),
                scheduleItem(
                  time: "11 AM - 12 PM",
                  title: "Cleaning the house",
                  isDone: false,
                  hasExtra: false,
                ),
                scheduleItem(
                  time: "12 PM - 1 PM",
                  title: "Cleaning the house",
                  isDone: true,
                  hasExtra: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget scheduleItem({
    required String time,
    required String title,
    required bool isDone,
    required bool hasExtra,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isDone ? Icons.check_circle : Icons.cancel,
                color: isDone ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Icon(
                !isDone ? Icons.cancel : Icons.check_circle,
                color: !isDone ? Colors.red : Colors.green,
              ),
            ],
          ),
          if (hasExtra) ...[
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                3,
                    (index) => Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}