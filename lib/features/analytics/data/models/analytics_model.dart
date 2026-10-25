class CategoryParticipation {
  final String category;
  final int count;
  final double percentage;

  const CategoryParticipation({
    required this.category,
    required this.count,
    required this.percentage,
  });
}

class DepartmentParticipation {
  final String department;
  final int studentCount;
  final int totalEvents;
  final double averageAttendanceRate;

  const DepartmentParticipation({
    required this.department,
    required this.studentCount,
    required this.totalEvents,
    required this.averageAttendanceRate,
  });
}

class MonthlyTrendPoint {
  final String month;
  final int participants;
  final int events;

  const MonthlyTrendPoint({
    required this.month,
    required this.participants,
    required this.events,
  });
}

class AnalyticsSummary {
  final int totalStudents;
  final int totalEvents;
  final int totalParticipations;
  final double overallAttendanceRate;
  final int atRiskStudentsCount;
  final int activeClubsCount;

  const AnalyticsSummary({
    required this.totalStudents,
    required this.totalEvents,
    required this.totalParticipations,
    required this.overallAttendanceRate,
    required this.atRiskStudentsCount,
    required this.activeClubsCount,
  });
}
