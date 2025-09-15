import 'package:flutter/material.dart';

class ScheduleItem extends StatelessWidget {
  final String time;
  final String title;
  final bool isDone;
  final bool hasExtra;

  const ScheduleItem({
    super.key,
    required this.time,
    required this.title,
    required this.isDone,
    required this.hasExtra,
  });

  @override
  Widget build(BuildContext context) {
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
          Icon(
            isDone ? Icons.check_circle : Icons.cancel,
            color: isDone ? Colors.green : Colors.red,
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