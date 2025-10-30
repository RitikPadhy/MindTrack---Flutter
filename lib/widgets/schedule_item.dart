import 'package:flutter/material.dart';

class ScheduleItem extends StatelessWidget {
  final String time;
  final List<String> tasks;
  final bool isActive;
  final int scheduleIndex;
  final Map<String, bool> checkedState;
  final Function(int taskIndex, int boxIndex) onBoxSelected;

  const ScheduleItem({
    super.key,
    required this.time,
    required this.tasks,
    required this.isActive,
    required this.onBoxSelected,
    required this.checkedState,
    required this.scheduleIndex,
  });

  bool _isDisabled(int taskIndex, int boxIndex) {
    // If there are 2 tasks, make checkboxes at same index mutually exclusive
    if (tasks.length == 2) {
      final otherTaskIndex = taskIndex == 0 ? 1 : 0;
      final otherKey = "$scheduleIndex-$otherTaskIndex-$boxIndex";
      return checkedState[otherKey] ?? false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),

          // Tasks list
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(tasks.length, (taskIndex) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tasks[taskIndex],
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),

                  // ✅ Four boxes per task with mutual exclusivity
                  Row(
                    children: List.generate(4, (boxIndex) {
                      final key = "$scheduleIndex-$taskIndex-$boxIndex";
                      final isChecked = checkedState[key] ?? false;
                      final isDisabled = _isDisabled(taskIndex, boxIndex);

                      return GestureDetector(
                        onTap: isDisabled
                            ? null
                            : () => onBoxSelected(taskIndex, boxIndex),
                        child: Opacity(
                          opacity: isDisabled ? 0.4 : 1.0,
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black26),
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.transparent,
                            ),
                            child: isChecked
                                ? const Icon(Icons.check,
                                color: Colors.green, size: 20)
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),

                  // Divider between two tasks
                  if (taskIndex < tasks.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 2,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}