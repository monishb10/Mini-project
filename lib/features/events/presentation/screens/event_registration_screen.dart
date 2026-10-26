import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/event_controller.dart';

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      context.read<EventController>().loadEvents(
            currentUserId: auth.currentUser?.uid,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister({
    required EventController controller,
    required String eventId,
    required UserModel? user,
  }) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in with a valid student account to register.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await controller.registerStudent(
      eventId: eventId,
      student: user,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.successMessage ?? 'Registration successfully confirmed!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleCancelRegistration({
    required EventController controller,
    required String eventId,
    required String eventTitle,
    required UserModel? user,
  }) async {
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Event Registration?'),
        content: Text(
          'Are you sure you want to surrender your slot for "$eventTitle"? You can re-register if slots remain open before the deadline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Slot'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel Registration'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await controller.cancelStudentRegistration(
        eventId: eventId,
        student: user,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration cancelled for "$eventTitle".'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.watch<EventController>();
    final authController = context.watch<AuthController>();
    final currentUser = authController.currentUser;
    final events = controller.events;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Student Event Registration Catalog',
              subtitle:
                  'Enroll in upcoming technical symposiums, hackathons, seminars, and sports meets to accrue activity credits',
            ),

            // Feedback Banners
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

            // Search & Category Chips Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => controller.search(val),
                    decoration: InputDecoration(
                      hintText:
                          'Search available events by keyword, venue, or coordinator...',
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
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'All Categories',
                        'Technical',
                        'Workshop',
                        'Seminar',
                        'Cultural',
                        'Sports',
                        'Social Service',
                        'Hackathons & Ideathons',
                        'Leadership & Governance',
                      ].map((cat) {
                        final isSelected = controller.selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              cat,
                              style: const TextStyle(fontSize: 12),
                            ),
                            selected: isSelected,
                            onSelected: (_) => controller.filterCategory(cat),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (controller.isLoading)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: LoadingState(message: 'Loading available events...'),
              )
            else if (events.isEmpty)
              EmptyState(
                title: 'No Events Open for Registration',
                description:
                    'There are currently no events matching your selected category.',
                actionLabel: 'Show All Events',
                onAction: () => controller.filterCategory('All Categories'),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int crossAxisCount =
                      width < 720 ? 1 : (width < 1180 ? 2 : 3);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: width < 720 ? 1.3 : 1.15,
                    ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final isRegistered = event.isRegistered;
                      final isFull = event.isFull && !isRegistered;
                      final isClosed =
                          event.isRegistrationClosed || event.status != 'Upcoming';

                      return AppCard(
                        padding: const EdgeInsets.all(20),
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
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    event.category,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.stars_rounded,
                                        size: 14,
                                        color: AppColors.warning,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '+${event.activityPoints} pts',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                            // Date and Location
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
                            // Registration Deadline Indicator
                            Row(
                              children: [
                                Icon(
                                  isClosed
                                      ? Icons.timer_off_outlined
                                      : Icons.schedule_outlined,
                                  size: 13,
                                  color: isClosed
                                      ? AppColors.error
                                      : AppColors.textMutedLight,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.isRegistrationClosed
                                        ? 'Registration Closed (${DateFormat.MMMd().format(event.effectiveRegistrationDeadline)})'
                                        : 'Deadline: ${DateFormat.MMMd().add_jm().format(event.effectiveRegistrationDeadline)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isClosed
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isClosed
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
                            // Capacity & spots left
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Seats: ${event.registeredCount} / ${event.capacity}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  isFull
                                      ? 'Sold Out'
                                      : '${event.capacity - event.registeredCount} spots left',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isFull
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
                                  isFull
                                      ? AppColors.error
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Register / Cancel Action Button
                            SizedBox(
                              width: double.infinity,
                              child: isRegistered
                                  ? OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: const BorderSide(
                                          color: AppColors.error,
                                        ),
                                      ),
                                      onPressed: () =>
                                          _handleCancelRegistration(
                                        controller: controller,
                                        eventId: event.id,
                                        eventTitle: event.title,
                                        user: currentUser,
                                      ),
                                      icon: const Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: AppColors.success,
                                      ),
                                      label: const Text(
                                        'Enrolled (Click to Cancel)',
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: (isFull || isClosed)
                                          ? null
                                          : () => _handleRegister(
                                                controller: controller,
                                                eventId: event.id,
                                                user: currentUser,
                                              ),
                                      icon: Icon(
                                        isClosed
                                            ? Icons.block
                                            : Icons.app_registration,
                                        size: 16,
                                      ),
                                      label: Text(
                                        isClosed
                                            ? (event.status == 'Cancelled'
                                                ? 'Event Cancelled'
                                                : 'Registration Closed')
                                            : (isFull
                                                ? 'Capacity Reached'
                                                : 'Register Now'),
                                      ),
                                    ),
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
}
