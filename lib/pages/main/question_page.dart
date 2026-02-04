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
        SnackBar(content: Text(l10n.alreadySubmitted)),
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
          SnackBar(content: Text(l10n.submitSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${l10n.submitFailed} $e")),
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
                  l10n.mauqForm,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                  "${l10n.mauqDescription}\n"
                  "${l10n.translate('mauq_scale_1')}\n"
                  "${l10n.translate('mauq_scale_2')}\n"
                  "${l10n.translate('mauq_scale_3')}\n"
                  "${l10n.translate('mauq_scale_4')}\n"
                  "${l10n.translate('mauq_scale_5')}\n"
                  "${l10n.translate('mauq_scale_6')}\n"
                  "${l10n.translate('mauq_scale_7')}",
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(height: 16),

              // Questions
              ...List.generate(18, (index) {
                return _buildSlider(
                  label: "Q${index + 1}: ${l10n.translate('mauq_q${index + 1}')}",
                  value: _answers[index],
                  onChanged: _alreadySubmitted
                      ? null
                      : (v) => setState(() => _answers[index] = v),
                );
              }),

              const SizedBox(height: 20),

              // Feedback
              _buildFeedbackTextBox(l10n),

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

  Widget _buildSlider({
    required String label,
    required double value,
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
                String number = (languageCode == 'kn')
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

  Widget _buildFeedbackTextBox(AppLocalizations l10n) {
    return TextField(
      controller: _feedbackController,
      maxLines: 5,
      enabled: !_alreadySubmitted,
      decoration: InputDecoration(
        hintText: l10n.optionalFeedback,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}