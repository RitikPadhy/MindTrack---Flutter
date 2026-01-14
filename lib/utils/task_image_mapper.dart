import 'package:flutter/services.dart' show rootBundle;

class TaskImageMapper {
  // -----------------------------
  // Priority-based keywords mapping
  // First matching keyword wins
  // -----------------------------
  static const List<MapEntry<String, String>> _priorityWordList = [
    MapEntry("bath", "Bath"),
    MapEntry("dress", "Dressing"),
    MapEntry("groom", "Self care"),
    MapEntry("self care", "Self Care"),
    MapEntry("eat", "Eat"),
    MapEntry("exercise", "Exercise"),
    MapEntry("clean", "Clean"),
    MapEntry("cook", "Cook"),
    MapEntry("laundry", "Laundry"),
    MapEntry("with children", "Children"),
    MapEntry("with family", "Family"),
    MapEntry("with friends", "Friends"),
    MapEntry("call", "Call"),
    MapEntry("shopping", "Shopping"),
    MapEntry("medication management", "Medicine"),
    MapEntry("money management", "Money"),
    MapEntry("work", "Work"),
    MapEntry("studying", "Study"),
    MapEntry("class", "Study"),
    MapEntry("farm", "Farming"),
    MapEntry("read", "Read"),
    MapEntry("write", "Write"),
    MapEntry("drawing", "Art"),
    MapEntry("painting", "Art"),
    MapEntry("walk", "Walk"),
    MapEntry("running", "Running"),
    MapEntry("skipping", "Skipping"),
    MapEntry("football", "Football"),
    MapEntry("cricket", "Cricket"),
    MapEntry("carroms", "Carroms"),
    MapEntry("listening music", "Listening music"),
    MapEntry("meditation", "Yoga"),
    MapEntry("yoga", "Yoga"),
    MapEntry("watching tv", "Watching TV"),
    MapEntry("gardening", "Gardening"),
    MapEntry("stitching", "Stitching"),
    MapEntry("cycling", "Cycling"),
    MapEntry("pray", "Pray"),
    MapEntry("rest", "Sleep"),
    MapEntry("sleep", "Sleep"),
  ];

  // -----------------------------
  // Normalize task string
  // Lowercase, remove extra spaces
  // -----------------------------
  static String _normalizeTaskName(String taskName) =>
      taskName.toLowerCase().trim();

  /// Returns the proper image path for a task and gender, with fallback to common folder
  static Future<String?> getImagePath(String taskName, String gender) async {
    final normalizedTask = _normalizeTaskName(taskName);
    String? selectedImage;

    // Loop through priority list: first match wins
    for (final entry in _priorityWordList) {
      if (normalizedTask.contains(entry.key)) {
        selectedImage = entry.value;
        break;
      }
    }

    if (selectedImage == null) return null;

    // Gender folder fallback
    final genderFolder = (gender.toLowerCase() == 'male' || gender.toLowerCase() == 'female')
        ? gender.toLowerCase()
        : 'common';
    final genderPath = 'assets/tasks/$genderFolder/$selectedImage.png';
    final commonPath = 'assets/tasks/common/$selectedImage.png';

    // Try gender-specific image first
    try {
      await rootBundle.load(genderPath);
      return genderPath;
    } catch (_) {
      // Fallback to common folder
      try {
        await rootBundle.load(commonPath);
        return commonPath;
      } catch (_) {
        // If not found anywhere
        return null;
      }
    }
  }
}