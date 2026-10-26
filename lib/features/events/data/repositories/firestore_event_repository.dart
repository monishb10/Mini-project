import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';
import 'event_repository.dart';

class FirestoreEventRepository implements EventRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final MockEventRepository _fallbackRepo;

  FirestoreEventRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _fallbackRepo = MockEventRepository();

  @override
  Future<List<EventModel>> getEvents({
    String? category,
    String? department,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? currentUserId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('events');

      if (category != null &&
          category != 'All' &&
          category != 'All Categories' &&
          category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (department != null &&
          department != 'All' &&
          department != 'All Departments' &&
          department.isNotEmpty) {
        query = query.where('department', isEqualTo: department);
      }

      if (status != null &&
          status != 'All' &&
          status != 'All Statuses' &&
          status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        return _fallbackRepo.getEvents(
          category: category,
          department: department,
          status: status,
          startDate: startDate,
          endDate: endDate,
          searchQuery: searchQuery,
          currentUserId: currentUserId,
        );
      }

      // Check current user registrations for isRegistered flag
      final uid = currentUserId ?? _firebaseAuth.currentUser?.uid;
      final Set<String> registeredEventIds = {};
      if (uid != null) {
        try {
          final regSnapshot = await _firestore
              .collection('registrations')
              .where('studentId', isEqualTo: uid)
              .where('status', isEqualTo: 'registered')
              .get();
          for (final doc in regSnapshot.docs) {
            final eId = doc.data()['eventId'] as String?;
            if (eId != null) registeredEventIds.add(eId);
          }
        } catch (e) {
          debugPrint('[FirestoreEventRepository] Registrations check notice: $e');
        }
      }

      var list = snapshot.docs.map((doc) {
        final isReg = registeredEventIds.contains(doc.id);
        return EventModel.fromFirestore(
          doc.data(),
          doc.id,
          isRegisteredForCurrentUser: isReg,
        );
      }).toList();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        list = list
            .where((e) =>
                e.title.toLowerCase().contains(q) ||
                e.description.toLowerCase().contains(q) ||
                e.venue.toLowerCase().contains(q) ||
                e.category.toLowerCase().contains(q))
            .toList();
      }

      return list;
    } catch (e) {
      debugPrint('[FirestoreEventRepository] Note: $e');
      return _fallbackRepo.getEvents(
        category: category,
        department: department,
        status: status,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
        currentUserId: currentUserId,
      );
    }
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    try {
      final doc = await _firestore.collection('events').doc(id).get();
      if (doc.exists && doc.data() != null) {
        final uid = _firebaseAuth.currentUser?.uid;
        bool isReg = false;
        if (uid != null) {
          final regDoc = await _firestore
              .collection('registrations')
              .doc('${id}_$uid')
              .get();
          isReg = regDoc.exists && regDoc.data()?['status'] == 'registered';
        }
        return EventModel.fromFirestore(
          doc.data()!,
          doc.id,
          isRegisteredForCurrentUser: isReg,
        );
      }
      return _fallbackRepo.getEventById(id);
    } catch (e) {
      return _fallbackRepo.getEventById(id);
    }
  }

  @override
  Future<EventModel> addEvent(EventModel event, {String? organizerId}) async {
    // 1. Capacity validation
    if (event.capacity <= 0) {
      throw Exception('Validation Error: Event capacity must be greater than zero.');
    }

    // 2. Dates validation
    if (event.effectiveEndDate.isBefore(event.dateTime)) {
      throw Exception('Validation Error: End date cannot be earlier than start date.');
    }

    // 3. Deadline validation
    if (event.effectiveRegistrationDeadline.isAfter(event.dateTime)) {
      throw Exception('Validation Error: Registration deadline cannot be after the event start date.');
    }

    try {
      final uid = organizerId ?? _firebaseAuth.currentUser?.uid ?? 'org_admin';
      final docId = event.id.isNotEmpty
          ? event.id
          : 'evt_${DateTime.now().millisecondsSinceEpoch}';
      final secretToken = 'CHK_${DateTime.now().millisecondsSinceEpoch}_${docId.toUpperCase()}';

      final newEvent = event.copyWith(
        id: docId,
        organizerId: uid,
        checkInSecretToken: secretToken,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('events').doc(docId).set(newEvent.toFirestore());
      return newEvent;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to add event to Firestore: $e');
    }
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    if (event.capacity <= 0) {
      throw Exception('Validation Error: Event capacity must be greater than zero.');
    }

    if (event.effectiveEndDate.isBefore(event.dateTime)) {
      throw Exception('Validation Error: End date cannot be earlier than start date.');
    }

    try {
      final docRef = _firestore.collection('events').doc(event.id);
      await docRef.update(event.toFirestore());
      return event;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to update event in Firestore: $e');
    }
  }

  @override
  Future<EventModel> cancelEvent(String id, {String? reason}) async {
    try {
      final docRef = _firestore.collection('events').doc(id);
      await docRef.update({
        'status': 'Cancelled',
        'cancellationReason': reason ?? 'Cancelled by coordinator/administrator',
        'updatedAt': DateTime.now().toIso8601String(),
      });
      final updated = await getEventById(id);
      return updated ?? _fallbackRepo.cancelEvent(id, reason: reason);
    } catch (e) {
      return _fallbackRepo.cancelEvent(id, reason: reason);
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await _firestore.collection('events').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  @override
  Future<EventModel> toggleRegistration(String eventId, {UserModel? student}) async {
    final user = student ??
        UserModel(
          id: _firebaseAuth.currentUser?.uid ?? 'std_demo',
          email: _firebaseAuth.currentUser?.email ?? 'demo@college.edu',
          name: _firebaseAuth.currentUser?.displayName ?? 'Demo Student',
          role: 'student',
          createdAt: DateTime.now(),
        );

    final event = await getEventById(eventId);
    if (event == null) throw Exception('Event not found.');

    if (event.isRegistered) {
      await cancelStudentRegistration(eventId: eventId, student: user);
      return event.copyWith(
        isRegistered: false,
        registeredCount: event.registeredCount > 0 ? event.registeredCount - 1 : 0,
      );
    } else {
      await registerStudent(eventId: eventId, student: user);
      return event.copyWith(
        isRegistered: true,
        registeredCount: event.registeredCount + 1,
      );
    }
  }

  @override
  Future<RegistrationModel> registerStudent({
    required String eventId,
    required UserModel student,
  }) async {
    try {
      final eventRef = _firestore.collection('events').doc(eventId);
      final regId = '${eventId}_${student.uid}';
      final regRef = _firestore.collection('registrations').doc(regId);

      return await _firestore.runTransaction((transaction) async {
        final eventSnap = await transaction.get(eventRef);
        if (!eventSnap.exists || eventSnap.data() == null) {
          throw Exception('Event not found.');
        }

        final eventData = eventSnap.data()!;
        final event = EventModel.fromFirestore(eventData, eventSnap.id);

        // 1. Check Event Status
        if (event.status != 'Upcoming') {
          throw Exception('Registration Error: This event is marked as "${event.status}" and is not open for registration.');
        }

        // 2. Check Deadline
        if (event.isRegistrationClosed) {
          throw Exception('Registration Error: The registration deadline for this event has passed.');
        }

        // 3. Check Capacity
        if (event.registeredCount >= event.capacity) {
          throw Exception('Registration Error: This event has reached full capacity (${event.capacity} seats).');
        }

        // 4. Check Duplicate Registration
        final regSnap = await transaction.get(regRef);
        if (regSnap.exists && regSnap.data()?['status'] == 'registered') {
          throw Exception('Duplicate Registration: You are already registered for this event.');
        }

        final newReg = RegistrationModel(
          id: regId,
          eventId: eventId,
          eventTitle: event.title,
          studentId: student.uid,
          studentRollNumber: student.studentId ?? student.uid,
          studentName: student.name,
          studentEmail: student.email,
          studentDepartment: student.department ?? 'General',
          status: 'registered',
          registeredAt: DateTime.now(),
        );

        transaction.set(regRef, newReg.toFirestore(), SetOptions(merge: true));
        transaction.update(eventRef, {
          'registeredCount': FieldValue.increment(1),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        return newReg;
      });
    } catch (e) {
      debugPrint('[FirestoreEventRepository] Registration transaction notice: $e');
      if (e is Exception) rethrow;
      throw Exception('Registration transaction failed: $e');
    }
  }

  @override
  Future<void> cancelStudentRegistration({
    required String eventId,
    required UserModel student,
  }) async {
    try {
      final eventRef = _firestore.collection('events').doc(eventId);
      final regId = '${eventId}_${student.uid}';
      final regRef = _firestore.collection('registrations').doc(regId);

      await _firestore.runTransaction((transaction) async {
        final regSnap = await transaction.get(regRef);
        if (!regSnap.exists || regSnap.data()?['status'] != 'registered') {
          return; // Already cancelled or not registered
        }

        transaction.update(regRef, {
          'status': 'cancelled',
          'cancelledAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        transaction.update(eventRef, {
          'registeredCount': FieldValue.increment(-1),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      debugPrint('[FirestoreEventRepository] Cancel registration notice: $e');
      if (e is Exception) rethrow;
      throw Exception('Cancellation failed: $e');
    }
  }

  @override
  Future<List<RegistrationModel>> getEventRegistrations(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('registrations')
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'registered')
          .get();

      return snapshot.docs
          .map((doc) => RegistrationModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return _fallbackRepo.getEventRegistrations(eventId);
    }
  }
}
