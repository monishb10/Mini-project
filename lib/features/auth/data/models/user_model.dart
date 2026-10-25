class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin', 'faculty', 'student'
  final String? department;
  final String? studentId;
  final String? avatarUrl;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.department,
    this.studentId,
    this.avatarUrl,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isFaculty => role == 'faculty';
  bool get isStudent => role == 'student';

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
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
    'department': department,
    'studentId': studentId,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String,
    role: json['role'] as String,
    department: json['department'] as String?,
    studentId: json['studentId'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
