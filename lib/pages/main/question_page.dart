import 'package:flutter/material.dart';
import 'package:mind_track/l10n/app_localizations.dart';
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

  // true = Kannada, false = English
  bool _isKannada = false;

  @override
  void initState() {
    super.initState();
    _feedbackController.addListener(() {
      setState(() {
        feedbackText = _feedbackController.text;
      });
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitMAUQ() async {
    final Map<String, dynamic> payload = {
      for (int i = 0; i < 18; i++) "q${i + 1}": _answers[i].round(),
      "feedback_text": feedbackText,
    };

    try {
      await _api.submitMAUQ(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("MAUQ submitted successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit MAUQ: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                  _isKannada ? "MAUQ ಫಾರ್ಮ್" : "MAUQ Form",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Language toggle
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() => _isKannada = !_isKannada);
                  },
                  child: Text(
                    _isKannada ? "Switch to English" : "Switch to Kannada",
                    style: const TextStyle(fontSize: 12),
                  ),
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
                child: Text(
                  _isKannada
                      ? "ಈ ಪ್ರಶ್ನಾವಳಿಯಲ್ಲಿ:\n"
                      "1 – ಸಂಪೂರ್ಣವಾಗಿ ಒಪ್ಪುವುದಿಲ್ಲ\n"
                      "2 – ಒಪ್ಪುವುದಿಲ್ಲ\n"
                      "3 – ಸ್ವಲ್ಪ ಮಟ್ಟಿಗೆ ಒಪ್ಪುವುದಿಲ್ಲ\n"
                      "4 – ಒಪ್ಪುತ್ತೇನೆ ಅಥವಾ ಒಪ್ಪುವುದಿಲ್ಲ\n"
                      "5 – ಸ್ವಲ್ಪ ಮಟ್ಟಿಗೆ ಒಪ್ಪುತ್ತೇನೆ\n"
                      "6 – ಒಪ್ಪುತ್ತೇನೆ\n"
                      "7 – ಸಂಪೂರ್ಣವಾಗಿ ಒಪ್ಪುತ್ತೇನೆ"
                      : "In this questionnaire:\n"
                      "1 – Strongly disagree\n"
                      "2 – Disagree\n"
                      "3 – Somewhat disagree\n"
                      "4 – Neither agree nor disagree\n"
                      "5 – Somewhat agree\n"
                      "6 – Agree\n"
                      "7 – Strongly agree",
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(height: 16),

              // Questions
              ...List.generate(18, (index) {
                return _buildSlider(
                  label: "Q${index + 1}: ${_getQuestionText(index)}",
                  value: _answers[index],
                  onChanged: (v) => setState(() => _answers[index] = v),
                );
              }),

              const SizedBox(height: 20),

              // Feedback
              _buildFeedbackTextBox(),

              const SizedBox(height: 20),

              // Submit
              ElevatedButton(
                onPressed: _submitMAUQ,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.translate('Submit'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
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
                String number = _isKannada
                    ? ['೧', '೨', '೩', '೪', '೫', '೬', '೭'][i]
                    : '${i + 1}';
                return Text(number,
                    style:
                    const TextStyle(fontSize: 12, color: Colors.grey));
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTextBox() {
    return TextField(
      controller: _feedbackController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: _isKannada ? 'ಐಚ್ಛಿಕ ಪ್ರತಿಕ್ರಿಯೆ' : 'Optional Feedback',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _getQuestionText(int index) {
    const englishQuestions = [
      "The app was easy to use.",
      "It was easy for me to learn to use the app.",
      "The navigation was consistent between screens.",
      "The interface allowed me to use all functions offered.",
      "I could recover easily from mistakes.",
      "I like the interface of the app.",
      "Information was well organized.",
      "App adequately acknowledged progress.",
      "I feel comfortable using this app in social settings.",
      "Time involved in using the app was fitting.",
      "I would use this app again.",
      "Overall, I am satisfied with this app.",
      "The app is useful for my health and well-being.",
      "The app improved my access to healthcare services.",
      "The app helped me manage my health effectively.",
      "This app has all expected functions and capabilities.",
      "I could use the app even with poor internet connection.",
      "The app provides an acceptable way to receive healthcare services."
    ];

    const kannadaQuestions = [
      "ಆ್ಯಪ್ ಅನ್ನು ಬಳಸುವುದು ಸುಲಭವಾಗಿತ್ತು.",
      "ಆ್ಯಪ್ ಅನ್ನು ಬಳಸುವುದು ಕಲಿಯುವುದು ನನಗೆ ಸುಲಭವಾಗಿದೆ.",
      "ಸ್ಕ್ರೀನ್‌ಗಳ ನಡುವಿನ ನ್ಯಾವಿಗೇಶನ್ ಸಮಾನವಾಗಿತ್ತು.",
      "ಇಂಟರ್‌ಫೇಸ್ ಎಲ್ಲಾ ಫಂಕ್ಷನ್‌ಗಳನ್ನು ಬಳಸಲು ಅನುಮತಿಸಿತು.",
      "ತಪ್ಪುಗಳಿಂದ ಸುಲಭವಾಗಿ ಮರಳಿ ಬರುವಂತೆ ಮಾಡಲಾಗಿದೆ.",
      "ನನಗೆ ಆ್ಯಪ್‌ನ ಇಂಟರ್‌ಫೇಸ್ ಇಷ್ಟವಾಗಿದೆ.",
      "ಮಾಹಿತಿ ಚೆನ್ನಾಗಿ ಸಂಘಟಿತವಾಗಿದೆ.",
      "ಆ್ಯಪ್ ಪ್ರಗತಿಯನ್ನು ಸೂಕ್ತವಾಗಿ ಗುರುತಿಸಿದೆ.",
      "ಸಾಮಾಜಿಕ ಪರಿಸ್ಥಿತಿಗಳಲ್ಲಿ ಆ್ಯಪ್ ಬಳಕೆ ನನಗೆ ಅನುಕೂಲವಾಗಿದೆ.",
      "ಆ್ಯಪ್ ಬಳಸಲು ತೆಗೆದುಕೊಂಡ ಸಮಯ ಸೂಕ್ತವಾಗಿದೆ.",
      "ನಾನು ಈ ಆ್ಯಪ್ ಅನ್ನು ಮತ್ತೆ ಬಳಸುತ್ತೇನೆ.",
      "ಒಟ್ಟಾರೆ, ನಾನು ಆ್ಯಪ್‌ನಿಂದ ಸಂತೃಪ್ತನಾಗಿದ್ದೇನೆ.",
      "ಆ್ಯಪ್ ನನ್ನ ಆರೋಗ್ಯ ಮತ್ತು ಕಲ್ಯಾಣಕ್ಕೆ ಉಪಯುಕ್ತವಾಗಿದೆ.",
      "ಆ್ಯಪ್ ಆರೋಗ್ಯ ಸೇವೆಗಳಿಗೆ ನನ್ನ ಪ್ರವೇಶವನ್ನು ಸುಧಾರಿಸಿದೆ.",
      "ಆ್ಯಪ್ ನನ್ನ ಆರೋಗ್ಯವನ್ನು ಪರಿಣಾಮಕಾರಿಯಾಗಿ ನಿರ್ವಹಿಸಲು ಸಹಾಯ ಮಾಡಿತು.",
      "ಈ ಆ್ಯಪ್ ಎಲ್ಲ ನಿರೀಕ್ಷಿತ ಕಾರ್ಯಕ್ಷಮತೆ ಮತ್ತು ಸಾಮರ್ಥ್ಯಗಳನ್ನು ಹೊಂದಿದೆ.",
      "ತಗ್ಗಾದ ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕದಲ್ಲಿಯೂ ಆ್ಯಪ್ ಬಳಸಬಹುದು.",
      "ಆ್ಯಪ್ ಆರೋಗ್ಯ ಸೇವೆಗಳನ್ನು ಪಡೆಯಲು ಸೂಕ್ತ ಮಾರ್ಗವನ್ನು ಒದಗಿಸುತ್ತದೆ."
    ];

    return _isKannada ? kannadaQuestions[index] : englishQuestions[index];
  }
}