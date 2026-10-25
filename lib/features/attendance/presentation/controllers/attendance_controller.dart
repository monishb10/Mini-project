import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';

class AttendanceController extends ChangeNotifier {
  final AttendanceRepository _repository;

  List<AttendanceRecord> _records = [];
  String _selectedEventId = 'evt_01';
  bool _isLoading = false;
  String? _errorMessage;

  AttendanceController({AttendanceRepository? repository})
    : _repository = repository ?? MockAttendanceRepository() {
    loadAttendance(_selectedEventId);
  }

  List<AttendanceRecord> get records => _records;
  String get selectedEventId => _selectedEventId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get presentCount => _records.where((r) => r.status == 'Present').length;
  int get absentCount => _records.where((r) => r.status == 'Absent').length;
  int get excusedCount => _records.where((r) => r.status == 'Excused').length;
  int get totalRecords => _records.length;

  double get attendancePercentage =>
      totalRecords == 0 ? 0.0 : (presentCount / totalRecords) * 100;

  Future<void> loadAttendance(String eventId) async {
    _selectedEventId = eventId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _records = await _repository.getAttendanceForEvent(eventId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(String recordId, String newStatus) async {
    try {
      final updated = await _repository.updateStatus(recordId, newStatus);
      final index = _records.indexWhere((r) => r.id == recordId);
      if (index != -1) {
        _records[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> bulkMarkPresent() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.bulkMarkPresent(_selectedEventId);
      await loadAttendance(_selectedEventId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> quickCheckIn(String rollNumber, String markedBy) async {
    try {
      final newRecord = await _repository.recordQuickCheckIn(
        eventId: _selectedEventId,
        rollNumber: rollNumber,
        markedBy: markedBy,
      );
      _records.insert(0, newRecord);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
