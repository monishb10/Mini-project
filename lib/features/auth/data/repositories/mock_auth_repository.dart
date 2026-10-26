import 'dart:async';
import '../models/user_model.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final StreamController<UserModel?> _authStreamController =
      StreamController<UserModel?>.broadcast();

  UserModel? _currentUser = UserModel(
    id: 'usr_admin_01',
    email: 'admin@college.edu',
    name: 'Dr. Sarah Mitchell',
    role: 'admin',
    department: 'Computer Science & Engineering',
    avatarUrl: null,
    status: 'active',
    createdAt: DateTime(2025, 1, 1),
  );

  static final List<UserModel> demoAccounts = [
    UserModel(
      id: 'usr_admin_01',
      email: 'admin@college.edu',
      name: 'Dr. Sarah Mitchell',
      role: 'admin',
      department: 'Computer Science & Engineering',
      status: 'active',
      createdAt: DateTime(2025, 1, 1),
    ),
    UserModel(
      id: 'usr_faculty_02',
      email: 'faculty@college.edu',
      name: 'Prof. Rajesh Sharma',
      role: 'faculty',
      department: 'Information Technology',
      status: 'active',
      createdAt: DateTime(2025, 1, 10),
    ),
    UserModel(
      id: 'usr_student_03',
      email: 'student@college.edu',
      name: 'Aarav Patel',
      role: 'student',
      department: 'Computer Science & Engineering',
      studentId: '22CS104',
      status: 'active',
      createdAt: DateTime(2025, 8, 1),
    ),
  ];

  MockAuthRepository() {
    // Emit initial user to stream
    Timer.run(() => _authStreamController.add(_currentUser));
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStreamController.stream;

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _currentUser;
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    // Match demo accounts by email or synthesize
    UserModel? matched;
    for (final demo in demoAccounts) {
      if (demo.email.toLowerCase() == email.toLowerCase().trim()) {
        matched = demo;
        break;
      }
    }

    _currentUser = matched ??
        UserModel(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim(),
          name: email.split('@').first.toUpperCase(),
          role: email.contains('admin')
              ? 'admin'
              : (email.contains('faculty') ? 'faculty' : 'student'),
          department: 'Computer Science & Engineering',
          status: 'active',
          createdAt: DateTime.now(),
        );

    _authStreamController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? department,
    String? studentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    // Security Rule: Admin cannot be chosen publicly
    if (role.toLowerCase().trim() == 'admin') {
      throw Exception(
        'Security Violation: Administrator accounts cannot be created via public registration.',
      );
    }

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      name: name.trim(),
      role: role.toLowerCase().trim(),
      department: department?.trim(),
      studentId: studentId?.trim(),
      status: role == 'student' ? 'active' : 'pending_approval',
      createdAt: DateTime.now(),
    );

    _authStreamController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserModel> createInitialAdmin({
    required String email,
    required String password,
    required String name,
    required String adminSetupToken,
    String? department,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    if (adminSetupToken != 'SAPM_INITIAL_ADMIN_TOKEN_2026') {
      throw Exception('Invalid Administrative Setup Token. Access denied.');
    }

    _currentUser = UserModel(
      id: 'usr_admin_initial',
      email: email.trim(),
      name: name.trim(),
      role: 'admin',
      department: department?.trim() ?? 'Administration',
      status: 'active',
      createdAt: DateTime.now(),
    );

    _authStreamController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _currentUser = null;
    _authStreamController.add(null);
  }

  @override
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentUser = updatedUser;
    _authStreamController.add(_currentUser);
    return _currentUser!;
  }

  void switchRole(String role) {
    for (final demo in demoAccounts) {
      if (demo.role == role) {
        _currentUser = demo;
        _authStreamController.add(_currentUser);
        return;
      }
    }
  }

  void dispose() {
    _authStreamController.close();
  }
}
