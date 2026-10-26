import '../models/csv_import_result.dart';
import '../models/student_model.dart';
import '../utils/student_csv_parser.dart';

abstract class StudentRepository {
  Future<List<StudentModel>> getStudents({
    String? department,
    String? year,
    String? riskLevel,
    String? searchQuery,
  });
  Future<StudentModel?> getStudentById(String id);
  Future<StudentModel?> getStudentByRollNumber(String rollNumber);
  Future<StudentModel> addStudent(StudentModel student, {bool isAdmin = true});
  Future<StudentModel> updateStudent(StudentModel student, {bool isAdmin = true});
  Future<void> deleteStudent(String id, {bool isAdmin = true});
  Future<CsvImportResult> importStudentsFromCsv(String csvContent, {bool isAdmin = true});
}

class MockStudentRepository implements StudentRepository {
  final List<StudentModel> _students = [
    StudentModel(
      id: 'std_01',
      rollNumber: '22CS101',
      name: 'Aditya Verma',
      email: 'aditya.v@college.edu',
      department: 'Computer Science & Engineering',
      year: '3rd Year',
      section: 'A',
      cgpa: 8.92,
      totalEventsAttended: 14,
      activityPoints: 280,
      clusterGroup: 'Tech Innovators',
      riskLevel: 'Low',
      attendanceRate: 92.0,
      preferredCategories: [
        'Technical & Coding',
        'Hackathons & Ideathons',
        'Workshops & Seminars',
      ],
      enrolledAt: DateTime(2022, 8, 1),
    ),
    StudentModel(
      id: 'std_02',
      rollNumber: '22CS102',
      name: 'Ananya Deshmukh',
      email: 'ananya.d@college.edu',
      department: 'Computer Science & Engineering',
      year: '3rd Year',
      section: 'A',
      cgpa: 9.35,
      totalEventsAttended: 18,
      activityPoints: 360,
      clusterGroup: 'Tech Innovators',
      riskLevel: 'Low',
      attendanceRate: 96.5,
      preferredCategories: [
        'Technical & Coding',
        'Workshops & Seminars',
        'Leadership & Governance',
      ],
      enrolledAt: DateTime(2022, 8, 1),
    ),
    StudentModel(
      id: 'std_03',
      rollNumber: '22IT045',
      name: 'Rohan Mehra',
      email: 'rohan.m@college.edu',
      department: 'Information Technology',
      year: '3rd Year',
      section: 'B',
      cgpa: 6.42,
      totalEventsAttended: 2,
      activityPoints: 40,
      clusterGroup: 'At-Risk Disengaged',
      riskLevel: 'High',
      attendanceRate: 48.0,
      preferredCategories: ['Sports & Athletics'],
      enrolledAt: DateTime(2022, 8, 1),
    ),
    StudentModel(
      id: 'std_04',
      rollNumber: '23EC018',
      name: 'Sneha Kulkarni',
      email: 'sneha.k@college.edu',
      department: 'Electronics & Communication',
      year: '2nd Year',
      section: 'A',
      cgpa: 8.10,
      totalEventsAttended: 11,
      activityPoints: 210,
      clusterGroup: 'Cultural & Arts',
      riskLevel: 'Low',
      attendanceRate: 88.0,
      preferredCategories: ['Cultural & Arts', 'Social & Community Outreach'],
      enrolledAt: DateTime(2023, 8, 1),
    ),
    StudentModel(
      id: 'std_05',
      rollNumber: '21ME077',
      name: 'Vikram Singh Rathore',
      email: 'vikram.s@college.edu',
      department: 'Mechanical Engineering',
      year: '4th Year',
      section: 'B',
      cgpa: 7.20,
      totalEventsAttended: 5,
      activityPoints: 95,
      clusterGroup: 'Sports & Athletics',
      riskLevel: 'Medium',
      attendanceRate: 64.0,
      preferredCategories: ['Sports & Athletics', 'Workshops & Seminars'],
      enrolledAt: DateTime(2021, 8, 1),
    ),
    StudentModel(
      id: 'std_06',
      rollNumber: '24EE012',
      name: 'Pooja Hegde',
      email: 'pooja.h@college.edu',
      department: 'Electrical & Electronics',
      year: '1st Year',
      section: 'A',
      cgpa: 8.75,
      totalEventsAttended: 8,
      activityPoints: 160,
      clusterGroup: 'Tech Innovators',
      riskLevel: 'Low',
      attendanceRate: 86.0,
      preferredCategories: ['Technical & Coding', 'Workshops & Seminars'],
      enrolledAt: DateTime(2024, 8, 1),
    ),
    StudentModel(
      id: 'std_07',
      rollNumber: '22CS130',
      name: 'Karan Johar Sharma',
      email: 'karan.s@college.edu',
      department: 'Computer Science & Engineering',
      year: '3rd Year',
      section: 'C',
      cgpa: 5.95,
      totalEventsAttended: 1,
      activityPoints: 15,
      clusterGroup: 'At-Risk Disengaged',
      riskLevel: 'High',
      attendanceRate: 35.0,
      preferredCategories: ['Social & Community Outreach'],
      enrolledAt: DateTime(2022, 8, 1),
    ),
    StudentModel(
      id: 'std_08',
      rollNumber: '23BT004',
      name: 'Meera Nambiar',
      email: 'meera.n@college.edu',
      department: 'Biotechnology',
      year: '2nd Year',
      section: 'A',
      cgpa: 9.15,
      totalEventsAttended: 13,
      activityPoints: 260,
      clusterGroup: 'Social & Leadership',
      riskLevel: 'Low',
      attendanceRate: 94.0,
      preferredCategories: [
        'Social & Community Outreach',
        'Leadership & Governance',
        'Workshops & Seminars',
      ],
      enrolledAt: DateTime(2023, 8, 1),
    ),
    StudentModel(
      id: 'std_09',
      rollNumber: '22CV029',
      name: 'Gaurav Patil',
      email: 'gaurav.p@college.edu',
      department: 'Civil Engineering',
      year: '3rd Year',
      section: 'A',
      cgpa: 6.80,
      totalEventsAttended: 4,
      activityPoints: 70,
      clusterGroup: 'Sports & Athletics',
      riskLevel: 'Medium',
      attendanceRate: 59.0,
      preferredCategories: ['Sports & Athletics'],
      enrolledAt: DateTime(2022, 8, 1),
    ),
    StudentModel(
      id: 'std_10',
      rollNumber: '23IT089',
      name: 'Divya Nair',
      email: 'divya.n@college.edu',
      department: 'Information Technology',
      year: '2nd Year',
      section: 'B',
      cgpa: 8.45,
      totalEventsAttended: 10,
      activityPoints: 200,
      clusterGroup: 'Tech Innovators',
      riskLevel: 'Low',
      attendanceRate: 89.0,
      preferredCategories: ['Hackathons & Ideathons', 'Technical & Coding'],
      enrolledAt: DateTime(2023, 8, 1),
    ),
  ];

  @override
  Future<List<StudentModel>> getStudents({
    String? department,
    String? year,
    String? riskLevel,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    var results = List<StudentModel>.from(_students);

    if (department != null && department != 'All Departments') {
      results = results.where((s) => s.department == department).toList();
    }
    if (year != null && year != 'All Years') {
      results = results.where((s) => s.year == year).toList();
    }
    if (riskLevel != null && riskLevel != 'All Risk Levels') {
      results = results.where((s) => s.riskLevel == riskLevel).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      results = results
          .where(
            (s) =>
                s.name.toLowerCase().contains(q) ||
                s.rollNumber.toLowerCase().contains(q) ||
                s.email.toLowerCase().contains(q),
          )
          .toList();
    }

    return results;
  }

  @override
  Future<StudentModel?> getStudentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<StudentModel?> getStudentByRollNumber(String rollNumber) async {
    await Future.delayed(const Duration(milliseconds: 80));
    try {
      return _students.firstWhere(
        (s) => s.rollNumber.toLowerCase().trim() == rollNumber.toLowerCase().trim(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<StudentModel> addStudent(StudentModel student, {bool isAdmin = true}) async {
    await Future.delayed(const Duration(milliseconds: 250));

    // Admin authorization check
    if (!isAdmin) {
      throw Exception(
        'Access Denied: Only institutional administrators are authorized to create student records.',
      );
    }

    // Duplicate studentId / rollNumber prevention
    final isDuplicate = _students.any(
      (s) => s.rollNumber.toLowerCase().trim() == student.rollNumber.toLowerCase().trim(),
    );
    if (isDuplicate) {
      throw Exception(
        'Duplicate Student ID Error: A student with ID "${student.rollNumber}" already exists in the system.',
      );
    }

    final newStudent = student.copyWith(
      id: student.id.isNotEmpty ? student.id : 'std_${DateTime.now().millisecondsSinceEpoch}',
    );
    _students.insert(0, newStudent);
    return newStudent;
  }

  @override
  Future<StudentModel> updateStudent(StudentModel student, {bool isAdmin = true}) async {
    await Future.delayed(const Duration(milliseconds: 250));

    if (!isAdmin) {
      throw Exception(
        'Access Denied: Only institutional administrators are authorized to modify protected student records.',
      );
    }

    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      // Prevent changing to another student's rollNumber
      final rollConflict = _students.any(
        (s) => s.id != student.id && s.rollNumber.toLowerCase().trim() == student.rollNumber.toLowerCase().trim(),
      );
      if (rollConflict) {
        throw Exception(
          'Duplicate Student ID Error: Student ID "${student.rollNumber}" is already in use by another student.',
        );
      }

      _students[index] = student;
      return student;
    }
    throw Exception('Student with id ${student.id} not found.');
  }

  @override
  Future<void> deleteStudent(String id, {bool isAdmin = true}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (!isAdmin) {
      throw Exception(
        'Access Denied: Only institutional administrators are authorized to remove student records.',
      );
    }

    _students.removeWhere((s) => s.id == id);
  }

  @override
  Future<CsvImportResult> importStudentsFromCsv(String csvContent, {bool isAdmin = true}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (!isAdmin) {
      throw Exception(
        'Access Denied: Only institutional administrators are authorized to perform CSV student batch imports.',
      );
    }

    final existingIds = _students.map((s) => s.rollNumber.toLowerCase().trim()).toSet();
    final parseResult = StudentCsvParser.parse(
      csvContent: csvContent,
      existingStudentIds: existingIds,
    );

    // Insert valid parsed students
    for (final newStudent in parseResult.importedStudents) {
      _students.insert(0, newStudent);
    }

    return parseResult;
  }
}
