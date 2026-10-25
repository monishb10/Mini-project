class ReportModel {
  final String id;
  final String title;
  final String reportType;
  final DateTime generatedAt;
  final String generatedBy;
  final String academicYear;
  final String department;
  final String status; // 'Ready', 'Generating', 'Failed'
  final String fileFormat; // 'PDF', 'CSV', 'XLSX'
  final int recordsCount;
  final String summaryHighlights;

  const ReportModel({
    required this.id,
    required this.title,
    required this.reportType,
    required this.generatedAt,
    required this.generatedBy,
    required this.academicYear,
    required this.department,
    required this.status,
    required this.fileFormat,
    required this.recordsCount,
    required this.summaryHighlights,
  });

  ReportModel copyWith({
    String? id,
    String? title,
    String? reportType,
    DateTime? generatedAt,
    String? generatedBy,
    String? academicYear,
    String? department,
    String? status,
    String? fileFormat,
    int? recordsCount,
    String? summaryHighlights,
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      reportType: reportType ?? this.reportType,
      generatedAt: generatedAt ?? this.generatedAt,
      generatedBy: generatedBy ?? this.generatedBy,
      academicYear: academicYear ?? this.academicYear,
      department: department ?? this.department,
      status: status ?? this.status,
      fileFormat: fileFormat ?? this.fileFormat,
      recordsCount: recordsCount ?? this.recordsCount,
      summaryHighlights: summaryHighlights ?? this.summaryHighlights,
    );
  }
}
