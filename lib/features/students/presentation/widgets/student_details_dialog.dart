import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/student_model.dart';

class StudentDetailsDialog extends StatelessWidget {
  final StudentModel student;

  const StudentDetailsDialog({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              student.name.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: theme.textTheme.titleMedium),
                Text(
                  '${student.rollNumber} • ${student.department}',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 12),
              _buildMetricRow(
                'Academic Standing',
                'CGPA: ${student.cgpa} (${student.year}, Sec ${student.section})',
              ),
              _buildMetricRow(
                'Total Activities Attended',
                '${student.totalEventsAttended} Institutional Events',
              ),
              _buildMetricRow(
                'Activity Points Accumulated',
                '${student.activityPoints} credits',
              ),
              _buildMetricRow('Attendance Rate', '${student.attendanceRate}%'),
              _buildMetricRow('Mined Behavioral Cluster', student.clusterGroup),
              _buildMetricRow(
                'Intervention Risk Rating',
                student.riskLevel,
                isRisk: student.isAtRisk,
              ),
              const SizedBox(height: 12),
              Text(
                'Preferred Activity Categories:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: student.preferredCategories.map((c) {
                  return Chip(
                    label: Text(c, style: const TextStyle(fontSize: 11)),
                    backgroundColor: isDark
                        ? AppColors.surfaceSecondaryDark
                        : AppColors.surfaceSecondaryLight,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, {bool isRisk = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMutedLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isRisk ? AppColors.error : null,
            ),
          ),
        ],
      ),
    );
  }
}
