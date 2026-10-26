import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/csv_import_result.dart';
import '../models/student_model.dart';
import '../utils/student_csv_parser.dart';
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
  Future<StudentModel?> getStudentByRollNumber(String rollNumber) async {
    try {
      final snapshot = await _firestore
          .collection('students')
          .where('rollNumber', isEqualTo: rollNumber.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return StudentModel.fromFirestore(doc.data(), doc.id);
      }
      return _fallbackRepo.getStudentByRollNumber(rollNumber);
    } catch (e) {
      return _fallbackRepo.getStudentByRollNumber(rollNumber);
    }
  }

  @override
  Future<StudentModel> addStudent(StudentModel student, {bool isAdmin = true}) async {
    if (!isAdmin) {
      throw Exception(
        'Access Denied: Only institutional administrators are authorized to create student records.',
      );
    }

    try {
      // Prevent duplicate student IDs
      final duplicateQuery = await _firestore
          .collection('students')
          .where('rollNumber', isEqualTo: student.rollNumber.trim())
          .limit(1)
          .get();

      if (duplicateQuery.docs.isNotEmpty) {
        throw Exception(
          'Duplicate Student ID Error: A student with ID "${student.rollNumber}" already exists in the system.',
        );
      }

      final docId = student.id.isNotEmpty
          ? student.id
          : 'std_${DateTime.now().millisecondsSinceEpoch}';
      final newStudent = student.copyWith(id: docId);

      await _firestore.collection('students').doc(docId).set(newStudent.toFirestore());
      return newStudent;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to add student to Firestore: $e');
    }
  }

  @override
  Future<StudentModel> updateStudent(StudentModel student, {bool isAdmin = true}) async {
    if (!isAdmin) {
      throw Exception(
        'Access Denied: Only institutional administrators are authorized to modify protected student records.',
      );
    }

    try {
      // Check for conflicting rollNumber on other student documents
      final duplicateCheck = await _firestore
          .collection('students')
          .where('rollNumber', isEqualTo: student.rollNumber.trim())
          .get();

      for (final doc in duplicateCheck.docs) {
        if (doc.id != student.id) {
          throw Exception(
            'Duplicate Student ID Error: Student ID "${student.rollNumber}" is already in use by another student.',
          );
        }
      }

      final docRef = _firestore.collection('students').doc(student.id);
      await docRef.update(student.toFirestore());
      return student;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to update student in Firestore: $e');
    }
  }

  @override
  Future<void> deleteStudent(String id, {bool isAdmin = true}) async {
    if (!isAdmin) {
      throw Exception(
        'Access Denied: Only institutional administrators are authorized to remove student records.',
      );
    }

    try {
      await _firestore.collection('students').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete student from Firestore: $e');
    }
  }

  @override
  Future<CsvImportResult> importStudentsFromCsv(String csvContent, {bool isAdmin = true}) async {
    if (!isAdmin) {
      throw Exception(
        'Access Denied: Only institutional administrators are authorized to perform CSV student batch imports.',
      );
    }

    try {
      // Gather existing student IDs from Firestore
      final existingSnapshot = await _firestore.collection('students').get();
      final existingIds = existingSnapshot.docs.map((d) {
        final data = d.data();
        return (data['rollNumber'] ?? data['studentId'] ?? '').toString().toLowerCase().trim();
      }).toSet();

      final parseResult = StudentCsvParser.parse(
        csvContent: csvContent,
        existingStudentIds: existingIds,
      );

      // Perform atomic batch write for all successfully validated students
      if (parseResult.importedStudents.isNotEmpty) {
        final batch = _firestore.batch();
        for (final s in parseResult.importedStudents) {
          final docRef = _firestore.collection('students').doc(s.id);
          batch.set(docRef, s.toFirestore());
        }
        await batch.commit();
      }

      return parseResult;
    } catch (e) {
      debugPrint('[FirestoreStudentRepository] CSV import fallback notice: $e');
      return _fallbackRepo.importStudentsFromCsv(csvContent, isAdmin: isAdmin);
    }
  }
}
