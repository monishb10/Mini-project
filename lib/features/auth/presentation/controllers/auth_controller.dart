import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/firebase_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/mock_auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<UserModel?>? _authSubscription;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String? _successMessage;

  AuthController({AuthRepository? repository})
      : _repository = repository ??
            (FirebaseService.isInitialized
                ? FirebaseAuthRepository()
                : MockAuthRepository()) {
    _initAuthListener();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _currentUser != null;

  String get currentRole => _currentUser?.role ?? 'student';
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isFaculty => _currentUser?.isFaculty ?? false;
  bool get isStudent => _currentUser?.isStudent ?? false;
  bool get isUsingFirebase => _repository is FirebaseAuthRepository;

  void _initAuthListener() {
    _isLoading = true;
    notifyListeners();

    // Listen to continuous auth state stream (persisted across sessions)
    _authSubscription = _repository.authStateChanges.listen(
      (UserModel? user) {
        _currentUser = user;
        _isLoading = false;
        _isInitialized = true;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        _isInitialized = true;
        notifyListeners();
      },
    );

    // Initial check
    _repository.getCurrentUser().then((user) {
      if (_currentUser == null && user != null) {
        _currentUser = user;
      }
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }).catchError((error) {
      _errorMessage = error.toString();
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    });
  }

  /// Sign In with Email & Password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final user = await _repository.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _currentUser = user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Backward-compatible login method
  Future<bool> login({
    required String email,
    required String password,
    String? role,
  }) async {
    return signIn(email: email, password: password);
  }

  /// Public Registration (Only 'student' or 'faculty' allowed)
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? department,
    String? studentId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final user = await _repository.signUp(
        email: email.trim(),
        password: password.trim(),
        name: name.trim(),
        role: role.trim(),
        department: department?.trim(),
        studentId: studentId?.trim(),
      );
      _currentUser = user;
      _successMessage = 'Account created successfully! Welcome, ${user.name}.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Secure creation of initial administrator account
  Future<bool> createInitialAdmin({
    required String email,
    required String password,
    required String name,
    required String adminSetupToken,
    String? department,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final user = await _repository.createInitialAdmin(
        email: email.trim(),
        password: password.trim(),
        name: name.trim(),
        adminSetupToken: adminSetupToken.trim(),
        department: department?.trim(),
      );
      _currentUser = user;
      _successMessage = 'Administrator account successfully initialized!';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.sendPasswordResetEmail(email.trim());
      _successMessage = 'Password reset instructions have been sent to $email.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fast demo role switch for evaluation and testing
  Future<void> quickSwitchRole(String role) async {
    final repo = _repository;
    if (repo is MockAuthRepository) {
      repo.switchRole(role);
      _currentUser = await repo.getCurrentUser();
      notifyListeners();
      return;
    }

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
      status: 'active',
      createdAt: DateTime(2025, 1, 1),
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Sign out
  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.logout();
    } finally {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? department,
    String? studentId,
  }) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = _currentUser!.copyWith(
        name: name.trim(),
        email: email.trim(),
        department: department?.trim(),
        studentId: studentId?.trim(),
      );
      _currentUser = await _repository.updateProfile(updated);
      _successMessage = 'Profile updated successfully.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  String _cleanErrorMessage(dynamic error) {
    String msg = error.toString();
    if (msg.startsWith('Exception: ')) {
      msg = msg.substring(11);
    }
    return msg;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
