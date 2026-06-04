import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/gradient_header.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/daily_log.dart';
import '../../../core/providers/cycle_provider.dart';

class CycleHistoryScreen extends StatefulWidget {
  const CycleHistoryScreen({super.key});

  @override
  State<CycleHistoryScreen> createState() => _CycleHistoryScreenState();
}

class _CycleHistoryScreenState extends State<CycleHistoryScreen> {
  bool _showCharts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cycle History')),
      body: Consumer<CycleProvider>(
        builder: (context, cycleProvider, child) {
          final history = cycleProvider.cycleHistory;
          final symptomCounts = _buildSymptomCounts(cycleProvider.recentLogs);
          final highestSymptomCount = symptomCounts.fold<int>(0,
              (highest, item) => item.count > highest ? item.count : highest);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const GradientHeader(
                  icon: Icons.history,
                  title: 'Cycle History',
                  subtitle: 'Track your patterns and symptoms',
                ),
                const SizedBox(height: 24),

                // Toggle
                Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showCharts = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _showCharts
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'Charts & Stats',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _showCharts
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showCharts = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_showCharts
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'History List',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !_showCharts
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_showCharts) ...[
                  // Stats
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatCard(
                              'Average',
                              history.isEmpty
                                  ? '--'
                                  : '${cycleProvider.averageCycleLength}',
                              'Days')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildStatCard(
                              'Shortest',
                              history.isEmpty
                                  ? '--'
                                  : '${cycleProvider.shortestCycleLength}',
                              'Days')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildStatCard(
                              'Longest',
                              history.isEmpty
                                  ? '--'
                                  : '${cycleProvider.longestCycleLength}',
                              'Days')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Line Chart
                  if (history.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cycle Length Trend',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true, reservedSize: 30)),
                                  bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 22,
                                          getTitlesWidget: (val, meta) {
                                            final index = history.length -
                                                1 -
                                                val.toInt(); // Reverse index for chronological order
                                            if (index >= 0 &&
                                                index < history.length) {
                                              final month = DateFormat('MMM')
                                                  .format(
                                                      history[index].startDate);
                                              return Text(month,
                                                  style: const TextStyle(
                                                      fontSize: 10));
                                            }
                                            return const Text('');
                                          })),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: (history.length - 1)
                                    .toDouble()
                                    .clamp(0, double.infinity),
                                minY: 20,
                                maxY: 40,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: history.asMap().entries.map((e) {
                                      // Reverse mapping to plot chronological (oldest left, newest right)
                                      final x = (history.length - 1 - e.key)
                                          .toDouble();
                                      final y = (e.value.cycleLength ?? 28)
                                          .toDouble();
                                      return FlSpot(x, y);
                                    }).toList(),
                                    isCurved: true,
                                    color: AppColors.primary,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppColors.primary
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                          'Not enough data for charts. Log your cycles to see trends!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey)),
                    ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Symptom Frequency (Recent Logs)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 24),
                        if (highestSymptomCount == 0)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'No symptom logs yet.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true, reservedSize: 30)),
                                  bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 32,
                                          getTitlesWidget: (val, meta) {
                                            final index = val.toInt();
                                            if (index >= 0 &&
                                                index < symptomCounts.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6),
                                                child: Text(
                                                  symptomCounts[index].label,
                                                  style: const TextStyle(
                                                      fontSize: 10),
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          })),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                maxY: (highestSymptomCount + 1).toDouble(),
                                barGroups: [
                                  for (var i = 0; i < symptomCounts.length; i++)
                                    BarChartGroupData(x: i, barRods: [
                                      BarChartRodData(
                                        toY: symptomCounts[i].count.toDouble(),
                                        color: symptomCounts[i].color,
                                      )
                                    ]),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ] else ...[
                  // History List
                  if (history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                          'No past cycles recorded. Tap "Log Today\'s Symptoms" or the cycle day counter on the Home screen to record a cycle!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final cycle = history[index];
                        final length = cycle.cycleLength ?? 28;
                        final startStr =
                            DateFormat('MMM d, yyyy').format(cycle.startDate);

                        // If no end date is logged, calculate an approximate based on length
                        final endStr = cycle.endDate != null
                            ? DateFormat('MMM d, yyyy').format(cycle.endDate!)
                            : DateFormat('MMM d, yyyy').format(
                                cycle.startDate.add(Duration(days: length)));

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$startStr - $endStr',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$length Days',
                                      style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showReportSummary(context, cycleProvider),
                    icon: const Icon(Icons.summarize_outlined),
                    label: const Text('View Report Summary'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReportSummary(BuildContext context, CycleProvider cycleProvider) {
    final history = cycleProvider.cycleHistory;
    final logs = cycleProvider.recentLogs;
    final latestCycle = history.isEmpty
        ? 'No cycle recorded'
        : DateFormat('MMM d, yyyy').format(history.first.startDate);
    final average = history.isEmpty
        ? 'Not enough cycle data'
        : '${cycleProvider.averageCycleLength} days';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cycles recorded: ${history.length}'),
            Text('Recent symptom logs: ${logs.length}'),
            Text('Average cycle length: $average'),
            Text('Latest cycle start: $latestCycle'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  List<_SymptomCount> _buildSymptomCounts(List<DailyLog> logs) {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - 6, now.day);
    final recentLogs = logs.where((log) => !log.date.isBefore(cutoff)).toList();

    return [
      _SymptomCount(
        'Flow',
        recentLogs
            .where((log) => log.flow.isNotEmpty && log.flow != 'none')
            .length,
        Colors.red.shade300,
      ),
      _SymptomCount(
        'Cramps',
        recentLogs
            .where((log) => log.cramps.isNotEmpty && log.cramps != 'none')
            .length,
        Colors.orange.shade300,
      ),
      _SymptomCount(
        'Mood',
        recentLogs.where((log) => _isMoodChange(log.mood)).length,
        Colors.purple.shade300,
      ),
      _SymptomCount(
        'Notes',
        recentLogs.where((log) => log.notes.trim().isNotEmpty).length,
        Colors.teal.shade300,
      ),
    ];
  }

  bool _isMoodChange(String mood) {
    return mood == 'sad' || mood == 'anxious' || mood == 'irritable';
  }

  Widget _buildStatCard(String title, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24)),
          Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SymptomCount {
  final String label;
  final int count;
  final Color color;

  const _SymptomCount(this.label, this.count, this.color);
}
