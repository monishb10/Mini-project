import '../models/report_model.dart';

abstract class ReportRepository {
  Future<List<ReportModel>> getReports();
  Future<ReportModel> generateReport({
    required String title,
    required String reportType,
    required String department,
    required String academicYear,
    required String format,
  });
  Future<void> deleteReport(String id);
}

class MockReportRepository implements ReportRepository {
  final List<ReportModel> _reports = [
    ReportModel(
      id: 'rep_01',
      title: 'NAAC Criteria 5.3: Student Participation & Activities Audit',
      reportType: 'Accreditation Compliance',
      generatedAt: DateTime.now().subtract(const Duration(days: 2)),
      generatedBy: 'Dr. Sarah Mitchell (IQAC Coordinator)',
      academicYear: '2025-2026',
      department: 'All Departments',
      status: 'Ready',
      fileFormat: 'PDF',
      recordsCount: 4320,
      summaryHighlights:
          'Complies with NAAC Metric 5.3.3. 84.6% student involvement documented across 48 institutional events.',
    ),
    ReportModel(
      id: 'rep_02',
      title: 'At-Risk & Inactive Students Comprehensive Intervention Roster',
      reportType: 'Student Mentoring Audit',
      generatedAt: DateTime.now().subtract(const Duration(days: 5)),
      generatedBy: 'Student Welfare Committee',
      academicYear: '2025-2026',
      department: 'Computer Science & Engineering',
      status: 'Ready',
      fileFormat: 'CSV',
      recordsCount: 68,
      summaryHighlights:
          'Identified 68 students with < 50% participation. Flagged for mandatory faculty mentor intervention.',
    ),
    ReportModel(
      id: 'rep_03',
      title: 'Departmental Activity Points & Credits Distribution Matrix',
      reportType: 'Academic Credit Summary',
      generatedAt: DateTime.now().subtract(const Duration(days: 12)),
      generatedBy: 'Dean of Academic Affairs',
      academicYear: '2025-2026',
      department: 'All Departments',
      status: 'Ready',
      fileFormat: 'XLSX',
      recordsCount: 1420,
      summaryHighlights:
          'Total activity points awarded: 124,500. Average points per student: 87.6 credits.',
    ),
    ReportModel(
      id: 'rep_04',
      title: 'Apriori Association Rules Mining & Behavioral Affinity Digest',
      reportType: 'Pattern Mining Research',
      generatedAt: DateTime.now().subtract(const Duration(days: 1)),
      generatedBy: 'Data Mining Lab',
      academicYear: '2025-2026',
      department: 'Computer Science & Engineering',
      status: 'Ready',
      fileFormat: 'PDF',
      recordsCount: 15,
      summaryHighlights:
          'Top rule identified: Coding workshop students have 86% probability of Hackathon engagement (Lift: 2.26).',
    ),
  ];

  @override
  Future<List<ReportModel>> getReports() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<ReportModel>.from(_reports);
  }

  @override
  Future<ReportModel> generateReport({
    required String title,
    required String reportType,
    required String department,
    required String academicYear,
    required String format,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newReport = ReportModel(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      reportType: reportType,
      generatedAt: DateTime.now(),
      generatedBy: 'System Administrator',
      academicYear: academicYear,
      department: department,
      status: 'Ready',
      fileFormat: format,
      recordsCount: 250,
      summaryHighlights:
          'Automatically compiled based on latest participation records for $department ($academicYear).',
    );
    _reports.insert(0, newReport);
    return newReport;
  }

  @override
  Future<void> deleteReport(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _reports.removeWhere((r) => r.id == id);
  }
}
