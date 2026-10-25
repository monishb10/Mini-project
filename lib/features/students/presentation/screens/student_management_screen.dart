import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/page_header.dart';
import '../../data/models/student_model.dart';
import '../controllers/student_controller.dart';
import '../widgets/student_details_dialog.dart';
import '../widgets/student_form_dialog.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddStudentModal(BuildContext context) async {
    final controller = context.read<StudentController>();
    final messenger = ScaffoldMessenger.of(context);
    final newStudent = await showDialog<StudentModel>(
      context: context,
      builder: (_) => const StudentFormDialog(),
    );

    if (newStudent != null && mounted) {
      final success = await controller.addStudent(newStudent);
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Student ${newStudent.name} registered successfully!',
            ),
          ),
        );
      }
    }
  }

  void _showEditStudentModal(BuildContext context, StudentModel student) async {
    final controller = context.read<StudentController>();
    final messenger = ScaffoldMessenger.of(context);
    final updated = await showDialog<StudentModel>(
      context: context,
      builder: (_) => StudentFormDialog(studentToEdit: student),
    );

    if (updated != null && mounted) {
      final success = await controller.updateStudent(updated);
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Student ${updated.name} updated successfully!'),
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, StudentModel student) {
    final messenger = ScaffoldMessenger.of(context);
    final controller = context.read<StudentController>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Student Record?'),
        content: Text(
          'Are you sure you want to remove ${student.name} (${student.rollNumber})? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await controller.deleteStudent(student.id);
              if (success && mounted) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Student ${student.name} deleted.')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<StudentController>();
    final students = controller.students;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Student Roster & Participation Records',
              subtitle:
                  'Manage student enrollments, academic credits, behavioral clusters, and attendance records',
              actions: [
                ElevatedButton.icon(
                  onPressed: () => _showAddStudentModal(context),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('Add Student'),
                ),
              ],
            ),

            // Filters & Search Bar Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => controller.search(val),
                          decoration: InputDecoration(
                            hintText:
                                'Search by student name, roll number, or email...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      controller.search('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      // Department Dropdown
                      SizedBox(
                        width: 240,
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.selectedDepartment,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Department Filter',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items:
                              ['All Departments', ...AppConstants.departments]
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                        d,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            if (val != null) controller.filterDepartment(val);
                          },
                        ),
                      ),
                      // Year Dropdown
                      SizedBox(
                        width: 160,
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.selectedYear,
                          decoration: const InputDecoration(
                            labelText: 'Academic Year',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: ['All Years', ...AppConstants.years]
                              .map(
                                (y) => DropdownMenuItem(
                                  value: y,
                                  child: Text(
                                    y,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) controller.filterYear(val);
                          },
                        ),
                      ),
                      // Risk Filter
                      SizedBox(
                        width: 170,
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.selectedRiskLevel,
                          decoration: const InputDecoration(
                            labelText: 'Intervention Risk',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: ['All Risk Levels', 'Low', 'Medium', 'High']
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) controller.filterRiskLevel(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Table Card
            AppCard(
              padding: EdgeInsets.zero,
              child: controller.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: LoadingState(
                        message: 'Querying student database...',
                      ),
                    )
                  : students.isEmpty
                  ? EmptyState(
                      title: 'No Students Found',
                      description:
                          'No student matches your current filter criteria. Try adjusting or clearing your search filters.',
                      actionLabel: 'Reset Filters',
                      onAction: () {
                        _searchController.clear();
                        controller.search('');
                        controller.filterDepartment('All Departments');
                        controller.filterYear('All Years');
                        controller.filterRiskLevel('All Risk Levels');
                      },
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Showing ${students.length} Enrolled Students',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Average Attendance: ${controller.averageAttendance.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            horizontalMargin: 20,
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Roll No',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Student Name & Email',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Department',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Year & Sec',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Attendance %',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Credits',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Mined Cluster',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Risk',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Actions',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: students.map((student) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      student.rollNumber,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          student.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          student.email,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMutedLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      student.department,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${student.year} (${student.section})',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${student.attendanceRate}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: student.attendanceRate < 60
                                                ? AppColors.error
                                                : (student.attendanceRate < 75
                                                      ? AppColors.warning
                                                      : AppColors.success),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${student.activityPoints} pts',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getClusterColor(
                                          student.clusterGroup,
                                        ).withAlpha(30),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        student.clusterGroup,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _getClusterColor(
                                            student.clusterGroup,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: student.isAtRisk
                                            ? AppColors.errorLight
                                            : AppColors.successLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        student.riskLevel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: student.isAtRisk
                                              ? AppColors.error
                                              : AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.visibility_outlined,
                                            size: 18,
                                          ),
                                          tooltip: 'View Profile',
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (_) =>
                                                StudentDetailsDialog(
                                                  student: student,
                                                ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                          ),
                                          tooltip: 'Edit Student',
                                          onPressed: () =>
                                              _showEditStudentModal(
                                                context,
                                                student,
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: AppColors.error,
                                          ),
                                          tooltip: 'Delete Student',
                                          onPressed: () =>
                                              _confirmDelete(context, student),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
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

  Color _getClusterColor(String cluster) {
    if (cluster.contains('Tech')) return AppColors.clusterA;
    if (cluster.contains('Cultural')) return AppColors.clusterB;
    if (cluster.contains('Sports')) return AppColors.clusterC;
    if (cluster.contains('Risk')) return AppColors.error;
    return AppColors.secondary;
  }
}
