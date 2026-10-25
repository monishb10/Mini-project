import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _department;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _department = user?.department ?? AppConstants.departments.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final authController = context.read<AuthController>();
    final success = await authController.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      department: _department,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = context.watch<AuthController>();
    final themeController = context.watch<ThemeController>();
    final user = authController.currentUser;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'User Profile & System Settings',
              subtitle:
                  'Manage account credentials, appearance themes, institutional parameters, and data sync preferences',
            ),

            // Profile Card
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user?.name.substring(0, 1) ?? 'U',
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'User',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${user?.email} • ${user?.roleDisplay}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Role: ${user?.role.toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),

                  Text(
                    'Personal & Institutional Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Display Name',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Institutional Email',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _department,
                    decoration: const InputDecoration(
                      labelText: 'Department / Faculty Division',
                    ),
                    items: AppConstants.departments
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _department = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: authController.isLoading ? null : _saveProfile,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Save Profile Updates'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Appearance & Theme Card
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance & Visual Mode',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose between modern Clean Slate Light theme or Deep Midnight Dark theme',
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: !themeController.isDarkMode
                                ? AppColors.primaryContainer
                                : null,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () =>
                              themeController.setThemeMode(ThemeMode.light),
                          icon: const Icon(Icons.light_mode_outlined),
                          label: const Text('Light Mode'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: themeController.isDarkMode
                                ? AppColors.surfaceSecondaryDark
                                : null,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () =>
                              themeController.setThemeMode(ThemeMode.dark),
                          icon: const Icon(Icons.dark_mode_outlined),
                          label: const Text('Dark Mode'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Demo Role Switching Shortcuts Card
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Role Emulation (Evaluation Mode)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Switch roles instantly to inspect role-specific UI and features without logging out',
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: user?.role == 'admin'
                              ? AppColors.primary
                              : AppColors.surfaceSecondaryLight,
                          foregroundColor: user?.role == 'admin'
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                        onPressed: () {
                          authController.quickSwitchRole('admin');
                          context.go('/admin/dashboard');
                        },
                        icon: const Icon(Icons.admin_panel_settings, size: 16),
                        label: const Text('Emulate Admin (Dr. Sarah)'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: user?.role == 'faculty'
                              ? AppColors.primary
                              : AppColors.surfaceSecondaryLight,
                          foregroundColor: user?.role == 'faculty'
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                        onPressed: () {
                          authController.quickSwitchRole('faculty');
                          context.go('/faculty/dashboard');
                        },
                        icon: const Icon(Icons.psychology, size: 16),
                        label: const Text('Emulate Faculty (Prof. Rajesh)'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: user?.role == 'student'
                              ? AppColors.primary
                              : AppColors.surfaceSecondaryLight,
                          foregroundColor: user?.role == 'student'
                              ? Colors.white
                              : AppColors.textPrimaryLight,
                        ),
                        onPressed: () {
                          authController.quickSwitchRole('student');
                          context.go('/student/dashboard');
                        },
                        icon: const Icon(Icons.school, size: 16),
                        label: const Text('Emulate Student (Aarav Patel)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Session Logout Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign Out of Current Session',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Safely terminate your local active authentication session',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    onPressed: () async {
                      await authController.logout();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Sign Out'),
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
