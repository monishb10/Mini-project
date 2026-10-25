import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login({
    required String email,
    required String password,
    required String role,
  });
  Future<void> logout();
  Future<UserModel> updateProfile(UserModel updatedUser);
}

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser = UserModel(
    id: 'usr_admin_01',
    email: 'admin@college.edu',
    name: 'Dr. Sarah Mitchell',
    role: 'admin',
    department: 'Computer Science & Engineering',
    avatarUrl: null,
    createdAt: DateTime(2025, 1, 1),
  );

  static final List<UserModel> demoAccounts = [
    UserModel(
      id: 'usr_admin_01',
      email: 'admin@college.edu',
      name: 'Dr. Sarah Mitchell',
      role: 'admin',
      department: 'Computer Science & Engineering',
      createdAt: DateTime(2025, 1, 1),
    ),
    UserModel(
      id: 'usr_faculty_02',
      email: 'faculty@college.edu',
      name: 'Prof. Rajesh Sharma',
      role: 'faculty',
      department: 'Information Technology',
      createdAt: DateTime(2025, 1, 10),
    ),
    UserModel(
      id: 'usr_student_03',
      email: 'student@college.edu',
      name: 'Aarav Patel',
      role: 'student',
      department: 'Computer Science & Engineering',
      studentId: '22CS104',
      createdAt: DateTime(2025, 8, 1),
    ),
  ];

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentUser;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Match demo accounts or synthesize based on chosen role
    UserModel? matched;
    for (final demo in demoAccounts) {
      if (demo.role == role) {
        matched = demo.copyWith(email: email.isNotEmpty ? email : demo.email);
        break;
      }
    }

    _currentUser =
        matched ??
        UserModel(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: email.split('@').first.toUpperCase(),
          role: role,
          department: 'Computer Science & Engineering',
          createdAt: DateTime.now(),
        );

    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentUser = null;
  }

  @override
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = updatedUser;
    return _currentUser!;
  }
}
