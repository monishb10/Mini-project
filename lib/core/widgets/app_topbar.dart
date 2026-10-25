import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../theme/theme_controller.dart';
import '../utils/responsive_layout.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

class AppTopbar extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const AppTopbar({super.key, this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);
    final authController = context.watch<AuthController>();
    final themeController = context.watch<ThemeController>();

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 700;

          return Row(
            children: [
              if (isMobile)
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: onOpenDrawer,
                  tooltip: 'Open Menu',
                ),

              if (!isCompact) ...[
                // Quick Search Field
                SizedBox(
                  width: 240,
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: AppColors.textMutedLight,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      fillColor: isDark
                          ? AppColors.surfaceSecondaryDark
                          : AppColors.surfaceSecondaryLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (constraints.maxWidth > 850) ...[
                  const SizedBox(width: 12),
                  // Academic Session Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceSecondaryDark
                          : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.school,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AY ${AppConstants.academicYear}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              const Spacer(),

              // Theme Toggle
              IconButton(
                icon: Icon(
                  themeController.isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  size: 20,
                ),
                tooltip: themeController.isDarkMode
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                onPressed: () => themeController.toggleTheme(),
              ),

              // Notifications with Badge
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 22,
                    ),
                    tooltip: 'Notifications',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No unread system alerts. Association mining finished.',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 6),

              // User Avatar & Role Badge
              InkWell(
                onTap: () => context.go('/profile'),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          authController.currentUser?.name.substring(0, 1) ??
                              'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (constraints.maxWidth > 600) ...[
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              authController.currentUser?.name ?? 'User',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              authController.currentUser?.roleDisplay ??
                                  'Admin',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
