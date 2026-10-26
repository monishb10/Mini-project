import 'student_model.dart';

class CsvRowError {
  final int lineNumber;
  final String studentId;
  final String field;
  final String reason;

  const CsvRowError({
    required this.lineNumber,
    required this.studentId,
    required this.field,
    required this.reason,
  });

  @override
  String toString() => 'Line $lineNumber (ID: $studentId): [$field] $reason';
}

class CsvImportResult {
  final int totalRows;
  final int importedCount;
  final int skippedCount;
  final List<CsvRowError> errors;
  final List<StudentModel> importedStudents;

  const CsvImportResult({
    required this.totalRows,
    required this.importedCount,
    required this.skippedCount,
    required this.errors,
    required this.importedStudents,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccess => importedCount > 0 && errors.isEmpty;
}
