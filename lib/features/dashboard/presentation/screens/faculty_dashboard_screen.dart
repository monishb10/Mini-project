import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../events/presentation/controllers/event_controller.dart';
import '../../../students/presentation/controllers/student_controller.dart';

class FacultyDashboardScreen extends StatelessWidget {
  const FacultyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final authController = context.watch<AuthController>();
    final studentController = context.watch<StudentController>();
    final eventController = context.watch<EventController>();

    final user = authController.currentUser;
    final department = user?.department ?? 'Computer Science & Engineering';

    final deptStudents = studentController.students
        .where(
          (s) => s.department == department || department == 'All Departments',
        )
        .toList();
    final atRiskInDept = deptStudents.where((s) => s.isAtRisk).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Faculty Advisor & Mentor Console',
              subtitle:
                  'Department: $department • Mentor: ${user?.name ?? "Faculty Advisor"}',
              actions: [
                OutlinedButton.icon(
                  onPressed: () => context.go('/attendance'),
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  label: const Text('Open QR Attendance'),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/events'),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Host Department Event'),
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
                      title: 'My Department Students',
                      value:
                          '${deptStudents.isNotEmpty ? deptStudents.length : 420}',
                      subtitle: 'Active in CSE & IT tracks',
                      icon: Icons.school_outlined,
                      iconColor: AppColors.primary,
                      onTap: () => context.go('/students'),
                    ),
                    StatCard(
                      title: 'Pending Attendance Approvals',
                      value: '2 Events',
                      subtitle: 'Hackathon & Cloud Bootcamp',
                      icon: Icons.checklist_rtl_rounded,
                      iconColor: AppColors.warning,
                      onTap: () => context.go('/attendance'),
                    ),
                    StatCard(
                      title: 'Department Participation Rate',
                      value: '89.4%',
                      subtitle: '+4.1% above college average',
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.success,
                      trendText: 'High affinity',
                      isTrendPositive: true,
                      onTap: () => context.go('/analytics'),
                    ),
                    StatCard(
                      title: 'Mentees Flagged At-Risk',
                      value:
                          '${atRiskInDept.isNotEmpty ? atRiskInDept.length : 2}',
                      subtitle: '< 50% participation rate',
                      icon: Icons.priority_high_rounded,
                      iconColor: AppColors.error,
                      trendText: 'Action needed',
                      isTrendPositive: false,
                      onTap: () => context.go('/students'),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Main Row: Mentee Intervention Roster + Upcoming Department Events
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: At Risk Mentees Table
                Expanded(
                  flex: isDesktop ? 6 : 1,
                  child: AppCard(
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
                                  'Mentee Early Warning & Risk Roster',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Pattern mining algorithm flagged these students for disengagement risk',
                                  style: theme.textTheme.labelMedium,
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Intervention Queue',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),

                        if (atRiskInDept.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'All department mentees are currently active!',
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: atRiskInDept.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final student = atRiskInDept[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.errorLight,
                                  child: Text(
                                    student.name.substring(0, 1),
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  student.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  '${student.rollNumber} • ${student.year} • Attended: ${student.totalEventsAttended} events (${student.attendanceRate}% attendance)',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.warning,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Intervention request scheduled for ${student.name}. Peer mentor assigned.',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.assignment_ind_outlined,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Counsel Mentee',
                                    style: TextStyle(fontSize: 12),
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
                  // Right Column: Department Coordinated Events
                  Expanded(
                    flex: 4,
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Department Events',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/events'),
                                child: const Text('All Events'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: eventController.upcomingEvents
                                .take(3)
                                .length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 14),
                            itemBuilder: (context, index) {
                              final event =
                                  eventController.upcomingEvents[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: AppColors.textMutedLight,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          event.venue,
                                          style: theme.textTheme.labelMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Reg: ${event.registeredCount}/${event.capacity}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                        ),
                                        onPressed: () =>
                                            context.go('/attendance'),
                                        child: const Text(
                                          'Take Attendance',
                                          style: TextStyle(fontSize: 11),
                                        ),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
