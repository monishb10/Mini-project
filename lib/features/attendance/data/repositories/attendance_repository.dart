import '../models/attendance_model.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> getAttendanceForEvent(String eventId);
  Future<AttendanceRecord> updateStatus(String recordId, String newStatus);
  Future<void> bulkMarkPresent(String eventId);
  Future<AttendanceRecord> recordQuickCheckIn({
    required String eventId,
    required String rollNumber,
    required String markedBy,
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
      checkInMode: 'Manual Roll Call',
    ),
    AttendanceRecord(
      id: 'att_04',
      eventId: 'evt_01',
      eventTitle: 'National Hackathon 2026: CodeSpark',
      studentId: 'std_04',
      studentRollNumber: '23EC018',
      studentName: 'Sneha Kulkarni',
      studentDepartment: 'Electronics & Communication',
      status: 'Present',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      markedBy: 'Admin Portal',
      checkInMode: 'Manual Roll Call',
    ),
    AttendanceRecord(
      id: 'att_05',
      eventId: 'evt_01',
      eventTitle: 'National Hackathon 2026: CodeSpark',
      studentId: 'std_05',
      studentRollNumber: '21ME077',
      studentName: 'Vikram Singh Rathore',
      studentDepartment: 'Mechanical Engineering',
      status: 'Excused',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      markedBy: 'HOD Mechanical',
      checkInMode: 'Manual Roll Call',
    ),
    AttendanceRecord(
      id: 'att_06',
      eventId: 'evt_02',
      eventTitle: 'Flutter & Cloud Native Bootcamp',
      studentId: 'std_01',
      studentRollNumber: '22CS101',
      studentName: 'Aditya Verma',
      studentDepartment: 'Computer Science & Engineering',
      status: 'Present',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      markedBy: 'Prof. Rajesh Sharma',
      checkInMode: 'QR Scanner',
    ),
    AttendanceRecord(
      id: 'att_07',
      eventId: 'evt_02',
      eventTitle: 'Flutter & Cloud Native Bootcamp',
      studentId: 'std_06',
      studentRollNumber: '24EE012',
      studentName: 'Pooja Hegde',
      studentDepartment: 'Electrical & Electronics',
      status: 'Present',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      markedBy: 'Prof. Rajesh Sharma',
      checkInMode: 'Manual Roll Call',
    ),
  ];

  @override
  Future<List<AttendanceRecord>> getAttendanceForEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final matched = _records.where((r) => r.eventId == eventId).toList();
    if (matched.isEmpty) {
      // Return a populated list derived for this event
      return [
        AttendanceRecord(
          id: 'att_gen_1',
          eventId: eventId,
          eventTitle: 'Selected Event Attendance',
          studentId: 'std_01',
          studentRollNumber: '22CS101',
          studentName: 'Aditya Verma',
          studentDepartment: 'Computer Science & Engineering',
          status: 'Present',
          timestamp: DateTime.now(),
          markedBy: 'Faculty Coordinator',
          checkInMode: 'QR Scanner',
        ),
        AttendanceRecord(
          id: 'att_gen_2',
          eventId: eventId,
          eventTitle: 'Selected Event Attendance',
          studentId: 'std_02',
          studentRollNumber: '22CS102',
          studentName: 'Ananya Deshmukh',
          studentDepartment: 'Computer Science & Engineering',
          status: 'Present',
          timestamp: DateTime.now(),
          markedBy: 'Faculty Coordinator',
          checkInMode: 'QR Scanner',
        ),
        AttendanceRecord(
          id: 'att_gen_3',
          eventId: eventId,
          eventTitle: 'Selected Event Attendance',
          studentId: 'std_03',
          studentRollNumber: '22IT045',
          studentName: 'Rohan Mehra',
          studentDepartment: 'Information Technology',
          status: 'Absent',
          timestamp: DateTime.now(),
          markedBy: 'Faculty Coordinator',
          checkInMode: 'Manual Roll Call',
        ),
      ];
    }
    return matched;
  }

  @override
  Future<AttendanceRecord> updateStatus(
    String recordId,
    String newStatus,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      final updated = _records[index].copyWith(
        status: newStatus,
        timestamp: DateTime.now(),
      );
      _records[index] = updated;
      return updated;
    }
    return AttendanceRecord(
      id: recordId,
      eventId: 'evt_01',
      eventTitle: 'Updated Event',
      studentId: 'std_00',
      studentRollNumber: 'ROLL_TEMP',
      studentName: 'Updated Student',
      studentDepartment: 'General',
      status: newStatus,
      timestamp: DateTime.now(),
      markedBy: 'Coordinator',
    );
  }

  @override
  Future<void> bulkMarkPresent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    for (int i = 0; i < _records.length; i++) {
      if (_records[i].eventId == eventId) {
        _records[i] = _records[i].copyWith(
          status: 'Present',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  @override
  Future<AttendanceRecord> recordQuickCheckIn({
    required String eventId,
    required String rollNumber,
    required String markedBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final newRecord = AttendanceRecord(
      id: 'att_${DateTime.now().millisecondsSinceEpoch}',
      eventId: eventId,
      eventTitle: 'Event Check-In',
      studentId: 'std_custom',
      studentRollNumber: rollNumber,
      studentName: 'Student $rollNumber',
      studentDepartment: 'Computer Science & Engineering',
      status: 'Present',
      timestamp: DateTime.now(),
      markedBy: markedBy,
      checkInMode: 'QR Scanner',
    );
    _records.insert(0, newRecord);
    return newRecord;
  }
}
