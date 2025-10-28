import 'package:flutter/material.dart';

class ScheduleItem extends StatelessWidget {
  final String time;
  final String title;
  final Set<int> checkedBoxes; // ✅ multiple boxes allowed
  final bool isActive; // ✅ highlight only if active
  final ValueChanged<int> onBoxSelected;

  const ScheduleItem({
    super.key,
    required this.time,
    required this.title,
    required this.checkedBoxes,
    required this.isActive,
    required this.onBoxSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(128, 128, 128, 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              4,
                  (index) => GestureDetector(
                onTap: () => onBoxSelected(index),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: checkedBoxes.contains(index)
                      ? const Icon(Icons.check, color: Colors.green, size: 20)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}