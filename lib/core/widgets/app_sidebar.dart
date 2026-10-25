import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

class AppSidebar extends StatelessWidget {
  final String currentRoute;
  final VoidCallback? onCloseDrawer;

  const AppSidebar({super.key, required this.currentRoute, this.onCloseDrawer});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 270,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E1B4B),
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.borderDark : Colors.white.withAlpha(25),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // College / Project Brand Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withAlpha(20), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(90),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SAPM System',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pattern Mining Platform',
                        style: TextStyle(
                          color: Colors.white.withAlpha(160),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onCloseDrawer != null)
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: onCloseDrawer,
                  ),
              ],
            ),
          ),

          // Role Switcher Quick Pill (for presentation / demo ease)
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withAlpha(25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACTIVE ROLE',
                        style: TextStyle(
                          color: Colors.white.withAlpha(140),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        authController.currentUser?.roleDisplay ?? 'Admin',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Switch Demo Role',
                  icon: const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onSelected: (role) {
                    authController.quickSwitchRole(role);
                    if (role == 'admin') context.go('/admin/dashboard');
                    if (role == 'faculty') context.go('/faculty/dashboard');
                    if (role == 'student') context.go('/student/dashboard');
                    if (onCloseDrawer != null) onCloseDrawer!();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'admin',
                      child: Text('Admin View (Sarah)'),
                    ),
                    const PopupMenuItem(
                      value: 'faculty',
                      child: Text('Faculty View (Rajesh)'),
                    ),
                    const PopupMenuItem(
                      value: 'student',
                      child: Text('Student View (Aarav)'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                _buildSectionHeader('DASHBOARDS'),
                _buildNavItem(
                  context: context,
                  title: 'Admin Dashboard',
                  icon: Icons.dashboard_rounded,
                  route: '/admin/dashboard',
                  isActive: currentRoute == '/admin/dashboard',
                ),
                _buildNavItem(
                  context: context,
                  title: 'Faculty Dashboard',
                  icon: Icons.school_rounded,
                  route: '/faculty/dashboard',
                  isActive: currentRoute == '/faculty/dashboard',
                ),
                _buildNavItem(
                  context: context,
                  title: 'Student Dashboard',
                  icon: Icons.person_pin_rounded,
                  route: '/student/dashboard',
                  isActive: currentRoute == '/student/dashboard',
                ),

                const SizedBox(height: 14),
                _buildSectionHeader('CORE MANAGEMENT'),
                _buildNavItem(
                  context: context,
                  title: 'Students Roster',
                  icon: Icons.people_alt_rounded,
                  route: '/students',
                  isActive: currentRoute == '/students',
                ),
                _buildNavItem(
                  context: context,
                  title: 'Event Management',
                  icon: Icons.event_available_rounded,
                  route: '/events',
                  isActive: currentRoute == '/events',
                ),
                _buildNavItem(
                  context: context,
                  title: 'Event Registration',
                  icon: Icons.app_registration_rounded,
                  route: '/event-registration',
                  isActive: currentRoute == '/event-registration',
                ),
                _buildNavItem(
                  context: context,
                  title: 'Attendance Roll',
                  icon: Icons.fact_check_rounded,
                  route: '/attendance',
                  isActive: currentRoute == '/attendance',
                ),

                const SizedBox(height: 14),
                _buildSectionHeader('INTELLIGENCE & MINING'),
                _buildNavItem(
                  context: context,
                  title: 'Participation Analytics',
                  icon: Icons.pie_chart_outline_rounded,
                  route: '/analytics',
                  isActive: currentRoute == '/analytics',
                ),
                _buildNavItem(
                  context: context,
                  title: 'Pattern Mining (Apriori)',
                  icon: Icons.scatter_plot_rounded,
                  route: '/pattern-mining',
                  isActive: currentRoute == '/pattern-mining',
                  badge: 'Core AI',
                ),
                _buildNavItem(
                  context: context,
                  title: 'Accreditation Reports',
                  icon: Icons.description_outlined,
                  route: '/reports',
                  isActive: currentRoute == '/reports',
                ),

                const SizedBox(height: 14),
                _buildSectionHeader('PREFERENCES'),
                _buildNavItem(
                  context: context,
                  title: 'Profile & Settings',
                  icon: Icons.settings_outlined,
                  route: '/profile',
                  isActive: currentRoute == '/profile',
                ),
              ],
            ),
          ),

          // User Footer & Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withAlpha(20), width: 1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    authController.currentUser?.name.substring(0, 1) ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        authController.currentUser?.name ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        authController.currentUser?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withAlpha(160),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Logout',
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () async {
                    await authController.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6, top: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withAlpha(120),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String route,
    required bool isActive,
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onCloseDrawer != null) onCloseDrawer!();
            context.go(route);
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? Colors.white : Colors.white.withAlpha(180),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withAlpha(200),
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
