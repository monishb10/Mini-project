import '../models/event_model.dart';

abstract class EventRepository {
  Future<List<EventModel>> getEvents({
    String? category,
    String? status,
    String? searchQuery,
  });
  Future<EventModel?> getEventById(String id);
  Future<EventModel> addEvent(EventModel event);
  Future<EventModel> updateEvent(EventModel event);
  Future<void> deleteEvent(String id);
  Future<EventModel> toggleRegistration(String eventId);
}

class MockEventRepository implements EventRepository {
  final List<EventModel> _events = [
    EventModel(
      id: 'evt_01',
      title: 'National Hackathon 2026: CodeSpark',
      description:
          '36-hour non-stop collegiate hackathon solving real-world challenges in healthcare, fintech, and green energy.',
      category: 'Hackathons & Ideathons',
      venue: 'Auditorium Complex & Innovation Hub',
      organizerDepartment: 'Computer Science & Engineering',
      dateTime: DateTime.now().add(const Duration(days: 4, hours: 3)),
      durationHours: 36.0,
      capacity: 150,
      registeredCount: 142,
      activityPoints: 50,
      status: 'Upcoming',
      coordinatorName: 'Dr. Sarah Mitchell',
      isRegistered: true,
    ),
    EventModel(
      id: 'evt_02',
      title: 'Flutter & Cloud Native Bootcamp',
      description:
          'Hands-on architectural workshop building reactive multi-platform web & mobile applications with Firebase integration.',
      category: 'Workshops & Seminars',
      venue: 'CS Seminar Hall 2',
      organizerDepartment: 'Information Technology',
      dateTime: DateTime.now().add(const Duration(days: 8, hours: 2)),
      durationHours: 6.0,
      capacity: 80,
      registeredCount: 65,
      activityPoints: 25,
      status: 'Upcoming',
      coordinatorName: 'Prof. Rajesh Sharma',
      isRegistered: false,
    ),
    EventModel(
      id: 'evt_03',
      title: 'Annual Inter-College Cultural Fest: Resonance',
      description:
          'Flagship cultural celebration featuring dance, battle of bands, theatricals, and fine arts competitions.',
      category: 'Cultural & Arts',
      venue: 'Main Open Air Theatre (OAT)',
      organizerDepartment: 'Electronics & Communication',
      dateTime: DateTime.now().add(const Duration(days: 14)),
      durationHours: 16.0,
      capacity: 500,
      registeredCount: 380,
      activityPoints: 30,
      status: 'Upcoming',
      coordinatorName: 'Prof. Anjali Gupta',
      isRegistered: false,
    ),
    EventModel(
      id: 'evt_04',
      title: 'AI & Machine Learning Research Symposium',
      description:
          'Keynotes by industry experts from Google DeepMind and Microsoft Research on Generative AI and Pattern Mining.',
      category: 'Technical & Coding',
      venue: 'Conference Hall A',
      organizerDepartment: 'Computer Science & Engineering',
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      durationHours: 8.0,
      capacity: 120,
      registeredCount: 118,
      activityPoints: 35,
      status: 'Completed',
      coordinatorName: 'Dr. Sarah Mitchell',
      isRegistered: true,
    ),
    EventModel(
      id: 'evt_05',
      title: 'Annual Sports Meet: Athlos 2026',
      description:
          'Inter-department athletic games: track & field, basketball, badminton, football, and chess.',
      category: 'Sports & Athletics',
      venue: 'University Sports Complex',
      organizerDepartment: 'Mechanical Engineering',
      dateTime: DateTime.now().add(const Duration(days: 20)),
      durationHours: 24.0,
      capacity: 300,
      registeredCount: 210,
      activityPoints: 25,
      status: 'Upcoming',
      coordinatorName: 'Coach K. Verma',
      isRegistered: false,
    ),
    EventModel(
      id: 'evt_06',
      title: 'Clean Campus & Green Energy Drive',
      description:
          'Solar awareness workshop followed by community tree plantation and recycling drive.',
      category: 'Social & Community Outreach',
      venue: 'Campus Grounds & Quadrangle',
      organizerDepartment: 'Civil Engineering',
      dateTime: DateTime.now().subtract(const Duration(days: 10)),
      durationHours: 4.0,
      capacity: 100,
      registeredCount: 94,
      activityPoints: 20,
      status: 'Completed',
      coordinatorName: 'Prof. Suresh Nair',
      isRegistered: true,
    ),
    EventModel(
      id: 'evt_07',
      title: 'Cybersecurity Defense & CTF Challenge',
      description:
          'Capture-the-flag competition on web vulnerabilities, binary exploitation, and cloud security.',
      category: 'Technical & Coding',
      venue: 'Virtual & Computing Lab 4',
      organizerDepartment: 'Information Technology',
      dateTime: DateTime.now().add(const Duration(hours: 5)),
      durationHours: 5.0,
      capacity: 90,
      registeredCount: 88,
      activityPoints: 30,
      status: 'Ongoing',
      coordinatorName: 'Prof. Rajesh Sharma',
      isRegistered: false,
    ),
  ];

  @override
  Future<List<EventModel>> getEvents({
    String? category,
    String? status,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    var results = List<EventModel>.from(_events);

    if (category != null && category != 'All Categories') {
      results = results.where((e) => e.category == category).toList();
    }
    if (status != null && status != 'All Statuses') {
      results = results.where((e) => e.status == status).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      results = results
          .where(
            (e) =>
                e.title.toLowerCase().contains(q) ||
                e.description.toLowerCase().contains(q) ||
                e.venue.toLowerCase().contains(q) ||
                e.organizerDepartment.toLowerCase().contains(q),
          )
          .toList();
    }

    return results;
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<EventModel> addEvent(EventModel event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newEvent = event.copyWith(
      id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
    );
    _events.insert(0, newEvent);
    return newEvent;
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      return event;
    }
    throw Exception('Event with id ${event.id} not found');
  }

  @override
  Future<void> deleteEvent(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _events.removeWhere((e) => e.id == id);
  }

  @override
  Future<EventModel> toggleRegistration(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final current = _events[index];
      final newStatus = !current.isRegistered;
      final updated = current.copyWith(
        isRegistered: newStatus,
        registeredCount: newStatus
            ? current.registeredCount + 1
            : (current.registeredCount > 0 ? current.registeredCount - 1 : 0),
      );
      _events[index] = updated;
      return updated;
    }
    throw Exception('Event with id $eventId not found');
  }
}
