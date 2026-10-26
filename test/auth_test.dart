import 'package:flutter_test/flutter_test.dart';
import 'package:student_pattern_mining/features/auth/data/models/user_model.dart';
import 'package:student_pattern_mining/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:student_pattern_mining/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  group('Part 2 Authentication & Role Security Tests', () {
    late MockAuthRepository mockRepository;
    late AuthController authController;

    setUp(() {
      mockRepository = MockAuthRepository();
      authController = AuthController(repository: mockRepository);
    });

    tearDown(() {
      authController.dispose();
      mockRepository.dispose();
    });

    test('Initial user is loaded with default admin session', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      expect(authController.isAuthenticated, isTrue);
      expect(authController.isAdmin, isTrue);
      expect(authController.currentUser?.email, equals('admin@college.edu'));
    });

    test('Public registration STRICTLY REJECTS admin role selection', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final success = await authController.signUp(
        email: 'attacker@college.edu',
        password: 'password123',
        name: 'Malicious Attacker',
        role: 'admin', // FORBIDDEN!
      );

      expect(success, isFalse);
      expect(authController.errorMessage, contains('Security Violation'));
      expect(authController.errorMessage, contains('Administrator accounts cannot be created via public registration'));
    });

    test('Public registration succeeds for Student role', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final success = await authController.signUp(
        email: 'rahul.k@college.edu',
        password: 'password123',
        name: 'Rahul Kumar',
        role: 'student',
        department: 'Information Technology',
        studentId: '22IT109',
      );

      expect(success, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.isStudent, isTrue);
      expect(authController.currentUser?.studentId, equals('22IT109'));
      expect(authController.currentUser?.roleDisplay, equals('Student'));
    });

    test('Public registration succeeds for Faculty role', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final success = await authController.signUp(
        email: 'prof.anita@college.edu',
        password: 'password123',
        name: 'Dr. Anita Roy',
        role: 'faculty',
        department: 'Electronics & Communication',
      );

      expect(success, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.isFaculty, isTrue);
      expect(authController.currentUser?.roleDisplay, equals('Faculty Advisor'));
    });

    test('Initial Admin creation FAILS with invalid setup token', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final success = await authController.createInitialAdmin(
        email: 'newadmin@college.edu',
        password: 'AdminPassword123!',
        name: 'System Admin',
        adminSetupToken: 'WRONG_UNAUTHORIZED_TOKEN',
      );

      expect(success, isFalse);
      expect(authController.errorMessage, contains('Invalid Administrative Setup Token'));
    });

    test('Initial Admin creation SUCCEEDS with valid setup token', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final success = await authController.createInitialAdmin(
        email: 'principal@college.edu',
        password: 'AdminPassword123!',
        name: 'Principal Dr. Nair',
        adminSetupToken: 'SAPM_INITIAL_ADMIN_TOKEN_2026',
        department: 'Office of the Principal',
      );

      expect(success, isTrue);
      expect(authController.isAuthenticated, isTrue);
      expect(authController.isAdmin, isTrue);
      expect(authController.currentUser?.roleDisplay, equals('Administrator'));
    });

    test('Sign out clears session and sets currentUser to null', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      expect(authController.isAuthenticated, isTrue);

      await authController.logout();
      expect(authController.isAuthenticated, isFalse);
      expect(authController.currentUser, isNull);
    });

    test('UserModel Firestore serialization roundtrip', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'usr_test_100',
        email: 'test@college.edu',
        name: 'Test Student',
        role: 'student',
        department: 'Computer Science',
        studentId: '22CS999',
        status: 'active',
        createdAt: now,
      );

      final firestoreMap = user.toFirestore();
      expect(firestoreMap['uid'], equals('usr_test_100'));
      expect(firestoreMap['role'], equals('student'));
      expect(firestoreMap['studentId'], equals('22CS999'));

      final restored = UserModel.fromFirestore(firestoreMap, 'usr_test_100');
      expect(restored.id, equals('usr_test_100'));
      expect(restored.email, equals('test@college.edu'));
      expect(restored.isStudent, isTrue);
      expect(restored.studentId, equals('22CS999'));
    });
  });
}
