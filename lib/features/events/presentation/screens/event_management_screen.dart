import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/models/event_model.dart';
import '../../data/models/registration_model.dart';
import '../controllers/event_controller.dart';
import '../widgets/event_form_dialog.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEventModal(BuildContext context, AuthController authController) async {
    final controller = context.read<EventController>();
    final messenger = ScaffoldMessenger.of(context);
    final newEvent = await showDialog<EventModel>(
      context: context,
      builder: (_) => const EventFormDialog(),
    );

    if (newEvent != null && mounted) {
      final success = await controller.addEvent(
        newEvent,
        organizerId: authController.currentUser?.uid,
      );
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Event "${newEvent.title}" published successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showEditEventModal(BuildContext context, EventModel event) async {
    final controller = context.read<EventController>();
    final messenger = ScaffoldMessenger.of(context);
    final updated = await showDialog<EventModel>(
      context: context,
      builder: (_) => EventFormDialog(eventToEdit: event),
    );

    if (updated != null && mounted) {
      final success = await controller.updateEvent(updated);
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Event "${updated.title}" updated!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _confirmCancelEvent(BuildContext context, EventModel event) {
    final messenger = ScaffoldMessenger.of(context);
    final controller = context.read<EventController>();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cancel "${event.title}"?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cancelling this event will prevent further registrations and inform enrolled students.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Cancellation Reason (Optional)',
                hintText: 'e.g. Inclement weather, speaker unavailable',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await controller.cancelEvent(
                event.id,
                reason: reasonController.text.trim().isNotEmpty
                    ? reasonController.text.trim()
                    : null,
              );
              if (success && mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Event "${event.title}" marked as Cancelled.'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEvent(BuildContext context, EventModel event) {
    final messenger = ScaffoldMessenger.of(context);
    final controller = context.read<EventController>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event Permanently?'),
        content: Text(
          'Are you sure you want to completely delete "${event.title}"? All registration and attendance logs for this event will be disconnected. This action is restricted to administrators.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Event'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await controller.deleteEvent(event.id);
              if (success && mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Event "${event.title}" deleted from system.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _showRegistrationsModal(BuildContext context, EventModel event) {
    final controller = context.read<EventController>();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                            'Enrolled Students: ${event.title}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Capacity: ${event.registeredCount} / ${event.capacity} registered • Venue: ${event.venue}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Expanded(
                  child: FutureBuilder<List<RegistrationModel>>(
                    future: controller.getEventRegistrations(event.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingState(
                          message: 'Fetching enrolled students...',
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Failed to load registrations: ${snapshot.error}',
                            style: const TextStyle(color: AppColors.error),
                          ),
                        );
                      }

                      final registrations = snapshot.data ?? [];
                      if (registrations.isEmpty) {
                        return const EmptyState(
                          title: 'No Registrations Yet',
                          description:
                              'No students have registered for this event yet.',
                        );
                      }

                      return ListView.separated(
                        itemCount: registrations.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final reg = registrations[index];
                          final isReg = reg.isRegistered;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isReg
                                  ? AppColors.primaryContainer
                                  : AppColors.surfaceSecondaryLight,
                              child: Text(
                                reg.studentName.isNotEmpty
                                    ? reg.studentName[0].toUpperCase()
                                    : 'S',
                                style: TextStyle(
                                  color: isReg
                                      ? AppColors.primary
                                      : AppColors.textMutedLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              reg.studentName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              '${reg.studentRollNumber} • ${reg.studentDepartment} • ${reg.studentEmail}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isReg
                                        ? AppColors.successLight
                                        : AppColors.errorLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    reg.status.toUpperCase(),
                                    style: TextStyle(
                                      color: isReg
                                          ? AppColors.success
                                          : AppColors.error,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat.MMMd().add_jm().format(
                                    reg.registeredAt,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMutedLight,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context, EventController controller) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      initialDateRange: controller.filterStartDate != null &&
              controller.filterEndDate != null
          ? DateTimeRange(
              start: controller.filterStartDate!,
              end: controller.filterEndDate!,
            )
          : null,
    );

    if (picked != null) {
      controller.filterDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.watch<EventController>();
    final authController = context.watch<AuthController>();
    final events = controller.events;
    final canManageEvents = authController.isAdmin || authController.isFaculty;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Institutional Event & Activity Management',
              subtitle:
                  'Host, coordinate, and schedule collegiate workshops, hackathons, and cultural meets',
              actions: [
                if (canManageEvents)
                  ElevatedButton.icon(
                    onPressed: () => _showAddEventModal(context, authController),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Event'),
                  ),
              ],
            ),

            // Error and Success Feedback Banners
            if (controller.errorMessage != null) ...[
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
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        controller.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                      onPressed: () => controller.clearMessages(),
                    ),
                  ],
                ),
              ),
            ],

            if (controller.successMessage != null) ...[
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
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        controller.successMessage!,
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AppColors.success),
                      onPressed: () => controller.clearMessages(),
                    ),
                  ],
                ),
              ),
            ],

            // Search and Multi-Parameter Filter Card
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
                                'Search events by name, venue, organizer...',
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
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => _pickDateRange(context, controller),
                        icon: const Icon(Icons.date_range, size: 18),
                        label: Text(
                          controller.filterStartDate != null &&
                                  controller.filterEndDate != null
                              ? '${DateFormat.MMMd().format(controller.filterStartDate!)} - ${DateFormat.MMMd().format(controller.filterEndDate!)}'
                              : 'Filter Dates',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      if (controller.filterStartDate != null) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Clear Date Filter',
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          onPressed: () => controller.filterDateRange(null, null),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Category Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.selectedCategory,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            'All Categories',
                            'Technical',
                            'Workshop',
                            'Seminar',
                            'Cultural',
                            'Sports',
                            'Social Service',
                            'Hackathons & Ideathons',
                            'Leadership & Governance',
                          ]
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) controller.filterCategory(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Department Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.selectedDepartment,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            'All Departments',
                            ...AppConstants.departments,
                          ]
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
                      const SizedBox(width: 12),

                      // Status Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.selectedStatus,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            'All Statuses',
                            'Upcoming',
                            'Ongoing',
                            'Completed',
                            'Cancelled',
                          ]
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) controller.filterStatus(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: LoadingState(message: 'Loading events catalog...'),
              )
            else if (events.isEmpty)
              EmptyState(
                title: 'No Events Found',
                description: 'No events match your current filter parameters.',
                actionLabel: canManageEvents ? 'Publish First Event' : null,
                onAction: canManageEvents
                    ? () => _showAddEventModal(context, authController)
                    : null,
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int crossAxisCount =
                      width < 700 ? 1 : (width < 1200 ? 2 : 3);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: width < 700 ? 1.25 : 1.15,
                    ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final isCancelled = event.status == 'Cancelled';

                      return AppCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusBg(event.status),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        event.status.toUpperCase(),
                                        style: TextStyle(
                                          color: _getStatusColor(event.status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        event.category,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                    '+${event.activityPoints} credits',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              event.description,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            // Department & Venue
                            Row(
                              children: [
                                const Icon(
                                  Icons.business_outlined,
                                  size: 13,
                                  color: AppColors.textMutedLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event.organizerDepartment,
                                  style: theme.textTheme.labelMedium,
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.place_outlined,
                                  size: 13,
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
                            // Date and Registration Deadline
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 13,
                                  color: AppColors.textMutedLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat.yMMMd().format(event.dateTime),
                                  style: theme.textTheme.labelMedium,
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 13,
                                  color: AppColors.textMutedLight,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Deadline: ${DateFormat.MMMd().format(event.effectiveRegistrationDeadline)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: event.isRegistrationClosed
                                          ? AppColors.error
                                          : AppColors.textSecondaryLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Capacity & Occupancy
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Registrations: ${event.registeredCount} / ${event.capacity}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${(event.occupancyRate * 100).toInt()}% Full',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: event.isFull
                                        ? AppColors.error
                                        : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: event.occupancyRate,
                                minHeight: 6,
                                backgroundColor: isDark
                                    ? AppColors.surfaceSecondaryDark
                                    : AppColors.surfaceSecondaryLight,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  event.isFull
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Card Action Footer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _showRegistrationsModal(
                                    context,
                                    event,
                                  ),
                                  icon: const Icon(
                                    Icons.people_alt_outlined,
                                    size: 16,
                                  ),
                                  label: Text(
                                    'Students (${event.registeredCount})',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (canManageEvents) ...[
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                        ),
                                        tooltip: 'Edit Event',
                                        onPressed: () =>
                                            _showEditEventModal(context, event),
                                      ),
                                      if (!isCancelled)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.event_busy_outlined,
                                            size: 18,
                                            color: AppColors.warning,
                                          ),
                                          tooltip: 'Cancel Event',
                                          onPressed: () =>
                                              _confirmCancelEvent(context, event),
                                        ),
                                    ],
                                    if (authController.isAdmin)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color: AppColors.error,
                                        ),
                                        tooltip: 'Delete Event Permanently',
                                        onPressed: () =>
                                            _confirmDeleteEvent(context, event),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return AppColors.info;
      case 'Ongoing':
        return AppColors.warning;
      case 'Completed':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Upcoming':
        return AppColors.infoLight;
      case 'Ongoing':
        return AppColors.warningLight;
      case 'Completed':
        return AppColors.successLight;
      case 'Cancelled':
        return AppColors.errorLight;
      default:
        return AppColors.surfaceSecondaryLight;
    }
  }
}
