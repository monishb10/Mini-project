import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../events/data/models/event_model.dart';
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
  final _qrTokenInputController = TextEditingController();

  @override
  void dispose() {
    _qrRollInputController.dispose();
    _qrTokenInputController.dispose();
    super.dispose();
  }

  void _handleQuickCheckIn(
    AttendanceController controller,
    AuthController authController,
  ) async {
    final roll = _qrRollInputController.text.trim();
    if (roll.isEmpty) return;

    final user = authController.currentUser;
    final success = await controller.quickCheckIn(
      roll,
      user?.name ?? 'Faculty Coordinator',
      verifyingUserId: user?.uid,
      checkInMode: 'Manual Roll Call',
    );

    if (success && mounted) {
      _qrRollInputController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verified: Student $roll marked PRESENT via roll-call.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showEventQrCodeModal(BuildContext context, EventModel? event) {
    if (event == null) return;
    final token = event.checkInSecretToken ?? 'CHK_${event.id.toUpperCase()}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Event Check-In QR Pass',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                '${event.organizerDepartment} • ${DateFormat.yMMMd().format(event.dateTime)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Mock QR Code Graphic Box
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.qr_code_rounded,
                      size: 140,
                      color: AppColors.primary,
                    ),
                    Text(
                      token,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Backend Verification Token:',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      token,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Students present this code or QR pass to coordinators for verified check-in.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close Pass'),
          ),
        ],
      ),
    );
  }

  void _showScanQrModal(
    BuildContext context,
    AttendanceController controller,
    AuthController authController,
    EventModel? event,
  ) {
    if (event == null) return;
    final token = event.checkInSecretToken ?? 'CHK_${event.id.toUpperCase()}';
    _qrTokenInputController.text = token;
    final rollCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan & Verify QR Check-In'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the student roll number and the event QR secret code to verify check-in against the backend server:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rollCtrl,
                decoration: const InputDecoration(
                  labelText: 'Student Roll Number',
                  hintText: 'e.g. 22CS104',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _qrTokenInputController,
                decoration: const InputDecoration(
                  labelText: 'Event QR Secret Token',
                  hintText: 'CHK_...',
                  prefixIcon: Icon(Icons.security_rounded),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final roll = rollCtrl.text.trim();
              final qrTok = _qrTokenInputController.text.trim();
              if (roll.isEmpty || qrTok.isEmpty) return;

              final user = authController.currentUser;
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);

              final success = await controller.verifyAndRecordQrCheckIn(
                eventId: event.id,
                rollNumber: roll,
                qrToken: qrTok,
                verifyingUser: user!,
              );

              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'QR Verified: Student $roll checked in successfully!'
                          : (controller.errorMessage ?? 'QR check-in failed.'),
                    ),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            icon: const Icon(Icons.verified_user_rounded, size: 16),
            label: const Text('Verify & Check In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventController = context.watch<EventController>();
    final attendanceController = context.watch<AttendanceController>();
    final authController = context.watch<AuthController>();

    final events = eventController.events;
    final records = attendanceController.records;
    final currentEvent = events.isNotEmpty
        ? events.firstWhere(
            (e) => e.id == attendanceController.selectedEventId,
            orElse: () => events.first,
          )
        : null;

    final isAuthorizedToMark =
        authController.isAdmin || authController.isFaculty;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Attendance Verification & Check-In System',
              subtitle:
                  'Verify student attendance via live roll-call or trusted QR scanner for official activity credits',
              actions: [
                OutlinedButton.icon(
                  onPressed: () => _showEventQrCodeModal(context, currentEvent),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                  label: const Text('Show QR Pass'),
                ),
                const SizedBox(width: 8),
                if (isAuthorizedToMark)
                  ElevatedButton.icon(
                    onPressed: () => _showScanQrModal(
                      context,
                      attendanceController,
                      authController,
                      currentEvent,
                    ),
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                    label: const Text('Scan QR Code'),
                  ),
                const SizedBox(width: 8),
                if (isAuthorizedToMark)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    onPressed: () => attendanceController.bulkMarkPresent(
                      user: authController.currentUser,
                    ),
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text('Mark All Present'),
                  ),
              ],
            ),

            // Feedback Banners
            if (attendanceController.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        attendanceController.errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                      onPressed: () => attendanceController.clearMessages(),
                    ),
                  ],
                ),
              ),
            ],

            if (attendanceController.successMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        attendanceController.successMessage!,
                        style: const TextStyle(color: AppColors.success, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AppColors.success),
                      onPressed: () => attendanceController.clearMessages(),
                    ),
                  ],
                ),
              ),
            ],

            // Event Picker Card
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
                    initialValue: events.any((e) => e.id == attendanceController.selectedEventId)
                        ? attendanceController.selectedEventId
                        : (events.isNotEmpty ? events.first.id : null),
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
                          overflow: TextOverflow.ellipsis,
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

                  // Quick Check-in Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _qrRollInputController,
                          enabled: isAuthorizedToMark,
                          onSubmitted: (_) => _handleQuickCheckIn(
                            attendanceController,
                            authController,
                          ),
                          decoration: InputDecoration(
                            hintText: isAuthorizedToMark
                                ? 'Quick Roll Call: Enter student roll number (e.g. 22CS105) & press Check-In'
                                : 'Read-only attendance view. Authorized faculty/admins can check-in students.',
                            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                            suffixIcon: isAuthorizedToMark
                                ? ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _handleQuickCheckIn(
                                      attendanceController,
                                      authController,
                                    ),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Check-In'),
                                  )
                                : null,
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
                  childAspectRatio: width < 650 ? 1.7 : 2.1,
                  children: [
                    StatCard(
                      title: 'Present Count',
                      value: '${attendanceController.presentCount}',
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: AppColors.success,
                    ),
                    StatCard(
                      title: 'Absent Count',
                      value: '${attendanceController.absentCount}',
                      icon: Icons.highlight_off_rounded,
                      iconColor: AppColors.error,
                    ),
                    StatCard(
                      title: 'Excused Leave',
                      value: '${attendanceController.excusedCount}',
                      icon: Icons.help_outline_rounded,
                      iconColor: AppColors.warning,
                    ),
                    StatCard(
                      title: 'Turnout Rate',
                      value:
                          '${attendanceController.attendancePercentage.toStringAsFixed(1)}%',
                      icon: Icons.pie_chart_outline_rounded,
                      iconColor: AppColors.primary,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Attendance Roll Roster Table
            Text(
              'Enrolled Student Roster & Live Status',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (attendanceController.isLoading)
              const LoadingState(message: 'Updating attendance ledger...')
            else if (records.isEmpty)
              const EmptyState(
                title: 'No Registered Attendees Found',
                description:
                    'No students have registered or checked in for this event yet.',
                icon: Icons.people_outline_rounded,
              )
            else
              AppCard(
                padding: EdgeInsets.zero,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('Roll No')),
                      DataColumn(label: Text('Student Name')),
                      DataColumn(label: Text('Department')),
                      DataColumn(label: Text('Verification Mode')),
                      DataColumn(label: Text('Check-In Time')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Roll Call Actions')),
                    ],
                    rows: records.map((record) {
                      final isPresent = record.status == 'Present';
                      final isAbsent = record.status == 'Absent';
                      final isExcused = record.status == 'Excused';

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              record.studentRollNumber,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          DataCell(Text(record.studentName)),
                          DataCell(Text(record.studentDepartment)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  record.checkInMode.contains('QR')
                                      ? Icons.qr_code_2_rounded
                                      : Icons.edit_note_rounded,
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
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPresent
                                    ? AppColors.successLight
                                    : (isAbsent
                                        ? AppColors.errorLight
                                        : AppColors.warningLight),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                record.status,
                                style: TextStyle(
                                  color: isPresent
                                      ? AppColors.success
                                      : (isAbsent
                                          ? AppColors.error
                                          : AppColors.warning),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Mark Present',
                                  icon: Icon(
                                    Icons.check_circle_rounded,
                                    size: 20,
                                    color: isPresent
                                        ? AppColors.success
                                        : Colors.grey.withAlpha(100),
                                  ),
                                  onPressed: isAuthorizedToMark
                                      ? () => attendanceController.updateStatus(
                                            record.id,
                                            'Present',
                                            user: authController.currentUser,
                                          )
                                      : null,
                                ),
                                IconButton(
                                  tooltip: 'Mark Absent',
                                  icon: Icon(
                                    Icons.cancel_rounded,
                                    size: 20,
                                    color: isAbsent
                                        ? AppColors.error
                                        : Colors.grey.withAlpha(100),
                                  ),
                                  onPressed: isAuthorizedToMark
                                      ? () => attendanceController.updateStatus(
                                            record.id,
                                            'Absent',
                                            user: authController.currentUser,
                                          )
                                      : null,
                                ),
                                IconButton(
                                  tooltip: 'Mark Excused',
                                  icon: Icon(
                                    Icons.help_rounded,
                                    size: 20,
                                    color: isExcused
                                        ? AppColors.warning
                                        : Colors.grey.withAlpha(100),
                                  ),
                                  onPressed: isAuthorizedToMark
                                      ? () => attendanceController.updateStatus(
                                            record.id,
                                            'Excused',
                                            user: authController.currentUser,
                                          )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
