import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthController({AuthRepository? repository})
    : _repository = repository ?? MockAuthRepository() {
    _initUser();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  String get currentRole => _currentUser?.role ?? 'admin';
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isFaculty => _currentUser?.isFaculty ?? false;
  bool get isStudent => _currentUser?.isStudent ?? false;

  Future<void> _initUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _repository.getCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.login(
        email: email,
        password: password,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> quickSwitchRole(String role) async {
    _isLoading = true;
    notifyListeners();

    String email;
    String name;
    String? studentId;

    switch (role) {
      case 'admin':
        email = 'admin@college.edu';
        name = 'Dr. Sarah Mitchell';
        break;
      case 'faculty':
        email = 'faculty@college.edu';
        name = 'Prof. Rajesh Sharma';
        break;
      case 'student':
        email = 'student@college.edu';
        name = 'Aarav Patel';
        studentId = '22CS104';
        break;
      default:
        email = 'user@college.edu';
        name = 'Demo User';
    }

    _currentUser = UserModel(
      id: 'usr_$role',
      email: email,
      name: name,
      role: role,
      department: 'Computer Science & Engineering',
      studentId: studentId,
      createdAt: DateTime(2025, 1, 1),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _repository.logout();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? department,
  }) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final updated = _currentUser!.copyWith(
        name: name,
        email: email,
        department: department,
      );
      _currentUser = await _repository.updateProfile(updated);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
