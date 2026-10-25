import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/page_header.dart';
import '../controllers/analytics_controller.dart';

class ParticipationAnalyticsScreen extends StatelessWidget {
  const ParticipationAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final controller = context.watch<AnalyticsController>();

    if (controller.isLoading) {
      return const Scaffold(
        body: LoadingState(message: 'Computing institutional analytics...'),
      );
    }

    final depts = controller.departmentData;
    final categories = controller.categoryData;
    final trend = controller.monthlyTrend;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Institutional Participation Analytics',
              subtitle:
                  'Multi-dimensional statistical breakdowns across engineering departments, months, and activity clusters',
              actions: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Analytics dataset compiled for export.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Download Dataset'),
                ),
              ],
            ),

            // Top Insights Summary Bar
            AppCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.primaryContainer.withAlpha(50),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.insights,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Executive AI Finding: High Correlation with Technical Bootcamps',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Computer Science and Information Technology lead institutional engagement at 91.2% and 87.5% attendance. Mechanical and Civil show highest potential for inter-disciplinary Hackathon recruitment.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Main Charts Grid
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: _buildDepartmentBarChart(context, depts, isDark),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: _buildCategoryPieChart(context, categories, isDark),
                  ),
                ],
              )
            else ...[
              _buildDepartmentBarChart(context, depts, isDark),
              const SizedBox(height: 20),
              _buildCategoryPieChart(context, categories, isDark),
            ],

            const SizedBox(height: 24),

            // Attendance Growth Timeline
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Annual Participation Trajectory (2025 - 2026)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total verified student attendances recorded per calendar month',
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 260,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 200,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: isDark
                                ? Colors.white.withAlpha(15)
                                : Colors.black.withAlpha(15),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              interval: 200,
                              getTitlesWidget: (v, _) => Text(
                                '${v.toInt()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMutedLight,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (v, _) {
                                final idx = v.toInt();
                                if (idx >= 0 && idx < trend.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      trend[idx].month,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              trend.length,
                              (i) => FlSpot(
                                i.toDouble(),
                                trend[i].participants.toDouble(),
                              ),
                            ),
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 4,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withAlpha(40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentBarChart(
    BuildContext context,
    List depts,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Departmental Attendance Rates (%)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Comparison of mean student participation percentage across branches',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: isDark
                        ? Colors.white.withAlpha(15)
                        : Colors.black.withAlpha(15),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 25,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMutedLight,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx >= 0 && idx < depts.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              depts[idx].department,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(depts.length, (i) {
                  final dept = depts[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: dept.averageAttendanceRate,
                        color: dept.averageAttendanceRate > 85
                            ? AppColors.primary
                            : AppColors.secondary,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(
    BuildContext context,
    List categories,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.clusterA,
      AppColors.clusterB,
      AppColors.clusterC,
      AppColors.clusterD,
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Domain Share',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Relative distribution of active student registrations',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 36,
                sections: List.generate(categories.length, (i) {
                  final cat = categories[i];
                  return PieChartSectionData(
                    color: colors[i % colors.length],
                    value: cat.percentage,
                    title: '${cat.percentage.toInt()}%',
                    radius: 44,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(categories.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        categories[i].category,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${categories[i].percentage}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
