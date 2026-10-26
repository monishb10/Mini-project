class StudentModel {
  final String id;
  final String rollNumber;
  final String name;
  final String email;
  final String department;
  final String year;
  final String section;
  final double cgpa;
  final int totalEventsAttended;
  final int activityPoints;
  final String clusterGroup;
  final String riskLevel; // 'Low', 'Medium', 'High'
  final double attendanceRate; // e.g. 85.5
  final List<String> preferredCategories;
  final DateTime enrolledAt;

  const StudentModel({
    required this.id,
    required this.rollNumber,
    required this.name,
    required this.email,
    required this.department,
    required this.year,
    required this.section,
    required this.cgpa,
    required this.totalEventsAttended,
    required this.activityPoints,
    required this.clusterGroup,
    required this.riskLevel,
    required this.attendanceRate,
    required this.preferredCategories,
    required this.enrolledAt,
  });

  bool get isAtRisk => riskLevel == 'High';

  StudentModel copyWith({
    String? id,
    String? rollNumber,
    String? name,
    String? email,
    String? department,
    String? year,
    String? section,
    double? cgpa,
    int? totalEventsAttended,
    int? activityPoints,
    String? clusterGroup,
    String? riskLevel,
    double? attendanceRate,
    List<String>? preferredCategories,
    DateTime? enrolledAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      rollNumber: rollNumber ?? this.rollNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      year: year ?? this.year,
      section: section ?? this.section,
      cgpa: cgpa ?? this.cgpa,
      totalEventsAttended: totalEventsAttended ?? this.totalEventsAttended,
      activityPoints: activityPoints ?? this.activityPoints,
      clusterGroup: clusterGroup ?? this.clusterGroup,
      riskLevel: riskLevel ?? this.riskLevel,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      enrolledAt: enrolledAt ?? this.enrolledAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'rollNumber': rollNumber,
    'name': name,
    'email': email,
    'department': department,
    'year': year,
    'section': section,
    'cgpa': cgpa,
    'totalEventsAttended': totalEventsAttended,
    'activityPoints': activityPoints,
    'clusterGroup': clusterGroup,
    'riskLevel': riskLevel,
    'attendanceRate': attendanceRate,
    'preferredCategories': preferredCategories,
    'enrolledAt': enrolledAt.toIso8601String(),
  };

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'rollNumber': rollNumber,
    'name': name,
    'email': email,
    'department': department,
    'year': year,
    'section': section,
    'cgpa': cgpa,
    'totalEventsAttended': totalEventsAttended,
    'activityPoints': activityPoints,
    'clusterGroup': clusterGroup,
    'riskLevel': riskLevel,
    'attendanceRate': attendanceRate,
    'preferredCategories': preferredCategories,
    'enrolledAt': enrolledAt.toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json['id'] as String? ?? '',
    rollNumber: json['rollNumber'] as String? ?? '',
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    department: json['department'] as String? ?? '',
    year: json['year'] as String? ?? '',
    section: json['section'] as String? ?? '',
    cgpa: (json['cgpa'] as num?)?.toDouble() ?? 0.0,
    totalEventsAttended: (json['totalEventsAttended'] as num?)?.toInt() ?? 0,
    activityPoints: (json['activityPoints'] as num?)?.toInt() ?? 0,
    clusterGroup: json['clusterGroup'] as String? ?? 'General',
    riskLevel: json['riskLevel'] as String? ?? 'Low',
    attendanceRate: (json['attendanceRate'] as num?)?.toDouble() ?? 100.0,
    preferredCategories: json['preferredCategories'] != null
        ? List<String>.from(json['preferredCategories'] as List)
        : [],
    enrolledAt: json['enrolledAt'] != null
        ? DateTime.tryParse(json['enrolledAt'] as String) ?? DateTime.now()
        : DateTime.now(),
  );

  factory StudentModel.fromFirestore(Map<String, dynamic> json, String docId) =>
      StudentModel(
        id: (json['id'] as String?)?.isNotEmpty == true
            ? json['id'] as String
            : docId,
        rollNumber: json['rollNumber'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        department: json['department'] as String? ?? '',
        year: json['year'] as String? ?? '',
        section: json['section'] as String? ?? '',
        cgpa: (json['cgpa'] as num?)?.toDouble() ?? 0.0,
        totalEventsAttended:
            (json['totalEventsAttended'] as num?)?.toInt() ?? 0,
        activityPoints: (json['activityPoints'] as num?)?.toInt() ?? 0,
        clusterGroup: json['clusterGroup'] as String? ?? 'General',
        riskLevel: json['riskLevel'] as String? ?? 'Low',
        attendanceRate: (json['attendanceRate'] as num?)?.toDouble() ?? 100.0,
        preferredCategories: json['preferredCategories'] != null
            ? List<String>.from(json['preferredCategories'] as List)
            : [],
        enrolledAt: json['enrolledAt'] != null
            ? DateTime.tryParse(json['enrolledAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}
