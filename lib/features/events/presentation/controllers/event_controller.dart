import 'package:flutter/material.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

class EventController extends ChangeNotifier {
  final EventRepository _repository;

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedCategory = 'All Categories';
  String _selectedStatus = 'All Statuses';
  String _searchQuery = '';

  EventController({EventRepository? repository})
    : _repository = repository ?? MockEventRepository() {
    loadEvents();
  }

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedCategory => _selectedCategory;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  List<EventModel> get upcomingEvents =>
      _events.where((e) => e.status == 'Upcoming').toList();

  List<EventModel> get registeredEvents =>
      _events.where((e) => e.isRegistered).toList();

  int get totalEventsCount => _events.length;
  int get activeEventsCount => _events
      .where((e) => e.status == 'Upcoming' || e.status == 'Ongoing')
      .length;

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _repository.getEvents(
        category: _selectedCategory,
        status: _selectedStatus,
        searchQuery: _searchQuery,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterCategory(String category) {
    _selectedCategory = category;
    loadEvents();
  }

  void filterStatus(String status) {
    _selectedStatus = status;
    loadEvents();
  }

  void search(String query) {
    _searchQuery = query;
    loadEvents();
  }

  Future<bool> addEvent(EventModel event) async {
    try {
      await _repository.addEvent(event);
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent(EventModel event) async {
    try {
      await _repository.updateEvent(event);
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      await _repository.deleteEvent(id);
      await loadEvents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleRegistration(String eventId) async {
    try {
      final updated = await _repository.toggleRegistration(eventId);
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _events[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
