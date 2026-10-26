import 'package:flutter_test/flutter_test.dart';
import 'package:student_pattern_mining/features/attendance/data/repositories/attendance_repository.dart';
import 'package:student_pattern_mining/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:student_pattern_mining/features/auth/data/models/user_model.dart';
import 'package:student_pattern_mining/features/events/data/models/event_model.dart';
import 'package:student_pattern_mining/features/events/data/repositories/event_repository.dart';
import 'package:student_pattern_mining/features/events/presentation/controllers/event_controller.dart';
import 'package:student_pattern_mining/features/students/data/models/student_model.dart';
import 'package:student_pattern_mining/features/students/data/repositories/student_repository.dart';
import 'package:student_pattern_mining/features/students/data/utils/student_csv_parser.dart';
import 'package:student_pattern_mining/features/students/presentation/controllers/student_controller.dart';

void main() {
  group('Part 3 A: Student Management & CSV Import Tests', () {
    late MockStudentRepository repository;
    late StudentController controller;

    setUp(() async {
      repository = MockStudentRepository();
      controller = StudentController(repository: repository);
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('Add student succeeds with unique roll number / studentId', () async {
      final newStudent = StudentModel(
        id: 'new_student_1',
        name: 'Priya Sharma',
        rollNumber: '22CS299',
        email: 'priya.s@college.edu',
        department: 'Computer Science & Engineering',
        year: '3rd Year',
        section: 'A',
        cgpa: 8.9,
        totalEventsAttended: 4,
        activityPoints: 40,
        clusterGroup: 'Tech Innovators',
        riskLevel: 'Low',
        attendanceRate: 92.0,
        preferredCategories: const ['Technical & Coding', 'Workshops & Seminars'],
        enrolledAt: DateTime.now(),
      );

      final success = await controller.addStudent(newStudent, isAdmin: true);
      expect(success, isTrue);

      final fetched = await repository.getStudentByRollNumber('22CS299');
      expect(fetched, isNotNull);
      expect(fetched!.name, equals('Priya Sharma'));
      expect(fetched.interests, contains('Technical & Coding'));
    });

    test('Add student strictly rejects duplicate student ID / roll number', () async {
      final duplicateStudent = StudentModel(
        id: 'dup_student_1',
        name: 'Imposter Student',
        rollNumber: '22CS101', // Existing ID in mock roster
        email: 'imposter@college.edu',
        department: 'Computer Science & Engineering',
        year: '3rd Year',
        section: 'B',
        cgpa: 7.0,
        totalEventsAttended: 1,
        activityPoints: 10,
        clusterGroup: 'Exploratory',
        riskLevel: 'Medium',
        attendanceRate: 80.0,
        preferredCategories: const ['Cultural'],
        enrolledAt: DateTime.now(),
      );

      final success = await controller.addStudent(duplicateStudent, isAdmin: true);
      expect(success, isFalse);
      expect(controller.errorMessage, contains('already exists'));
    });

    test('Protected student record mutation strictly requires Administrator privileges', () async {
      // Non-admin attempting to delete a student record
      final deleteSuccess = await controller.deleteStudent('std_01', isAdmin: false);
      expect(deleteSuccess, isFalse);
      expect(controller.errorMessage?.toLowerCase(), contains('administrator'));

      // Non-admin attempting to add a student record
      final addSuccess = await controller.addStudent(
        StudentModel(
          id: 'unauth_1',
          name: 'Unauthorized Student',
          rollNumber: '22CS999',
          email: 'unauth@college.edu',
          department: 'Computer Science & Engineering',
          year: '1st Year',
          section: 'A',
          cgpa: 6.5,
          totalEventsAttended: 0,
          activityPoints: 0,
          clusterGroup: 'New',
          riskLevel: 'Low',
          attendanceRate: 85.0,
          preferredCategories: const [],
          enrolledAt: DateTime.now(),
        ),
        isAdmin: false,
      );
      expect(addSuccess, isFalse);
      expect(controller.errorMessage?.toLowerCase(), contains('administrator'));
    });

    test('CSV Parser validates headers, extracts valid rows, and flags row-level errors', () {
      const csvData = '''
studentId,name,email,department,year,section,interests
22CS801,Aarav Patel,aarav@college.edu,Computer Science,3,A,AI; Robotics
22IT802,Ananya Roy,ananya@college.edu,Information Technology,2,B,Web Development
22CS801,Duplicate Patel,dup@college.edu,Computer Science,3,A,Cloud
INVALID_ROW,No Email,,Computer Science,3,A,Design
22EC803,Bad Year,bad@college.edu,Electronics,0,A,IoT
''';

      final existingIds = {'22CS101'};
      final result = StudentCsvParser.parse(
        csvContent: csvData,
        existingStudentIds: existingIds,
      );

      expect(result.totalRows, equals(5));
      expect(result.importedCount, equals(2));
      expect(result.errors.length, equals(3));

      // Row 1 & 2 valid
      expect(result.importedStudents[0].studentId, equals('22CS801'));
      expect(result.importedStudents[0].interests, contains('AI'));
      expect(result.importedStudents[1].studentId, equals('22IT802'));

      // Errors captured
      // Duplicate in batch
      expect(result.errors.any((e) => e.reason.contains('Duplicate')), isTrue);
      // Missing required email
      expect(result.errors.any((e) => e.field == 'email'), isTrue);
      // Invalid year (year 0)
      expect(result.errors.any((e) => e.field == 'year'), isTrue);
    });

    test('CSV Parser catches collision against existing database IDs', () {
      const csvData = '''
studentId,name,email,department,year,section,interests
22CS101,Collision Student,collision@college.edu,Computer Science,3,A,Cloud
''';

      final existingIds = {'22CS101'}; // already in system
      final result = StudentCsvParser.parse(
        csvContent: csvData,
        existingStudentIds: existingIds,
      );

      expect(result.importedCount, equals(0));
      expect(result.errors.length, equals(1));
      expect(result.errors.first.reason, contains('already exists in the system'));
    });
  });

  group('Part 3 B: Event Management & Validation Tests', () {
    late MockEventRepository repository;
    late EventController controller;

    setUp(() async {
      repository = MockEventRepository();
      controller = EventController(repository: repository);
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('Create event enforces capacity > 0', () async {
      final now = DateTime.now().add(const Duration(days: 5));
      final invalidEvent = EventModel(
        id: 'ev_invalid_cap',
        title: 'Zero Capacity Hackathon',
        description: 'Test description',
        category: 'Technical',
        venue: 'Lab 1',
        organizerDepartment: 'Computer Science & Engineering',
        dateTime: now,
        endDate: now.add(const Duration(hours: 3)),
        registrationDeadline: now.subtract(const Duration(hours: 6)),
        durationHours: 3.0,
        capacity: 0, // INVALID!
        registeredCount: 0,
        activityPoints: 20,
        status: 'Upcoming',
        coordinatorName: 'Prof. Test',
      );

      final success = await controller.addEvent(invalidEvent);
      expect(success, isFalse);
      expect(controller.errorMessage, contains('greater than zero'));
    });

    test('Create event enforces endDate >= startDate', () async {
      final now = DateTime.now().add(const Duration(days: 5));
      final invalidEvent = EventModel(
        id: 'ev_invalid_dates',
        title: 'Inverted Dates Symposium',
        description: 'Test description',
        category: 'Technical',
        venue: 'Auditorium',
        organizerDepartment: 'Computer Science & Engineering',
        dateTime: now,
        endDate: now.subtract(const Duration(hours: 2)), // End before start!
        registrationDeadline: now.subtract(const Duration(hours: 6)),
        durationHours: 2.0,
        capacity: 100,
        registeredCount: 0,
        activityPoints: 20,
        status: 'Upcoming',
        coordinatorName: 'Prof. Test',
      );

      final success = await controller.addEvent(invalidEvent);
      expect(success, isFalse);
      expect(controller.errorMessage, contains('End date cannot be earlier'));
    });

    test('Create event enforces registrationDeadline <= startDate', () async {
      final now = DateTime.now().add(const Duration(days: 5));
      final invalidEvent = EventModel(
        id: 'ev_invalid_deadline',
        title: 'Late Registration Workshop',
        description: 'Test description',
        category: 'Workshop',
        venue: 'Seminar Hall',
        organizerDepartment: 'Information Technology',
        dateTime: now,
        endDate: now.add(const Duration(hours: 4)),
        registrationDeadline: now.add(const Duration(hours: 1)), // Deadline after event started!
        durationHours: 4.0,
        capacity: 50,
        registeredCount: 0,
        activityPoints: 15,
        status: 'Upcoming',
        coordinatorName: 'Prof. Test',
      );

      final success = await controller.addEvent(invalidEvent);
      expect(success, isFalse);
      expect(controller.errorMessage, contains('Registration deadline cannot be after'));
    });

    test('Faculty and Admin can cancel an event with audit log', () async {
      final event = controller.events.first;

      final success = await controller.cancelEvent(
        event.id,
        reason: 'Unforeseen university holiday',
      );
      expect(success, isTrue);

      final updated = controller.events.firstWhere((e) => e.id == event.id);
      expect(updated.status, equals('Cancelled'));
    });
  });

  group('Part 3 C: Student Event Registration Tests', () {
    late MockEventRepository repository;
    late EventController controller;

    final testStudent = UserModel(
      id: 'student_user_1',
      name: 'Rohan Verma',
      email: 'rohan.v@college.edu',
      role: 'student',
      department: 'Computer Science & Engineering',
      studentId: '22CS105',
      createdAt: DateTime.now(),
    );

    setUp(() async {
      repository = MockEventRepository();
      controller = EventController(repository: repository);
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('Student successfully registers for available event and increments count', () async {
      // Find an event that is not full and student is not yet registered (evt_02)
      final event = controller.events.firstWhere((e) => e.id == 'evt_02');
      final initialCount = event.registeredCount;

      final success = await controller.registerStudent(
        eventId: event.id,
        student: testStudent,
      );

      expect(success, isTrue);
      final updated = controller.events.firstWhere((e) => e.id == event.id);
      expect(updated.registeredCount, equals(initialCount + 1));
      expect(updated.isRegistered, isTrue);

      // Verify registration record in repository
      final registrations = await repository.getEventRegistrations(event.id);
      expect(registrations.any((r) => r.studentId == testStudent.uid && r.isRegistered), isTrue);
    });

    test('Prevent duplicate registration for the same student on the same event', () async {
      final event = controller.events.firstWhere((e) => e.id == 'evt_02');

      // First registration succeeds
      final firstSuccess = await controller.registerStudent(
        eventId: event.id,
        student: testStudent,
      );
      expect(firstSuccess, isTrue);

      // Second registration attempt is rejected
      final secondSuccess = await controller.registerStudent(
        eventId: event.id,
        student: testStudent,
      );
      expect(secondSuccess, isFalse);
      expect(controller.errorMessage, contains('already registered'));
    });

    test('Strictly enforce capacity limits when event is full', () async {
      final now = DateTime.now().add(const Duration(days: 4));
      final tinyEvent = EventModel(
        id: 'tiny_event_1',
        title: 'Exclusive Mentorship Session',
        description: 'Single seat session',
        category: 'Seminar',
        venue: 'Dean Office',
        organizerDepartment: 'Computer Science & Engineering',
        dateTime: now,
        endDate: now.add(const Duration(hours: 1)),
        registrationDeadline: now.subtract(const Duration(hours: 2)),
        durationHours: 1.0,
        capacity: 1,
        registeredCount: 0,
        activityPoints: 10,
        status: 'Upcoming',
        coordinatorName: 'Dr. Dean',
      );
      await repository.addEvent(tinyEvent);
      await controller.loadEvents();

      // First student fills the capacity
      final s1 = await controller.registerStudent(
        eventId: tinyEvent.id,
        student: testStudent,
      );
      expect(s1, isTrue);

      // Second student attempts to register
      final student2 = testStudent.copyWith(
        id: 'student_user_2',
        studentId: '22CS106',
        email: 'second@college.edu',
      );
      final s2 = await controller.registerStudent(
        eventId: tinyEvent.id,
        student: student2,
      );
      expect(s2, isFalse);
      expect(controller.errorMessage, contains('is full'));
    });

    test('Student can cancel existing registration and release seat', () async {
      final event = controller.events.firstWhere((e) => e.id == 'evt_02');

      // Register
      await controller.registerStudent(eventId: event.id, student: testStudent);
      final countAfterReg = controller.events.firstWhere((e) => e.id == event.id).registeredCount;

      // Cancel
      final cancelSuccess = await controller.cancelStudentRegistration(
        eventId: event.id,
        student: testStudent,
      );
      expect(cancelSuccess, isTrue);

      final countAfterCancel = controller.events.firstWhere((e) => e.id == event.id).registeredCount;
      expect(countAfterCancel, equals(countAfterReg - 1));
    });
  });

  group('Part 3 D: Attendance & QR Check-In Verification Tests', () {
    late MockAttendanceRepository repository;
    late AttendanceController controller;

    final facultyVerifier = UserModel(
      id: 'faculty_1',
      name: 'Dr. Aris Thorne',
      email: 'aris.t@college.edu',
      role: 'faculty',
      department: 'Computer Science & Engineering',
      createdAt: DateTime.now(),
    );

    setUp(() async {
      repository = MockAttendanceRepository();
      controller = AttendanceController(repository: repository);
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('Faculty roll call records attendance status accurately', () async {
      final record = controller.records.first;

      await controller.updateStatus(record.id, 'Absent');
      final updated = controller.records.firstWhere((r) => r.id == record.id);
      expect(updated.status, equals('Absent'));

      await controller.updateStatus(record.id, 'Excused');
      final updatedExcused = controller.records.firstWhere((r) => r.id == record.id);
      expect(updatedExcused.status, equals('Excused'));
    });

    test('QR check-in verification succeeds with valid event secret token', () async {
      // Event 'evt_01' has checkInSecretToken 'CHK_CODESPARK_2026'
      final success = await controller.verifyAndRecordQrCheckIn(
        eventId: 'evt_01',
        rollNumber: '22CS108',
        qrToken: 'CHK_CODESPARK_2026',
        verifyingUser: facultyVerifier,
      );

      expect(success, isTrue);
      expect(controller.successMessage, contains('Check-in recorded'));

      final record = controller.records.firstWhere(
        (r) => r.eventId == 'evt_01' && r.studentRollNumber == '22CS108',
      );
      expect(record.status, equals('Present'));
      expect(record.checkInMode, equals('QR Scanner'));
      expect(record.verifyingUserId, equals(facultyVerifier.uid));
    });

    test('QR check-in strictly rejects forged or mismatched tokens', () async {
      final success = await controller.verifyAndRecordQrCheckIn(
        eventId: 'evt_01',
        rollNumber: '22CS109',
        qrToken: 'FORGED_INVALID_TOKEN',
        verifyingUser: facultyVerifier,
      );

      expect(success, isFalse);
      expect(controller.errorMessage, contains('Invalid or expired'));
    });

    test('QR check-in prevents duplicate check-in for already present attendee', () async {
      // First check-in
      final first = await controller.verifyAndRecordQrCheckIn(
        eventId: 'evt_01',
        rollNumber: '22CS110',
        qrToken: 'CHK_CODESPARK_2026',
        verifyingUser: facultyVerifier,
      );
      expect(first, isTrue);

      // Duplicate check-in attempt for the same student
      final duplicate = await controller.verifyAndRecordQrCheckIn(
        eventId: 'evt_01',
        rollNumber: '22CS110',
        qrToken: 'CHK_CODESPARK_2026',
        verifyingUser: facultyVerifier,
      );
      expect(duplicate, isFalse);
      expect(controller.errorMessage, contains('already checked in as Present'));
    });
  });
}
