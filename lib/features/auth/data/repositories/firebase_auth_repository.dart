import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// Default secure setup token for creating the initial institutional administrator.
  /// Can be overridden at runtime via Dart environment variable: --dart-define=ADMIN_SETUP_TOKEN=...
  static const String defaultAdminSetupToken = String.fromEnvironment(
    'ADMIN_SETUP_TOKEN',
    defaultValue: 'SAPM_INITIAL_ADMIN_TOKEN_2026',
  );

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((User? firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromFirestore(doc.data()!, doc.id);
        }
        // Fallback user model while document propagates
        return UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
          role: 'student',
          createdAt: DateTime.now(),
        );
      } catch (e) {
        debugPrint('[FirebaseAuthRepository] Error fetching user profile: $e');
        return UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          role: 'student',
          createdAt: DateTime.now(),
        );
      }
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
        role: 'student',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[FirebaseAuthRepository] Error in getCurrentUser: $e');
      return null;
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Authentication returned an empty user credential.');
      }

      // Fetch user profile from Firestore users collection
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!userDoc.exists || userDoc.data() == null) {
        // Automatically link an existing Auth user if Firestore doc was pending
        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? email,
          name: firebaseUser.displayName ?? email.split('@').first,
          role: 'student',
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toFirestore());
        return newUser;
      }

      final user = UserModel.fromFirestore(userDoc.data()!, userDoc.id);

      // Verify account status
      if (user.status == 'suspended') {
        await _firebaseAuth.signOut();
        throw Exception('Your account has been suspended by the administrator.');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthErrorMessage(e.code, e.message));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Sign in failed: ${e.toString()}');
    }
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
    final sanitizedRole = role.toLowerCase().trim();

    // Critical Security Requirement: Admin role can NEVER be registered publicly!
    if (sanitizedRole == 'admin') {
      throw Exception(
        'Security Violation: Administrator accounts cannot be created via public registration. '
        'Contact your institution administrator or use the secure setup bootstrap process.',
      );
    }

    if (sanitizedRole != 'student' && sanitizedRole != 'faculty') {
      throw Exception('Invalid role selected: Only Student and Faculty roles are permitted.');
    }

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create user authentication credential.');
      }

      // Update Firebase Auth display name
      await firebaseUser.updateDisplayName(name.trim());

      final newUser = UserModel(
        id: firebaseUser.uid,
        email: email.trim(),
        name: name.trim(),
        role: sanitizedRole,
        department: department?.trim(),
        studentId: sanitizedRole == 'student' ? studentId?.trim() : null,
        status: sanitizedRole == 'student' ? 'active' : 'pending_approval',
        createdAt: DateTime.now(),
      );

      // Write user profile to Cloud Firestore users/{uid} collection
      await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toFirestore());

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthErrorMessage(e.code, e.message));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> createInitialAdmin({
    required String email,
    required String password,
    required String name,
    required String adminSetupToken,
    String? department,
  }) async {
    // Validate the secure one-time setup token
    if (adminSetupToken.trim() != defaultAdminSetupToken) {
      throw Exception(
        'Security Error: Invalid Administrative Setup Token. '
        'Access denied. Please check your system configuration.',
      );
    }

    try {
      // Create user credential in Firebase Auth
      UserCredential credential;
      try {
        credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // If already created in Auth, sign in and elevate to admin
          credential = await _firebaseAuth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
        } else {
          rethrow;
        }
      }

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Admin user creation returned null user.');
      }

      await firebaseUser.updateDisplayName(name.trim());

      final adminUser = UserModel(
        id: firebaseUser.uid,
        email: email.trim(),
        name: name.trim(),
        role: 'admin',
        department: department?.trim() ?? 'Administration',
        status: 'active',
        createdAt: DateTime.now(),
      );

      // Write verified admin record to Firestore users/{uid}
      await _firestore.collection('users').doc(firebaseUser.uid).set(
        adminUser.toFirestore(),
        SetOptions(merge: true),
      );

      return adminUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthErrorMessage(e.code, e.message));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Admin initialization failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthErrorMessage(e.code, e.message));
    } catch (e) {
      throw Exception('Failed to send password reset: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('[FirebaseAuthRepository] Sign out error: $e');
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel updatedUser) async {
    try {
      // Protect sensitive fields from client mutation: role and uid cannot be changed via updateProfile!
      await _firestore.collection('users').doc(updatedUser.id).update({
        'name': updatedUser.name,
        'department': updatedUser.department ?? '',
        'studentId': updatedUser.studentId ?? '',
        'avatarUrl': updatedUser.avatarUrl ?? '',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return updatedUser;
    } catch (e) {
      throw Exception('Failed to update profile in database: ${e.toString()}');
    }
  }

  /// Map Firebase error codes to readable, user-friendly messages
  String _mapAuthErrorMessage(String code, String? defaultMessage) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address. Please check or register a new account.';
      case 'wrong-password':
        return 'Incorrect password. Please verify your credentials.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account is already registered with this institutional email address.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters with mixed letters and numbers.';
      case 'invalid-email':
        return 'The email format entered is invalid.';
      case 'user-disabled':
        return 'This account has been disabled by the college administrator.';
      case 'too-many-requests':
        return 'Access blocked due to multiple failed login attempts. Please wait a moment and try again.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in Firebase Console. Please enable it in the Authentication tab.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet or Firebase emulator connection.';
      default:
        return defaultMessage ?? 'An authentication error occurred (Code: $code).';
    }
  }
}
