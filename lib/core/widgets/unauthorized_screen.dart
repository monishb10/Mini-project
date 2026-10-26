import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../widgets/app_card.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

class UnauthorizedScreen extends StatelessWidget {
  final String? attemptedPath;

  const UnauthorizedScreen({
    super.key,
    this.attemptedPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AppCard(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Access Restricted (403)',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You do not have administrative privileges to access this module.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // User Info Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceSecondaryDark
                          : AppColors.surfaceSecondaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Authenticated Account:',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              user?.roleDisplay.toUpperCase() ?? 'GUEST',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        if (attemptedPath != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Attempted Route: $attemptedPath',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await authController.logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Sign Out'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (authController.isAdmin) {
                              context.go('/admin/dashboard');
                            } else if (authController.isFaculty) {
                              context.go('/faculty/dashboard');
                            } else {
                              context.go('/student/dashboard');
                            }
                          },
                          icon: const Icon(Icons.dashboard_outlined, size: 18),
                          label: const Text('My Dashboard'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
