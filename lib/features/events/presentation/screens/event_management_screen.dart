import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/page_header.dart';
import '../../data/models/event_model.dart';
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

  void _showAddEventModal(BuildContext context) async {
    final controller = context.read<EventController>();
    final messenger = ScaffoldMessenger.of(context);
    final newEvent = await showDialog<EventModel>(
      context: context,
      builder: (_) => const EventFormDialog(),
    );

    if (newEvent != null && mounted) {
      final success = await controller.addEvent(newEvent);
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Event "${newEvent.title}" published successfully!'),
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
          SnackBar(content: Text('Event "${updated.title}" updated!')),
        );
      }
    }
  }

  void _confirmDeleteEvent(BuildContext context, EventModel event) {
    final messenger = ScaffoldMessenger.of(context);
    final controller = context.read<EventController>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel & Delete Event?'),
        content: Text(
          'Are you sure you want to delete "${event.title}"? Registered students will be notified.',
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
                  SnackBar(content: Text('Event "${event.title}" deleted.')),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.watch<EventController>();
    final events = controller.events;

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
                ElevatedButton.icon(
                  onPressed: () => _showAddEventModal(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create Event'),
                ),
              ],
            ),

            // Search and Category Filter
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.selectedCategory,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filter Category',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items:
                              [
                                    'All Categories',
                                    ...AppConstants.eventCategories,
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
                      const SizedBox(width: 14),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Filter Status',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items:
                              [
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
                actionLabel: 'Publish First Event',
                onAction: () => _showAddEventModal(context),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int crossAxisCount = width < 700 ? 1 : (width < 1150 ? 2 : 3);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: width < 700 ? 1.4 : 1.25,
                    ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return AppCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  Icons.place_outlined,
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
                            const SizedBox(height: 10),
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
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  tooltip: 'Edit Event',
                                  onPressed: () =>
                                      _showEditEventModal(context, event),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppColors.error,
                                  ),
                                  tooltip: 'Delete Event',
                                  onPressed: () =>
                                      _confirmDeleteEvent(context, event),
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
