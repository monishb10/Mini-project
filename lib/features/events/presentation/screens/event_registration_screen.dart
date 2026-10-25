import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/page_header.dart';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<EventController>();
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

            // Search & Category Chips
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
                      children:
                          [
                            'All Categories',
                            ...AppConstants.eventCategories,
                          ].map((cat) {
                            final isSelected =
                                controller.selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  cat,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: isSelected,
                                onSelected: (_) =>
                                    controller.filterCategory(cat),
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
                  int crossAxisCount = width < 720 ? 1 : (width < 1150 ? 2 : 3);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: width < 720 ? 1.35 : 1.18,
                    ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final isRegistered = event.isRegistered;
                      final isFull = event.isFull && !isRegistered;

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
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule_outlined,
                                  size: 14,
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
                            const SizedBox(height: 10),
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
                            const SizedBox(height: 14),
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
                                      onPressed: () async {
                                        await controller.toggleRegistration(
                                          event.id,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Cancelled registration for ${event.title}',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: AppColors.success,
                                      ),
                                      label: const Text(
                                        'Registered (Click to Cancel)',
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: isFull
                                          ? null
                                          : () async {
                                              await controller
                                                  .toggleRegistration(event.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Successfully registered for ${event.title}! (+${event.activityPoints} credits)',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                      icon: const Icon(
                                        Icons.app_registration,
                                        size: 16,
                                      ),
                                      label: Text(
                                        isFull
                                            ? 'Capacity Reached'
                                            : 'Register Now',
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
