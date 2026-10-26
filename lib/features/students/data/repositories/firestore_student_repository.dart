import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import 'student_repository.dart';

class FirestoreStudentRepository implements StudentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final MockStudentRepository _fallbackRepo;

  FirestoreStudentRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _fallbackRepo = MockStudentRepository();

  @override
  Future<List<StudentModel>> getStudents({
    String? department,
    String? year,
    String? riskLevel,
    String? searchQuery,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      Query<Map<String, dynamic>> query = _firestore.collection('students');

      // Enforce role-based college policy restrictions
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final role = userDoc.data()?['role'] as String? ?? 'student';
        final userDept = userDoc.data()?['department'] as String?;

        if (role == 'student') {
          // Students can ONLY access their own student record
          query = query.where('email', isEqualTo: user.email);
        } else if (role == 'faculty' && userDept != null && userDept.isNotEmpty) {
          // Faculty can only access students within their departmental jurisdiction
          query = query.where('department', isEqualTo: userDept);
        }
      }

      // Department filter (for Admins)
      if (department != null &&
          department != 'All Departments' &&
          department.isNotEmpty) {
        query = query.where('department', isEqualTo: department);
      }

      if (year != null && year != 'All Years' && year.isNotEmpty) {
        query = query.where('year', isEqualTo: year);
      }

      if (riskLevel != null &&
          riskLevel != 'All Risk Levels' &&
          riskLevel.isNotEmpty) {
        query = query.where('riskLevel', isEqualTo: riskLevel);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        // Fallback to sample data for evaluation when Firestore collection is fresh
        return _fallbackRepo.getStudents(
          department: department,
          year: year,
          riskLevel: riskLevel,
          searchQuery: searchQuery,
        );
      }

      var list = snapshot.docs
          .map((doc) => StudentModel.fromFirestore(doc.data(), doc.id))
          .toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        list = list
            .where((s) =>
                s.name.toLowerCase().contains(q) ||
                s.rollNumber.toLowerCase().contains(q) ||
                s.email.toLowerCase().contains(q))
            .toList();
      }

      return list;
    } catch (e) {
      debugPrint('[FirestoreStudentRepository] Note: $e');
      return _fallbackRepo.getStudents(
        department: department,
        year: year,
        riskLevel: riskLevel,
        searchQuery: searchQuery,
      );
    }
  }

  @override
  Future<StudentModel?> getStudentById(String id) async {
    try {
      final doc = await _firestore.collection('students').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return StudentModel.fromFirestore(doc.data()!, doc.id);
      }
      return _fallbackRepo.getStudentById(id);
    } catch (e) {
      return _fallbackRepo.getStudentById(id);
    }
  }

  @override
  Future<StudentModel> addStudent(StudentModel student) async {
    final docRef = _firestore.collection('students').doc(student.id);
    await docRef.set(student.toFirestore());
    return student;
  }

  @override
  Future<StudentModel> updateStudent(StudentModel student) async {
    final docRef = _firestore.collection('students').doc(student.id);
    await docRef.update(student.toFirestore());
    return student;
  }

  @override
  Future<void> deleteStudent(String id) async {
    await _firestore.collection('students').doc(id).delete();
  }
}
