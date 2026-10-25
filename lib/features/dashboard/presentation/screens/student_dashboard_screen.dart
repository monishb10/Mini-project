import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../events/presentation/controllers/event_controller.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final authController = context.watch<AuthController>();
    final eventController = context.watch<EventController>();

    final user = authController.currentUser;
    final registeredEvents = eventController.registeredEvents;

    const totalCreditsEarned = 280;
    const graduationGoalCredits = 300;
    final progress = (totalCreditsEarned / graduationGoalCredits).clamp(
      0.0,
      1.0,
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Student Activity Hub & Credit Record',
              subtitle:
                  'Welcome back, ${user?.name ?? "Student"} (${user?.studentId ?? "22CS101"}) • ${user?.department ?? "Computer Science"}',
              actions: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/event-registration'),
                  icon: const Icon(Icons.explore_outlined, size: 18),
                  label: const Text('Browse Event Catalog'),
                ),
              ],
            ),

            // Top Stat Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount = width < 650 ? 1 : (width < 1050 ? 2 : 4);

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: width < 650 ? 2.5 : 1.8,
                  children: [
                    StatCard(
                      title: 'Events Completed',
                      value: '14',
                      subtitle: 'Technical, Hackathons & Seminars',
                      icon: Icons.verified_outlined,
                      iconColor: AppColors.primary,
                      trendText: '+3 this month',
                      isTrendPositive: true,
                    ),
                    StatCard(
                      title: 'Activity Credits Earned',
                      value: '$totalCreditsEarned pts',
                      subtitle: 'Goal: $graduationGoalCredits points',
                      icon: Icons.stars_rounded,
                      iconColor: AppColors.warning,
                      trendText: '93% completed',
                      isTrendPositive: true,
                    ),
                    StatCard(
                      title: 'My Attendance Rating',
                      value: '92.5%',
                      subtitle: 'Verified by Faculty Roll-call',
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: AppColors.success,
                      trendText: 'Excellent Standing',
                      isTrendPositive: true,
                    ),
                    StatCard(
                      title: 'Mined Activity Persona',
                      value: 'Tech Innovator',
                      subtitle: 'Cluster: Competitive Coding & Cloud',
                      icon: Icons.auto_awesome_rounded,
                      iconColor: AppColors.clusterA,
                      trendText: 'Top 5% Cohort',
                      isTrendPositive: true,
                      onTap: () => context.go('/pattern-mining'),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Degree Activity Credits Progress Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Institutional Activity Credit Milestone',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'AICTE & College Graduation Requirement: 300 non-academic credits',
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                      Text(
                        '$totalCreditsEarned / $graduationGoalCredits Points',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: isDark
                          ? AppColors.surfaceSecondaryDark
                          : AppColors.surfaceSecondaryLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Just 20 more activity points needed to satisfy the Honours Degree criterion.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Main Row: Registered Events + Pattern Mining Recommendations
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Registered Events
                Expanded(
                  flex: isDesktop ? 6 : 1,
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Registered Events',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.go('/event-registration'),
                              child: const Text('Register for More'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),

                        if (registeredEvents.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text('No upcoming registered events.'),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: registeredEvents.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 14),
                            itemBuilder: (context, index) {
                              final event = registeredEvents[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.event,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                title: Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                subtitle: Text(
                                  '${DateFormat.yMMMd().format(event.dateTime)} • ${event.venue} • +${event.activityPoints} pts',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                  ),
                                  onPressed: () => eventController
                                      .toggleRegistration(event.id),
                                  child: const Text(
                                    'Cancel Reg',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                if (isDesktop) ...[
                  const SizedBox(width: 20),
                  // Right Column: Apriori Recommendations
                  Expanded(
                    flex: 4,
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.recommend_rounded,
                                color: AppColors.clusterA,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Mined For You (Apriori AI)',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Students with your attendance history also registered for:',
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          _buildRecommendationItem(
                            context: context,
                            title: 'Flutter & Cloud Native Bootcamp',
                            category: 'Workshops & Seminars',
                            reason:
                                '86% confidence rule based on Python workshop completion',
                            credits: '+25 pts',
                            onRegister: () => context.go('/event-registration'),
                          ),
                          const SizedBox(height: 14),
                          _buildRecommendationItem(
                            context: context,
                            title: 'Cybersecurity Defense Challenge',
                            category: 'Technical & Coding',
                            reason:
                                'Frequent itemset affinity for Tech Innovators',
                            credits: '+30 pts',
                            onRegister: () => context.go('/event-registration'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem({
    required BuildContext context,
    required String title,
    required String category,
    required String reason,
    required String credits,
    required VoidCallback onRegister,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  credits,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            category,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reason,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              onPressed: onRegister,
              child: const Text(
                'View & Register',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
