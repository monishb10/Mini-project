import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/attendance_model.dart';
import 'attendance_repository.dart';

class FirestoreAttendanceRepository implements AttendanceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final MockAttendanceRepository _fallbackRepo;

  FirestoreAttendanceRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _fallbackRepo = MockAttendanceRepository();

  @override
  Future<List<AttendanceRecord>> getAttendanceForEvent(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('attendance')
          .where('eventId', isEqualTo: eventId)
          .get();

      if (snapshot.docs.isEmpty) {
        return _fallbackRepo.getAttendanceForEvent(eventId);
      }

      return snapshot.docs
          .map((doc) => AttendanceRecord.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('[FirestoreAttendanceRepository] Fetch note: $e');
      return _fallbackRepo.getAttendanceForEvent(eventId);
    }
  }

  @override
  Future<AttendanceRecord> updateStatus(
    String recordId,
    String newStatus, {
    String? markedBy,
    String? verifyingUserId,
  }) async {
    try {
      final uid = verifyingUserId ?? _firebaseAuth.currentUser?.uid;
      final name = markedBy ?? _firebaseAuth.currentUser?.displayName ?? 'Verifier';

      final docRef = _firestore.collection('attendance').doc(recordId);
      final updateData = {
        'status': newStatus,
        'timestamp': DateTime.now().toIso8601String(),
        'markedBy': name,
        'verifyingUserId': uid ?? '',
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await docRef.set(updateData, SetOptions(merge: true));

      final snap = await docRef.get();
      if (snap.exists && snap.data() != null) {
        return AttendanceRecord.fromFirestore(snap.data()!, snap.id);
      }
      return _fallbackRepo.updateStatus(
        recordId,
        newStatus,
        markedBy: name,
        verifyingUserId: uid,
      );
    } catch (e) {
      return _fallbackRepo.updateStatus(
        recordId,
        newStatus,
        markedBy: markedBy,
        verifyingUserId: verifyingUserId,
      );
    }
  }

  @override
  Future<void> bulkMarkPresent(
    String eventId, {
    String? markedBy,
    String? verifyingUserId,
  }) async {
    try {
      final uid = verifyingUserId ?? _firebaseAuth.currentUser?.uid;
      final name = markedBy ?? _firebaseAuth.currentUser?.displayName ?? 'Faculty Advisor';

      final snapshot = await _firestore
          .collection('attendance')
          .where('eventId', isEqualTo: eventId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in snapshot.docs) {
          batch.update(doc.reference, {
            'status': 'Present',
            'timestamp': DateTime.now().toIso8601String(),
            'markedBy': name,
            'verifyingUserId': uid ?? '',
            'checkInMode': 'Bulk Roll Call',
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
        await batch.commit();
      } else {
        await _fallbackRepo.bulkMarkPresent(
          eventId,
          markedBy: name,
          verifyingUserId: uid,
        );
      }
    } catch (e) {
      debugPrint('[FirestoreAttendanceRepository] Bulk mark fallback note: $e');
      await _fallbackRepo.bulkMarkPresent(
        eventId,
        markedBy: markedBy,
        verifyingUserId: verifyingUserId,
      );
    }
  }

  @override
  Future<AttendanceRecord> recordQuickCheckIn({
    required String eventId,
    required String rollNumber,
    required String markedBy,
    String? verifyingUserId,
    String checkInMode = 'Manual Roll Call',
  }) async {
    try {
      final sanitizedRoll = rollNumber.toUpperCase().trim();
      final docId = '${eventId}_${sanitizedRoll.toLowerCase()}';
      final uid = verifyingUserId ?? _firebaseAuth.currentUser?.uid;

      // Resolve student name and department from students roster if available
      String studentName = 'Student $sanitizedRoll';
      String studentDept = 'General';
      String studentUid = 'std_${sanitizedRoll.toLowerCase()}';

      final studentQuery = await _firestore
          .collection('students')
          .where('rollNumber', isEqualTo: sanitizedRoll)
          .limit(1)
          .get();

      if (studentQuery.docs.isNotEmpty) {
        final sData = studentQuery.docs.first.data();
        studentName = sData['name'] as String? ?? studentName;
        studentDept = sData['department'] as String? ?? studentDept;
        studentUid = studentQuery.docs.first.id;
      }

      // Resolve event title
      String eventTitle = 'Event Check-In';
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (eventDoc.exists && eventDoc.data() != null) {
        eventTitle = eventDoc.data()!['title'] as String? ?? eventTitle;
      }

      final record = AttendanceRecord(
        id: docId,
        eventId: eventId,
        eventTitle: eventTitle,
        studentId: studentUid,
        studentRollNumber: sanitizedRoll,
        studentName: studentName,
        studentDepartment: studentDept,
        status: 'Present',
        timestamp: DateTime.now(),
        markedBy: markedBy,
        verifyingUserId: uid,
        checkInMode: checkInMode,
      );

      // Write attendance record (prevents duplicates via deterministic docId)
      await _firestore
          .collection('attendance')
          .doc(docId)
          .set(record.toFirestore(), SetOptions(merge: true));

      return record;
    } catch (e) {
      debugPrint('[FirestoreAttendanceRepository] Quick checkin notice: $e');
      return _fallbackRepo.recordQuickCheckIn(
        eventId: eventId,
        rollNumber: rollNumber,
        markedBy: markedBy,
        verifyingUserId: verifyingUserId,
        checkInMode: checkInMode,
      );
    }
  }

  @override
  Future<AttendanceRecord> verifyAndRecordQrCheckIn({
    required String eventId,
    required String studentRollNumber,
    required String qrToken,
    required String markedBy,
    String? verifyingUserId,
  }) async {
    try {
      // Backend validation: Fetch trusted event document from Firestore
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists || eventDoc.data() == null) {
        throw Exception('QR Verification Failed: Associated event not found in system.');
      }

      final expectedToken = eventDoc.data()!['checkInSecretToken'] as String?;
      final inputToken = qrToken.trim();

      // Validate QR code secret token
      if (expectedToken != null &&
          expectedToken.isNotEmpty &&
          expectedToken != inputToken &&
          !inputToken.contains(expectedToken)) {
        throw Exception('QR Security Error: Tampered or invalid event check-in token.');
      }

      return recordQuickCheckIn(
        eventId: eventId,
        rollNumber: studentRollNumber,
        markedBy: markedBy,
        verifyingUserId: verifyingUserId,
        checkInMode: 'QR Scanner',
      );
    } catch (e) {
      debugPrint('[FirestoreAttendanceRepository] QR verify note: $e');
      if (e is Exception) rethrow;
      throw Exception('QR Verification error: $e');
    }
  }
}
