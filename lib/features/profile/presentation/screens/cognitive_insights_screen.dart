import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/mindflow_theme.dart';
import '../../../auth/presentation/providers/user_provider.dart';
import '../../domain/models/personality_trend.dart';
import '../../../identity/domain/models/personality_vector.dart';

class CognitiveInsightsScreen extends ConsumerStatefulWidget {
  const CognitiveInsightsScreen({super.key});

  @override
  ConsumerState<CognitiveInsightsScreen> createState() =>
      _CognitiveInsightsScreenState();
}

class _CognitiveInsightsScreenState
    extends ConsumerState<CognitiveInsightsScreen> {
  List<PersonalityTrend> _trends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrends();
  }

  Future<void> _loadTrends() async {
    final trends = await ref.read(userProvider.notifier).getTrends();
    if (mounted) {
      setState(() {
        _trends = trends.reversed.toList(); // Oldest first for the chart
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final isPro = userState.isSubscribed;

    return Scaffold(
      backgroundColor: MindFlowTheme.cream, // #FAFAFA
      appBar: AppBar(
        title: const Text(
          'Cognitive Insights',
          style: TextStyle(
            color: MindFlowTheme.obsidian,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: MindFlowTheme.obsidian),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildTrendChart(isPro),
              const SizedBox(height: 32),
              _buildAboutMeSection(isPro),
            ],
          ),
        ),
      ),
      // floatingActionButton: kDebugMode
      //     ? FloatingActionButton(
      //         onPressed: _simulateData,
      //         child: const Icon(Icons.refresh),
      //       )
      //     : null,
      floatingActionButton: null,
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Evolution',
          style: TextStyle(
            color: MindFlowTheme.obsidian,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Track how your cognitive patterns shift over time.',
          style: TextStyle(
            color: MindFlowTheme.obsidianLight,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart(bool isPro) {
    if (!isPro) {
      return _buildLockedFeature('Unlock Pro to view your cognitive trends.');
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_trends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights, size: 48, color: MindFlowTheme.obsidianLight),
            SizedBox(height: 16),
            Text(
              'No trends detected yet.',
              style: TextStyle(
                color: MindFlowTheme.obsidian,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your cognitive patterns will appear here\nafter your first recalibration session.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MindFlowTheme.obsidianLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Prepare chart data
    // We'll show 4 lines: D, N, R, S
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false), // Too crowded usually
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (_trends.length - 1).toDouble(),
          minY: 0,
          maxY: 1,
          lineBarsData: [
            _buildLine(
                Colors.blue, (i) => _trends[i].vector.discipline), // Discipline
            _buildLine(
                Colors.purple, (i) => _trends[i].vector.novelty), // Novelty
            _buildLine(
                Colors.red, (i) => _trends[i].vector.reactivity), // Reactivity
            _buildLine(
                Colors.green, (i) => _trends[i].vector.structure), // Structure
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLine(Color color, double Function(int) activeValue) {
    return LineChartBarData(
      spots: List.generate(_trends.length, (index) {
        return FlSpot(index.toDouble(), activeValue(index));
      }),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildAboutMeSection(bool isPro) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About Me Context',
          style: TextStyle(
            color: MindFlowTheme.obsidian,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This context helps Gemini understand you better.',
                style: TextStyle(
                  color: MindFlowTheme.obsidianLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              // Placeholder for editable text fields
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Your Core Values',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: isPro, // Gate editing
              ),
              if (!isPro)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Unlock Pro to customize your AI context.',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLockedFeature(String message) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
