import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/services/firebase_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/analytics/presentation/controllers/analytics_controller.dart';
import 'features/attendance/presentation/controllers/attendance_controller.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/events/presentation/controllers/event_controller.dart';
import 'features/pattern_mining/presentation/controllers/pattern_mining_controller.dart';
import 'features/reports/presentation/controllers/report_controller.dart';
import 'features/students/presentation/controllers/student_controller.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider<AuthController>.value(value: _authController),
        ChangeNotifierProvider(create: (_) => StudentController()),
        ChangeNotifierProvider(create: (_) => EventController()),
        ChangeNotifierProvider(create: (_) => AttendanceController()),
        ChangeNotifierProvider(create: (_) => AnalyticsController()),
        ChangeNotifierProvider(create: (_) => PatternMiningController()),
        ChangeNotifierProvider(create: (_) => ReportController()),
      ],
      child: Consumer2<ThemeController, AuthController>(
        builder: (context, themeController, authController, _) {
          final router = createRouter(authController);

          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
