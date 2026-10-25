class AttendanceRecord {
  final String id;
  final String eventId;
  final String eventTitle;
  final String studentId;
  final String studentRollNumber;
  final String studentName;
  final String studentDepartment;
  final String status; // 'Present', 'Absent', 'Excused'
  final DateTime timestamp;
  final String markedBy;
  final String checkInMode;

  const AttendanceRecord({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.studentId,
    required this.studentRollNumber,
    required this.studentName,
    required this.studentDepartment,
    required this.status,
    required this.timestamp,
    required this.markedBy,
    this.checkInMode = 'Manual Roll Call',
  });

  bool get isPresent => status == 'Present';

  AttendanceRecord copyWith({
    String? id,
    String? eventId,
    String? eventTitle,
    String? studentId,
    String? studentRollNumber,
    String? studentName,
    String? studentDepartment,
    String? status,
    DateTime? timestamp,
    String? markedBy,
    String? checkInMode,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      studentId: studentId ?? this.studentId,
      studentRollNumber: studentRollNumber ?? this.studentRollNumber,
      studentName: studentName ?? this.studentName,
      studentDepartment: studentDepartment ?? this.studentDepartment,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      markedBy: markedBy ?? this.markedBy,
      checkInMode: checkInMode ?? this.checkInMode,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventId': eventId,
    'eventTitle': eventTitle,
    'studentId': studentId,
    'studentRollNumber': studentRollNumber,
    'studentName': studentName,
    'studentDepartment': studentDepartment,
    'status': status,
    'timestamp': timestamp.toIso8601String(),
    'markedBy': markedBy,
    'checkInMode': checkInMode,
  };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json['id'] as String,
        eventId: json['eventId'] as String,
        eventTitle: json['eventTitle'] as String,
        studentId: json['studentId'] as String,
        studentRollNumber: json['studentRollNumber'] as String,
        studentName: json['studentName'] as String,
        studentDepartment: json['studentDepartment'] as String,
        status: json['status'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        markedBy: json['markedBy'] as String,
        checkInMode: json['checkInMode'] as String? ?? 'Manual Roll Call',
      );
}
