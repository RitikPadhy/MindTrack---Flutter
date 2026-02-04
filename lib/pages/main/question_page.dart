import 'package:flutter/material.dart';
import 'package:mind_track/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  final ApiService _api = ApiService();

  // 18 sliders, neutral midpoint = 4
  final List<double> _answers = List.filled(18, 4);

  String feedbackText = "";
  final TextEditingController _feedbackController = TextEditingController();

  // Selected language code for the form
  String? _selectedFormLanguage;

  // Check if feedback already submitted
  bool _alreadySubmitted = false;

  // SharedPreferences key
  static const String mauqSubmittedKey = 'mauq_submitted';

  @override
  void initState() {
    super.initState();
    _feedbackController.addListener(() {
      setState(() {
        feedbackText = _feedbackController.text;
      });
    });
    _checkIfAlreadySubmitted();
  }

  Future<void> _checkIfAlreadySubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySubmitted = prefs.getBool(mauqSubmittedKey) ?? false;

    if (alreadySubmitted && mounted) {
      setState(() {
        _alreadySubmitted = true;
      });

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('mauq_already_submitted'))),
      );
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitMAUQ() async {
    final l10n = AppLocalizations.of(context);
    final Map<String, dynamic> payload = {
      for (int i = 0; i < 18; i++) "q${i + 1}": _answers[i].round(),
      "feedback_text": feedbackText,
    };

    try {
      await _api.submitMAUQ(payload);

      // Save flag locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(mauqSubmittedKey, true);

      setState(() {
        _alreadySubmitted = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.translate('mauq_submitted_success'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${l10n.translate('mauq_submit_failed')} $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Use selected form language or fall back to system locale
    final langCode = _selectedFormLanguage ?? l10n.locale.languageCode;
    
    // Determine number symbols based on language
    final List<String> numberSymbols = (langCode == 'kn')
        ? ['೧', '೨', '೩', '೪', '೫', '೬', '೭']
        : ['1', '2', '3', '4', '5', '6', '7'];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF9FE2BF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _translateLocal(l10n, langCode, 'mauq_form'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Language selection chips
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    _buildLanguageChip(l10n, 'en', 'English'),
                    _buildLanguageChip(l10n, 'hi', 'हिंदी'),
                    _buildLanguageChip(l10n, 'kn', 'ಕನ್ನಡ'),
                    _buildLanguageChip(l10n, 'ml', 'മലയാളം'),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Scale description (shown once)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(128, 128, 128, 0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _translateLocal(l10n, langCode, 'in_this_questionnaire'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    ...List.generate(7, (i) {
                      return Text(
                        _translateLocal(l10n, langCode, 'scale_${i + 1}'),
                        style: const TextStyle(fontSize: 13),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Questions
              ...List.generate(18, (index) {
                return _buildSlider(
                  label: "Q${index + 1}: ${_translateLocal(l10n, langCode, 'mauq_q${index + 1}')}",
                  value: _answers[index],
                  numberSymbols: numberSymbols,
                  onChanged: _alreadySubmitted
                      ? null
                      : (v) => setState(() => _answers[index] = v),
                );
              }),

              const SizedBox(height: 20),

              // Feedback
              _buildFeedbackTextBox(l10n, langCode),

              const SizedBox(height: 20),

              // Submit
              ElevatedButton(
                onPressed: _alreadySubmitted ? null : _submitMAUQ,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _alreadySubmitted ? Colors.grey : Colors.lightGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.submit,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageChip(AppLocalizations l10n, String code, String label) {
    // Current active language for the form
    final currentLang = _selectedFormLanguage ?? l10n.locale.languageCode;
    final isSelected = currentLang == code;

    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
      selected: isSelected,
      selectedColor: const Color(0xFF9FE2BF),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedFormLanguage = code;
          });
        }
      },
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required List<String> numberSymbols,
    ValueChanged<double>? onChanged,
  }) {
    final languageCode = AppLocalizations.of(context).locale.languageCode;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(128, 128, 128, 0.1),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 15),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.lightGreen,
              inactiveTrackColor: Colors.grey.shade200,
              trackHeight: 8,
              thumbColor: Colors.lightGreen,
              overlayColor: const Color.fromRGBO(76, 175, 80, 0.2),
              showValueIndicator: ShowValueIndicator.onDrag,
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 7,
              divisions: 6,
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                return Text(numberSymbols[i],
                    style:
                    const TextStyle(fontSize: 12, color: Colors.grey));
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTextBox(AppLocalizations l10n, String langCode) {
    return TextField(
      controller: _feedbackController,
      maxLines: 5,
      enabled: !_alreadySubmitted,
      decoration: InputDecoration(
        hintText: _translateLocal(l10n, langCode, 'optional_feedback'),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Helper to translate using the override language or fallback to l10n delegate
  String _translateLocal(AppLocalizations l10n, String langCode, String key) {
    return l10n.translateWithCode(key, langCode);
  }
}