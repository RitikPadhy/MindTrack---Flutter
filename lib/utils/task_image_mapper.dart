/// A utility class to map tasks to image assets using simple keyword matching.
class TaskImageMapper {
  // Map simple keywords (sub-words) to their corresponding image filenames.
  // The order is important: place specific keywords first, and generic ones last,
  // as the first match found will be used.
  static const Map<String, String> _keywordToFilename = {
    // --- Specific Activities/Primary Keywords ---

    // **NEW/MODIFIED:** Prioritize 'eating_with_family' over 'eating'
    "watch": "spending_time_with_family",
    "family": "spending_time_with_family",
    "parents": "spending_time_with_family",
    "eat_with_family": "eating_with_family", // Added specific family eating

    // **NEW:** Added music
    "music": "listening_to_music",

    "class": "working",
    "clinic": "working",
    "lecture": "working",
    "exam": "working",
    "homework": "working",
    "study": "working",

    "prayer": "doing_yoga",
    "doing_yoga": "doing_yoga",
    "reflection": "doing_yoga",
    "spiritual": "doing_yoga",

    "lunch": "eating_with_family",
    "dinner": "eating_with_family",
    "breakfast": "eating_with_family",
    "cook": "cooking",
    "clean": "cleaning",
    "laundry": "doing_laundry",
    "yoga": "doing_yoga",

    "walk": "going_for_walk",
    "running": "running",
    "cycle": "cycling",
    "football": "playing_football",
    "games": "playing_games_with_people",
    "play": "playing",

    "bath": "bathing",
    "groom": "grooming",
    "brush": "grooming",
    "fresh": "grooming",
    "dress": "dressing",
    "medicine": "taking_medicines",
    "shop": "shopping",
    "read": "reading",

    // --- Generic/Fallback Keywords ---
    // **MODIFIED:** 'family' is now higher up. 'child' and 'friend' moved up for better priority.
    "child": "spending_time_with_children",
    "friend": "socializing_with_friends",
    "social": "socializing_with_friends",
    "work": "working", // Using this name as it's the only work image provided
    "farm": "farming",
    "garden": "gardening",
    "eat": "eating_with_family", // Generic 'eat' fallback
  };

  /// Normalizes the task name to a safe, lowercase, underscore-separated key.
  static String _normalizeTaskName(String taskName) {
    // 1. Lowercase and replace spaces with underscores
    String normalized = taskName.toLowerCase().replaceAll(' ', '_');
    // 2. Remove non-alphanumeric characters (keeps it simple for contains check)
    return normalized.replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  /// Returns the full asset path for a given task and gender by searching for
  /// a keyword match within the task name.
  static String? getImagePath(String taskName, String gender) {
    final normalizedTask = _normalizeTaskName(taskName);

    String? selectedFilename;

    // Iterate through keywords to find the first match in the normalized task name
    for (final entry in _keywordToFilename.entries) {
      final keyword = entry.key;
      final filename = entry.value;

      if (normalizedTask.contains(keyword)) {
        selectedFilename = filename;
        break; // Use the first and most specific match found
      }
    }

    if (selectedFilename == null) {
      return null;
    }

    // Determine the gender folder.
    final genderFolder = gender.toLowerCase() == 'male' ? 'male' : 'female';

    // Construct the full path
    final path = 'assets/tasks/$genderFolder/$selectedFilename.png';
    return path;
  }
}