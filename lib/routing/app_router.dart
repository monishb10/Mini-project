import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/app_shell.dart';
import '../features/analytics/presentation/screens/participation_analytics_screen.dart';
import '../features/attendance/presentation/screens/attendance_management_screen.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../features/dashboard/presentation/screens/faculty_dashboard_screen.dart';
import '../features/dashboard/presentation/screens/student_dashboard_screen.dart';
import '../features/events/presentation/screens/event_management_screen.dart';
import '../features/events/presentation/screens/event_registration_screen.dart';
import '../features/pattern_mining/presentation/screens/pattern_mining_screen.dart';
import '../features/profile/presentation/screens/profile_settings_screen.dart';
import '../features/reports/presentation/screens/reports_screen.dart';
import '../features/students/presentation/screens/student_management_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

GoRouter createRouter(AuthController authController) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/admin/dashboard',
    refreshListenable: authController,
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isAuthenticated = authController.isAuthenticated;

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        if (authController.isAdmin) return '/admin/dashboard';
        if (authController.isFaculty) return '/faculty/dashboard';
        if (authController.isStudent) return '/student/dashboard';
        return '/admin/dashboard';
      }

      if (state.matchedLocation == '/') {
        if (authController.isAdmin) return '/admin/dashboard';
        if (authController.isFaculty) return '/faculty/dashboard';
        if (authController.isStudent) return '/student/dashboard';
        return '/admin/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(state: state, child: child);
        },
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/faculty/dashboard',
            builder: (context, state) => const FacultyDashboardScreen(),
          ),
          GoRoute(
            path: '/student/dashboard',
            builder: (context, state) => const StudentDashboardScreen(),
          ),
          GoRoute(
            path: '/students',
            builder: (context, state) => const StudentManagementScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventManagementScreen(),
          ),
          GoRoute(
            path: '/event-registration',
            builder: (context, state) => const EventRegistrationScreen(),
          ),
          GoRoute(
            path: '/attendance',
            builder: (context, state) => const AttendanceManagementScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const ParticipationAnalyticsScreen(),
          ),
          GoRoute(
            path: '/pattern-mining',
            builder: (context, state) => const PatternMiningScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileSettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
