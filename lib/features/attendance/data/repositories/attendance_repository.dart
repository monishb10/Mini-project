import '../models/attendance_model.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> getAttendanceForEvent(String eventId);
  Future<AttendanceRecord> updateStatus(
    String recordId,
    String newStatus, {
    String? markedBy,
    String? verifyingUserId,
  });
  Future<void> bulkMarkPresent(
    String eventId, {
    String? markedBy,
    String? verifyingUserId,
  });
  Future<AttendanceRecord> recordQuickCheckIn({
    required String eventId,
    required String rollNumber,
    required String markedBy,
    String? verifyingUserId,
    String checkInMode,
  });
  Future<AttendanceRecord> verifyAndRecordQrCheckIn({
    required String eventId,
    required String studentRollNumber,
    required String qrToken,
    required String markedBy,
    String? verifyingUserId,
  });
}

class MockAttendanceRepository implements AttendanceRepository {
  final List<AttendanceRecord> _records = [
    AttendanceRecord(
      id: 'att_01',
      eventId: 'evt_01',
      eventTitle: 'National Hackathon 2026: CodeSpark',
      studentId: 'std_01',
      studentRollNumber: '22CS101',
      studentName: 'Aditya Verma',
      studentDepartment: 'Computer Science & Engineering',
      status: 'Present',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      markedBy: 'Faculty Advisor',
      verifyingUserId: 'usr_faculty_02',
      checkInMode: 'QR Scanner',
    ),
    AttendanceRecord(
      id: 'att_02',
      eventId: 'evt_01',
      eventTitle: 'National Hackathon 2026: CodeSpark',
      studentId: 'std_02',
      studentRollNumber: '22CS102',
      studentName: 'Ananya Deshmukh',
      studentDepartment: 'Computer Science & Engineering',
      status: 'Present',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      markedBy: 'Faculty Advisor',
      verifyingUserId: 'usr_faculty_02',
      checkInMode: 'QR Scanner',
    ),
    AttendanceRecord(
      id: 'att_03',
      eventId: 'evt_01',
      eventTitle: 'National Hackathon 2026: CodeSpark',
      studentId: 'std_03',
      studentRollNumber: '22IT045',
      studentName: 'Rohan Mehra',
      studentDepartment: 'Information Technology',
      status: 'Absent',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      markedBy: 'Admin Portal',
      verifyingUserId: 'usr_admin_01',
      checkInMode: 'Manual Roll Call',
    ),
    AttendanceRecord(
      id: 'att_04',
      eventId: 'evt_01',
      eventTitle: 'National Hackathon 2026: CodeSpark',
      studentId: 'std_04',
      studentRollNumber: '23EC018',
      studentName: 'Priya Iyer',
      studentDepartment: 'Electronics & Communication',
      status: 'Excused',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      markedBy: 'Faculty Advisor',
      verifyingUserId: 'usr_faculty_02',
      checkInMode: 'Manual Roll Call',
    ),
    AttendanceRecord(
      id: 'att_05',
      eventId: 'evt_02',
      eventTitle: 'Flutter & Cloud Native Bootcamp',
      studentId: 'std_05',
      studentRollNumber: '22CS105',
      studentName: 'Siddharth Nair',
      studentDepartment: 'Computer Science & Engineering',
      status: 'Present',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      markedBy: 'Prof. Rajesh Sharma',
      verifyingUserId: 'usr_faculty_02',
      checkInMode: 'Manual Roll Call',
    ),
    AttendanceRecord(
      id: 'att_06',
      eventId: 'evt_02',
      eventTitle: 'Flutter & Cloud Native Bootcamp',
      studentId: 'std_06',
      studentRollNumber: '22CS106',
      studentName: 'Sneha Kulkarni',
      studentDepartment: 'Computer Science & Engineering',
      status: 'Absent',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      markedBy: 'Prof. Rajesh Sharma',
      verifyingUserId: 'usr_faculty_02',
      checkInMode: 'Manual Roll Call',
    ),
  ];

  @override
  Future<List<AttendanceRecord>> getAttendanceForEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final matching = _records.where((r) => r.eventId == eventId).toList();
    if (matching.isEmpty) {
      // Seed default roster for demo events if empty
      return _records.take(4).map((r) => r.copyWith(eventId: eventId)).toList();
    }
    return matching;
  }

  @override
  Future<AttendanceRecord> updateStatus(
    String recordId,
    String newStatus, {
    String? markedBy,
    String? verifyingUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      final updated = _records[index].copyWith(
        status: newStatus,
        timestamp: DateTime.now(),
        markedBy: markedBy ?? _records[index].markedBy,
        verifyingUserId: verifyingUserId ?? _records[index].verifyingUserId,
      );
      _records[index] = updated;
      return updated;
    }

    final placeholder = AttendanceRecord(
      id: recordId,
      eventId: 'evt_current',
      eventTitle: 'Event Roll-Call',
      studentId: 'std_temp',
      studentRollNumber: 'TEMP',
      studentName: 'Student',
      studentDepartment: 'General',
      status: newStatus,
      timestamp: DateTime.now(),
      markedBy: markedBy ?? 'Coordinator',
      verifyingUserId: verifyingUserId,
    );
    _records.insert(0, placeholder);
    return placeholder;
  }

  @override
  Future<void> bulkMarkPresent(
    String eventId, {
    String? markedBy,
    String? verifyingUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    for (int i = 0; i < _records.length; i++) {
      if (_records[i].eventId == eventId) {
        _records[i] = _records[i].copyWith(
          status: 'Present',
          timestamp: DateTime.now(),
          markedBy: markedBy ?? _records[i].markedBy,
          verifyingUserId: verifyingUserId ?? _records[i].verifyingUserId,
          checkInMode: 'Bulk Roll Call',
        );
      }
    }
  }

  @override
  Future<AttendanceRecord> recordQuickCheckIn({
    required String eventId,
    required String rollNumber,
    required String markedBy,
    String? verifyingUserId,
    String checkInMode = 'Manual Roll Call',
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Prevent duplicate attendance for the same event and student
    final existingIdx = _records.indexWhere(
      (r) =>
          r.eventId == eventId &&
          r.studentRollNumber.toLowerCase().trim() ==
              rollNumber.toLowerCase().trim(),
    );

    if (existingIdx != -1) {
      if (_records[existingIdx].status == 'Present') {
        throw Exception('Student $rollNumber is already checked in as Present for this event.');
      }
      final existing = _records[existingIdx].copyWith(
        status: 'Present',
        timestamp: DateTime.now(),
        markedBy: markedBy,
        verifyingUserId: verifyingUserId,
        checkInMode: checkInMode,
      );
      _records[existingIdx] = existing;
      return existing;
    }

    final newRecord = AttendanceRecord(
      id: '${eventId}_${rollNumber.toLowerCase().trim()}',
      eventId: eventId,
      eventTitle: 'Event Check-In',
      studentId: 'std_${rollNumber.toLowerCase()}',
      studentRollNumber: rollNumber.toUpperCase(),
      studentName: 'Student ${rollNumber.toUpperCase()}',
      studentDepartment: 'Computer Science & Engineering',
      status: 'Present',
      timestamp: DateTime.now(),
      markedBy: markedBy,
      verifyingUserId: verifyingUserId,
      checkInMode: checkInMode,
    );
    _records.insert(0, newRecord);
    return newRecord;
  }

  @override
  Future<AttendanceRecord> verifyAndRecordQrCheckIn({
    required String eventId,
    required String studentRollNumber,
    required String qrToken,
    required String markedBy,
    String? verifyingUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    // Backend validation of QR Token
    if (!qrToken.startsWith('CHK_') && !qrToken.contains(eventId.toUpperCase())) {
      throw Exception('QR Verification Failed: Invalid or expired event check-in token.');
    }

    return recordQuickCheckIn(
      eventId: eventId,
      rollNumber: studentRollNumber,
      markedBy: markedBy,
      verifyingUserId: verifyingUserId,
      checkInMode: 'QR Scanner',
    );
  }
}
