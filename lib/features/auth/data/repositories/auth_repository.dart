import '../models/user_model.dart';

abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;

  /// Get currently signed-in user
  Future<UserModel?> getCurrentUser();

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Public registration - Role CANNOT be 'admin'
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? department,
    String? studentId,
  });

  /// Secure creation of initial administrator with verified setup token
  Future<UserModel> createInitialAdmin({
    required String email,
    required String password,
    required String name,
    required String adminSetupToken,
    String? department,
  });

  /// Send password reset link to user's email
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out current user
  Future<void> logout();

  /// Update user profile details
  Future<UserModel> updateProfile(UserModel updatedUser);
}
