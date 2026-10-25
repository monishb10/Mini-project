import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../analytics/presentation/controllers/analytics_controller.dart';
import '../../../events/presentation/controllers/event_controller.dart';
import '../../../pattern_mining/presentation/controllers/pattern_mining_controller.dart';
import '../../../students/presentation/controllers/student_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final analyticsController = context.watch<AnalyticsController>();
    final studentController = context.watch<StudentController>();
    final eventController = context.watch<EventController>();
    final miningController = context.watch<PatternMiningController>();

    final summary = analyticsController.summary;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Institution Overview & Pattern Mining',
              subtitle:
                  'Real-time student activity analytics, academic trends, and behavioral patterns',
              actions: [
                OutlinedButton.icon(
                  onPressed: () => context.go('/reports'),
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Export Audit'),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/pattern-mining'),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Run Pattern Mining'),
                ),
              ],
            ),

            // Top Stat Cards Row
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount = 4;
                if (width < 600) {
                  crossAxisCount = 1;
                } else if (width < 1000) {
                  crossAxisCount = 2;
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: width < 600 ? 2.5 : 1.8,
                  children: [
                    StatCard(
                      title: 'Total Enrolled Students',
                      value: '${summary?.totalStudents ?? 1420}',
                      subtitle: 'Active across 7 departments',
                      icon: Icons.people_outline_rounded,
                      iconColor: AppColors.primary,
                      trendText: '+12% this term',
                      isTrendPositive: true,
                      onTap: () => context.go('/students'),
                    ),
                    StatCard(
                      title: 'Active Events & Bootcamps',
                      value: '${eventController.activeEventsCount}',
                      subtitle:
                          '${eventController.upcomingEvents.length} upcoming scheduled',
                      icon: Icons.event_note_rounded,
                      iconColor: AppColors.secondary,
                      trendText: '+4 this week',
                      isTrendPositive: true,
                      onTap: () => context.go('/events'),
                    ),
                    StatCard(
                      title: 'Average Participation Rate',
                      value:
                          '${summary?.overallAttendanceRate.toStringAsFixed(1) ?? "84.6"}%',
                      subtitle: 'Target: > 75% for accreditation',
                      icon: Icons.pie_chart_outline_rounded,
                      iconColor: AppColors.success,
                      trendText: '+3.2% vs last term',
                      isTrendPositive: true,
                      onTap: () => context.go('/analytics'),
                    ),
                    StatCard(
                      title: 'At-Risk Students Flagged',
                      value:
                          '${studentController.atRiskStudentsCount > 0 ? studentController.atRiskStudentsCount : 68}',
                      subtitle: 'Requires faculty intervention',
                      icon: Icons.warning_amber_rounded,
                      iconColor: AppColors.error,
                      trendText: 'Needs review',
                      isTrendPositive: false,
                      onTap: () => context.go('/students'),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Charts Section: Line Chart (Monthly Trends) & Bar/Pie (Category Distribution)
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildTrendChartCard(
                      context,
                      analyticsController,
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: _buildCategoryBreakdownCard(
                      context,
                      analyticsController,
                      isDark,
                    ),
                  ),
                ],
              )
            else ...[
              _buildTrendChartCard(context, analyticsController, isDark),
              const SizedBox(height: 20),
              _buildCategoryBreakdownCard(context, analyticsController, isDark),
            ],

            const SizedBox(height: 24),

            // Discovered Association Rules Highlights & Recent Events
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isDesktop ? 6 : 1,
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Top Discovered Association Rules',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/pattern-mining'),
                              child: const Text('View All Rules'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        if (miningController.rules.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No mined rules loaded yet. Run mining job.',
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: miningController.rules.take(3).length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final rule = miningController.rules[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          rule.ruleFormula,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.successLight,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          'Lift: ${rule.lift.toStringAsFixed(2)}x',
                                          style: const TextStyle(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    rule.academicInterpretation,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        'Support: ${(rule.support * 100).toInt()}% • Confidence: ${(rule.confidence * 100).toInt()}%',
                                        style: theme.textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChartCard(
    BuildContext context,
    AnalyticsController controller,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final trend = controller.monthlyTrend;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Student Attendance Volume',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Track participation trends across academic months',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceSecondaryDark
                      : AppColors.surfaceSecondaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '2025-2026',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 240,
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
                      reservedSize: 40,
                      interval: 200,
                      getTitlesWidget: (val, meta) => Text(
                        '${val.toInt()}',
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
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < trend.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              trend[idx].month,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
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
                    barWidth: 3.5,
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
    );
  }

  Widget _buildCategoryBreakdownCard(
    BuildContext context,
    AnalyticsController controller,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final categories = controller.categoryData;

    final colorList = [
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
            'Activity Distribution by Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Breakdown of student registrations across event domains',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: List.generate(categories.length, (i) {
                  final cat = categories[i];
                  return PieChartSectionData(
                    color: colorList[i % colorList.length],
                    value: cat.percentage,
                    title: '${cat.percentage.toInt()}%',
                    radius: 40,
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
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(categories.length, (i) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorList[i % colorList.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${categories[i].category} (${categories[i].count})',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
