import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mind_track/l10n/app_localizations.dart';
import '../../services/api_service.dart';
import 'dart:math';

class ContentPage2 extends StatefulWidget {
  const ContentPage2({super.key});

  @override
  State<ContentPage2> createState() => _ContentPage2State();
}

class _ContentPage2State extends State<ContentPage2> {
  String _selectedPeriod = 'month'; // Default period
  List<Map<String, dynamic>> _topTasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  final ApiService _apiService = ApiService(); // Initialize ApiService

  @override
  void initState() {
    super.initState();
    _fetchProgress(); // Fetch initial data
  }

  String getTopTaskMessage(Map<String, dynamic> topTask, AppLocalizations l10n) {
    if (topTask['percentage_done'] == null || topTask['percentage_done'] <= 0) {
      return l10n.translate('keep_logging');
    }

    final String taskName = topTask['task'];
    final List<String> messages = [
      '${l10n.translate('great_work_1')} $taskName',
      '${l10n.translate('great_work_2')} $taskName',
      '${l10n.translate('great_work_3')} $taskName',
    ];

    final random = Random();
    return messages[random.nextInt(messages.length)];
  }

  // --- Data Fetching Logic ---
  Future<void> _fetchProgress() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _topTasks = [];
    });

    try {
      final data = await _apiService.getProgress(_selectedPeriod.toLowerCase());
      final List<dynamic> tasks = data['top_tasks'];

      setState(() {
        _topTasks = tasks.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      // Log the error for debugging
      debugPrint('Error fetching progress: $e');
      setState(() {
        _errorMessage = AppLocalizations.of(context).translate('failed_to_load');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UI Builder Methods ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    bool hasData = _topTasks.isNotEmpty;
    bool hasZeroProgress = hasData &&
        ((_topTasks.first['percentage_done'] ?? 0) <= 0);

    Widget contentWidget;

    if (_isLoading) {
      contentWidget = const Center(child: CircularProgressIndicator(color: Color(0xFF9FE2BF)));
    } else if (_errorMessage != null) {
      contentWidget = Center(child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)));
    } else if (!hasData || hasZeroProgress) {
      contentWidget = Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            l10n.translate('start_doing_tasks'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    } else {
      // Show the Pie Chart
      contentWidget = SizedBox(
        height: 250,
        child: PieChart(
          PieChartData(
            sections: _getSections(_topTasks),
            sectionsSpace: 4,
            centerSpaceRadius: 70,
            borderData: FlBorderData(show: false),
          ),
        ),
      );
    }


    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  l10n.translate('track_your_progress'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Day/Week/Month Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProgressButton(l10n.translate('day').toUpperCase()),
                  _buildProgressButton(l10n.translate('week').toUpperCase()),
                  _buildProgressButton(l10n.translate('month').toUpperCase()),
                ],
              ),

              const SizedBox(height: 50), // Adjusted spacing

              // Pie Chart / Message / Loader
              // The main content widget now takes a fixed height or natural space
              SizedBox(
                height: 300, // Fixed height for the chart/message area
                child: contentWidget,
              ),

              const Spacer(), // Pushes the following content to the bottom

              // Information Box (The requested box)
              if (!_isLoading && _errorMessage == null && hasData)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(128, 128, 128, 0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFFDE7)),
                  ),
                  child: Text(
                    _topTasks.first['percentage_done'] > 0
                        ? getTopTaskMessage(_topTasks.first, l10n)
                        : l10n.translate('keep_logging'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xA6000000),
                    ),
                  ),
                ),

              // Removed the final Spacer and SizedBox since the box is now near the bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressButton(String text) {
    final isSelected = text.toLowerCase() == _selectedPeriod;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          setState(() {
            _selectedPeriod = text.toLowerCase();
          });
          _fetchProgress();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFDE7) : Colors.white,
          border: Border.all(color: const Color(0xFFFFFDE7)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(128, 128, 128, 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.black54,
          ),
        ),
      ),
    );
  }

  // --- Pie Chart Sections based on API data ---
  List<PieChartSectionData> _getSections(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) return [];

    final values = tasks.map<double>((t) {
      final v = t['percentage_done'];
      if (v is int) return v.toDouble();
      if (v is double) return v;
      return 0.0;
    }).toList();
    final titles = tasks.map<String>((t) => '${t['task']}\n${t['percentage_done']}%').toList();

    // Color range: from light green → soft golden-cream
    const startColor = Color(0xFFCCF5E1); // pale mint-green
    const endColor   = Color(0xFFFFE6A7); // soft golden-cream

    Color interpolateColor(double t) {
      return Color.lerp(startColor, endColor, t)!;
    }

    return List.generate(values.length, (i) {
      final double t = values.length <= 1 ? 0.5 : i / (values.length - 1);
      final color = interpolateColor(t);

      return PieChartSectionData(
        color: color,
        value: values[i],
        title: titles[i],
        radius: 105,
        titlePositionPercentageOffset: 0.5,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      );
    });
  }
}