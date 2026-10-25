import '../models/analytics_model.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsSummary> getSummary();
  Future<List<CategoryParticipation>> getCategoryParticipation();
  Future<List<DepartmentParticipation>> getDepartmentParticipation();
  Future<List<MonthlyTrendPoint>> getMonthlyTrend();
}

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  Future<AnalyticsSummary> getSummary() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const AnalyticsSummary(
      totalStudents: 1420,
      totalEvents: 48,
      totalParticipations: 4320,
      overallAttendanceRate: 84.6,
      atRiskStudentsCount: 68,
      activeClubsCount: 16,
    );
  }

  @override
  Future<List<CategoryParticipation>> getCategoryParticipation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      CategoryParticipation(
        category: 'Technical & Coding',
        count: 1240,
        percentage: 28.7,
      ),
      CategoryParticipation(
        category: 'Workshops & Seminars',
        count: 980,
        percentage: 22.7,
      ),
      CategoryParticipation(
        category: 'Hackathons & Ideathons',
        count: 750,
        percentage: 17.4,
      ),
      CategoryParticipation(
        category: 'Cultural & Arts',
        count: 560,
        percentage: 13.0,
      ),
      CategoryParticipation(
        category: 'Sports & Athletics',
        count: 480,
        percentage: 11.1,
      ),
      CategoryParticipation(
        category: 'Social Outreach',
        count: 310,
        percentage: 7.1,
      ),
    ];
  }

  @override
  Future<List<DepartmentParticipation>> getDepartmentParticipation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      DepartmentParticipation(
        department: 'CSE',
        studentCount: 420,
        totalEvents: 18,
        averageAttendanceRate: 91.2,
      ),
      DepartmentParticipation(
        department: 'IT',
        studentCount: 260,
        totalEvents: 12,
        averageAttendanceRate: 87.5,
      ),
      DepartmentParticipation(
        department: 'ECE',
        studentCount: 240,
        totalEvents: 10,
        averageAttendanceRate: 82.0,
      ),
      DepartmentParticipation(
        department: 'EEE',
        studentCount: 180,
        totalEvents: 8,
        averageAttendanceRate: 78.4,
      ),
      DepartmentParticipation(
        department: 'MECH',
        studentCount: 210,
        totalEvents: 9,
        averageAttendanceRate: 74.0,
      ),
      DepartmentParticipation(
        department: 'CIVIL',
        studentCount: 110,
        totalEvents: 6,
        averageAttendanceRate: 69.8,
      ),
    ];
  }

  @override
  Future<List<MonthlyTrendPoint>> getMonthlyTrend() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      MonthlyTrendPoint(month: 'Aug', participants: 320, events: 4),
      MonthlyTrendPoint(month: 'Sep', participants: 580, events: 7),
      MonthlyTrendPoint(month: 'Oct', participants: 720, events: 9),
      MonthlyTrendPoint(month: 'Nov', participants: 410, events: 5),
      MonthlyTrendPoint(month: 'Dec', participants: 190, events: 3),
      MonthlyTrendPoint(month: 'Jan', participants: 650, events: 8),
      MonthlyTrendPoint(month: 'Feb', participants: 880, events: 10),
      MonthlyTrendPoint(month: 'Mar', participants: 920, events: 12),
    ];
  }
}
