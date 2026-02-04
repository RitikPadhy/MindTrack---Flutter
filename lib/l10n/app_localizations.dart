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
      'enter_uid_password': 'Enter UID Password',
      'uid': 'UID',
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
      'great_work_1': 'Good progress! You stayed engaged in',
      'great_work_2': 'Good effort! This week, you focused on',
      'great_work_3': 'You strengthened your routine through engaging in',
      'keep_logging': 'Keep logging your tasks to see personalized insights here!',
      
      // Content Page 3 - Daily Schedule
      'daily_schedule': 'Daily Schedule',
      
      // Content Page 4 - Weekly Feedback
      'weekly_feedback': 'Weekly Feedback',
      'member_since': 'Member Since:',
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
      
      // Task Names (for Daily Schedule)
      'task_prayer': 'Prayer',
      'task_exercise': 'Exercise',
      'task_breakfast': 'Breakfast',
      'task_lunch': 'Lunch',
      'task_dinner': 'Dinner',
      'task_work': 'Work',
      'task_study': 'Study',
      'task_reading': 'Reading',
      'task_meditation': 'Meditation',
      'task_yoga': 'Yoga',
      'task_walk': 'Walk',
      'task_running': 'Running',
      'task_cooking': 'Cooking',
      'task_cleaning': 'Cleaning',
      'task_shopping': 'Shopping',
      'task_family_time': 'Family Time',
      'task_social': 'Social',
      'task_hobby': 'Hobby',
      'task_rest': 'Rest',
      'task_sleep': 'Sleep',
      'task_bathing': 'Bathing',
      'task_grooming': 'Grooming',
      'task_medicine': 'Medicine',

      // MAUQ Form
      'mauq_form': 'MAUQ Form',
      'mauq_description': 'In this questionnaire:',
      'mauq_scale_1': '1 – Strongly disagree',
      'mauq_scale_2': '2 – Disagree',
      'mauq_scale_3': '3 – Somewhat disagree',
      'mauq_scale_4': '4 – Neither agree nor disagree',
      'mauq_scale_5': '5 – Somewhat agree',
      'mauq_scale_6': '6 – Agree',
      'mauq_scale_7': '7 – Strongly agree',
      'optional_feedback': 'Optional Feedback',
      'submit': 'Submit',
      'already_submitted': 'Feedback was already submitted!',
      'submit_success': 'MAUQ submitted successfully!',
      'submit_failed': 'Failed to submit MAUQ:',

      // MAUQ Questions
      'mauq_q1': 'The app was easy to use.',
      'mauq_q2': 'It was easy for me to learn to use the app.',
      'mauq_q3': 'The navigation was consistent between screens.',
      'mauq_q4': 'The interface allowed me to use all functions offered.',
      'mauq_q5': 'I could recover easily from mistakes.',
      'mauq_q6': 'I like the interface of the app.',
      'mauq_q7': 'Information was well organized.',
      'mauq_q8': 'App adequately acknowledged progress.',
      'mauq_q9': 'I feel comfortable using this app in social settings.',
      'mauq_q10': 'Time involved in using the app was fitting.',
      'mauq_q11': 'I would use this app again.',
      'mauq_q12': 'Overall, I am satisfied with this app.',
      'mauq_q13': 'The app is useful for my health and well-being.',
      'mauq_q14': 'The app improved my access to healthcare services.',
      'mauq_q15': 'The app helped me manage my health effectively.',
      'mauq_q16': 'This app has all expected functions and capabilities.',
      'mauq_q17': 'I could use the app even with poor internet connection.',
      'mauq_q18': 'The app provides an acceptable way to receive healthcare services.',
    },
    'hi': {
      // Auth Page
      'enter_uid_password': 'यूआईडी पासवर्ड दर्ज करें',
      'uid': 'यूआईडी',
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
      
      // Content Page 1 - Reading
      'reading_material': 'पठन सामग्री',
      'feeling_low_energy': 'कम ऊर्जा महसूस कर रहे हैं?',
      'feeling_stressed': 'तनाव महसूस कर रहे हैं?',
      'feeling_lonely': 'अकेलापन महसूस कर रहे हैं?',
      'why_doing_important': '"करना" क्यों महत्वपूर्ण है',
      'no_content_available': 'कोई सामग्री उपलब्ध नहीं है।',
      
      // Content Page 2 - Track Progress
      'track_your_progress': 'अपनी प्रगति ट्रैक करें',
      'day': 'दिन',
      'week': 'सप्ताह',
      'month': 'महीना',
      'start_doing_tasks': 'कार्य करना शुरू करें या अपने शीर्ष आंकड़े यहां देखने के लिए कुछ प्रगति लॉग करने का प्रयास करें!',
      'failed_to_load': 'डेटा लोड करने में विफल। कृपया अपना कनेक्शन जांचें।',
      'great_work_1': 'अच्छी प्रगति! आप इसमें लगे रहे',
      'great_work_2': 'अच्छा प्रयास! इस सप्ताह, आप इस पर ध्यान केंद्रित कर रहे थे',
      'great_work_3': 'आपने इसमें लगे रहने के माध्यम से अपनी दिनचर्या को मजबूत किया',
      'keep_logging': 'यहां व्यक्तिगत अंतर्दृष्टि देखने के लिए अपने कार्यों को लॉग करते रहें!',
      
      // Content Page 3 - Daily Schedule
      'daily_schedule': 'दैनिक कार्यक्रम',
      
      // Content Page 4 - Weekly Feedback
      'weekly_feedback': 'साप्ताहिक फीडबैक',
      'member_since': 'सदस्य बने:',
      'energy_levels': 'ऊर्जा स्तर',
      'satisfaction': 'संतुष्टि',
      'happiness': 'खुशी',
      'proud_of_achievements': 'मेरी उपलब्धियों पर गर्व है',
      'how_busy': 'आप कितने व्यस्त महसूस करते हैं?',
      'any_thoughts': 'इस सप्ताह के बारे में कोई विचार या टिप्पणी?',
      'feedback_saved': 'सप्ताह के लिए साप्ताहिक फीडबैक',
      'saved_and_reset': 'सहेजा और रीसेट किया गया।',
      'failed_to_sync': 'चेतावनी: फीडबैक सिंक करने में विफल:',
      'local_data_retained': '। स्थानीय डेटा बरकरार रखा गया।',
      'feedback_complete': 'फीडबैक पूर्ण! 📝',
      'thanks_for_feedback': 'आपके फीडबैक के लिए धन्यवाद! सप्ताह के लिए आपका डेटा',
      'successfully_saved': 'सफलतापूर्वक सहेजा गया है और आपका नया सप्ताह शुरू हो गया है।',
      
      // Content Page 5 - Achievements
      'achievements': 'उपलब्धियां',
      'fetching_report': 'आपकी साप्ताहिक रिपोर्ट प्राप्त की जा रही है...',
      'congratulations': 'बधाई हो! यहां आपकी माइंड ट्रैक साप्ताहिक रिपोर्ट है।',
      'mind_track_welcome': 'माइंड ट्रैक में आपका स्वागत है',
      'check_back_after_sync': 'अपने पहले साप्ताहिक सिंक के बाद वापस जांचें!',
      'achievements_appear_here': 'आपकी साप्ताहिक उपलब्धियां यहां दिखाई देंगी।',
      'consistency_goal': 'निरंतरता लक्ष्य',
      'keep_tracking': 'अपनी दिनचर्या को ट्रैक करते रहें।',
      'tiny_actions': 'छोटी क्रियाएं बड़ी आदतें बनाती हैं। 5 दिनों की गतिविधि का लक्ष्य रखें।',
      'variety_goal': 'विविधता लक्ष्य',
      'explore_activities': 'विभिन्न गतिविधियों का अन्वेषण करें।',
      'aim_for_variety': '3 या अधिक जीवन क्षेत्रों में गतिविधियों को ट्रैक करने का लक्ष्य रखें।',
      'getting_started': 'शुरुआत करना',
      'more_achievements': 'अपनी दैनिक दिनचर्या को ट्रैक करते रहें! अगले सप्ताह के सिंक के बाद और उपलब्धियां अनलॉक होंगी।',
      
      // Task Names (for Daily Schedule)
      'task_prayer': 'प्रार्थना',
      'task_exercise': 'व्यायाम',
      'task_breakfast': 'नाश्ता',
      'task_lunch': 'दोपहर का भोजन',
      'task_dinner': 'रात का खाना',
      'task_work': 'काम',
      'task_study': 'अध्ययन',
      'task_reading': 'पढ़ना',
      'task_meditation': 'ध्यान',
      'task_yoga': 'योग',
      'task_walk': 'टहलना',
      'task_running': 'दौड़ना',
      'task_cooking': 'खाना बनाना',
      'task_cleaning': 'सफाई',
      'task_shopping': 'खरीदारी',
      'task_family_time': 'परिवार के साथ समय',
      'task_social': 'सामाजिक',
      'task_hobby': 'शौक',
      'task_rest': 'आराम',
      'task_sleep': 'नींद',
      'task_bathing': 'स्नान',
      'task_grooming': 'तैयार होना',
      'task_medicine': 'दवा',

      // MAUQ Form
      'mauq_form': 'MAUQ फॉर्म',
      'mauq_description': 'इस प्रश्नावली में:',
      'mauq_scale_1': '1 – दृढ़ता से असहमत',
      'mauq_scale_2': '2 – असहमत',
      'mauq_scale_3': '3 – थोड़ा असहमत',
      'mauq_scale_4': '4 – न सहमत और न असहमत',
      'mauq_scale_5': '5 – थोड़ा सहमत',
      'mauq_scale_6': '6 – सहमत',
      'mauq_scale_7': '7 – दृढ़ता से सहमत',
      'optional_feedback': 'वैकल्पिक फीडबैक',
      'submit': 'सबमिट करें',
      'already_submitted': 'फीडबैक पहले ही सबमिट किया जा चुका है!',
      'submit_success': 'MAUQ सफलतापूर्वक सबमिट किया गया!',
      'submit_failed': 'MAUQ सबमिट करने में विफल:',

      // MAUQ Questions
      'mauq_q1': 'ऐप का उपयोग करना आसान था।',
      'mauq_q2': 'मेरे लिए ऐप का उपयोग करना सीखना आसान था।',
      'mauq_q3': 'स्क्रीन के बीच नेविगेशन सुसंगत था।',
      'mauq_q4': 'इंटरफ़ेस ने मुझे पेश किए गए सभी कार्यों का उपयोग करने की अनुमति दी।',
      'mauq_q5': 'मैं गलतियों से आसानी से उबर सकता था।',
      'mauq_q6': 'मुझे ऐप का इंटरफ़ेस पसंद है।',
      'mauq_q7': 'जानकारी अच्छी तरह से व्यवस्थित थी।',
      'mauq_q8': 'ऐप ने प्रगति को पर्याप्त रूप से स्वीकार किया।',
      'mauq_q9': 'मैं सामाजिक सेटिंग्स में इस ऐप का उपयोग करने में सहज महसूस करता हूं।',
      'mauq_q10': 'ऐप का उपयोग करने में लगने वाला समय उपयुक्त था।',
      'mauq_q11': 'मैं इस ऐप का दोबारा उपयोग करूंगा।',
      'mauq_q12': 'कुल मिलाकर, मैं इस ऐप से संतुष्ट हूं।',
      'mauq_q13': 'ऐप मेरे स्वास्थ्य और कल्याण के लिए उपयोगी है।',
      'mauq_q14': 'ऐप ने स्वास्थ्य सेवाओं तक मेरी पहुंच में सुधार किया।',
      'mauq_q15': 'ऐप ने मुझे अपने स्वास्थ्य को प्रभावी ढंग से प्रबंधित करने में मदद की।',
      'mauq_q16': 'इस ऐप में सभी अपेक्षित कार्य और क्षमताएं हैं।',
      'mauq_q17': 'मैं खराब इंटरनेट कनेक्शन के साथ भी ऐप का उपयोग कर सकता था।',
      'mauq_q18': 'ऐप स्वास्थ्य सेवाएं प्राप्त करने का एक स्वीकार्य तरीका प्रदान करता है।',
    },
    'kn': {
      // Auth Page
      'enter_uid_password': 'UID ಪಾಸ್ವರ್ಡ್ ನಮೂದಿಸಿ',
      'uid': 'ಯುಐಡಿ',
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
      
      // Content Page 1 - Reading
      'reading_material': 'ಓದುವ ವಸ್ತು',
      'feeling_low_energy': 'ಕಡಿಮೆ ಶಕ್ತಿ ಅನುಭವಿಸುತ್ತಿದ್ದೀರಾ?',
      'feeling_stressed': 'ಒತ್ತಡ ಅನುಭವಿಸುತ್ತಿದ್ದೀರಾ?',
      'feeling_lonely': 'ಏಕಾಂಗಿ ಅನುಭವಿಸುತ್ತಿದ್ದೀರಾ?',
      'why_doing_important': '"ಮಾಡುವುದು" ಏಕೆ ಮುಖ್ಯ',
      'no_content_available': 'ಯಾವುದೇ ವಿಷಯ ಲಭ್ಯವಿಲ್ಲ.',
      
      // Content Page 2 - Track Progress
      'track_your_progress': 'ನಿಮ್ಮ ಪ್ರಗತಿಯನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡಿ',
      'day': 'ದಿನ',
      'week': 'ವಾರ',
      'month': 'ತಿಂಗಳು',
      'start_doing_tasks': 'ಕಾರ್ಯಗಳನ್ನು ಮಾಡಲು ಪ್ರಾರಂಭಿಸಿ ಅಥವಾ ನಿಮ್ಮ ಉನ್ನತ ಅಂಕಿಅಂಶಗಳನ್ನು ಇಲ್ಲಿ ನೋಡಲು ಕೆಲವು ಪ್ರಗತಿಯನ್ನು ಲಾಗ್ ಮಾಡಲು ಪ್ರಯತ್ನಿಸಿ!',
      'failed_to_load': 'ಡೇಟಾ ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ.',
      'great_work_1': 'ಒಳ್ಳೆಯ ಪ್ರಗತಿ! ನೀವು ಇದರಲ್ಲಿ ತೊಡಗಿಸಿಕೊಂಡಿದ್ದೀರಿ',
      'great_work_2': 'ಒಳ್ಳೆಯ ಪ್ರಯತ್ನ! ಈ ವಾರ, ನೀವು ಇದರಲ್ಲಿ ಗಮನ ಹರಿಸಿದ್ದೀರಿ',
      'great_work_3': 'ನೀವು ಇದರಲ್ಲಿ ತೊಡಗಿಸಿಕೊಂಡು ನಿಮ್ಮ ರೂಟೀನ್ ಅನ್ನು ಬಲಪಡಿಸಿದ್ದೀರಿ',
      'keep_logging': 'ವೈಯಕ್ತಿಕ ಒಳನೋಟಗಳನ್ನು ಇಲ್ಲಿ ನೋಡಲು ನಿಮ್ಮ ಕಾರ್ಯಗಳನ್ನು ಲಾಗ್ ಮಾಡುತ್ತಲೇ ಇರಿ!',
      
      // Content Page 3 - Daily Schedule
      'daily_schedule': 'ದೈನಂದಿನ ವೇಳಾಪಟ್ಟಿ',
      
      // Content Page 4 - Weekly Feedback
      'weekly_feedback': 'ಸಾಪ್ತಾಹಿಕ ಪ್ರತಿಕ್ರಿಯೆ',
      'member_since': 'ಸದಸ್ಯರಾದ ದಿನಾಂಕ:',
      'energy_levels': 'ಶಕ್ತಿ ಮಟ್ಟಗಳು',
      'satisfaction': 'ತೃಪ್ತಿ',
      'happiness': 'ಸಂತೋಷ',
      'proud_of_achievements': 'ನನ್ನ ಸಾಧನೆಗಳ ಬಗ್ಗೆ ಹೆಮ್ಮೆ',
      'how_busy': 'ನೀವು ಎಷ್ಟು ಕಾರ್ಯನಿರತರಾಗಿದ್ದೀರಿ?',
      'any_thoughts': 'ಈ ವಾರದ ಬಗ್ಗೆ ಯಾವುದೇ ಆಲೋಚನೆಗಳು ಅಥವಾ ಕಾಮೆಂಟ್‌ಗಳು?',
      'feedback_saved': 'ವಾರಕ್ಕೆ ಸಾಪ್ತಾಹಿಕ ಪ್ರತಿಕ್ರಿಯೆ',
      'saved_and_reset': 'ಉಳಿಸಲಾಗಿದೆ ಮತ್ತು ಮರುಹೊಂದಿಸಲಾಗಿದೆ.',
      'failed_to_sync': 'ಎಚ್ಚರಿಕೆ: ಪ್ರತಿಕ್ರಿಯೆ ಸಿಂಕ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ:',
      'local_data_retained': '. ಸ್ಥಳೀಯ ಡೇಟಾ ಉಳಿಸಿಕೊಳ್ಳಲಾಗಿದೆ.',
      'feedback_complete': 'ಪ್ರತಿಕ್ರಿಯೆ ಪೂರ್ಣಗೊಂಡಿದೆ! 📝',
      'thanks_for_feedback': 'ನಿಮ್ಮ ಪ್ರತಿಕ್ರಿಯೆಗೆ ಧನ್ಯವಾದಗಳು! ವಾರಕ್ಕೆ ನಿಮ್ಮ ಡೇಟಾ',
      'successfully_saved': 'ಯಶಸ್ವಿಯಾಗಿ ಉಳಿಸಲಾಗಿದೆ ಮತ್ತು ನಿಮ್ಮ ಹೊಸ ವಾರ ಪ್ರಾರಂಭವಾಗಿದೆ.',
      
      // Content Page 5 - Achievements
      'achievements': 'ಸಾಧನೆಗಳು',
      'fetching_report': 'ನಿಮ್ಮ ಸಾಪ್ತಾಹಿಕ ವರದಿಯನ್ನು ಪಡೆಯಲಾಗುತ್ತಿದೆ...',
      'congratulations': 'ಅಭಿನಂದನೆಗಳು! ಇಲ್ಲಿ ನಿಮ್ಮ ಮೈಂಡ್ ಟ್ರ್ಯಾಕ್ ಸಾಪ್ತಾಹಿಕ ವರದಿ ಇದೆ.',
      'mind_track_welcome': 'ಮೈಂಡ್ ಟ್ರ್ಯಾಕ್‌ಗೆ ಸ್ವಾಗತ',
      'check_back_after_sync': 'ನಿಮ್ಮ ಮೊದಲ ಸಾಪ್ತಾಹಿಕ ಸಿಂಕ್ ನಂತರ ಮತ್ತೆ ಪರಿಶೀಲಿಸಿ!',
      'achievements_appear_here': 'ನಿಮ್ಮ ಸಾಪ್ತಾಹಿಕ ಸಾಧನೆಗಳು ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತವೆ.',
      'consistency_goal': 'ಸ್ಥಿರತೆಯ ಗುರಿ',
      'keep_tracking': 'ನಿಮ್ಮ ದಿನಚರಿಗಳನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡುತ್ತಲೇ ಇರಿ.',
      'tiny_actions': 'ಸಣ್ಣ ಕ್ರಿಯೆಗಳು ದೊಡ್ಡ ಅಭ್ಯಾಸಗಳನ್ನು ನಿರ್ಮಿಸುತ್ತವೆ. 5 ದಿನಗಳ ಚಟುವಟಿಕೆಗೆ ಗುರಿ ಇರಿಸಿ.',
      'variety_goal': 'ವೈವಿಧ್ಯತೆಯ ಗುರಿ',
      'explore_activities': 'ವಿವಿಧ ಚಟುವಟಿಕೆಗಳನ್ನು ಅನ್ವೇಷಿಸಿ.',
      'aim_for_variety': '3 ಅಥವಾ ಹೆಚ್ಚಿನ ಜೀವನ ಕ್ಷೇತ್ರಗಳಲ್ಲಿ ಚಟುವಟಿಕೆಗಳನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡಲು ಗುರಿ ಇರಿಸಿ.',
      'getting_started': 'ಪ್ರಾರಂಭಿಸುವುದು',
      'more_achievements': 'ನಿಮ್ಮ ದೈನಂದಿನ ದಿನಚರಿಗಳನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡುತ್ತಲೇ ಇರಿ! ಮುಂದಿನ ವಾರದ ಸಿಂಕ್ ನಂತರ ಹೆಚ್ಚಿನ ಸಾಧನೆಗಳು ಅನ್‌ಲಾಕ್ ಆಗುತ್ತವೆ.',
      
      // Task Names (for Daily Schedule)
      'task_prayer': 'ಪ್ರಾರ್ಥನೆ',
      'task_exercise': 'ವ್ಯಾಯಾಮ',
      'task_breakfast': 'ಬೆಳಗಿನ ಉಪಾಹಾರ',
      'task_lunch': 'ಮಧ್ಯಾಹ್ನದ ಊಟ',
      'task_dinner': 'ರಾತ್ರಿಯ ಊಟ',
      'task_work': 'ಕೆಲಸ',
      'task_study': 'ಅಧ್ಯಯನ',
      'task_reading': 'ಓದುವುದು',
      'task_meditation': 'ಧ್ಯಾನ',
      'task_yoga': 'ಯೋಗ',
      'task_walk': 'ನಡೆಯುವುದು',
      'task_running': 'ಓಡುವುದು',
      'task_cooking': 'ಅಡುಗೆ',
      'task_cleaning': 'ಸ್ವಚ್ಛತೆ',
      'task_shopping': 'ಶಾಪಿಂಗ್',
      'task_family_time': 'ಕುಟುಂಬದ ಸಮಯ',
      'task_social': 'ಸಾಮಾಜಿಕ',
      'task_hobby': 'ಹವ್ಯಾಸ',
      'task_rest': 'ವಿಶ್ರಾಂತಿ',
      'task_sleep': 'ನಿದ್ರೆ',
      'task_bathing': 'ಸ್ನಾನ',
      'task_grooming': 'ಅಲಂಕಾರ',
      'task_medicine': 'ಔಷಧ',

      // MAUQ Form
      'mauq_form': 'MAUQ ಫಾರ್ಮ್',
      'mauq_description': 'ಈ ಪ್ರಶ್ನಾವಳಿಯಲ್ಲಿ:',
      'mauq_scale_1': '1 – ಸಂಪೂರ್ಣವಾಗಿ ಒಪ್ಪುವುದಿಲ್ಲ',
      'mauq_scale_2': '2 – ಒಪ್ಪುವುದಿಲ್ಲ',
      'mauq_scale_3': '3 – ಸ್ವಲ್ಪ ಮಟ್ಟಿಗೆ ಒಪ್ಪುವುದಿಲ್ಲ',
      'mauq_scale_4': '4 – ಒಪ್ಪುತ್ತೇನೆ ಅಥವಾ ಒಪ್ಪುವುದಿಲ್ಲ',
      'mauq_scale_5': '5 – ಸ್ವಲ್ಪ ಮಟ್ಟಿಗೆ ಒಪ್ಪುತ್ತೇನೆ',
      'mauq_scale_6': '6 – ಒಪ್ಪುತ್ತೇನೆ',
      'mauq_scale_7': '7 – ಸಂಪೂರ್ಣವಾಗಿ ಒಪ್ಪುತ್ತೇನೆ',
      'optional_feedback': 'ಐಚ್ಛಿಕ ಪ್ರತಿಕ್ರಿಯೆ',
      'submit': 'ಸಲ್ಲಿಸು',
      'already_submitted': 'ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಈಗಾಗಲೇ ಸಲ್ಲಿಸಲಾಗಿದೆ!',
      'submit_success': 'MAUQ ಅನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಸಲ್ಲಿಸಲಾಗಿದೆ!',
      'submit_failed': 'MAUQ ಸಲ್ಲಿಸಲು ವಿಫಲವಾಗಿದೆ:',

      // MAUQ Questions
      'mauq_q1': 'ಆ್ಯಪ್ ಅನ್ನು ಬಳಸುವುದು ಸುಲಭವಾಗಿತ್ತು.',
      'mauq_q2': 'ಆ್ಯಪ್ ಅನ್ನು ಬಳಸುವುದು ಕಲಿಯುವುದು ನನಗೆ ಸುಲಭವಾಗಿದೆ.',
      'mauq_q3': 'ಸ್ಕ್ರೀನ್‌ಗಳ ನಡುವಿನ ನ್ಯಾವಿಗೇಶನ್ ಸಮಾನವಾಗಿತ್ತು.',
      'mauq_q4': 'ಇಂಟರ್‌ಫೇಸ್ ಎಲ್ಲಾ ಫಂಕ್ಷನ್‌ಗಳನ್ನು ಬಳಸಲು ಅನುಮತಿಸಿತು.',
      'mauq_q5': 'ತಪ್ಪುಗಳಿಂದ ಸುಲಭವಾಗಿ ಮರಳಿ ಬರುವಂತೆ ಮಾಡಲಾಗಿದೆ.',
      'mauq_q6': 'ನನಗೆ ಆ್ಯಪ್‌ನ ಇಂಟರ್‌ಫೇಸ್ ಇಷ್ಟವಾಗಿದೆ.',
      'mauq_q7': 'ಮಾಹಿತಿ ಚೆನ್ನಾಗಿ ಸಂಘಟಿತವಾಗಿದೆ.',
      'mauq_q8': 'ಆ್ಯಪ್ ಪ್ರಗತಿಯನ್ನು ಸೂಕ್ತವಾಗಿ ಗುರುತಿಸಿದೆ.',
      'mauq_q9': 'ಸಾಮಾಜಿಕ ಪರಿಸ್ಥಿತಿಗಳಲ್ಲಿ ಆ್ಯಪ್ ಬಳಕೆ ನನಗೆ ಅನುಕೂಲವಾಗಿದೆ.',
      'mauq_q10': 'ಆ್ಯಪ್ ಬಳಸಲು ತೆಗೆದುಕೊಂಡ ಸಮಯ ಸೂಕ್ತವಾಗಿದೆ.',
      'mauq_q11': 'ನಾನು ಈ ಆ್ಯಪ್ ಅನ್ನು ಮತ್ತೆ ಬಳಸುತ್ತೇನೆ.',
      'mauq_q12': 'ಒಟ್ಟಾರೆ, ನಾನು ಆ್ಯಪ್‌ನಿಂದ ಸಂತೃಪ್ತನಾಗಿದ್ದೇನೆ.',
      'mauq_q13': 'ಆ್ಯಪ್ ನನ್ನ ಆರೋಗ್ಯ ಮತ್ತು ಕಲ್ಯಾಣಕ್ಕೆ ಉಪಯುಕ್ತವಾಗಿದೆ.',
      'mauq_q14': 'ಆ್ಯಪ್ ಆರೋಗ್ಯ ಸೇವೆಗಳಿಗೆ ನನ್ನ ಪ್ರವೇಶವನ್ನು ಸುಧಾರಿಸಿದೆ.',
      'mauq_q15': 'ಆ್ಯಪ್ ನನ್ನ ಆರೋಗ್ಯವನ್ನು ಪರಿಣಾಮಕಾರಿಯಾಗಿ ನಿರ್ವಹಿಸಲು ಸಹಾಯ ಮಾಡಿತು.',
      'mauq_q16': 'ಈ ಆ್ಯಪ್ ಎಲ್ಲ ನಿರೀಕ್ಷಿತ ಕಾರ್ಯಕ್ಷಮತೆ ಮತ್ತು ಸಾಮರ್ಥ್ಯಗಳನ್ನು ಹೊಂದಿದೆ.',
      'mauq_q17': 'ತಗ್ಗಾದ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕದಲ್ಲಿಯೂ ಆ್ಯಪ್ ಬಳಸಬಹುದು.',
      'mauq_q18': 'ಆ್ಯಪ್ ಆರೋಗ್ಯ ಸೇವೆಗಳನ್ನು ಪಡೆಯಲು ಸೂಕ್ತ ಮಾರ್ಗವನ್ನು ಒದಗಿಸುತ್ತದೆ.',
    },
    'ml': {
      // Auth Page
      'enter_uid_password': 'യുഐഡി പാസ്‌വേഡ് നൽകുക',
      'uid': 'യുഐഡി',
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
      
      // Content Page 1 - Reading
      'reading_material': 'വായനാ സാമഗ്രി',
      'feeling_low_energy': 'കുറഞ്ഞ ഊർജ്ജം അനുഭവപ്പെടുന്നുണ്ടോ?',
      'feeling_stressed': 'സമ്മർദ്ദം അനുഭവപ്പെടുന്നുണ്ടോ?',
      'feeling_lonely': 'ഏകാന്തത അനുഭവപ്പെടുന്നുണ്ടോ?',
      'why_doing_important': '"ചെയ്യുന്നത്" എന്തുകൊണ്ട് പ്രധാനം',
      'no_content_available': 'ഉള്ളടക്കം ലഭ്യമല്ല.',
      
      // Content Page 2 - Track Progress
      'track_your_progress': 'നിങ്ങളുടെ പുരോഗതി ട്രാക്ക് ചെയ്യുക',
      'day': 'ദിവസം',
      'week': 'ആഴ്ച',
      'month': 'മാസം',
      'start_doing_tasks': 'ജോലികൾ ചെയ്യാൻ തുടങ്ങുക അല്ലെങ്കിൽ നിങ്ങളുടെ മികച്ച സ്ഥിതിവിവരക്കണക്കുകൾ ഇവിടെ കാണാൻ കുറച്ച് പുരോഗതി ലോഗ് ചെയ്യാൻ ശ്രമിക്കുക!',
      'failed_to_load': 'ഡാറ്റ ലോഡ് ചെയ്യുന്നതിൽ പരാജയപ്പെട്ടു. ദയവായി നിങ്ങളുടെ കണക്ഷൻ പരിശോധിക്കുക.',
      'great_work_1': 'നല്ല പുരോഗതി! നിങ്ങൾ ഇതിൽ താൽപ്പര്യം പുലർത്തി',
      'great_work_2': 'നല്ല ശ്രമം! ഈ ആഴ്ച, നിങ്ങൾ ഇതിൽ ശ്രദ്ധ കേന്ദ്രീകരിച്ചു',
      'great_work_3': 'നിങ്ങൾ ഇതിൽ താൽപ്പര്യം പുലർത്തിയത് വഴി നിങ്ങളുടെ റൂട്ടീൻ ശക്തമാക്കി',
      'and_staying_consistent': ', കൂടാതെ സ്ഥിരത പാലിക്കുന്നു.',
      'keep_logging': 'വ്യക്തിഗത ഉൾക്കാഴ്ചകൾ ഇവിടെ കാണാൻ നിങ്ങളുടെ ജോലികൾ ലോഗ് ചെയ്യുന്നത് തുടരുക!',
      
      // Content Page 3 - Daily Schedule
      'daily_schedule': 'ദൈനംദിന ഷെഡ്യൂൾ',
      
      // Content Page 4 - Weekly Feedback
      'weekly_feedback': 'പ്രതിവാര ഫീഡ്‌ബാക്ക്',
      'member_since': 'അംഗമായത്:',
      'energy_levels': 'ഊർജ്ജ നിലകൾ',
      'satisfaction': 'സംതൃപ്തി',
      'happiness': 'സന്തോഷം',
      'proud_of_achievements': 'എന്റെ നേട്ടങ്ങളിൽ അഭിമാനം',
      'how_busy': 'നിങ്ങൾക്ക് എത്ര തിരക്കായിരുന്നു?',
      'any_thoughts': 'ഈ ആഴ്ചയെക്കുറിച്ച് എന്തെങ്കിലും ചിന്തകളോ അഭിപ്രായങ്ങളോ?',
      'feedback_saved': 'ആഴ്ചയ്ക്കുള്ള പ്രതിവാര ഫീഡ്‌ബാക്ക്',
      'saved_and_reset': 'സംരക്ഷിച്ചു, റീസെറ്റ് ചെയ്തു.',
      'failed_to_sync': 'മുന്നറിയിപ്പ്: ഫീഡ്‌ബാക്ക് സമന്വയിപ്പിക്കുന്നതിൽ പരാജയപ്പെട്ടു:',
      'local_data_retained': '. പ്രാദേശിക ഡാറ്റ നിലനിർത്തി.',
      'feedback_complete': 'ഫീഡ്‌ബാക്ക് പൂർത്തിയായി! 📝',
      'thanks_for_feedback': 'നിങ്ങളുടെ ഫീഡ്‌ബാക്കിന് നന്ദി! ആഴ്ചയ്ക്കുള്ള നിങ്ങളുടെ ഡാറ്റ',
      'successfully_saved': 'വിജയകരമായി സംരക്ഷിച്ചു, നിങ്ങളുടെ പുതിയ ആഴ്ച ആരംഭിച്ചു.',
      
      // Content Page 5 - Achievements
      'achievements': 'നേട്ടങ്ങൾ',
      'fetching_report': 'നിങ്ങളുടെ പ്രതിവാര റിപ്പോർട്ട് എടുക്കുന്നു...',
      'congratulations': 'അഭിനന്ദനങ്ങൾ! ഇതാ നിങ്ങളുടെ മൈൻഡ് ട്രാക്ക് പ്രതിവാര റിപ്പോർട്ട്.',
      'mind_track_welcome': 'മൈൻഡ് ട്രാക്കിലേക്ക് സ്വാഗതം',
      'check_back_after_sync': 'നിങ്ങളുടെ ആദ്യ പ്രതിവാര സമന്വയത്തിന് ശേഷം തിരികെ പരിശോധിക്കുക!',
      'achievements_appear_here': 'നിങ്ങളുടെ പ്രതിവാര നേട്ടങ്ങൾ ഇവിടെ ദൃശ്യമാകും.',
      'consistency_goal': 'സ്ഥിരത ലക്ഷ്യം',
      'keep_tracking': 'നിങ്ങളുടെ ദിനചര്യകൾ ട്രാക്ക് ചെയ്യുന്നത് തുടരുക.',
      'tiny_actions': 'ചെറിയ പ്രവർത്തനങ്ങൾ വലിയ ശീലങ്ങൾ നിർമ്മിക്കുന്നു. 5 ദിവസത്തെ പ്രവർത്തനത്തിന് ലക്ഷ്യമിടുക.',
      'variety_goal': 'വൈവിധ്യ ലക്ഷ്യം',
      'explore_activities': 'വ്യത്യസ്ത പ്രവർത്തനങ്ങൾ പര്യവേക്ഷണം ചെയ്യുക.',
      'aim_for_variety': '3 അല്ലെങ്കിൽ അതിലധികം ജീവിത മേഖലകളിൽ പ്രവർത്തനങ്ങൾ ട്രാക്ക് ചെയ്യാൻ ലക്ഷ്യമിടുക.',
      'getting_started': 'ആരംഭിക്കുന്നു',
      'more_achievements': 'നിങ്ങളുടെ ദൈനംദിന ദിനചര്യകൾ ട്രാക്ക് ചെയ്യുന്നത് തുടരുക! അടുത്ത ആഴ്ചയുടെ സമന്വയത്തിന് ശേഷം കൂടുതൽ നേട്ടങ്ങൾ അൺലോക്ക് ചെയ്യും.',
      
      // Task Names (for Daily Schedule)
      'task_prayer': 'പ്രാർത്ഥന',
      'task_exercise': 'വ്യായാമം',
      'task_breakfast': 'പ്രഭാതഭക്ഷണം',
      'task_lunch': 'ഉച്ചഭക്ഷണം',
      'task_dinner': 'അത്താഴം',
      'task_work': 'ജോലി',
      'task_study': 'പഠനം',
      'task_reading': 'വായന',
      'task_meditation': 'ധ്യാനം',
      'task_yoga': 'യോഗ',
      'task_walk': 'നടത്തം',
      'task_running': 'ഓട്ടം',
      'task_cooking': 'പാചകം',
      'task_cleaning': 'വൃത്തിയാക്കൽ',
      'task_shopping': 'ഷോപ്പിംഗ്',
      'task_family_time': 'കുടുംബ സമയം',
      'task_social': 'സാമൂഹികം',
      'task_hobby': 'ഹോബി',
      'task_rest': 'വിശ്രമം',
      'task_sleep': 'ഉറക്കം',
      'task_bathing': 'കുളി',
      'task_grooming': 'ഒരുക്കം',
      'task_medicine': 'മരുന്ന്',

      // MAUQ Form
      'mauq_form': 'MAUQ ഫോം',
      'mauq_description': 'ഈ ചോദ്യാവലിയിൽ:',
      'mauq_scale_1': '1 – ശക്തമായി വിയോജിക്കുന്നു',
      'mauq_scale_2': '2 – വിയോജിക്കുന്നു',
      'mauq_scale_3': '3 – ഒരളവു വരെ വിയോജിക്കുന്നു',
      'mauq_scale_4': '4 – യോജിക്കുകയോ വിയോജിക്കുകയോ ചെയ്യുന്നില്ല',
      'mauq_scale_5': '5 – ഒരളവു വരെ യോജിക്കുന്നു',
      'mauq_scale_6': '6 – യോജിക്കുന്നു',
      'mauq_scale_7': '7 – ശക്തമായി യോജിക്കുന്നു',
      'optional_feedback': 'ഓപ്ഷണൽ ഫീഡ്‌ബാക്ക്',
      'submit': 'സമർപ്പിക്കുക',
      'already_submitted': 'ഫീഡ്‌ബാക്ക് ഇതിനകം സമർപ്പിച്ചു!',
      'submit_success': 'MAUQ വിജയകരമായി സമർപ്പിച്ചു!',
      'submit_failed': 'MAUQ സമർപ്പിക്കുന്നതിൽ പരാജയപ്പെട്ടു:',

      // MAUQ Questions
      'mauq_q1': 'ആപ്പ് ഉപയോഗിക്കാൻ എളുപ്പമായിരുന്നു.',
      'mauq_q2': 'ആപ്പ് ഉപയോഗിക്കാൻ പഠിക്കുന്നത് എനിക്ക് എളുപ്പമായിരുന്നു.',
      'mauq_q3': 'സ്ക്രീനുകൾ തമ്മിലുള്ള നാവിഗേഷൻ സുസ്ഥിരമായിരുന്നു.',
      'mauq_q4': 'വാഗ്ദാനം ചെയ്ത എല്ലാ പ്രവർത്തനങ്ങളും ഉപയോഗിക്കാൻ ഇന്റർഫേസ് എന്നെ അനുവദിച്ചു.',
      'mauq_q5': 'തെറ്റുകളിൽ നിന്ന് എളുപ്പത്തിൽ കരകയറാൻ എനിക്ക് കഴിഞ്ഞു.',
      'mauq_q6': 'എനിക്ക് ആപ്പിന്റെ ഇന്റർഫേസ് ഇഷ്ടപ്പെട്ടു.',
      'mauq_q7': 'വിവരങ്ങൾ നന്നായി ക്രമീകരിച്ചിരുന്നു.',
      'mauq_q8': 'ആപ്പ് പുരോഗതി വേണ്ടവിധം അംഗീകരിച്ചു.',
      'mauq_q9': 'സാമൂഹിക സാഹചര്യങ്ങളിൽ ഈ ആപ്പ് ഉപയോഗിക്കുന്നത് എനിക്ക് സുഖകരമാണ്.',
      'mauq_q10': 'ആപ്പ് ഉപയോഗിക്കാൻ എടുത്ത സമയം അനുയോജ്യമായിരുന്നു.',
      'mauq_q11': 'ഞാൻ ഈ ആപ്പ് വീണ്ടും ഉപയോഗിക്കും.',
      'mauq_q12': 'മൊത്തത്തിൽ, ഈ ആപ്പിൽ ഞാൻ സംതൃപ്തനാണ്.',
      'mauq_q13': 'എന്റെ ആരോഗ്യത്തിനും ക്ഷേമത്തിനും ആപ്പ് ഉപകാരപ്രദമാണ്.',
      'mauq_q14': 'ആപ്പ് എനിക്ക് ആരോഗ്യ സേവനങ്ങളിലേക്കുള്ള പ്രവേശനം മെച്ചപ്പെടുത്തി.',
      'mauq_q15': 'എന്റെ ആരോഗ്യം ഫലപ്രദമായി കൈകാര്യം ചെയ്യാൻ ആപ്പ് എന്നെ സഹായിച്ചു.',
      'mauq_q16': 'ഈ ആപ്പിൽ പ്രതീക്ഷിക്കുന്ന എല്ലാ പ്രവർത്തനങ്ങളും കഴിവുകളും ഉണ്ട്.',
      'mauq_q17': 'മോശം ഇന്റർനെറ്റ് കണക്ഷനിൽ പോലും എനിക്ക് ആപ്പ് ഉപയോഗിക്കാൻ കഴിഞ്ഞു.',
      'mauq_q18': 'ആരോഗ്യ സേവനങ്ങൾ സ്വീകരിക്കുന്നതിന് ആപ്പ് സ്വീകാര്യമായ ഒരു മാർഗ്ഗം നൽകുന്നു.',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']?[key] ?? 
           key;
  }

  // Convenience getters for commonly used strings
  String get uid => translate('uid');
  String get enterUidPassword => translate('enter_uid_password');
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

  // MAUQ Form
  String get mauqForm => translate('mauq_form');
  String get mauqDescription => translate('mauq_description');
  String get optionalFeedback => translate('optional_feedback');
  String get submit => translate('submit');
  String get alreadySubmitted => translate('already_submitted');
  String get submitSuccess => translate('submit_success');
  String get submitFailed => translate('submit_failed');
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