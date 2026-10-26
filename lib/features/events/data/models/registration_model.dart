class RegistrationModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String studentId;
  final String studentRollNumber;
  final String studentName;
  final String studentEmail;
  final String studentDepartment;
  final String status; // 'registered', 'cancelled', 'waitlisted'
  final DateTime registeredAt;
  final DateTime? cancelledAt;

  const RegistrationModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.studentId,
    required this.studentRollNumber,
    required this.studentName,
    required this.studentEmail,
    required this.studentDepartment,
    this.status = 'registered',
    required this.registeredAt,
    this.cancelledAt,
  });

  bool get isRegistered => status == 'registered';
  bool get isCancelled => status == 'cancelled';

  RegistrationModel copyWith({
    String? id,
    String? eventId,
    String? eventTitle,
    String? studentId,
    String? studentRollNumber,
    String? studentName,
    String? studentEmail,
    String? studentDepartment,
    String? status,
    DateTime? registeredAt,
    DateTime? cancelledAt,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      studentId: studentId ?? this.studentId,
      studentRollNumber: studentRollNumber ?? this.studentRollNumber,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      studentDepartment: studentDepartment ?? this.studentDepartment,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'registrationId': id,
    'eventId': eventId,
    'eventTitle': eventTitle,
    'studentId': studentId,
    'studentRollNumber': studentRollNumber,
    'studentName': studentName,
    'studentEmail': studentEmail,
    'studentDepartment': studentDepartment,
    'status': status,
    'registeredAt': registeredAt.toIso8601String(),
    'cancelledAt': cancelledAt?.toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory RegistrationModel.fromFirestore(
    Map<String, dynamic> json,
    String docId,
  ) {
    return RegistrationModel(
      id: docId,
      eventId: json['eventId'] as String? ?? '',
      eventTitle: json['eventTitle'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      studentRollNumber: json['studentRollNumber'] as String? ?? '',
      studentName: json['studentName'] as String? ?? '',
      studentEmail: json['studentEmail'] as String? ?? '',
      studentDepartment: json['studentDepartment'] as String? ?? '',
      status: json['status'] as String? ?? 'registered',
      registeredAt: json['registeredAt'] != null
          ? DateTime.tryParse(json['registeredAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.tryParse(json['cancelledAt'] as String)
          : null,
    );
  }
}
