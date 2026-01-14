import 'package:flutter/services.dart' show rootBundle;

class TaskImageMapper {
  // -----------------------------
  // Mapping from keywords to exact image filenames
  // -----------------------------
  static const Map<String, String> _wordToImage = {
    "bathing": "Bath,Bathing",
    "dressing": "Dressing",
    "grooming": "Grooming, Self care",
    "self care": "Grooming, Self care",
    "eating": "Eat,Eating",
    "exercise": "Exercise",
    "medication management": "Medicine, Medication",
    "cleaning": "Clean,Cleaning",
    "cooking": "Cook,Cooking",
    "laundry": "Laundry",
    "with children": "With Children",
    "with family": "With family .png",
    "with friends": "With friends 1",
    "call": "Call, Phone",
    "phone": "Call, Phone",
    "shopping": "Shopping",
    "money management": "Money Management 1",
    "work": "Work, Working 1",
    "working": "Work, Working 1",
    "studying": "Studying",
    "class": "Studying",
    "farm": "Farm, Farming",
    "farming": "Farm, Farming",
    "read": "Read, Reading",
    "reading": "Read, Reading",
    "write": "Write, Writing",
    "writing": "Write, Writing",
    "drawing": "Drawing, Painting",
    "painting": "Drawing, Painting",
    "walk": "Walk, Walking",
    "walking": "Walk, Walking",
    "running": "Run, Running",
    "skipping": "Skipping",
    "football": "Football",
    "cricket": "Cricket",
    "carroms": "Carroms",
    "listening music": "Listening Music",
    "meditation": "Meditation, Yoga 1",
    "yoga": "Meditation, Yoga 1",
    "watching tv": "Watching TV",
    "gardening": "Gardening",
    "sewing": "Sewing, Stitching",
    "stitching": "Sewing, Stitching",
    "cycling": "Cycling",
    "pray": "Prayer",
    "prayer": "Prayer",
    "rest": "Sleep, Sleeping",
    "sleep": "Sleep, Sleeping",
  };

  static String _normalizeTaskName(String taskName) =>
      taskName.toLowerCase().trim();

  /// Returns a Future path of the image, automatically falling back to common folder.
  static Future<String?> getImagePath(String taskName, String gender) async {
    final normalizedTask = _normalizeTaskName(taskName);
    String? selectedImage;

    for (final entry in _wordToImage.entries) {
      if (normalizedTask.contains(entry.key)) {
        selectedImage = entry.value;
        break;
      }
    }

    if (selectedImage == null) return null;

    final genderFolder = gender.toLowerCase() == 'male' ? 'male' : 'female';
    final genderPath = 'assets/tasks/$genderFolder/$selectedImage.png';
    final commonPath = 'assets/tasks/common/$selectedImage.png';

    // Try loading the gender-specific asset
    try {
      await rootBundle.load(genderPath);
      return genderPath;
    } catch (_) {
      // Fallback to common folder if gender-specific asset is missing
      try {
        await rootBundle.load(commonPath);
        return commonPath;
      } catch (_) {
        // If nothing exists, return null
        return null;
      }
    }
  }
}