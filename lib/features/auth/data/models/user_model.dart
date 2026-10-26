class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin', 'faculty', 'student'
  final String? department;
  final String? studentId;
  final String? avatarUrl;
  final String status; // 'active', 'pending_approval', 'suspended'
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.department,
    this.studentId,
    this.avatarUrl,
    this.status = 'active',
    required this.createdAt,
  });

  String get uid => id;
  bool get isAdmin => role == 'admin';
  bool get isFaculty => role == 'faculty';
  bool get isStudent => role == 'student';
  bool get isActive => status == 'active';

  String get roleDisplay {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'faculty':
        return 'Faculty Advisor';
      case 'student':
        return 'Student';
      default:
        return role;
    }
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? department,
    String? studentId,
    String? avatarUrl,
    String? status,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      studentId: studentId ?? this.studentId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uid': id,
    'email': email,
    'name': name,
    'role': role,
    'department': department,
    'studentId': studentId,
    'avatarUrl': avatarUrl,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  Map<String, dynamic> toFirestore() => {
    'uid': id,
    'email': email,
    'name': name,
    'role': role,
    'department': department ?? '',
    'studentId': studentId ?? '',
    'avatarUrl': avatarUrl ?? '',
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: (json['uid'] ?? json['id']) as String? ?? '',
    email: json['email'] as String? ?? '',
    name: json['name'] as String? ?? '',
    role: json['role'] as String? ?? 'student',
    department: json['department'] as String?,
    studentId: json['studentId'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    status: json['status'] as String? ?? 'active',
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
  );

  factory UserModel.fromFirestore(Map<String, dynamic> json, String docId) =>
      UserModel(
        id: (json['uid'] as String?)?.isNotEmpty == true
            ? json['uid'] as String
            : docId,
        email: json['email'] as String? ?? '',
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? 'student',
        department: json['department'] as String?,
        studentId: json['studentId'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        status: json['status'] as String? ?? 'active',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}
