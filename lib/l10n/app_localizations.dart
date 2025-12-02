import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // All translatable strings
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Auth Page
      'email': 'Email',
      'password': 'Password',
      'old_password': 'Old Password',
      'new_password': 'New Password',
      'sign_in': 'Sign In',
      'set_new_password': 'Set New Password',
      'forgot_password': 'Forgot password? Change it now',
      'remembered_password': 'Remembered password? Sign In',
      'select_language': 'Select Language',
      'language': 'Language',
      
      // Messages
      'enter_email_password': 'Please enter both email and password.',
      'fill_all_fields': 'Please fill in all fields (Email, Old Password, New Password).',
      'password_changed': 'Password changed successfully! Please log in with your new password.',
      'cannot_reach_server': 'Cannot reach server. Please check your internet or DNS settings.',
      
      // Navigation
      'reading': 'Reading',
      'track': 'Track',
      'home': 'Home',
      'feedback': 'Feedback',
      'goals': 'Goals',
      
      // Common
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'ok': 'OK',
      'save': 'Save',
      
      // Content Page 1 - Reading
      'reading_material': 'Reading Material',
      'feeling_low_energy': 'Feeling low energy?',
      'feeling_stressed': 'Feeling stressed?',
      'feeling_lonely': 'Feeling lonely?',
      'why_doing_important': 'Why "doing" is important',
      'no_content_available': 'No content available.',
      
      // Content Page 2 - Track Progress
      'track_your_progress': 'Track Your Progress',
      'day': 'DAY',
      'week': 'WEEK',
      'month': 'MONTH',
      'start_doing_tasks': 'Start doing the tasks or try logging some progress to see your top statistics here!',
      'failed_to_load': 'Failed to load data. Please check your connection.',
      'great_work': 'Great work! You are focusing on',
      'and_staying_consistent': ', and staying consistent.',
      'keep_logging': 'Keep logging your tasks to see personalized insights here!',
      
      // Content Page 3 - Daily Schedule
      'daily_schedule': 'Daily Schedule',
      
      // Content Page 4 - Weekly Feedback
      'weekly_feedback': 'Weekly Feedback',
      'member_since': 'Member Since:',
      'week': 'Week',
      'energy_levels': 'Energy Levels',
      'satisfaction': 'Satisfaction',
      'happiness': 'Happiness',
      'proud_of_achievements': 'Proud of my achievements',
      'how_busy': 'How busy you felt?',
      'any_thoughts': 'Any thoughts or comments about this week?',
      'feedback_saved': 'Weekly feedback for Week',
      'saved_and_reset': 'saved and reset.',
      'failed_to_sync': 'Warning: Failed to sync feedback:',
      'local_data_retained': '. Local data retained.',
      'feedback_complete': 'Feedback Complete! 📝',
      'thanks_for_feedback': 'Thanks for your feedback! Your data for Week',
      'successfully_saved': 'has been successfully saved and your new week has begun.',
      
      // Content Page 5 - Achievements
      'achievements': 'Achievements',
      'fetching_report': 'Fetching your weekly report...',
      'congratulations': 'Congratulations! Here is your Mind Track Weekly Report.',
      'mind_track_welcome': 'Mind Track Welcome',
      'check_back_after_sync': 'Check back after your first weekly sync!',
      'achievements_appear_here': 'Your weekly achievements will appear here.',
      'consistency_goal': 'Consistency Goal',
      'keep_tracking': 'Keep tracking your routines.',
      'tiny_actions': 'Tiny actions build big habits. Aim for 5 days of activity.',
      'variety_goal': 'Variety Goal',
      'explore_activities': 'Explore different activities.',
      'aim_for_variety': 'Aim to track activities in 3 or more life areas.',
      'getting_started': 'Getting Started',
      'more_achievements': 'Keep tracking your daily routines! More achievements unlock after next week\'s sync.',
    },
    'hi': {
      // Auth Page
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'old_password': 'पुराना पासवर्ड',
      'new_password': 'नया पासवर्ड',
      'sign_in': 'साइन इन करें',
      'set_new_password': 'नया पासवर्ड सेट करें',
      'forgot_password': 'पासवर्ड भूल गए? अभी बदलें',
      'remembered_password': 'पासवर्ड याद आ गया? साइन इन करें',
      'select_language': 'भाषा चुनें',
      'language': 'भाषा',
      
      // Messages
      'enter_email_password': 'कृपया ईमेल और पासवर्ड दोनों दर्ज करें।',
      'fill_all_fields': 'कृपया सभी फ़ील्ड भरें (ईमेल, पुराना पासवर्ड, नया पासवर्ड)।',
      'password_changed': 'पासवर्ड सफलतापूर्वक बदल दिया गया! कृपया अपने नए पासवर्ड से लॉग इन करें।',
      'cannot_reach_server': 'सर्वर तक नहीं पहुंच सकते। कृपया अपना इंटरनेट या DNS सेटिंग्स जांचें।',
      
      // Navigation
      'reading': 'पढ़ना',
      'track': 'ट्रैक',
      'home': 'होम',
      'feedback': 'फीडबैक',
      'goals': 'लक्ष्य',
      
      // Common
      'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि',
      'success': 'सफलता',
      'cancel': 'रद्द करें',
      'ok': 'ठीक है',
      'save': 'सहेजें',
    },
    'kn': {
      // Auth Page
      'email': 'ಇಮೇಲ್',
      'password': 'ಪಾಸ್‌ವರ್ಡ್',
      'old_password': 'ಹಳೆಯ ಪಾಸ್‌ವರ್ಡ್',
      'new_password': 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್',
      'sign_in': 'ಸೈನ್ ಇನ್ ಮಾಡಿ',
      'set_new_password': 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಹೊಂದಿಸಿ',
      'forgot_password': 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರುವಿರಾ? ಈಗ ಬದಲಾಯಿಸಿ',
      'remembered_password': 'ಪಾಸ್‌ವರ್ಡ್ ನೆನಪಿದೆಯೇ? ಸೈನ್ ಇನ್ ಮಾಡಿ',
      'select_language': 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ',
      'language': 'ಭಾಷೆ',
      
      // Messages
      'enter_email_password': 'ದಯವಿಟ್ಟು ಇಮೇಲ್ ಮತ್ತು ಪಾಸ್‌ವರ್ಡ್ ಎರಡನ್ನೂ ನಮೂದಿಸಿ.',
      'fill_all_fields': 'ದಯವಿಟ್ಟು ಎಲ್ಲಾ ಕ್ಷೇತ್ರಗಳನ್ನು ಭರ್ತಿ ಮಾಡಿ (ಇಮೇಲ್, ಹಳೆಯ ಪಾಸ್‌ವರ್ಡ್, ಹೊಸ ಪಾಸ್‌ವರ್ಡ್).',
      'password_changed': 'ಪಾಸ್‌ವರ್ಡ್ ಯಶಸ್ವಿಯಾಗಿ ಬದಲಾಯಿಸಲಾಗಿದೆ! ದಯವಿಟ್ಟು ನಿಮ್ಮ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್‌ನೊಂದಿಗೆ ಲಾಗ್ ಇನ್ ಮಾಡಿ.',
      'cannot_reach_server': 'ಸರ್ವರ್ ತಲುಪಲು ಸಾಧ್ಯವಿಲ್ಲ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಇಂಟರ್ನೆಟ್ ಅಥವಾ DNS ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.',
      
      // Navigation
      'reading': 'ಓದುವುದು',
      'track': 'ಟ್ರ್ಯಾಕ್',
      'home': 'ಮುಖಪುಟ',
      'feedback': 'ಪ್ರತಿಕ್ರಿಯೆ',
      'goals': 'ಗುರಿಗಳು',
      
      // Common
      'loading': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
      'error': 'ದೋಷ',
      'success': 'ಯಶಸ್ಸು',
      'cancel': 'ರದ್ದುಮಾಡಿ',
      'ok': 'ಸರಿ',
      'save': 'ಉಳಿಸಿ',
    },
    'ml': {
      // Auth Page
      'email': 'ഇമെയിൽ',
      'password': 'പാസ്‌വേഡ്',
      'old_password': 'പഴയ പാസ്‌വേഡ്',
      'new_password': 'പുതിയ പാസ്‌വേഡ്',
      'sign_in': 'സൈൻ ഇൻ ചെയ്യുക',
      'set_new_password': 'പുതിയ പാസ്‌വേഡ് സജ്ജമാക്കുക',
      'forgot_password': 'പാസ്‌വേഡ് മറന്നോ? ഇപ്പോൾ മാറ്റുക',
      'remembered_password': 'പാസ്‌വേഡ് ഓർമ്മയുണ്ടോ? സൈൻ ഇൻ ചെയ്യുക',
      'select_language': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
      'language': 'ഭാഷ',
      
      // Messages
      'enter_email_password': 'ദയവായി ഇമെയിലും പാസ്‌വേഡും നൽകുക.',
      'fill_all_fields': 'ദയവായി എല്ലാ ഫീൽഡുകളും പൂരിപ്പിക്കുക (ഇമെയിൽ, പഴയ പാസ്‌വേഡ്, പുതിയ പാസ്‌വേഡ്).',
      'password_changed': 'പാസ്‌വേഡ് വിജയകരമായി മാറ്റി! ദയവായി നിങ്ങളുടെ പുതിയ പാസ്‌വേഡ് ഉപയോഗിച്ച് ലോഗിൻ ചെയ്യുക.',
      'cannot_reach_server': 'സെർവറിലേക്ക് എത്താൻ കഴിയുന്നില്ല. ദയവായി നിങ്ങളുടെ ഇന്റർനെറ്റ് അല്ലെങ്കിൽ DNS ക്രമീകരണങ്ങൾ പരിശോധിക്കുക.',
      
      // Navigation
      'reading': 'വായന',
      'track': 'ട്രാക്ക്',
      'home': 'ഹോം',
      'feedback': 'ഫീഡ്‌ബാക്ക്',
      'goals': 'ലക്ഷ്യങ്ങൾ',
      
      // Common
      'loading': 'ലോഡ് ചെയ്യുന്നു...',
      'error': 'പിശക്',
      'success': 'വിജയം',
      'cancel': 'റദ്ദാക്കുക',
      'ok': 'ശരി',
      'save': 'സംരക്ഷിക്കുക',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']?[key] ?? 
           key;
  }

  // Convenience getters for commonly used strings
  String get email => translate('email');
  String get password => translate('password');
  String get oldPassword => translate('old_password');
  String get newPassword => translate('new_password');
  String get signIn => translate('sign_in');
  String get setNewPassword => translate('set_new_password');
  String get forgotPassword => translate('forgot_password');
  String get rememberedPassword => translate('remembered_password');
  String get selectLanguage => translate('select_language');
  String get language => translate('language');
  
  String get enterEmailPassword => translate('enter_email_password');
  String get fillAllFields => translate('fill_all_fields');
  String get passwordChanged => translate('password_changed');
  String get cannotReachServer => translate('cannot_reach_server');
  
  String get reading => translate('reading');
  String get track => translate('track');
  String get home => translate('home');
  String get feedback => translate('feedback');
  String get goals => translate('goals');
  
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get cancel => translate('cancel');
  String get ok => translate('ok');
  String get save => translate('save');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'kn', 'ml'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}