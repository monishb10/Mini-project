import '../../../auth/data/models/user_model.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';

abstract class EventRepository {
  Future<List<EventModel>> getEvents({
    String? category,
    String? department,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? currentUserId,
  });
  Future<EventModel?> getEventById(String id);
  Future<EventModel> addEvent(EventModel event, {String? organizerId});
  Future<EventModel> updateEvent(EventModel event);
  Future<EventModel> cancelEvent(String id, {String? reason});
  Future<void> deleteEvent(String id);
  Future<EventModel> toggleRegistration(String eventId, {UserModel? student});
  Future<RegistrationModel> registerStudent({
    required String eventId,
    required UserModel student,
  });
  Future<void> cancelStudentRegistration({
    required String eventId,
    required UserModel student,
  });
  Future<List<RegistrationModel>> getEventRegistrations(String eventId);
}

class MockEventRepository implements EventRepository {
  final List<EventModel> _events = [
    EventModel(
      id: 'evt_01',
      title: 'National Hackathon 2026: CodeSpark',
      description:
          '36-hour non-stop collegiate hackathon solving real-world challenges in healthcare, fintech, and green energy.',
      category: 'Technical',
      venue: 'Auditorium Complex & Innovation Hub',
      organizerDepartment: 'Computer Science & Engineering',
      dateTime: DateTime.now().add(const Duration(days: 4, hours: 3)),
      endDate: DateTime.now().add(const Duration(days: 5, hours: 15)),
      registrationDeadline: DateTime.now().add(const Duration(days: 3)),
      durationHours: 36.0,
      capacity: 150,
      registeredCount: 142,
      activityPoints: 50,
      status: 'Upcoming',
      coordinatorName: 'Dr. Sarah Mitchell',
      checkInSecretToken: 'CHK_CODESPARK_2026',
      isRegistered: true,
    ),
    EventModel(
      id: 'evt_02',
      title: 'Flutter & Cloud Native Bootcamp',
      description:
          'Hands-on architectural workshop building reactive multi-platform web & mobile applications with Firebase integration.',
      category: 'Workshop',
      venue: 'CS Seminar Hall 2',
      organizerDepartment: 'Information Technology',
      dateTime: DateTime.now().add(const Duration(days: 8, hours: 2)),
      endDate: DateTime.now().add(const Duration(days: 8, hours: 8)),
      registrationDeadline: DateTime.now().add(const Duration(days: 7)),
      durationHours: 6.0,
      capacity: 80,
      registeredCount: 65,
      activityPoints: 25,
      status: 'Upcoming',
      coordinatorName: 'Prof. Rajesh Sharma',
      checkInSecretToken: 'CHK_BOOTCAMP_2026',
      isRegistered: false,
    ),
    EventModel(
      id: 'evt_03',
      title: 'Annual Inter-College Cultural Fest: Resonance',
      description:
          'Flagship cultural celebration featuring dance, battle of bands, theatricals, and fine arts competitions.',
      category: 'Cultural',
      venue: 'Main Open Air Theatre (OAT)',
      organizerDepartment: 'Electronics & Communication',
      dateTime: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 16)),
      registrationDeadline: DateTime.now().add(const Duration(days: 12)),
      durationHours: 24.0,
      capacity: 350,
      registeredCount: 310,
      activityPoints: 30,
      status: 'Upcoming',
      coordinatorName: 'Dr. Anita Roy',
      checkInSecretToken: 'CHK_RESONANCE_2026',
      isRegistered: false,
    ),
    EventModel(
      id: 'evt_04',
      title: 'Inter-Department Sports Meet: Khel Utsav',
      description:
          'Intra-collegiate athletics, cricket, football, basketball, and badminton tournament.',
      category: 'Sports',
      venue: 'College Sports Grounds & Indoor Arena',
      organizerDepartment: 'Mechanical Engineering',
      dateTime: DateTime.now().add(const Duration(days: 18)),
      endDate: DateTime.now().add(const Duration(days: 20)),
      registrationDeadline: DateTime.now().add(const Duration(days: 15)),
      durationHours: 48.0,
      capacity: 200,
      registeredCount: 185,
      activityPoints: 35,
      status: 'Upcoming',
      coordinatorName: 'Prof. Suresh Patil',
      checkInSecretToken: 'CHK_SPORTS_2026',
      isRegistered: true,
    ),
    EventModel(
      id: 'evt_05',
      title: 'AI in Healthcare & Drug Discovery Symposium',
      description:
          'Industry keynotes and research paper presentations on neural networks in medical diagnostics.',
      category: 'Seminar',
      venue: 'Management Auditorium',
      organizerDepartment: 'Artificial Intelligence & Data Science',
      dateTime: DateTime.now().add(const Duration(days: 22)),
      endDate: DateTime.now().add(const Duration(days: 22, hours: 6)),
      registrationDeadline: DateTime.now().add(const Duration(days: 20)),
      durationHours: 5.0,
      capacity: 100,
      registeredCount: 42,
      activityPoints: 20,
      status: 'Upcoming',
      coordinatorName: 'Dr. Vikram Chandra',
      checkInSecretToken: 'CHK_AIHEALTH_2026',
      isRegistered: false,
    ),
    EventModel(
      id: 'evt_06',
      title: 'Youth Clean-Up Drive & Lake Rejuvenation',
      description:
          'Community eco-volunteering and sapling plantation initiative around the campus lake.',
      category: 'Social Service',
      venue: 'North Campus Lake & Eco Park',
      organizerDepartment: 'Civil Engineering',
      dateTime: DateTime.now().add(const Duration(days: 26)),
      endDate: DateTime.now().add(const Duration(days: 26, hours: 4)),
      registrationDeadline: DateTime.now().add(const Duration(days: 25)),
      durationHours: 4.0,
      capacity: 120,
      registeredCount: 94,
      activityPoints: 30,
      status: 'Upcoming',
      coordinatorName: 'Prof. Meenakshi Sundaram',
      checkInSecretToken: 'CHK_ECODRIVE_2026',
      isRegistered: false,
    ),
  ];

  final List<RegistrationModel> _registrations = [];

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
    await Future.delayed(const Duration(milliseconds: 100));
    var results = List<EventModel>.from(_events);

    if (category != null && category != 'All' && category != 'All Categories' && category.isNotEmpty) {
      results = results.where((e) => e.category.toLowerCase().contains(category.toLowerCase())).toList();
    }
    if (department != null && department != 'All' && department != 'All Departments' && department.isNotEmpty) {
      results = results.where((e) => e.organizerDepartment == department).toList();
    }
    if (status != null && status != 'All' && status != 'All Statuses' && status.isNotEmpty) {
      results = results.where((e) => e.status.toLowerCase() == status.toLowerCase()).toList();
    }
    if (startDate != null) {
      results = results.where((e) => e.dateTime.isAfter(startDate) || e.dateTime.isAtSameMomentAs(startDate)).toList();
    }
    if (endDate != null) {
      results = results.where((e) => e.dateTime.isBefore(endDate) || e.dateTime.isAtSameMomentAs(endDate)).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      results = results
          .where(
            (e) =>
                e.title.toLowerCase().contains(q) ||
                e.description.toLowerCase().contains(q) ||
                e.venue.toLowerCase().contains(q) ||
                e.category.toLowerCase().contains(q),
          )
          .toList();
    }

    return results;
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    await Future.delayed(const Duration(milliseconds: 80));
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<EventModel> addEvent(EventModel event, {String? organizerId}) async {
    await Future.delayed(const Duration(milliseconds: 250));

    // Validate capacity
    if (event.capacity <= 0) {
      throw Exception('Validation Error: Event capacity must be greater than zero.');
    }

    // Validate dates
    if (event.effectiveEndDate.isBefore(event.dateTime)) {
      throw Exception('Validation Error: End date cannot be earlier than start date.');
    }

    // Validate registration deadline
    if (event.effectiveRegistrationDeadline.isAfter(event.dateTime)) {
      throw Exception('Validation Error: Registration deadline cannot be after the event start date.');
    }

    final newEvent = event.copyWith(
      id: event.id.isNotEmpty ? event.id : 'evt_${DateTime.now().millisecondsSinceEpoch}',
      organizerId: organizerId ?? 'org_admin',
      checkInSecretToken: 'CHK_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _events.insert(0, newEvent);
    return newEvent;
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    await Future.delayed(const Duration(milliseconds: 250));

    if (event.capacity <= 0) {
      throw Exception('Validation Error: Event capacity must be greater than zero.');
    }

    if (event.effectiveEndDate.isBefore(event.dateTime)) {
      throw Exception('Validation Error: End date cannot be earlier than start date.');
    }

    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      return event;
    }
    throw Exception('Event with id ${event.id} not found.');
  }

  @override
  Future<EventModel> cancelEvent(String id, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      final cancelled = _events[index].copyWith(status: 'Cancelled');
      _events[index] = cancelled;
      return cancelled;
    }
    throw Exception('Event with id $id not found.');
  }

  @override
  Future<void> deleteEvent(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _events.removeWhere((e) => e.id == id);
  }

  @override
  Future<EventModel> toggleRegistration(String eventId, {UserModel? student}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final current = _events[index];
      final newStatus = !current.isRegistered;

      // Backend capacity check on registration
      if (newStatus && current.registeredCount >= current.capacity) {
        throw Exception('Registration Error: Event is already at maximum capacity (${current.capacity} seats).');
      }

      // Backend deadline check
      if (newStatus && current.isRegistrationClosed) {
        throw Exception('Registration Error: Registration deadline has passed for this event.');
      }

      final updated = current.copyWith(
        isRegistered: newStatus,
        registeredCount: newStatus
            ? current.registeredCount + 1
            : (current.registeredCount > 0 ? current.registeredCount - 1 : 0),
      );
      _events[index] = updated;
      return updated;
    }
    throw Exception('Event with id $eventId not found.');
  }

  @override
  Future<RegistrationModel> registerStudent({
    required String eventId,
    required UserModel student,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final eventIndex = _events.indexWhere((e) => e.id == eventId);
    if (eventIndex == -1) {
      throw Exception('Event not found.');
    }

    final event = _events[eventIndex];

    // 1. Check Deadline
    if (event.isRegistrationClosed) {
      throw Exception('Registration Error: Registration deadline for "${event.title}" has passed.');
    }

    // 2. Check Capacity
    if (event.registeredCount >= event.capacity) {
      throw Exception('Registration Error: Event "${event.title}" is full (Capacity: ${event.capacity}).');
    }

    // 3. Check Duplicate Registration
    final duplicate = _registrations.any(
      (r) => r.eventId == eventId && r.studentId == student.uid && r.isRegistered,
    );
    if (duplicate) {
      throw Exception('Duplicate Registration: You are already registered for this event.');
    }

    final reg = RegistrationModel(
      id: '${eventId}_${student.uid}',
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

    _registrations.add(reg);
    _events[eventIndex] = event.copyWith(
      registeredCount: event.registeredCount + 1,
      isRegistered: true,
    );

    return reg;
  }

  @override
  Future<void> cancelStudentRegistration({
    required String eventId,
    required UserModel student,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final eventIndex = _events.indexWhere((e) => e.id == eventId);
    if (eventIndex == -1) {
      throw Exception('Event not found.');
    }

    final regIndex = _registrations.indexWhere(
      (r) => r.eventId == eventId && r.studentId == student.uid && r.isRegistered,
    );

    if (regIndex != -1) {
      _registrations[regIndex] = _registrations[regIndex].copyWith(
        status: 'cancelled',
        cancelledAt: DateTime.now(),
      );
    }

    final event = _events[eventIndex];
    _events[eventIndex] = event.copyWith(
      registeredCount: event.registeredCount > 0 ? event.registeredCount - 1 : 0,
      isRegistered: false,
    );
  }

  @override
  Future<List<RegistrationModel>> getEventRegistrations(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _registrations.where((r) => r.eventId == eventId && r.isRegistered).toList();
  }
}
