import 'package:flutter_test/flutter_test.dart';
import 'package:student_pattern_mining/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:student_pattern_mining/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:student_pattern_mining/features/auth/data/models/user_model.dart';
import 'package:student_pattern_mining/features/auth/presentation/controllers/auth_controller.dart';
import 'package:student_pattern_mining/features/events/presentation/controllers/event_controller.dart';
import 'package:student_pattern_mining/features/pattern_mining/presentation/controllers/pattern_mining_controller.dart';
import 'package:student_pattern_mining/features/reports/presentation/controllers/report_controller.dart';
import 'package:student_pattern_mining/features/students/presentation/controllers/student_controller.dart';

void main() {
  group('UserModel Unit Tests', () {
    test('role getters return correct boolean values', () {
      final admin = UserModel(
        id: '1',
        email: 'admin@college.edu',
        name: 'Admin',
        role: 'admin',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(admin.isAdmin, isTrue);
      expect(admin.isFaculty, isFalse);
      expect(admin.isStudent, isFalse);
      expect(admin.roleDisplay, equals('Administrator'));

      final faculty = admin.copyWith(role: 'faculty');
      expect(faculty.isFaculty, isTrue);
      expect(faculty.roleDisplay, equals('Faculty Advisor'));

      final student = admin.copyWith(role: 'student');
      expect(student.isStudent, isTrue);
      expect(student.roleDisplay, equals('Student'));
    });
  });

  group('StudentController Unit Tests', () {
    test('loads students and computes metrics correctly', () async {
      final controller = StudentController();
      // wait for initial async load
      await Future.delayed(const Duration(milliseconds: 350));

      expect(controller.students.isNotEmpty, isTrue);
      expect(controller.totalStudentsCount, greaterThan(0));
      expect(controller.averageAttendance, greaterThan(0));
    });

    test('search filters students by name or roll number', () async {
      final controller = StudentController();
      await Future.delayed(const Duration(milliseconds: 350));

      controller.search('Aditya');
      await Future.delayed(const Duration(milliseconds: 350));

      expect(controller.students.every((s) => s.name.contains('Aditya')), isTrue);
    });
  });

  group('EventController Unit Tests', () {
    test('toggles registration and adjusts registeredCount', () async {
      final controller = EventController();
      await Future.delayed(const Duration(milliseconds: 350));

      final firstEvent = controller.events.first;
      final initialRegistered = firstEvent.isRegistered;
      final initialCount = firstEvent.registeredCount;

      final success = await controller.toggleRegistration(firstEvent.id);
      expect(success, isTrue);

      final updated = controller.events.firstWhere((e) => e.id == firstEvent.id);
      expect(updated.isRegistered, equals(!initialRegistered));
      if (!initialRegistered) {
        expect(updated.registeredCount, equals(initialCount + 1));
      } else {
        expect(updated.registeredCount, equals(initialCount - 1));
      }
    });
  });

  group('AttendanceController Unit Tests', () {
    test('loads records and computes attendance percentage', () async {
      final controller = AttendanceController();
      await Future.delayed(const Duration(milliseconds: 350));

      expect(controller.records.isNotEmpty, isTrue);
      expect(controller.attendancePercentage, inInclusiveRange(0.0, 100.0));
    });

    test('updates attendance status of record', () async {
      final controller = AttendanceController();
      await Future.delayed(const Duration(milliseconds: 350));

      final firstRecord = controller.records.first;
      await controller.updateStatus(firstRecord.id, 'Absent');

      final updated = controller.records.firstWhere((r) => r.id == firstRecord.id);
      expect(updated.status, equals('Absent'));
    });
  });

  group('PatternMiningController Unit Tests', () {
    test('loads rules and clusters and adjusts with thresholds', () async {
      final controller = PatternMiningController();
      await Future.delayed(const Duration(milliseconds: 400));

      expect(controller.rules.isNotEmpty, isTrue);
      expect(controller.clusters.isNotEmpty, isTrue);

      // Increase support threshold to filter out low-frequency rules
      controller.updateParameters(minSupport: 0.35);
      await Future.delayed(const Duration(milliseconds: 400));

      expect(controller.rules.every((r) => r.support >= 0.35), isTrue);
    });
  });

  group('ReportController Unit Tests', () {
    test('generates and stores new academic report', () async {
      final controller = ReportController();
      await Future.delayed(const Duration(milliseconds: 350));

      final initialCount = controller.reports.length;
      final success = await controller.generateReport(
        title: 'IQAC Test Audit',
        reportType: 'Accreditation Compliance',
        department: 'All Departments',
        academicYear: '2025-2026',
        format: 'PDF',
      );

      expect(success, isTrue);
      expect(controller.reports.length, equals(initialCount + 1));
      expect(controller.reports.first.title, equals('IQAC Test Audit'));
    });
  });

  group('AnalyticsController Unit Tests', () {
    test('loads institutional metrics summary', () async {
      final controller = AnalyticsController();
      await Future.delayed(const Duration(milliseconds: 350));

      expect(controller.summary, isNotNull);
      expect(controller.categoryData.isNotEmpty, isTrue);
      expect(controller.departmentData.isNotEmpty, isTrue);
      expect(controller.monthlyTrend.isNotEmpty, isTrue);
    });
  });

  group('AuthController Unit Tests', () {
    test('quick role switch assigns correct roles and permissions', () async {
      final controller = AuthController();
      await Future.delayed(const Duration(milliseconds: 200));

      await controller.quickSwitchRole('faculty');
      expect(controller.isFaculty, isTrue);
      expect(controller.currentUser?.roleDisplay, equals('Faculty Advisor'));

      await controller.quickSwitchRole('student');
      expect(controller.isStudent, isTrue);
      expect(controller.currentUser?.studentId, equals('22CS104'));
    });
  });
}
