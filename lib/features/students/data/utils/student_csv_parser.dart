import '../models/csv_import_result.dart';
import '../models/student_model.dart';

class StudentCsvParser {
  StudentCsvParser._();

  /// Parse and validate CSV data for students.
  /// Existing student IDs set is checked to detect conflicts with existing records.
  static CsvImportResult parse({
    required String csvContent,
    required Set<String> existingStudentIds,
  }) {
    final lines = csvContent
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const CsvImportResult(
        totalRows: 0,
        importedCount: 0,
        skippedCount: 0,
        errors: [
          CsvRowError(
            lineNumber: 0,
            studentId: 'N/A',
            field: 'File',
            reason: 'CSV file is empty. Please provide student data with headers.',
          ),
        ],
        importedStudents: [],
      );
    }

    final headerLine = lines.first.toLowerCase();
    final hasHeader = headerLine.contains('id') ||
        headerLine.contains('name') ||
        headerLine.contains('email');

    final dataLines = hasHeader ? lines.sublist(1) : lines;
    final int startLineNumber = hasHeader ? 2 : 1;

    final normalizedExistingIds =
        existingStudentIds.map((id) => id.toLowerCase().trim()).toSet();
    final List<CsvRowError> errors = [];
    final List<StudentModel> importedStudents = [];
    final Set<String> batchStudentIds = {};
    int skippedCount = 0;

    for (int i = 0; i < dataLines.length; i++) {
      final lineNum = startLineNumber + i;
      final rawLine = dataLines[i];

      // Parse comma-separated line (handling simple quotes if present)
      final columns = _parseCsvRow(rawLine);
      if (columns.length < 3) {
        errors.add(
          CsvRowError(
            lineNumber: lineNum,
            studentId: columns.isNotEmpty ? columns[0] : 'Unknown',
            field: 'Row Format',
            reason: 'Insufficient columns. Expected at least: studentId, name, email, department.',
          ),
        );
        skippedCount++;
        continue;
      }

      final rollNumber = columns[0].trim();
      final name = columns.length > 1 ? columns[1].trim() : '';
      final email = columns.length > 2 ? columns[2].trim() : '';
      final department = columns.length > 3 && columns[3].trim().isNotEmpty
          ? columns[3].trim()
          : 'Computer Science & Engineering';
      final year = columns.length > 4 && columns[4].trim().isNotEmpty
          ? columns[4].trim()
          : '1st Year';
      final section = columns.length > 5 && columns[5].trim().isNotEmpty
          ? columns[5].trim()
          : 'A';
      final interestsRaw = columns.length > 6 ? columns[6].trim() : '';

      // 1. Validate Student ID
      if (rollNumber.isEmpty) {
        errors.add(
          CsvRowError(
            lineNumber: lineNum,
            studentId: 'EMPTY',
            field: 'studentId',
            reason: 'Student ID / Roll Number cannot be empty.',
          ),
        );
        skippedCount++;
        continue;
      }

      // Duplicate Check 1: In this batch
      if (batchStudentIds.contains(rollNumber.toLowerCase())) {
        errors.add(
          CsvRowError(
            lineNumber: lineNum,
            studentId: rollNumber,
            field: 'studentId',
            reason: 'Duplicate student ID found within the same CSV batch.',
          ),
        );
        skippedCount++;
        continue;
      }

      // Duplicate Check 2: Already in existing database
      if (normalizedExistingIds.contains(rollNumber.toLowerCase())) {
        errors.add(
          CsvRowError(
            lineNumber: lineNum,
            studentId: rollNumber,
            field: 'studentId',
            reason: 'Duplicate student ID: Student $rollNumber already exists in the system.',
          ),
        );
        skippedCount++;
        continue;
      }

      // 2. Validate Name
      if (name.isEmpty) {
        errors.add(
          CsvRowError(
            lineNumber: lineNum,
            studentId: rollNumber,
            field: 'name',
            reason: 'Student name is required.',
          ),
        );
        skippedCount++;
        continue;
      }

      // 3. Validate Email
      if (!email.contains('@') || !email.contains('.')) {
        errors.add(
          CsvRowError(
            lineNumber: lineNum,
            studentId: rollNumber,
            field: 'email',
            reason: 'Invalid email format "$email".',
          ),
        );
        skippedCount++;
        continue;
      }

      // 4. Validate Academic Year
      final yearInt = int.tryParse(year.replaceAll(RegExp(r'[^0-9]'), ''));
      if (yearInt != null && (yearInt < 1 || yearInt > 5)) {
        errors.add(
          CsvRowError(
            lineNumber: lineNum,
            studentId: rollNumber,
            field: 'year',
            reason: 'Invalid academic Year "$year". Expected a year between 1 and 5.',
          ),
        );
        skippedCount++;
        continue;
      }

      // Parse interests
      final List<String> interests = interestsRaw.isNotEmpty
          ? interestsRaw
              .split(RegExp(r'[;,]'))
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList()
          : ['Technical & Coding'];

      batchStudentIds.add(rollNumber.toLowerCase());
      importedStudents.add(
        StudentModel(
          id: 'std_${DateTime.now().millisecondsSinceEpoch}_$i',
          rollNumber: rollNumber,
          name: name,
          email: email,
          department: department,
          year: year,
          section: section,
          cgpa: 8.5,
          totalEventsAttended: 0,
          activityPoints: 0,
          clusterGroup: 'Tech Innovators',
          riskLevel: 'Low',
          attendanceRate: 100.0,
          preferredCategories: interests,
          enrolledAt: DateTime.now(),
        ),
      );
    }

    return CsvImportResult(
      totalRows: dataLines.length,
      importedCount: importedStudents.length,
      skippedCount: skippedCount,
      errors: errors,
      importedStudents: importedStudents,
    );
  }

  static List<String> _parseCsvRow(String line) {
    final List<String> result = [];
    final StringBuffer current = StringBuffer();
    bool insideQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        insideQuotes = !insideQuotes;
      } else if (char == ',' && !insideQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }
}
