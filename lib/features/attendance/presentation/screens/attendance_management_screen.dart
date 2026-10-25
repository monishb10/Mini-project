import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../events/presentation/controllers/event_controller.dart';
import '../controllers/attendance_controller.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState
    extends State<AttendanceManagementScreen> {
  final _qrRollInputController = TextEditingController();

  @override
  void dispose() {
    _qrRollInputController.dispose();
    super.dispose();
  }

  void _handleQuickCheckIn(AttendanceController controller) async {
    final roll = _qrRollInputController.text.trim();
    if (roll.isEmpty) return;

    final success = await controller.quickCheckIn(roll, 'Faculty Coordinator');
    if (success && mounted) {
      _qrRollInputController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verified: Student $roll marked PRESENT via QR check-in.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final eventController = context.watch<EventController>();
    final attendanceController = context.watch<AttendanceController>();

    final events = eventController.events;
    final records = attendanceController.records;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Attendance Verification & Check-In System',
              subtitle:
                  'Verify student attendance via live roll-call or QR scanner simulator for activity credit verification',
              actions: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Attendance roster exported as CSV.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Export CSV'),
                ),
                ElevatedButton.icon(
                  onPressed: () => attendanceController.bulkMarkPresent(),
                  icon: const Icon(Icons.done_all_rounded, size: 18),
                  label: const Text('Mark All Present'),
                ),
              ],
            ),

            // Event Picker & QR Simulator Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.event_seat_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select Active Event for Roll Call:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: attendanceController.selectedEventId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: events.map((e) {
                      return DropdownMenuItem(
                        value: e.id,
                        child: Text(
                          '${e.title} (${e.category}) - ${DateFormat.yMMMd().format(e.dateTime)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) attendanceController.loadAttendance(val);
                    },
                  ),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 14),

                  // Quick QR Simulator
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _qrRollInputController,
                          onSubmitted: (_) =>
                              _handleQuickCheckIn(attendanceController),
                          decoration: InputDecoration(
                            hintText:
                                'Simulate QR Scan: enter roll number (e.g. 22CS105) & press Check-In',
                            prefixIcon: const Icon(
                              Icons.qr_code_scanner,
                              size: 20,
                            ),
                            suffixIcon: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () =>
                                  _handleQuickCheckIn(attendanceController),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Check-In'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Live Attendance Stats
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount = width < 650 ? 2 : 4;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: width < 650 ? 1.8 : 2.0,
                  children: [
                    StatCard(
                      title: 'Total Enrolled',
                      value: '${attendanceController.totalRecords}',
                      icon: Icons.group_outlined,
                      iconColor: AppColors.primary,
                    ),
                    StatCard(
                      title: 'Present',
                      value: '${attendanceController.presentCount}',
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.success,
                    ),
                    StatCard(
                      title: 'Absent',
                      value: '${attendanceController.absentCount}',
                      icon: Icons.cancel_outlined,
                      iconColor: AppColors.error,
                    ),
                    StatCard(
                      title: 'Attendance %',
                      value:
                          '${attendanceController.attendancePercentage.toStringAsFixed(1)}%',
                      icon: Icons.percent,
                      iconColor: AppColors.secondary,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Attendance Roll Call Table
            AppCard(
              padding: EdgeInsets.zero,
              child: attendanceController.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: LoadingState(
                        message: 'Loading attendance register...',
                      ),
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
                                'Roll Call Roster (${records.length} Students)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Real-time sync enabled',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                  fontSize: 12,
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
                            columnSpacing: 28,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Roll No',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Student Name',
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
                                  'Check-In Mode',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Timestamp',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Status Toggle',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: records.map((record) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      record.studentRollNumber,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      record.studentName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      record.studentDepartment,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          record.checkInMode.contains('QR')
                                              ? Icons.qr_code_2
                                              : Icons.edit_note,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          record.checkInMode,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      DateFormat.jm().format(record.timestamp),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMutedLight,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SegmentedButton<String>(
                                      segments: const [
                                        ButtonSegment(
                                          value: 'Present',
                                          label: Text(
                                            'Present',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ),
                                        ButtonSegment(
                                          value: 'Absent',
                                          label: Text(
                                            'Absent',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ),
                                        ButtonSegment(
                                          value: 'Excused',
                                          label: Text(
                                            'Excused',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ),
                                      ],
                                      selected: {record.status},
                                      onSelectionChanged:
                                          (Set<String> newSelection) {
                                            attendanceController.updateStatus(
                                              record.id,
                                              newSelection.first,
                                            );
                                          },
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
}
