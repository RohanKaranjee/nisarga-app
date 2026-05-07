import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/gradient_header.dart';
import '../../../core/theme/app_colors.dart';

class CycleHistoryScreen extends StatefulWidget {
  const CycleHistoryScreen({super.key});

  @override
  State<CycleHistoryScreen> createState() => _CycleHistoryScreenState();
}

class _CycleHistoryScreenState extends State<CycleHistoryScreen> {
  bool _showCharts = true;

  final List<Map<String, dynamic>> _history = [
    {
      "startDate": "Feb 1, 2026",
      "endDate": "Feb 5, 2026",
      "length": 28,
      "flow": "Medium",
      "notes": "Normal cycle, mild cramps on day 1"
    },
    {
      "startDate": "Jan 4, 2026",
      "endDate": "Jan 8, 2026",
      "length": 29,
      "flow": "Heavy",
      "notes": "More painful than usual"
    },
    {
      "startDate": "Dec 6, 2025",
      "endDate": "Dec 10, 2025",
      "length": 27,
      "flow": "Medium",
      "notes": "Slight spotting before start"
    },
    {
      "startDate": "Nov 9, 2025",
      "endDate": "Nov 13, 2025",
      "length": 30,
      "flow": "Light",
      "notes": "Very light flow this time"
    },
    {
      "startDate": "Oct 10, 2025",
      "endDate": "Oct 14, 2025",
      "length": 28,
      "flow": "Medium",
      "notes": "Normal cycle"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cycle History')),
      body: SingleChildScrollView(
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
                color: Colors.grey.shade200,
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
                          color: _showCharts ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'Charts & Stats',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _showCharts ? Colors.white : Colors.grey.shade600,
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
                          color: !_showCharts ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'History List',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_showCharts ? Colors.white : Colors.grey.shade600,
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
                  Expanded(child: _buildStatCard('Average', '28', 'Days')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Shortest', '27', 'Days')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Longest', '30', 'Days')),
                ],
              ),
              const SizedBox(height: 24),
              
              // Line Chart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cycle Length Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (val, meta) {
                              const months = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb'];
                              if (val.toInt() >= 0 && val.toInt() < months.length) {
                                return Text(months[val.toInt()]);
                              }
                              return const Text('');
                            })),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 4,
                          minY: 20,
                          maxY: 35,
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 28),
                                FlSpot(1, 30),
                                FlSpot(2, 27),
                                FlSpot(3, 29),
                                FlSpot(4, 28),
                              ],
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bar Chart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Symptom Frequency (Last 6 Months)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (val, meta) {
                              const symptoms = ['Cramps', 'Bloating', 'Headache', 'Mood', 'Fatigue'];
                              if (val.toInt() >= 0 && val.toInt() < symptoms.length) {
                                return Text(symptoms[val.toInt()], style: const TextStyle(fontSize: 10));
                              }
                              return const Text('');
                            })),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5, color: Colors.red.shade300)]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 3, color: Colors.blue.shade300)]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 2, color: Colors.orange.shade300)]),
                            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 4, color: Colors.purple.shade300)]),
                            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 6, color: Colors.teal.shade300)]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // History List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final cycle = _history[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${cycle["startDate"]} - ${cycle["endDate"]}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${cycle["length"]} Days',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Flow: ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Text(cycle['flow'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Notes: ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Expanded(child: Text(cycle['notes'], style: const TextStyle(fontSize: 14))),
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
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Export Report (PDF)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 24)),
          Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
