import 'package:flutter/material.dart';
import 'package:mind_track/utils/task_image_mapper.dart';
import 'package:mind_track/l10n/app_localizations.dart';

class ScheduleItem extends StatelessWidget {
  final String time;
  final List<String> tasks;
  final bool isActive;
  final int scheduleIndex;
  final Map<String, bool> checkedState;
  final Function(int taskIndex, int boxIndex) onBoxSelected;
  final String dateKey;
  final String userGender;

  const ScheduleItem({
    super.key,
    required this.time,
    required this.tasks,
    required this.isActive,
    required this.onBoxSelected,
    required this.checkedState,
    required this.scheduleIndex,
    required this.dateKey,
    required this.userGender,
  });

  String _generateBoxKey(int taskIndex, int boxIndex) {
    return "$dateKey-$scheduleIndex-$taskIndex-$boxIndex";
  }

  String _translateTask(BuildContext context, String taskName) {
    final l10n = AppLocalizations.of(context);
    final lowerTask = taskName.toLowerCase();

    if (lowerTask.contains('prayer')) return l10n.translate('task_prayer');
    if (lowerTask.contains('exercise')) return l10n.translate('task_exercise');
    if (lowerTask.contains('breakfast')) return l10n.translate('task_breakfast');
    if (lowerTask.contains('lunch')) return l10n.translate('task_lunch');
    if (lowerTask.contains('dinner')) return l10n.translate('task_dinner');
    if (lowerTask.contains('work')) return l10n.translate('task_work');
    if (lowerTask.contains('study')) return l10n.translate('task_study');
    if (lowerTask.contains('reading') || lowerTask.contains('read')) return l10n.translate('task_reading');
    if (lowerTask.contains('meditation') || lowerTask.contains('meditate')) return l10n.translate('task_meditation');
    if (lowerTask.contains('yoga')) return l10n.translate('task_yoga');
    if (lowerTask.contains('walk')) return l10n.translate('task_walk');
    if (lowerTask.contains('running') || lowerTask.contains('run')) return l10n.translate('task_running');
    if (lowerTask.contains('cooking') || lowerTask.contains('cook')) return l10n.translate('task_cooking');
    if (lowerTask.contains('cleaning') || lowerTask.contains('clean')) return l10n.translate('task_cleaning');
    if (lowerTask.contains('shopping') || lowerTask.contains('shop')) return l10n.translate('task_shopping');
    if (lowerTask.contains('family')) return l10n.translate('task_family_time');
    if (lowerTask.contains('social')) return l10n.translate('task_social');
    if (lowerTask.contains('hobby')) return l10n.translate('task_hobby');
    if (lowerTask.contains('rest')) return l10n.translate('task_rest');
    if (lowerTask.contains('sleep')) return l10n.translate('task_sleep');
    if (lowerTask.contains('bath')) return l10n.translate('task_bathing');
    if (lowerTask.contains('groom')) return l10n.translate('task_grooming');
    if (lowerTask.contains('medicine')) return l10n.translate('task_medicine');

    return taskName;
  }

  bool _isDisabled(int taskIndex, int boxIndex) {
    return false; // all boxes always enabled
  }

  Widget _buildTaskImages() {
    return FutureBuilder<List<String>>(
      future: _loadTaskImages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final validImagePaths = snapshot.data!;
        const double kStandardImageAreaWidth = 100.0;
        const double kWideImageAreaWidth = 120.0;
        const double kImageSize = 90.0;
        const double kOverlap = 60.0;
        const double kDiagonalShift = 20.0;
        final bool isTwoTasks = validImagePaths.length == 2;
        final double kImageAreaWidth = isTwoTasks ? kWideImageAreaWidth : kStandardImageAreaWidth;
        final double containerHeight = isTwoTasks ? kImageSize + kOverlap : kImageSize;

        return SizedBox(
          width: kImageAreaWidth,
          height: containerHeight,
          child: Stack(
            children: validImagePaths.asMap().entries.map((entry) {
              final index = entry.key;
              final imagePath = entry.value;
              final double topOffset = index == 0 ? 0.0 : kOverlap;
              final double leftOffset = (isTwoTasks && index == 1) ? kDiagonalShift : 0.0;

              return Positioned(
                top: topOffset,
                left: leftOffset,
                child: Material(
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.2),
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    width: kImageSize,
                    height: kImageSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Helper function to await all images
  Future<List<String>> _loadTaskImages() async {
    final List<String?> paths = await Future.wait(
        tasks.map((task) => TaskImageMapper.getImagePath(task, userGender)));
    return paths.whereType<String>().toList();
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(tasks.length, (taskIndex) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _translateTask(context, tasks[taskIndex]),
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(4, (boxIndex) {
                              final key = _generateBoxKey(taskIndex, boxIndex);
                              final isChecked = checkedState[key] ?? false;
                              final isDisabled = _isDisabled(taskIndex, boxIndex);

                              return GestureDetector(
                                onTap: isDisabled ? null : () => onBoxSelected(taskIndex, boxIndex),
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
                                        ? const Icon(Icons.check, color: Colors.green, size: 20)
                                        : null,
                                  ),
                                ),
                              );
                            }),
                          ),
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
            ),
            const SizedBox(width: 12),
            _buildTaskImages(),
          ],
        ),
      ),
    );
  }
}