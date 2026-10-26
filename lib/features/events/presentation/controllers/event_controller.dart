import 'package:flutter/material.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/event_model.dart';
import '../../data/models/registration_model.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/firestore_event_repository.dart';

class EventController extends ChangeNotifier {
  final EventRepository _repository;

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  String _selectedCategory = 'All Categories';
  String _selectedDepartment = 'All Departments';
  String _selectedStatus = 'All Statuses';
  String _searchQuery = '';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  EventController({EventRepository? repository})
      : _repository = repository ??
            (FirebaseService.isInitialized
                ? FirestoreEventRepository()
                : MockEventRepository()) {
    loadEvents();
  }

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  String get selectedCategory => _selectedCategory;
  String get selectedDepartment => _selectedDepartment;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;

  List<EventModel> get upcomingEvents =>
      _events.where((e) => e.status == 'Upcoming').toList();

  List<EventModel> get registeredEvents =>
      _events.where((e) => e.isRegistered).toList();

  int get totalEventsCount => _events.length;
  int get activeEventsCount => _events
      .where((e) => e.status == 'Upcoming' || e.status == 'Ongoing')
      .length;

  Future<void> loadEvents({String? currentUserId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _repository.getEvents(
        category: _selectedCategory,
        department: _selectedDepartment,
        status: _selectedStatus,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
        searchQuery: _searchQuery,
        currentUserId: currentUserId,
      );
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterCategory(String category) {
    _selectedCategory = category;
    loadEvents();
  }

  void filterDepartment(String department) {
    _selectedDepartment = department;
    loadEvents();
  }

  void filterStatus(String status) {
    _selectedStatus = status;
    loadEvents();
  }

  void filterDateRange(DateTime? start, DateTime? end) {
    _filterStartDate = start;
    _filterEndDate = end;
    loadEvents();
  }

  void search(String query) {
    _searchQuery = query;
    loadEvents();
  }

  Future<bool> addEvent(EventModel event, {String? organizerId}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final created = await _repository.addEvent(event, organizerId: organizerId);
      _successMessage = 'Event "${created.title}" successfully created.';
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent(EventModel event) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.updateEvent(event);
      _successMessage = 'Event "${event.title}" details updated successfully.';
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelEvent(String id, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.cancelEvent(id, reason: reason);
      _successMessage = 'Event has been officially cancelled.';
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.deleteEvent(id);
      _successMessage = 'Event removed from directory.';
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleRegistration(String eventId, {UserModel? student}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.toggleRegistration(eventId, student: student);
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _events[index] = updated;
      }
      _successMessage = updated.isRegistered
          ? 'Registration confirmed for "${updated.title}".'
          : 'Registration cancelled for "${updated.title}".';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerStudent({
    required String eventId,
    required UserModel student,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final reg = await _repository.registerStudent(
        eventId: eventId,
        student: student,
      );
      _successMessage = 'Successfully registered for "${reg.eventTitle}"!';
      await loadEvents(currentUserId: student.uid);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelStudentRegistration({
    required String eventId,
    required UserModel student,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.cancelStudentRegistration(
        eventId: eventId,
        student: student,
      );
      _successMessage = 'Registration cancelled.';
      await loadEvents(currentUserId: student.uid);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<RegistrationModel>> getEventRegistrations(String eventId) async {
    return _repository.getEventRegistrations(eventId);
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  String _cleanError(dynamic e) {
    String msg = e.toString();
    if (msg.startsWith('Exception: ')) {
      msg = msg.substring(11);
    }
    return msg;
  }
}
